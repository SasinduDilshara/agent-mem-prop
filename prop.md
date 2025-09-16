
Proposal: Advanced Memory Management for Ballerina AI Agents
Authors: Sasindu Alahakoon
Reviewers: Shafreen Anfar
Created: 2025-09-17

1. Summary
This proposal introduces a comprehensive, multi-layered memory management system for Ballerina AI Agents. The current agent memory is a basic, in-memory message window that discards old messages, limiting an agent's ability to conduct long, meaningful conversations. This proposal outlines a solution that mimics human memory by introducing concepts of Short-Term Memory (STM) for managing active conversations and Long-Term Memory (LTM) for persistent knowledge. This system will enable developers to build agents that are contextual, personalized, and capable of handling long-running, complex interactions.

2. Motivation
The current agent memory implementation in Ballerina, MessageWindowChatMemory, provides a basic, fixed-size chat history. While functional for short conversations, it has significant limitations:
Context Loss: It operates on a "first-in, first-out" basis. Once the message window is full, the oldest messages are permanently deleted, regardless of their importance. A critical fact mentioned at the start of a long conversation is lost forever.
No Persistence: The memory is stored in an in-memory map, meaning the entire conversation history is lost if the agent restarts. This prevents the creation of agents that can resume conversations or remember users across sessions.
Lack of Intelligence: It treats all messages as a simple transcript. There is no mechanism to distill important facts, understand the semantic meaning of the conversation, or access a static knowledge base.
To build truly intelligent and useful agents, we need a more sophisticated memory system that can intelligently preserve context, persist information, and manage different types of knowledge.

