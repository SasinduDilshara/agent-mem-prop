import ballerina/ai;
import ballerinax/mongodb;
import ballerinax/redis;
import ballerina/sql;

# Record type to hold static facts
type StaticFact anydata;

# Static memory for storing unchanging facts and information about the agent.
# This memory type is read-only and contains predefined knowledge that doesn't change during conversations.
public isolated class StaticMemory {
    *ai:Memory;
    
    # Name identifier for this memory instance
    private string name;
    
    # Database client for storing static facts
    private mongodb:Client|redis:Client|sql:Client factStore;

    # Initializes the static memory with predefined facts.
    #
    # + factStore - Database client for persistent storage
    # + name - Identifier for this memory instance
    # + maxTokens - Maximum tokens allowed in this memory
    public isolated function init(
            StaticFact[] facts,
            mongodb:Client|redis:Client|sql:Client factStore, 
            string name = "static_memory") {
        self.name = name;
        self.factStore = factStore;
        check self.insertFacts(facts);
    }

    # Static memory doesn't support deletion as it contains permanent facts.
    #
    # + sessionId - Session identifier (unused)
    # + return - Always returns an error indicating operation not supported
    public isolated function delete(string sessionId) returns ai:MemoryError? {
        return error("Static memory does not support delete operation");
    }

    # Retrieves static facts relevant to the current context.
    #
    # + sessionId - Session identifier 
    # + message - Current message context for relevance filtering
    # + return - Array of relevant static facts or error
    public isolated function get(string sessionId, ai:ChatMessage message) returns StaticFact[]|ai:MemoryError {
        return self.load();
    }

    # Static memory doesn't support updates as facts are predefined.
    #
    # + sessionId - Session identifier (unused)
    # + message - Message to store (unused)
    # + return - Always returns an error indicating operation not supported
    public isolated function update(string sessionId, ai:ChatMessage message) returns ai:MemoryError? {
        return error("Static memory does not support update operation");
    }

    # Loads predefined facts from the database.
    #
    # + return - Error if loading fails, array of static content on success
    private isolated function load() returns StaticFact[]|ai:MemoryError? {
        // Load static facts from database
        return [
            // retrive from the factStore
            { 'key: "name", value: "BI Copilot" },
            { 'key: "role", value: "Programming Assistant" }
        ];
    }

    # Inserts predefined facts into the database.
    # + return - Error if insertion fails, `nil` on success
    private isolated function insertFacts(StaticFact[] facts) returns ai:MemoryError? {
        // Insert predefined facts into the database
        return;
    }
}
