//
// Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

# JSON update operator client.
public type JsonUpdateOperator client object {
    JobInfo job;
    SalesforceBaseClient httpBaseClient;

    public function __init(JobInfo job, SalesforceConfiguration salesforceConfig) {
        self.job = job;
        self.httpBaseClient = new(salesforceConfig);
    }

    # Create JSON update batch.
    #
    # + payload - update data in JSON format
    # + return - BatchInfo record if successful else ConnectorError occured
    public remote function update(json payload) returns @tainted BatchInfo|ConnectorError {
        json response = check self.httpBaseClient->createJsonRecord([<@untainted> JOB, self.job.id,
            <@untainted> BATCH], payload);
        return getBatch(response);
    }

    # Get JSON update operator job information.
    #
    # + return - JobInfo record if successful else ConnectorError occured
    public remote function getJobInfo() returns @tainted JobInfo|ConnectorError {
        json response = check self.httpBaseClient->getJsonRecord([<@untainted> JOB, self.job.id]);
        return getJob(response);
    }

    # Close JSON update operator job.
    #
    # + return - JobInfo record if successful else ConnectorError occured
    public remote function closeJob() returns @tainted JobInfo|ConnectorError {
        json response = check self.httpBaseClient->createJsonRecord([<@untainted> JOB, self.job.id],
            JSON_STATE_CLOSED_PAYLOAD);
        return getJob(response);
    }

    # Abort JSON update operator job.
    #
    # + return - JobInfo record if successful else ConnectorError occured
    public remote function abortJob() returns @tainted JobInfo|ConnectorError {
        json response = check self.httpBaseClient->createJsonRecord([<@untainted> JOB, self.job.id],
            JSON_STATE_ABORTED_PAYLOAD);
        return getJob(response);
    }

    # Get JSON update batch information.
    #
    # + batchId - batch ID 
    # + return - BatchInfo record if successful else ConnectorError occured
    public remote function getBatchInfo(string batchId) returns @tainted BatchInfo|ConnectorError {
        json response = check self.httpBaseClient->getJsonRecord([<@untainted> JOB, self.job.id, <@untainted> BATCH, 
            batchId]);
        return getBatch(response);
    }

    # Get information of all batches of JSON update operator job.
    #
    # + return - BatchInfo record if successful else ConnectorError occured
    public remote function getAllBatches() returns @tainted BatchInfo[]|ConnectorError {
        json response = check self.httpBaseClient->getJsonRecord([<@untainted> JOB, self.job.id, <@untainted> BATCH]);
        return getBatchInfoList(response);
    }

    # Retrieve the JSON batch request.
    #
    # + batchId - batch ID
    # + return - JSON Batch request if successful else ConnectorError occured
    public remote function getBatchRequest(string batchId) returns @tainted json|ConnectorError {
        return self.httpBaseClient->getJsonRecord([<@untainted> JOB, self.job.id, <@untainted> BATCH, batchId, 
            <@untainted> REQUEST]);
    }

    # Get the results of the batch.
    #
    # + batchId - batch ID
    # + numberOfTries - number of times checking the batch state
    # + waitTime - time between two tries in ms
    # + return - Batch result as CSV if successful else ConnectorError occured
    public remote function getResult(string batchId, int numberOfTries = 1, int waitTime = 3000) 
        returns @tainted Result[]|ConnectorError {
        return checkBatchStateAndGetResults(getBatchPointer, getResultsPointer, self, batchId, numberOfTries, waitTime);        
    }
};
