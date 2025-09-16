import ballerina/ai;
import ballerinax/mongodb;
import ballerinax/redis;
import ballerina/sql;

public isolated class StaticMemory {
    *ai:Memory;
    private string name;
    private mongodb:Client|redis:Client|sql:Client factStore;
    private int maxTokens;

    public isolated function init(ai:ModelProvider modelProvider, 
            mongodb:Client|redis:Client|sql:Client factStore, 
            string name = "static_memory",
            int maxTokens = 2000) {
        self.name = name;
        self.factStore = factStore;
        self.maxTokens = maxTokens;

        // Add facts in the initialization phase.
        self.insertAll();
    }

    public isolated function delete(string sessionId) returns ai:MemoryError? {
        return error("Static memory does not support delete operation");
    }

    public isolated function get(string sessionId, ai:ChatMessage message) returns ai:ChatMessage[]|ai:MemoryError {
        return error("Static memory does not support delete operation");
    }

    public isolated function update(string sessionId, ai:ChatMessage message) returns ai:MemoryError? {
        return error("Static memory does not support delete operation");
    }

    private isolated function insertAll() returns ai:MemoryError? {
        return;
    }
}
