import ballerina/ai;
import ballerina/sql;
import ballerinax/mongodb;
import ballerinax/redis;

# Default prompt template for summarizing conversation history
final readonly & ai:Prompt DEFAULT_SUMMARY_PROMPT = `Summarize the following conversation history, focusing on key information, decisions, and context that should be remembered for future interactions.`;

# Default AI model provider instance
ai:ModelProvider defaultModel = check ai:getDefaultModelProvider();

# Default configuration for STM summarization strategy
final STMSummarizeConfiguration DEFAULT_FLUSH_CONFIG = {
    modelProvider: defaultModel
};

# Configuration for flushing STM content to Long Term Memory blocks.
type FlushToLTMConfiguration record {|
    # Maximum ratio of STM tokens before triggering flush to LTM
    decimal maxSTMTokenRatio = 0.5;
    
    # Whether to include persistent memory in system prompts
    boolean isPersistMemoryInsertedIntoTheSystemPrompt = false;
    
    # Array of Long Term Memory blocks to add the flush content
    Memory[] LTMemoryBlocks = [];
|};

# Configuration for summarizing STM content when token limits are exceeded.
type STMSummarizeConfiguration record {|
    # Number of recent messages to include in summarization
    int summaryMessageCount = 2;
    
    # AI model provider for generating summaries
    ai:ModelProvider modelProvider;
    
    # Prompt template for summarization
    ai:Prompt summaryPrompt = DEFAULT_SUMMARY_PROMPT;
    
    # Maximum tokens allowed in generated summary
    int maxSummaryTokens?;
|};

# Configuration for trimming older messages when memory is full.
type TrimLastMessagesConfiguration record {|
    # Maximum tokens to keep after trimming operation
    int maxMemoryTokens = 500;
|};

# Configuration for deleting oldest messages when memory exceeds limits.
type DeleteLastMessagesConfiguration record {|
    # Maximum number of messages to retain after deletion
    int maxMessageCount = 10;
|};

# Configuration defining STM overflow handling strategies and limits.
type STMMemoryOverflowConfig record {|
    # Maximum token count allocated for the memory
    int maxMemoryTokenCount = 2000;
    
    # Strategy configuration for handling STM overflow
    FlushToLTMConfiguration|STMSummarizeConfiguration
        |TrimLastMessagesConfiguration|DeleteLastMessagesConfiguration flushSTMOverflowmemory = DEFAULT_FLUSH_CONFIG;
|};

# Type alias for supported database clients in agent memory storage.
type AgentMemoryDbStore mongodb:Client|redis:Client|sql:Client;

type MemoryContent record {
    ai:ChatMessage[] chatMessages;
    StaticFact[] staticFacts;
    ExtractiveMemoryFact[] extractedFacts;
    ai:QueryMatch[] vectorMatches;
};

# Main agent memory class implementing Short Term Memory (STM) with overflow handling.
# Manages active conversation memory and implements strategies for handling memory limits.
public isolated class AgentMemory {
    *ai:Memory;
    
    # Storage for chat messages, either in-memory map or database client
    private final map<ai:MemoryChatMessage[]>|AgentMemoryDbStore messageStore;
    
    # Storage for system messages, either in-memory map or database client  
    private final map<ai:MemoryChatSystemMessage>|AgentMemoryDbStore systemMessageStore;
    
    # Configuration for handling memory overflow scenarios
    private STMMemoryOverflowConfig filterConfig = {};

    # Initializes the agent memory with configurable storage backends and overflow handling.
    #
    # + messageStore - Storage backend for chat messages (in-memory map or database)
    # + systemMessageStore - Storage backend for system messages (in-memory map or database)
    # + filterConfig - Configuration for memory overflow handling strategies
    public isolated function init(
                map<ai:MemoryChatMessage[]>|AgentMemoryDbStore? messageStore = (), 
                map<ai:MemoryChatSystemMessage>|AgentMemoryDbStore? systemMessageStore = (),
                STMMemoryOverflowConfig? filterConfig = {}) {
        self.messageStore = messageStore ?: {};
        self.systemMessageStore = systemMessageStore ?: {};
        self.filterConfig = filterConfig ?: {};
    }

    # Retrieves conversation history for a session, applying filtering and token limits.
    #
    # + sessionId - Session identifier for memory isolation
    # + message - Current message providing context for retrieval
    # + return - Array of relevant conversation messages or memory error
    public isolated function get(string sessionId, ai:ChatMessage message) returns ai:ChatMessage[]|MemoryContent|ai:MemoryError {
        // Retrieve messages from storage (map or database) for the sessionId
        // If the LTM blocks are configured, retrieve relevant messages for the sessionId from them as well
        // Apply token counting and filtering based on `filterConfig`
        // Return messages within token limits, prioritizing recent messages
    }

    # Stores a new message and handles memory overflow using configured strategy.
    #
    # + sessionId - Session identifier for memory isolation
    # + message - New message to store in memory
    # + return - Nil on success, memory error if storage or overflow handling fails
    public isolated function update(string sessionId, ai:ChatMessage message) returns ai:MemoryError? {
        // Add message to storage (map or database) for the sessionId
        // Check token count against limits
        // If over limit, execute overflow strategy (summarize, trim, delete, or flush to LTM) for the older messages
        return;
    }

    # Deletes all stored messages and system messages for a specific session.
    #
    # + sessionId - Session identifier for which to clear all memory
    # + return - Nil on successful deletion, memory error if operation fails
    public isolated function delete(string sessionId) returns ai:MemoryError? {
        // Clear messages from both messageStore and systemMessageStore
        // If LTM blocks are configured, delete messages for the sessionId from them as well
        return;
    }

    # Calculates approximate token count for an array of messages.
    #
    # + messages - Array of messages to count tokens for
    # + return - Estimated token count
    private isolated function calculateTokenCount(ai:MemoryChatMessage[] messages) returns int {
        // Calculates approximate token count for an array of messages.
        return 100;
    }

    # Handles memory overflow using the configured strategy.
    #
    # + sessionId - Session identifier
    # + messages - Current messages that exceed token limits
    # + return - Nil on success, error if overflow handling fails
    private isolated function handleMemoryOverflow(string sessionId) returns ai:MemoryError? {
        // Execute strategy based on flushSTMOverflowmemory type
        // - Summarize: Use AI to create summary and replace old messages
        // - Trim: Remove oldest messages keeping within limits  
        // - Delete: Remove specified number of oldest messages
        // - FlushToLTM: Move messages to Long Term Memory blocks
        return;
    }
}
