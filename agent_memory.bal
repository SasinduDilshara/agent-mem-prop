import ballerina/ai;
import ballerina/sql;

# Default prompt template for the summarization strategy.
final readonly & ai:Prompt DEFAULT_SUMMARY_PROMPT = `...`;

# Enum representing the available overflow strategies for an Stm without an Ltm.
public enum OverflowStrategy {
    Summarize = "Summarize",
    Trim = "Trim"
}

# Configuration for summarizing Stm content when it overflows.
public type SummarizeOverflowConfig record {|
    Summarize 'strategy = Summarize;
    # AI model provider for generating summaries. 
    # If not provided, the default will be the model that use by the agent.
    ai:ModelProvider modelProvider?;
    # Prompt template for summarization.
    ai:Prompt summarizationPrompt = DEFAULT_SUMMARY_PROMPT;
    # Number of recent messages to include in the summarization context.
    int numberOfMessagesToSummarize = 5;
|};

# Configuration for trimming older messages when Stm is full.
public type TrimOverflowConfig record {|
    Trim 'strategy = Trim;
|};

# A union type representing the available overflow strategies for an Stm without an Ltm.
public type OverflowHandlingStrategy SummarizeOverflowConfig|TrimOverflowConfig;

// --- Memory Content & Storage Types ---

# Supported database clients for persist Stm memory storage.
public type PersistStMemoryStore sql:Client;

# The Stm message storage, either in-memory map or persistent DB client.
public type MessageStore map<ai:ChatMessage[]>|PersistStMemoryStore;

# Represents the consolidated content retrieved from memory for prompting the model.
public type MemoryContent record {|
    # The list of chat messages forming the conversational context.
    record {
        string role;
        string content;
    }[] messages;
    # Static facts retrieved from Ltm (if available).
    string[]? staticFacts;
    # Facts extracted from the conversation, stored in Ltm (if available).
    map<anydata>? extractedFacts;
    # Results from a vector similarity search in Ltm (if available).
    ai:QueryMatch[]? vectorMatches;
|};

// --- Long-Term Memory (Ltm) ---

# Represents the optional Long-Term Memory, a container for persistent knowledge blocks.
# Its methods are designed to be called asynchronously.
isolated class LongTermMemory {
    # Storage for the pluggable memory blocks.
    private final LtMemoryBlock[] memoryBlocks;
    # Maximum token count for the aggregated long-term memory context.
    private final int maxMemoryTokenCount = 2048;

    # Initializes the Ltm with a set of pluggable memory blocks.
    # + memoryBlocks - An array of Ltm blocks (e.g., Static, Extractive, Vector).
    public isolated function init(LongTermMemoryConfig ltmConfig) {
        self.memoryBlocks = ltmConfig.memoryBlocks;
        self.maxMemoryTokenCount = ltmConfig.maxMemoryTokenCount;
    }

    # Retrieves relevant long-term context for a given session.
    public isolated function get(string sessionId, ai:ChatMessage|ai:ChatMessage[] context, RetrieveOptions options = {}) returns MemoryContent|ai:MemoryError {
        // Implementation to aggregate results from each memoryBlock.
        // Ensure the total token count does not exceed self.maxMemoryTokenCount.
        // If the limit is exceeded, prioritize memory blocks in order of static, extractive, then vector.
    }

    # Updates the Ltm blocks with new information from the conversation.
    public isolated function update(string sessionId, ai:ChatMessage|ai:ChatMessage[] context, UpdateOptions options = {}) returns ai:MemoryError? {
        // Implementation to update each memoryBlock.
    }

    # Deletes all data for a specific session from all Ltm blocks.
    public isolated function delete(string sessionId) returns ai:MemoryError? {
        // Implementation to delete from each memoryBlock.
    }
}

// --- Short-Term Memory (Stm) ---

