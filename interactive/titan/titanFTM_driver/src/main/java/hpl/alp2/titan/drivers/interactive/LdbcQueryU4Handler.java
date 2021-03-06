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

import com.ldbc.driver.DbException;
import com.ldbc.driver.OperationHandler;
import com.ldbc.driver.OperationResultReport;
import com.ldbc.driver.workloads.ldbc.snb.interactive.LdbcUpdate4AddForum;
import com.thinkaurelius.titan.core.TitanException;
import com.tinkerpop.blueprints.Vertex;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.naming.directory.SchemaViolationException;
import java.util.HashMap;
import java.util.Map;

/**
 * Adds forum and it's moderator and tags. Assume moderator person and tags exist
 * Created by Tomer Sagi on 14-Nov-14.
 */
public class LdbcQueryU4Handler extends OperationHandler<LdbcUpdate4AddForum> {
    final static Logger logger = LoggerFactory.getLogger(LdbcQueryU4Handler.class);

    @Override
    protected OperationResultReport executeOperation(LdbcUpdate4AddForum operation) throws DbException {

        TitanFTMDb.BasicClient client = ((TitanFTMDb.BasicDbConnectionState) dbConnectionState()).client();

        try {
            Map<String, Object> props = new HashMap<>(2);
            props.put("title", operation.forumTitle());
            props.put("creationDate", operation.creationDate().getTime());
            logger.debug("U4 Adding forum {} , {}" , operation.forumId(), props.toString());
            Vertex forum = client.addVertex(operation.forumId(), "Forum", props);
            Map<String, Object> eProps = new HashMap<>(0);
            for (Long tagID : operation.tagIds()) {
                Vertex tagV = client.getVertex(tagID, "Tag");
                client.addEdge(forum, tagV, "hasTag", eProps);
            }

            Vertex mod = client.getVertex(operation.moderatorPersonId(), "Person");
            client.addEdge(forum, mod, "hasModerator", eProps);
            logger.debug("U4 completed Adding forum {} " , operation.forumId());

        } catch (SchemaViolationException e) {
            logger.error("invalid vertex label requested by query update");
            e.printStackTrace();
        }

        try {
            client.commit();
        } catch (TitanException e) {
            logger.error("Couldn't complete U4 handler, db didn't commit");
            e.printStackTrace();
        }
        return operation.buildResult(0, null);
    }
}
