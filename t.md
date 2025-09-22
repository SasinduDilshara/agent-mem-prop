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

A key feature of this STM component is its intelligent handling of memory overflow. Based on developer configuration, when the active conversation exceeds a token limit, the system can employ one of several strategies:

Summarize: Use an LLM to create a concise summary of the older parts of the conversation, replacing many messages with one, thus preserving context while saving space.

Trim/Delete: Employ a simple strategy of removing the oldest messages to make space for new ones.

Flush to LTM: This is a hybrid strategy. Specific LTM blocks are updated differently:

The ExtractiveMemory is updated with every new message to continuously capture key facts as they appear.

When the STM overflows, older messages are then flushed to the ConversationalMemory block to preserve their semantic meaning before being dropped from the active STM.

Long-Term Memory (LTM) is not a single entity but a collection of specialized, pluggable memory blocks designed for different types of knowledge:

A static memory block for storing unchanging, foundational knowledge (e.g., company policies, the agent's purpose). This LTM memory block is global for every user and every thread.

An extractive memory block that uses an LLM to identify and pull key facts from a conversation (e.g., user's name, preferences) and stores them as structured data. This LTM memory block stores data specifically for each user.

A conversational memory block that stores information as vector embeddings of past interactions, allowing for the retrieval of information based on conceptual meaning rather than just keywords. This LTM memory block stores data specifically for each user.

4. Use Case Analysis: HR Policy Chatbot
This use case demonstrates how the memory system creates a stateful and intelligent HR assistant.

(The initial conversation between Sarah and the assistant remains the same as in your original document.)

The Challenge: The Limits of Short-Term Memory
As this conversation grows, the agent's Short-Term Memory (STM) begins to fill up. The agent is at risk of forgetting critical details from the beginning of the chat (like Sarah's name and department). Let's see how our proposed memory framework intelligently handles this challenge.

4.1 Scenario 1: Configuration with a Summarization Strategy
In this approach, when the STM gets too full, it pauses to summarize the older parts of the conversation into a concise brief, ensuring it never loses the core context.

(This section remains the same as in your original document.)

4.2 Scenario 2: Configuration with a "Flush to LTM" Strategy
This strategy is more advanced. The agent meticulously files away information into a structured, persistent Long-Term Memory (LTM). This information can be recalled in future conversations, even days or weeks later.

4.2.1 The Flushing Process
As the conversation unfolds, the memory framework employs a dual strategy:

Continuous Extraction: With each new message from Sarah, the system analyzes the dialogue in real-time to update the ExtractiveMemory with key facts (e.g., user name: Sarah, department: Marketing, eligibility: confirmed). This happens regardless of whether the STM is full.

Overflow Flushing: Only when the STM exceeds its token limit does the framework take the oldest messages and flush them to the ConversationalMemory, storing their semantic meaning as vector embeddings for future similarity searches.

4.2.2 Long-Term Memory (After Processing)
After processing the conversation, the agent's LTM has built a rich, structured knowledge base:

XML

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

    <conversational_memory>
      - (Vector embeddings representing discussions on eligibility, application process, equipment, and international work policies).
    </conversational_memory>
</memory>
4.2.3 Chat history (STM) After Flushing
With the crucial details safely stored in LTM, the oldest messages can be safely dropped from the agent's active STM. The working memory is now lean, containing only the most recent exchanges.

JSON

[
  { "role": "user", "content": "What if my manager initially says no?" },
  { "role": "assistant", "content": "If your manager declines your request, you have options..." },
  { "role": "user", "content": "No, just want to be prepared. What about equipment..." },
  { "role": "assistant", "content": "Yes, the company provides essential equipment..." },
  { "role": "user", "content": "Perfect! One more question - can I work from abroad occasionally?" },
  { "role": "assistant", "content": "Working from abroad has additional restrictions..." },
  { "role": "user", "content": "That's very helpful! I think I have everything I need for now." }
]
The Benefit: This approach provides the deepest form of memory. The agent's working memory stays fast, while it builds a persistent knowledge base that enables true personalization and contextual recall over long periods.

5. Developer Experience
A developer would interact with these components through a clear and declarative API.

Code snippet

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

// Renamed from VectorMemory
ConversationalMemory conversationalLTMBlock = new(
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
            staticLTMBlock, extractiveLTMBlock, conversationalLTMBlock
        ]
    }
);

public function main() {
    // Create an AI agent with the STM memory only.
    ai:Agent agent = check new(
        {
            model: modelProvider,
            systemPrompt: ...,
            tools: [...],
            memory: agentMemory
        }
    );

    // Create AI Agent with STM and LTM memory.
    ai:Agent agentWithLTM = check new(
        {
            model: modelProvider,
            systemPrompt: ...,
            tools: [...],
            memory: agentMemoryWithLTM // Corrected to use agentMemoryWithLTM
        }
    );
}
6. Key Conceptual Components
The implementation will consist of the following key conceptual components:

A Standard Memory Interface: A common interface that all memory types will adhere to.

The STM Orchestrator: The central component that manages active chat history and executes the configured overflow strategy.

Pluggable LTM Blocks: A suite of components for different knowledge types:

A Static Knowledge Store for foundational, read-only facts.

An Extractive Knowledge Store for pulling specific details from conversations.

A Semantic (Conversational) Knowledge Store for vector-based similarity searches.
