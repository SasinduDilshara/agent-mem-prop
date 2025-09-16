import ballerina/ai;
import ballerina/sql;
import ballerinax/mongodb;
import ballerinax/redis;

# Record type to hold extracted facts associated with a session
public type ExtractiveMemoryFact record {
    string sessionId;
    anydata[] facts;
};

# Default prompt for extracting important facts from conversations
final readonly & ai:Prompt DEFAULT_FACT_EXTRACTION_PROMPT = `Extract important facts and information from this conversation that should be remembered for future interactions.`;

# Default prompt for retrieving relevant facts based on current context
final readonly & ai:Prompt DEFAULT_FACT_RETRIEVAL_PROMPT = `Find the most relevant facts from previous conversations based on the current context.`;

# Memory that extracts and stores important facts from conversations.
# Uses AI to identify and extract key information for future reference.
public isolated class ExtractiveMemory {
    *ai:Memory;
    
    # Name identifier for this memory instance
    private string name;
    
    # AI model provider for fact extraction
    private ai:ModelProvider modelProvider;
    
    # Database client for storing extracted facts
    private mongodb:Client|redis:Client|sql:Client factStore;
    
    # Maximum token limit for this memory block
    private int maxTokens;
    
    # Prompt template for extracting facts from conversations
    private ai:Prompt factExtractionPrompt;
    
    # Prompt template for retrieving relevant facts
    private ai:Prompt factRetrievalPrompt;
    
    # Cache of extracted facts organized by session
    private ExtractiveMemoryFact[] extractedFacts = [];

    # Initializes the extractive memory for fact extraction and storage.
    #
    # + modelProvider - AI model provider for fact processing
    # + factStore - Database client for persistent storage
    # + name - Identifier for this memory instance
    # + maxTokens - Maximum tokens allowed in this memory
    # + factExtractionPrompt - Custom prompt for fact extraction
    # + factRetrievalPrompt - Custom prompt for fact retrieval
    public isolated function init(ai:ModelProvider modelProvider, 
            readonly & mongodb:Client|redis:Client|sql:Client factStore, 
            string name = "extractive_memory",
            int maxTokens = 2000, 
            readonly & ai:Prompt factExtractionPrompt = DEFAULT_FACT_EXTRACTION_PROMPT, 
            readonly & ai:Prompt factRetrievalPrompt = DEFAULT_FACT_RETRIEVAL_PROMPT) {
        self.name = name;
        self.modelProvider = modelProvider;
        self.factStore = factStore;
        self.maxTokens = maxTokens;
        self.factExtractionPrompt = factExtractionPrompt;
        self.factRetrievalPrompt = factRetrievalPrompt;
    }

    # Deletes all extracted facts for a specific session.
    #
    # + sessionId - Session identifier
    # + return - Error if deletion fails, nil on success
    public isolated function delete(string sessionId) returns ai:MemoryError? {
        // Remove facts from cache and database for the session
        _ = self.extractedFacts.filter(fact => fact.sessionId != sessionId);
        // Delete from database using factStore client
        return;
    }

    # Retrieves relevant extracted facts based on current message context.
    #
    # + sessionId - Session identifier
    # + message - Current message for context-based retrieval
    # + return - Array of relevant extracted facts or error
    public isolated function get(string sessionId, ai:ChatMessage message) returns anydata[]|ai:MemoryError {
        // Use AI model with `factRetrievalPrompt` to find relevant facts for the message
        // If cache get outdated, reload from database
        // Retrive all the facts from the cache for the session and filter based on relevance using AI model
        // Apply relevance filtering and token limits
        return [
            // Apply relevance filtering and token limits
            "Relevant fact 1",
            "Relevant fact 2"
        ];
    }

    # Processes a new message to extract and store important facts.
    #
    # + sessionId - Session identifier
    # + message - Message to analyze for fact extraction
    # + return - Error if processing fails, nil on success
    public isolated function update(string sessionId, ai:ChatMessage message) returns ai:MemoryError? {
        // Use AI model with factExtractionPrompt to extract facts from message
        // If cache get outdated, reload from database
        // Store extracted facts in both cache and database
        ai:ChatMessage[] currentFacts = self.extractedFacts.get(sessionId) ?: [];
        
        // Extract new facts using AI model
        currentFacts.push(extractedFact);
        self.extractedFacts[sessionId] = currentFacts;

        // Insert into database using factStore client
        return;
    }
}