# Represents the mandatory Short-Term Memory, managing the active conversation window.
isolated class ShortTermMemory {
    # Storage for active chat messages.
    private final MessageStore messageStore;
    # The configured strategy for handling overflow when no Ltm is present.
    private final OverflowHandlingStrategy overflowStrategy;
    # Maximum token count for the active conversation history.
    private final int maxMemoryTokenCount;

    # Initializes the Stm.
    # + messageStore - The backend for storing messages (in-memory map or persist db client).
    # + overflowStrategy - The strategy to use when Stm overflows and no Ltm is available. If Ltm is present, this parameter will be ignored.
    # + maxMemoryTokenCount - The token limit that short term memory can holds.
    public isolated function init(ShortTermMemoryConfig stmConfig = {}) {
        self.messageStore = stmConfig.messageStore;
        self.overflowStrategy = stmConfig.overflowStrategy;
        self.maxMemoryTokenCount = stmConfig.maxMemoryTokenCount;
    }

    # Retrieves the active conversation history.
    # + sessionId - Session ID
    public isolated function get(string sessionId) returns ai:ChatMessage[]|ai:MemoryError {
        // Implementation to retrieve current messages from self.messageStore.
        return [];
    }
    
    # Updates the Stm with a new message and handles overflow.
    # + sessionId - Session ID
    # + context - New message(s) to add
    # + ltm - The optional Ltm instance. If provided, the overflow strategy will changes to move the data to Ltm.
    public isolated function update(string sessionId, ai:ChatMessage|ai:ChatMessage[] context, LongTermMemory? ltm = ()) returns ai:MemoryError? {
        // 1. Add the new message(s) to the messageStore.
        // 2. Check if the total token count exceeds self.maxMemoryTokenCount.
        // 3. If overflow occurs and no Ltm, apply the configured overflow strategy (summarize or trim).
        // 4. If overflow occurs and Ltm exists, 
        //    For each older message, 
        //       if it already sent to the ltm, remove from Stm.
        //       else, move it to Ltm using ltm.update()  
        //    Stop when the Stm token count is within limits.
        // 5. Initiate background process to update Ltm with new message(s) if Ltm exists.
        return;
    }

    # Deletes all messages for a specific session from the Stm.
    public isolated function delete(string sessionId) returns ai:MemoryError? {
        // Implementation to clear messages from self.messageStore.
        return;
    }
}

// --- Main Memory Orchestrator ---

# Configuration for the Short-Term Memory of the agent.
public type ShortTermMemoryConfig record {|
    # Storage backend for Stm messages (in-memory map or persistent DB client).
    MessageStore messageStore = {};
    # Strategy for handling Stm overflow when no Ltm is present.
    OverflowHandlingStrategy overflowStrategy = {'strategy: "Summarize"};
    # Maximum token count for Stm.
    int maxMemoryTokenCount = 2048;
|};

# Configuration for the agent's Long-Term Memory.
public type LongTermMemoryConfig record {|
    # An array of Ltm memory blocks (e.g., Static, Extractive, Vector).
    LtMemoryBlock[] memoryBlocks;
    # Maximum token count for the aggregated Ltm context.
    int maxMemoryTokenCount = 2048;
|};

# The main memory orchestrator that combines Stm and optional Ltm.
# This is the primary class that an AI agent would interact with.
public isolated class AgentWorkingMemory {
    *Memory;
    private final ShortTermMemory stm;
    private final LongTermMemory? ltm;

    # Initializes the complete agent memory system.
    # + stmConfig - Configuration for the Short-Term Memory of the agent.
    # + ltmConfig - Optional configuration for the Long-Term Memory of th agent.
    public isolated function init(ShortTermMemoryConfig stmConfig, LongTermMemoryConfig? ltmConfig = ()) {
        self.stm = new ShortTermMemory(stmConfig);
        if ltmConfig is LongTermMemoryConfig {
            self.ltm = new LongTermMemory(ltmConfig);
        }
    }

    # Retrieves memory contents from both Stm and Ltm for prompting.
    # + sessionId - Session identifier
    # + context - Current message(s) for context-based retrieval, 
    #             if context is not provided, all the memories related to the session will be retrieved.
    # + options - Retrieval configuration options
    # + return - Memory content or error
    public isolated function get(string sessionId, ai:ChatMessage|ai:ChatMessage[]? context = (), RetrieveOptions options = {}) returns MemoryContent|ai:MemoryError {
        // 1. Get the current conversation history from Stm.
        // 2. If Ltm exists, get long-term context and merge it.
    }

    # Updates the memory system with a new message.
    # + sessionId - Session identifier
    # + context - Message(s) to add to memory
    # + options - Update configuration options
    # + return - Error if update fails, nil on success
    public isolated function update(string sessionId, ai:ChatMessage|ai:ChatMessage[] context, UpdateOptions options = {}) returns ai:MemoryError? {
        // Update the Stm with the new context. This will eventually trigger Ltm update (if Ltm configured) as a background process.
    }

    # Deletes all memory for a session from both Stm and Ltm.
    # + sessionId - Session identifier
    public isolated function delete(string sessionId) returns ai:MemoryError? {
        // Deletes all memory for a session from both Stm and Ltm
    }
}