3. Description of the Proposed Solution
The proposed solution is centered around the AgentMemory class, which acts as the primary Short-Term Memory (STM). This class manages the immediate conversation history. To handle the finite nature of context windows, AgentMemory implements several overflow strategies. When the conversation history exceeds a configured token limit, it can automatically summarize, trim, or flush important information to specialized Long-Term Memory (LTM) blocks.
The storage for STM is flexible: it can use an in-memory map for simple, transient conversations, or it can be backed by a persistent database client (mongodb:Client|redis:Client|sql:Client) to maintain conversation history across restarts.
Long-Term Memory (LTM) is a collection of specialized, pluggable memory blocks for different types of knowledge:
StaticMemory: Stores unchanging, foundational knowledge about the agent or its domain (e.g., company policies, the agent's name). This memory is read-only during conversations and persists its facts in a configured database store (sql:Client, mongodb:Client, etc.).
ExtractiveMemory: Uses an LLM to identify and pull key facts from a conversation (e.g., "User's name is Sarah") and stores this structured data in a persistent database, linked to a session ID for later recall.
VectorMemory: Stores information as vector embeddings, allowing for semantic search. This requires an ai:VectorStore implementation (backed by a vector database) to store vectors and perform similarity searches, which is ideal for retrieving relevant documents based on meaning.
The AgentMemory class orchestrates interactions with these LTM blocks. When retrieving context for a new user message, it not only pulls from the recent chat history (STM) but also queries the LTM blocks to fetch relevant long-term knowledge, providing the LLM with a rich, comprehensive context.

4. Concrete Use Case: HR Policy Chatbot
The HR Policy Chatbot scenario demonstrates how the different memory components work together to create a stateful, intelligent conversational experience.
User Conversation Flow
The conversation begins with Sarah from Marketing asking about the remote work policy. The chatbot provides details on eligibility, the application process, handling denials, company-provided equipment, and rules for working abroad.

Scenario 1: Summarization Strategy (Token Limit Reached)
Here, the AgentMemory (STM) is configured to summarize the conversation when it exceeds a token limit.
Before Summarization (STM Overflow)
The STM holds the initial part of the conversation. As it nears its token limit, the history looks like this:
JSON


[
  {"role": "user", "content": "Hi, I'm Sarah from the Marketing team...", "timestamp": "..."},
  {"role": "assistant", "content": "Hello Sarah! I'm here to help...", "timestamp": "..."},
  {"role": "user", "content": "What are the eligibility criteria?", "timestamp": "..."},
  {"role": "assistant", "content": "For remote work eligibility, you need to...", "timestamp": "..."},
  {"role": "user", "content": "Yes, I've been here for 2 years...", "timestamp": "..."},
  {"role": "assistant", "content": "Great! Since you meet the criteria...", "timestamp": "..."},
  {"role": "user", "content": "What if my manager initially says no?", "timestamp": "..."},
  {"role": "assistant", "content": "If your manager declines your request...", "timestamp": "..."}
]


After Summarization
The AgentMemory uses an LLM to generate a summary of the older messages, replaces them with a single system message, and then appends the newer messages. This preserves context while freeing up tokens.
JSON


[
  {
    "role": "system",
    "content": "CONVERSATION SUMMARY: Sarah from Marketing team inquired about remote work policy. Key discussion points: Remote work allows 3 days/week with approval. Sarah meets eligibility criteria (2+ years experience, good performance). Discussed application process using Form HR-101, manager approval requirement, and options if manager declines (feedback, trial periods, HR mediation). All processes and requirements explained comprehensively.",
    "timestamp": "..."
  },
  { "role": "user", "content": "No, just want to be prepared. What about equipment...", "timestamp": "..." },
  { "role": "assistant", "content": "Yes, the company provides essential equipment...", "timestamp": "..." },
  { "role": "user", "content": "Perfect! One more question - can I work from abroad occasionally?", "timestamp": "..." },
  { "role": "assistant", "content": "Working from abroad has additional restrictions...", "timestamp": "..." },
  { "role": "user", "content": "That's very helpful! I think I have everything I need for now.", "timestamp": "..." },
  { "role": "assistant", "content": "Excellent! I'm glad I could help you understand our remote work policy, Sarah...", "timestamp": "..." }
]



Scenario 2: Flush to LTM Strategy
In this scenario, the AgentMemory is configured to flush important information to the LTM blocks when the token limit is reached.
Long Term Memory Blocks (After Flushing)
During the conversation, the AgentMemory processes the messages and pushes relevant information into the appropriate LTM stores.
XML


<memory>
<static_memory>
  - Remote work available up to 3 days per week with manager approval
  - International work: max 2 weeks/year, 30-day advance approval, approved countries only
  - Application form: HR-101 available on employee portal
</static_memory>


<extractive_memory>
  - Sarah (Marketing Team):
  - Tenure: 2 years with company
  - Performance: Good performance reviews (meets remote work eligibility)
  - Department: Marketing team
  - Interest: Remote work application, understanding policies and procedures
</extractive_memory>


<vector_memory>
  Remote Work Policy Context:
  - Policy discussion regarding eligibility criteria and application process
  - Employee equipment provisions and company support for remote workers  
  - International work restrictions and compliance requirements
</vector_memory>
</memory>


STM After Flushing
After flushing the key details to LTM, the STM can be trimmed to only keep the most recent messages, ensuring the context window remains small and efficient.
JSON


[
  { "role": "user", "content": "Perfect! One more question - can I work from abroad occasionally?", "timestamp": "..." },
  { "role": "assistant", "content": "Working from abroad has additional restrictions...", "timestamp": "..." },
  { "role": "user", "content": "That's very helpful! I think I have everything I need for now.", "timestamp": "..." },
  { "role": "assistant", "content": "Excellent! I'm glad I could help you understand our remote work policy, Sarah...", "timestamp": "..." }
]



5. Developer Experience
The design prioritizes ease of use. A developer can configure a sophisticated memory system with minimal boilerplate code by initializing the desired LTM blocks and configuring the AgentMemory with an overflow strategy.
Code snippet


// 1. Initialize data stores and providers
ai:ModelProvider modelProvider = check ai:getDefaultModelProvider();
ai:EmbeddingProvider embeddingProvider = check ai:getDefaultEmbeddingProvider();
sql:Client dbClient = check new; // Or Mongo, Redis
ai:VectorStore vectorStore = check new; // An implementation of a vector DB


// 2. Initialize LTM blocks
ai:Memory staticMem = new StaticMemory(dbClient);
ai:Memory extractiveMem = new ExtractiveMemory(modelProvider, dbClient);
ai:Memory vectorMem = new VectorMemory(modelProvider, embeddingProvider, vectorStore);


// 3. Configure STM overflow strategy (e.g., Flush to LTM)
FlushToLTMConfiguration flushConfig = {
    maxSTMTokenRatio: 0.7,
    LTMemoryBlocks: [extractiveMem, vectorMem] // Add relevant LTMs
};
STMMemoryOverflowConfig memoryConfig = {
    maxMemoryTokenCount: 4096,
    flushSTMOverflowmemory: flushConfig
};


// 4. Initialize the main AgentMemory
AgentMemory agentMemory = new AgentMemory(filterConfig = memoryConfig);


// 5. Use it with the agent
ai:Agent myAgent = check new(memory = agentMemory, ...);


This declarative approach allows developers to easily compose and experiment with different memory strategies to best suit their agent's needs.

6. Key Components & Implementation
The implementation will consist of the following key components as defined in the provided interfaces:
ai:Memory Interface: The core abstraction that all memory types will implement, ensuring methods for get, update, and delete are standardized.
AgentMemory Class: The central STM orchestrator. It will contain the logic for storing chat history and executing overflow strategies (handleMemoryOverflow).
LTM Implementations:
StaticMemory: Will focus on loading data from a persistent store (mongodb:Client|redis:Client|sql:Client).
ExtractiveMemory: Will use the configured ai:ModelProvider to run fact-extraction prompts and store results in a database.
VectorMemory: Will integrate with an ai:EmbeddingProvider and an ai:VectorStore for storage and similarity search.
Configuration Records: Types like STMMemoryOverflowConfig and FlushToLTMConfiguration will provide a clear, typed way for developers to configure memory behavior.

