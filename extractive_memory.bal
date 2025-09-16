import ballerina/ai;
import ballerina/sql;
import ballerinax/mongodb;
import ballerinax/redis;

final readonly & ai:Prompt DEFAULT_FACT_EXTRACTION_PROMPT = `<prompt>`;
final readonly & ai:Prompt DEFAULT_FACT_RETRIEVAL_PROMPT = `<prompt>`;

public isolated class ExtractiveMemory {
    *ai:Memory;
    private string name;
    private ai:ModelProvider modelProvider;
    private mongodb:Client|redis:Client|sql:Client factStore;
    private int maxTokens;
    private ai:Prompt factExtractionPrompt;
    private ai:Prompt factRetrievalPrompt;

    public isolated function init(ai:ModelProvider modelProvider, 
            readonly & mongodb:Client|redis:Client|sql:Client factStore, 
            string name = "semantic_memory",
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

    public isolated function delete(string sessionId) returns ai:MemoryError? {
        return;
    }

    public isolated function get(string sessionId, ai:ChatMessage message) returns ai:ChatMessage[]|ai:MemoryError {
        return [];
    }

    public isolated function update(string sessionId, ai:ChatMessage message) returns ai:MemoryError? {
        return;
    }
}
