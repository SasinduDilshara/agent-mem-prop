import ballerina/ai;

public isolated class VectorMemory {
    *ai:Memory;
    private string name;
    private ai:ModelProvider modelProvider;
    private ai:EmbeddingProvider embeddingProvider;
    private ai:VectorStore store;

    public isolated function init(ai:ModelProvider modelProvider, 
            ai:EmbeddingProvider embeddingProvider,
            ai:VectorStore store, 
            string name = "persist_memory") {
        self.name = name;
        self.modelProvider = modelProvider;
        self.embeddingProvider = embeddingProvider;
        self.store = store;
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
