/**(c) Copyright [2015] Hewlett-Packard Development Company, L.P.
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.**/

package hpl.alp2.titan.drivers.interactive;

import com.ldbc.driver.OperationHandler;
import com.ldbc.driver.OperationResultReport;
import com.ldbc.driver.workloads.ldbc.snb.interactive.LdbcQuery4;
import com.ldbc.driver.workloads.ldbc.snb.interactive.LdbcQuery4Result;
import com.tinkerpop.blueprints.Compare;
import com.tinkerpop.blueprints.Vertex;
import com.tinkerpop.gremlin.java.GremlinPipeline;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.naming.directory.SchemaViolationException;
import java.util.*;

/**
 * Created by Tomer Sagi on 06-Oct-14. Given a start Person, find Tags that are attached to Posts that were created by that Person’s
 * friends. Only include Tags that were attached to Posts created within a given time interval, and that were
 * never attached to Posts created before this interval. Return top 10 Tags, and the count of Posts, which were
 * created within the given time interval, that this Tag was attached to. Sort results descending by Post count,
 * and then ascending by Tag name.
 */
public class LdbcQuery4Handler extends OperationHandler<LdbcQuery4> {
    final static Logger logger = LoggerFactory.getLogger(LdbcQuery4Handler.class);

    @Override
    public OperationResultReport executeOperation(LdbcQuery4 operation) {
        /*
        Given a start Person, find Tags that are attached to Posts that were created by that Person’s
        friends. Only include Tags that were attached to Posts created within a given time interval, and that were
        never attached to Posts created before this interval. Return top 10 Tags, and the count of Posts, which were
        created within the given time interval, that this Tag was attached to. Sort results descending by Post count,
        and then ascending by Tag name.
         */
        long person_id = operation.personId();
        final long min_date = operation.startDate().getTime();
        final long max_date = QueryUtils.addDays(min_date, operation.durationDays());
        int limit = operation.limit();
        logger.debug("Query 4 called on Person id: {} with min date {} and max date {}",
                person_id, min_date, max_date);

        TitanFTMDb.BasicClient client = ((TitanFTMDb.BasicDbConnectionState) dbConnectionState()).client();


        //Prepare result map
        long startResMap = System.currentTimeMillis();
        Map<Vertex, Number> qRes = new HashMap<>();
//        PipeFunction Q4KEY_FUNC = new PipesFunction<Vertex, Vertex>() {
//            @Override
//            public Vertex compute(Vertex argument) {
//                return (Vertex) this.asMap.get("tag");
//            }
//        };

        long resMapTime = System.currentTimeMillis() - startResMap;
        logger.debug("Query 4 prepare res map time: {}", resMapTime );

        //Prepare nonTags
        long startTags = System.currentTimeMillis();
        Set<Vertex> nonTags = new HashSet<>();
        Iterable<Vertex> invalidPosts = client.getQuery().has("creationDate", Compare.LESS_THAN, min_date).vertices();
        GremlinPipeline<Iterable<Vertex>, Vertex> gpp = new GremlinPipeline<>(invalidPosts);
        gpp.filter(QueryUtils.ONLYPOSTS).out("hasTag").fill(nonTags); //TODO replace with a combined index on type and creationDate
        long nonTagTime = System.currentTimeMillis() - startTags;
        logger.debug("Query 4 prepare non tags time: {}", nonTagTime );

        //Main query
        long startMain = System.currentTimeMillis();
        Vertex root = null;
        try {
            root = client.getVertex(person_id, "Person");
        } catch (SchemaViolationException e) {
            e.printStackTrace();
        }
        GremlinPipeline<Vertex, Vertex> gp = (new GremlinPipeline<Vertex, Vertex>(root)).as("root");

        gp.out("knows").in("hasCreator")
                .filter(QueryUtils.ONLYPOSTS)//.has("label", "Comment") //this doesn't work for vertices - for edges only
                .interval("creationDate", min_date, max_date).out("hasTag")
                .except(nonTags).as("tag")
                .groupCount(qRes).iterate();
        //.orderMap(Tokens.T.decr).range(0,limit); //can't sort secondary sort on name

        long timeMain = System.currentTimeMillis() - startMain;
        logger.debug("Query 4 main time: {}", timeMain);

        //Sort result
        long startPost = System.currentTimeMillis();
        Map<Vertex, Long> qResInt = new HashMap<>();
        for (Map.Entry<Vertex, Number> e : qRes.entrySet())
            qResInt.put(e.getKey(), (Long) e.getValue());

        qResInt = QueryUtils.sortByValueAndKey(qResInt, false, true, TitanFTMDb.BasicClient.NAMECOMP);
        List<LdbcQuery4Result> result = new ArrayList<>();

        //output to res and limit
        int i = 0;
        for (Map.Entry<Vertex, Long> entry : qResInt.entrySet()) {
            Vertex tag = entry.getKey();
            i++;
            LdbcQuery4Result res = new LdbcQuery4Result((String) tag.getProperty("name"), entry.getValue().intValue());
            result.add(res);
            if (i == limit)
                break;
        }

        long timePost = System.currentTimeMillis() - startPost;
        logger.debug("Query 4 post-process time: {}", timePost);

        return operation.buildResult(0, result);

    }
}
