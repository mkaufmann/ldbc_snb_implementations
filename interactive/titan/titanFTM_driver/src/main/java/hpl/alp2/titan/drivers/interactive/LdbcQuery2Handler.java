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
import com.ldbc.driver.workloads.ldbc.snb.interactive.LdbcQuery2;
import com.ldbc.driver.workloads.ldbc.snb.interactive.LdbcQuery2Result;
import com.tinkerpop.blueprints.Compare;
import com.tinkerpop.blueprints.Vertex;
import com.tinkerpop.gremlin.java.GremlinPipeline;
import com.tinkerpop.pipes.PipeFunction;
import com.tinkerpop.pipes.util.structures.Pair;
import com.tinkerpop.pipes.util.structures.Row;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.naming.directory.SchemaViolationException;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by Tomer Sagi on 06-Oct-14.
 * Strategy: Double expansion root->friend->post
 */
public class LdbcQuery2Handler extends OperationHandler<LdbcQuery2> {
    final static Logger logger = LoggerFactory.getLogger(LdbcQuery2Handler.class);

    @Override
    public OperationResultReport executeOperation(LdbcQuery2 operation) {
        /*Given a start Person, find (most recent) Posts and Comments from all of that Person’s friends,
        that were created before (and including) a given date. Return the top 20 Posts/Comments, and the Person
        that created each of them. Sort results descending by creation date, and then ascending by Post identifier.*/
        long person_id = operation.personId();
        final long maxDate = operation.maxDate().getTime();//QueryUtils.addDays(operation.maxDate(),1);
        logger.debug("Query 2 called on Person id: {} with max date {}", person_id, maxDate);
        int limit = operation.limit();
        TitanFTMDb.BasicClient client = ((TitanFTMDb.BasicDbConnectionState) dbConnectionState()).client();

        Vertex root = null;
        try {
            root = client.getVertex(person_id, "Person");
        } catch (SchemaViolationException e) {
            e.printStackTrace();
        }

/* A shelved query model validation version
        final PipeFunction<Pair<Row, Row>, Integer> COMP_Q2 = new PipeFunction<Pair<Row, Row>, Integer>() {

            @Override
            public Integer compute(Pair<Row, Row> argument) {
                Vertex v1 = (Vertex) argument.getA().getColumn("post");
                Vertex v2 = (Vertex) argument.getB().getColumn("post");
                long d1 = v1.getProperty("creationDate");
                long d2 = v2.getProperty("creationDate");
                if (d1 == d2) {
                    return ((Long) v1.getId()).compareTo((Long) v2.getId());
                } else
                    return Long.compare(d2, d1);
            }
        };

        GremlinPipeline<Vertex, Vertex> gp = new GremlinPipeline<>(root);
        Iterable<Row> qResult = gp.out("knows").as("friend").in("hasCreator")
                .has("creationDate", Compare.LESS_THAN, maxDate)
                .as("post").select();
                //.order(COMP_Q2)
                //.range(0, limit - 1);

        List<LdbcQuery2Result> result = new ArrayList<>();
        int cnt = 0;
        long finalProjectionTime=0;
        for (Row r : qResult) {
            long startAdd = System.currentTimeMillis();
            Vertex post = (Vertex) r.getColumn("post");
            Long pid = client.getVLocalId((Long) post.getId());
            Vertex friend = (Vertex) r.getColumn("friend");
            String content = post.getProperty("content");
            if (content.length() == 0)
                content = post.getProperty("imageFile");
            LdbcQuery2Result res = new LdbcQuery2Result(client.getVLocalId((Long) friend.getId()),
                    (String) friend.getProperty("firstName"), (String) friend.getProperty("lastName"),
                    pid, content, (Long) post.getProperty("creationDate"));

            finalProjectionTime+=(System.currentTimeMillis()-startAdd);
            result.add(res);
            cnt++;
            if (cnt == limit) break;
        }

        logger.debug("Final projection time: {}" ,finalProjectionTime );
        return operation.buildResult(0, result);
    }
}
*/

        final PipeFunction<Pair<Row, Row>, Integer> COMP_Q2 = new PipeFunction<Pair<Row, Row>, Integer>() {

            @Override
            public Integer compute(Pair<Row, Row> argument) {
                Vertex v1 = (Vertex) argument.getA().getColumn("post");
                Vertex v2 = (Vertex) argument.getB().getColumn("post");
                long d1 = v1.getProperty("creationDate");
                long d2 = v2.getProperty("creationDate");
                if (d1 == d2) {
                    return ((Long) v1.getId()).compareTo((Long) v2.getId());
                } else
                    return Long.compare(d2, d1);
            }
        };

        GremlinPipeline<Vertex, Vertex> gp = new GremlinPipeline<>(root);
        Iterable<Row> qResult = gp.out("knows").as("friend").in("hasCreator")
                .has("creationDate", Compare.LESS_THAN, maxDate)
                .as("post").select()
                .order(COMP_Q2).range(0, limit - 1);

        List<LdbcQuery2Result> result = new ArrayList<>();
        for (Row r : qResult) {
            Vertex post = (Vertex) r.getColumn("post");
            Long pid = client.getVLocalId((Long) post.getId());
            Vertex friend = (Vertex) r.getColumn("friend");
            String content = post.getProperty("content");
            if (content.length() == 0)
                content = post.getProperty("imageFile");
            LdbcQuery2Result res = new LdbcQuery2Result(client.getVLocalId((Long) friend.getId()),
                    (String) friend.getProperty("firstName"), (String) friend.getProperty("lastName"),
                    pid, content, (Long) post.getProperty("creationDate"));

            result.add(res);
        }
        return operation.buildResult(0, result);
    }
}