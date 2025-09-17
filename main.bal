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
