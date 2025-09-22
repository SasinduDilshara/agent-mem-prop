import ballerina/ai;

# Configuration options for retrieve operation from memory.
public type RetrieveOptions record {|
    # Whether to include system messages in retrieval
    boolean includeSystemMessages = true;

    # Metadata filters for retrieval
    map<string|string[]> metadata?;
|};

# Configuration options for update operation to memory.
public type UpdateOptions record {|
    # Metadata to associate with the stored message
    map<string|string[]> metadata?;
|};

# Represents the memory interface for the agents.
public type Memory isolated object {

    # Retrieves all stored chat messages for a given session and for a given context.
    #
    # + sessionId - The ID associated with the memory
    # + context - The current message(s) for context
    #             if context is not provided, all the memories related to the session will be retrieved.
    # + options - Retrieval configuration options
    # + return - An array of messages or an `ai:Error`
    public isolated function get(string sessionId, ai:ChatMessage|ai:ChatMessage[]? context = (), RetrieveOptions options = {}) returns anydata|ai:MemoryError;

    # Adds a chat message to the memory for a given session.
    #
    # + sessionId - The ID associated with the memory
    # + messages - The messages to store
    # + options - Update configuration options
    # + return - nil on success, or an `ai:Error` if the operation fails 
    public isolated function update(string sessionId, ai:ChatMessage|ai:ChatMessage[] messages, UpdateOptions options = {}) returns ai:MemoryError?;

    # Deletes all stored messages.
    # + sessionId - The ID associated with the memory
    # + return - nil on success, or an `ai:Error` if the operation fails
    public isolated function delete(string sessionId) returns ai:MemoryError?;
};

# Represents the long term memory block interface for the agents.
public type LtMemoryBlock isolated object {
};
