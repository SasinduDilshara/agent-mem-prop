Proposal: Memory Management for Ballerina AI Agents
Authors: Sasindu Alahakoon
Reviewers:  Shafreen Anfar Anjana Supun Maryam Ziyad Mohamed Sabthar Azeem Muzammil Vinoth Vellummyilum Isuru Wijesiri
Created: 2025-09-18
1. Introduction
This proposal introduces a comprehensive, multi-layered memory management framework for Ballerina AI Agents. To move beyond the limitations of a simple, volatile message window, this framework presents a dual-memory system: a Short-Term Memory (STM) for managing the active conversation and a pluggable Long-Term Memory (LTM) for persistent knowledge. This will empower developers to build agents that are contextual, personalized, and capable of handling long, complex interactions with users.
2. Motivation
The current agent memory implementation in Ballerina provides an in-memory, fixed-size chat history queue that contains the latest interactions for each session. It has significant limitations for building sophisticated agents:
Context Loss: It operates on a "first-in, first-out" basis. Once the message window is full, the oldest messages are permanently deleted, regardless of their importance. A critical fact mentioned at the start of a long conversation is lost forever.
No Persistence: The memory is entirely in-memory, meaning the entire conversation history is lost if the agent restarts. This prevents the creation of agents that can resume conversations or remember users across sessions.
Lack of Intelligence: It treats all messages as a simple transcript. There is no mechanism to distill important facts, understand the semantic meaning of the conversation, or access a static knowledge base.
To build truly intelligent agents, we need a more advanced memory system that can intelligently preserve context, persist information, and manage different types of knowledge.
3. Description of the Proposed Solution
The proposed solution is centered around a Short-Term Memory (STM) component that acts as the primary orchestrator for an agent's memory. This Short-Term Memory manages the immediate, active conversation history and is flexible enough to use either an in-memory map for transient sessions or a persistent database for durable conversations.
A key feature of this STM component is its intelligent handling of memory overflow. It is not limited to a single behavior; instead, based on developer configuration, when the active conversation exceeds a token limit, the system can employ one of several strategies:
Summarize: Use an LLM to create a concise summary of the older parts of the conversation, replacing many messages with one, thus preserving context while saving space.
Trim/Delete: Employ a simple strategy of removing the oldest messages to make space for new ones.
Flush to LTM: Move important information from the active conversation into specialized Long-Term Memory (LTM) blocks for persistent storage and future retrieval.
Long-Term Memory (LTM) is not a single entity but a collection of specialized, pluggable memory blocks designed for different types of knowledge:
A static memory block for storing unchanging, foundational knowledge (e.g., company policies, the agent's purpose). 
This LTM memory block is global for every user and every thread.
An extractive memory block that uses an LLM to identify and pull key facts from a conversation (e.g., user's name, preferences) and stores them as structured data.
This LTM memory block stores data specifically for each user.
A vector-based semantic memory block that stores information as embeddings of the past interactions, allowing for the retrieval of information based on conceptual meaning rather than just keywords.
This LTM memory block stores data specifically for each user.
4. Use Case Analysis: HR Policy Chatbot
This use case demonstrates how the memory system creates a stateful and intelligent HR assistant.
The Scenario
An employee, Sarah, needs to understand the company's remote work policy. The company provides a chat agent on its official website for this purpose. The conversation between Sarah and the chat agent unfolds as follows:

User: Hi, I'm Sarah from the Marketing team. I need to understand our remote work policy. Assistant: Hello Sarah! I'm here to help you with HR policies. Our remote work policy allows eligible employees to work remotely up to 3 days per week with manager approval. Would you like me to explain the eligibility criteria or application process?
User: What are the eligibility criteria? Assistant: For remote work eligibility, you need to: 1. Have completed at least 6 months with the company 2. Have satisfactory performance ratings 3. Hold a role suitable for remote work (as determined by your manager) 4. Have necessary equipment and reliable internet connection. Are you meeting these criteria, Sarah?
User: Yes, I've been here for 2 years and have good performance reviews. How do I apply? Assistant: Great! Since you meet the criteria, here's the application process: 1. Submit Form HR-101 (Remote Work Application) 2. Get manager approval and signature... The form is available on the employee portal under "HR Forms".
User: What if my manager initially says no? Assistant: If your manager declines your request, you have options: 1. Ask for specific feedback... 2. Propose a trial period... 3. Request mediation through HR...
User: No, just want to be prepared. What about equipment - does the company provide anything? Assistant: Yes, the company provides essential equipment for remote work: - Laptop/desktop computer... - Ergonomic chair allowance up to $300...
User: Perfect! One more question - can I work from abroad occasionally? Assistant: Working from abroad has additional restrictions: - Maximum 2 weeks per year... - Must be approved 30 days in advance...
User: That's very helpful! I think I have everything I need for now. Assistant: Excellent! I'm glad I could help you understand our remote work policy, Sarah. Remember to submit Form HR-101 when you're ready to apply.


The Challenge: The Limits of Short-Term Memory
As this conversation grows, the agent's "working memory," or Short-Term Memory (STM), begins to fill up. Like a person trying to remember a long list of instructions, the agent is at risk of forgetting the critical details from the beginning of the chat (like Sarah's name, her department, and that she's already confirmed her eligibility). If left unmanaged, the agent would have to drop these old messages, leading to a frustrating experience where it might ask Sarah the same questions again.
Now, let's see how our proposed memory framework intelligently handles this challenge using two different, developer-configured strategies.
4. 1 Scenario 1: Configuration with a Summarization Strategy
In this approach, the agent is configured to act like a diligent note-taker. When its working memory gets too full, it pauses to summarize the older parts of the conversation into a concise brief, ensuring it never loses the core context.
In this scenario, there are no long-term memory blocks present since the user's strategy is to use the summarization technique to handle the STM overflows
4.1.1 Chat history(STM) Before Summarization
The agent's active memory is now full. The snippet below shows the most recent messages currently being held in the STM. The earlier messages (about Sarah's introduction and eligibility) are the ones that are now causing the memory to overflow.
[
  { "role": "user", "content": "What if my manager initially says no?" },
  { "role": "assistant", "content": "If your manager declines your request, you have options..." },
  { "role": "user", "content": "No, just want to be prepared. What about equipment..." },
  { "role": "assistant", "content": "Yes, the company provides essential equipment..." },
  { "role": "user", "content": "Perfect! One more question - can I work from abroad occasionally?" },
  { "role": "assistant", "content": "Working from abroad has additional restrictions..." },
  { "role": "user", "content": "That's very helpful! I think I have everything I need for now." }
]
4.1.2 The Summarization Process
Behind the scenes, the memory framework takes the oldest messages that are about to be dropped and sends them to a language model with an instruction like, "Summarize the key facts and user intent from this conversation." The model generates a short, dense summary.
4.1.3 Chat history (STM) After Summarization
The framework then rebuilds the agent's working memory. It replaces all the old messages with the single, AI-generated summary and appends the most recent messages. The agent's memory is now compact and efficient.
[
  {
    "role": "user",
    "content": "CONVERSATION SUMMARY: Sarah from Marketing team inquired about remote work policy. Key discussion points: Remote work allows 3 days/week with approval. Sarah meets eligibility criteria (2+ years experience, good performance). Discussed application process using Form HR-101, manager approval requirement, and options if manager declines (feedback, trial periods, HR mediation)."
  },
  { "role": "user", "content": "What if my manager initially says no?" },
  { "role": "assistant", "content": "If your manager declines your request, you have options..." },
  { "role": "user", "content": "No, just want to be prepared. What about equipment..." },
  { "role": "assistant", "content": "Yes, the company provides essential equipment..." },
  { "role": "user", "content": "Perfect! One more question - can I work from abroad occasionally?" },
  { "role": "assistant", "content": "Working from abroad has additional restrictions..." },
  { "role": "user", "content": "That's very helpful! I think I have everything I need for now." }
]
The Benefit: The agent has successfully avoided memory loss. It has freed up space but still "remembers" everything important, ensuring a coherent and context-aware conversation.

4.2 Scenario 2: Configuration with a "Flush to LTM" Strategy
This strategy is more advanced. Instead of just summarizing, the agent acts like a researcher, meticulously filing away detailed information into a structured, persistent Long-Term Memory (LTM). This information can be recalled in future conversations, even days or weeks later.
4.2.1 The Flushing Process
As the conversation unfolds, the memory framework actively analyzes the dialogue. It identifies different types of information and routes them to the appropriate LTM blocks for permanent storage.
4.2.2 Long-Term Memory (After Flushing)
After processing the older parts of the conversation, the agent's LTM has built a rich profile of the interaction. This is not a simple text blob but a structured knowledge base:
<memory>
    <static_memory>
      - Remote work: 3 days/week with approval.
      - International work: max 2 weeks/year, 30-day advance approval.
    </static_memory>


    <extractive_memory>
      - User: Sarah
      - Department: Marketing
      - Status: Eligible for remote work (2 years tenure, good performance).
    </extractive_memory>


    <vector_memory>
      - (Vector embeddings representing discussions on eligibility, application process, equipment, and international work policies).
    </vector_memory>
</memory>
4.2.3 Chat history (STM) After Flushing
With the crucial details safely stored in LTM, the oldest messages can be safely dropped from the agent's active STM. The working memory is now lean, containing only the most recent exchanges.
[
  { "role": "user", "content": "What if my manager initially says no?" },
  { "role": "assistant", "content": "If your manager declines your request, you have options..." },
  { "role": "user", "content": "No, just want to be prepared. What about equipment..." },
  { "role": "assistant", "content": "Yes, the company provides essential equipment..." },
  { "role": "user", "content": "Perfect! One more question - can I work from abroad occasionally?" },
  { "role": "assistant", "content": "Working from abroad has additional restrictions..." },
  { "role": "user", "content": "That's very helpful! I think I have everything I need for now." }
]
The Benefit: This approach provides the deepest form of memory. The agent's working memory stays fast and responsive, while it builds a persistent knowledge base that enables true personalization and contextual recall over long periods.


5. Developer Experience
A developer would interact with these components through a clear and declarative API. 
import ballerina/ai;
import ballerina/sql;
import ballerinax/java.jdbc;
import ballerinax/ai.openai;
import ballerinax/ai.pinecone;


jdbc:Client sqlLiteClient = check new(...);
jdbc:Client sqlLiteClient2 = check new(...);


openai:ModelProvider modelProvider = check new(...);
openai:EmbeddingProvider embeddingProvider = check new(...);


pinecone:VectorStore vectorStore = check new(...);


StaticMemory staticLTMBlock = new(
   facts = [
       {
           id: "fact1",
           content: "The capital of France is Paris."
       },
       {
           id: "fact2",
           content: "The tallest mountain in the world is Mount Everest."
       }
   ],
   factStore = sqlLiteClient
);


ExtractiveMemory extractiveLTMBlock = new(
   modelProvider = modelProvider,
   factStore = sqlLiteClient
);


VectorMemory vectorLTMBlock = new(
   modelProvider = modelProvider,
   store = vectorStore,
   embeddingProvider = embeddingProvider
);


AgentMemory agentMemory = new(
   messageStore = sqlLiteClient,
   systemMessageStore = sqlLiteClient2,
   filterConfig = {
       maxSummaryTokens: 500,
       modelProvider: modelProvider,
       summaryMessageCount: 10
   }
);


AgentMemory agentMemoryWithLTM = new(
   messageStore = sqlLiteClient,
   systemMessageStore = sqlLiteClient2,
   filterConfig = {
       maxSTMTokenRatio: 0.8,
       LTMemoryBlocks: [
           staticLTMBlock, extractiveLTMBlock, vectorLTMBlock
       ]
   }
);




public function main() {


   // Create an AI agent with the STM memory only. Agent will summarize older messages when the memory exceeds the token limit.
   ai:Agent agent = check new(
       {
           model: modelProvider,
           systemPrompt: ...,
           tools: [...],
           memory: agentMemory
       }
   );


   // Create AI Agent with STM and LTM memory. Agent will flush older messages to LTM when the STM memory exceeds the token limit.
   ai:Agent agentWithLTM = check new(
       {
           model: modelProvider,
           systemPrompt: ...,
           tools: [...],
           memory: agentMemory
       }
   );
}




6. Key Conceptual Components
The implementation will consist of the following key conceptual components:
A Standard Memory Interface: A common interface that all memory types will adhere to, ensuring interoperability.
The STM Orchestrator: The central component that manages active chat history and executes the configured overflow strategy.
Pluggable LTM Blocks: A suite of components for different knowledge types:
A Static Knowledge Store for foundational, read-only facts.
Gives the options to the user to implement using a inmemory, NoSQL or SQL database
An Extractive Knowledge Store for pulling specific details from conversations.
Gives the options to the user to implement using a inmemory, NoSQL or SQL database
A Semantic Knowledge Store for vector-based similarity searches.
Gives the options to the user to implement using a vector database
7. Implementation overview

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

# Type alias for supported database clients in agent memory storage.
type AgentMemoryDbStore mongodb:Client|redis:Client|sql:Client;

# Type representing facts stored in memory.
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
    private STMMemoryOverflowConfig filterConfig;

    # Maximum token count allocated for the memory
    private int maxMemoryTokenCount;

    # Initializes the agent memory with configurable storage backends and overflow handling.
    #
    # + messageStore - Storage backend for chat messages (in-memory map or database)
    # + systemMessageStore - Storage backend for system messages (in-memory map or database)
    # + filterConfig - Configuration for memory overflow handling strategies
    public isolated function init(
                map<ai:MemoryChatMessage[]>|AgentMemoryDbStore? messageStore = (), 
                map<ai:MemoryChatSystemMessage>|AgentMemoryDbStore? systemMessageStore = (),
                FlushToLTMConfiguration|STMSummarizeConfiguration|TrimLastMessagesConfiguration? filterConfig = DEFAULT_FLUSH_CONFIG,
                int maxMemoryTokenCount = 100000) {
        self.messageStore = messageStore ?: {};
        self.systemMessageStore = systemMessageStore ?: {};
        self.filterConfig = filterConfig ?: {};
        self.maxMemoryTokenCount = maxMemoryTokenCount;
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


import ballerina/ai;
import ballerinax/mongodb;
import ballerinax/redis;
import ballerina/sql;

# Record type to hold static facts
public type StaticFact anydata;

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


import ballerina/ai;

# Vector-based semantic memory using embeddings for similarity search.
# Stores and retrieves messages based on semantic similarity rather than exact matches.
public isolated class VectorMemory {
    *ai:Memory;
    
    # Name identifier for this memory instance
    private string name;
    
    # AI model provider for processing
    private ai:ModelProvider modelProvider;
    
    # Embedding provider for generating vector representations
    private ai:EmbeddingProvider embeddingProvider;
    
    # Vector store for similarity search operations
    private ai:VectorStore store;

    # Initializes the vector memory for semantic storage and retrieval.
    #
    # + modelProvider - AI model provider for processing
    # + embeddingProvider - Service for generating embeddings
    # + store - Vector database for similarity search
    # + name - Identifier for this memory instance
    public isolated function init(ai:ModelProvider modelProvider, 
            ai:EmbeddingProvider embeddingProvider,
            ai:VectorStore store, 
            string name = "vector_memory") {
        self.name = name;
        self.modelProvider = modelProvider;
        self.embeddingProvider = embeddingProvider;
        self.store = store;
    }

    # Deletes all vectors associated with a specific session.
    #
    # + sessionId - Session identifier
    # + return - Error if deletion fails, nil on success
    public isolated function delete(string sessionId) returns ai:MemoryError? {
        // Delete vectors from store filtering by sessionId metadata
        return;
    }

    # Retrieves semantically similar messages based on current context.
    #
    # + sessionId - Session identifier
    # + message - Current message for similarity search
    # + return - Array of semantically similar messages or error
    public isolated function get(string sessionId, ai:ChatMessage message) returns ai:QueryMatch[]|ai:MemoryError {
        // Generate embedding for current message using embeddingProvider
        // Perform similarity search in vector store
        // Return most similar messages within session context
        return [];
    }

    # Stores a new message as a vector embedding for future semantic retrieval.
    #
    # + sessionId - Session identifier
    # + message - Message to convert to embedding and store
    # + return - Error if storage fails, nil on success
    public isolated function update(string sessionId, ai:ChatMessage message) returns ai:MemoryError? {
        // Generate embedding for message using embeddingProvider
        // Store vector in vector store with sessionId as metadata
        return;
    }
}



import ballerina/ai;

# Represents the memory interface for the agents.
public type Memory isolated object {

    # Retrieves all stored chat messages.
    #
    # + sessionId - The ID associated with the memory
    # + return - An array of messages or an `ai:Error`
    public isolated function get(string sessionId, ai:ChatMessage message) returns anydata[]|ai:MemoryError;

    # Adds a chat message to the memory.
    #
    # + sessionId - The ID associated with the memory
    # + message - The message to store
    # + return - nil on success, or an `ai:Error` if the operation fails 
    public isolated function update(string sessionId, ai:ChatMessage message) returns ai:MemoryError?;

    # Deletes all stored messages.
    # + sessionId - The ID associated with the memory
    # + return - nil on success, or an `ai:Error` if the operation fails
    public isolated function delete(string sessionId) returns ai:MemoryError?;
};

