import ballerina/ai;
import ballerina/sql;
import ballerinax/mongodb;
import ballerinax/redis;

final readonly & ai:Prompt DEFAULT_SUMMARY_PROMPT = `<prompt>`;
ai:ModelProvider defaultModel = check ai:getDefaultModelProvider();

final STMSummarizeConfiguration DEFAULT_FLUSH_CONFIG = {
    modelProvider: defaultModel
};

type FlushToLTMConfiguration record {|
    decimal maxSTMTokenRatio = 0.5;
    boolean isPersistMemoryInsertedIntoTheSystemPrompt = false;
    Memory[] LTMemoryBlocks = [];
|};

type STMSummarizeConfiguration record {|
    int summaryMessageCount = 10;
    ai:ModelProvider modelProvider;
    ai:Prompt summaryPrompt = DEFAULT_SUMMARY_PROMPT;
    int maxSummaryTokens?;
|};

type TrimLastMessagesConfiguration record {|
    int maxSummaryTokens = 500;
|};

type DeleteLastMessagesConfiguration record {|
    int maxMessageCount = 10;
|};

type STMMemoryverflowConfig record {|
    int maxMemoryTokenCount = 2000;
    FlushToLTMConfiguration|STMSummarizeConfiguration
        |TrimLastMessagesConfiguration|DeleteLastMessagesConfiguration flushSTMConfig = DEFAULT_FLUSH_CONFIG;
|};

type AgentMemoryDbStore mongodb:Client|redis:Client|sql:Client;

public isolated class AgentMemory {
    *ai:Memory;
    private final map<ai:MemoryChatMessage[]>|AgentMemoryDbStore messageStore;
    private final map<ai:MemoryChatSystemMessage>|AgentMemoryDbStore systemMessageStore;
    private STMMemoryverflowConfig filterConfig = {};

    public isolated function init(
                map<ai:MemoryChatMessage[]>|AgentMemoryDbStore? messageStore = (), 
                map<ai:MemoryChatSystemMessage>|AgentMemoryDbStore? systemMessageStore = (),
                STMMemoryverflowConfig? filterConfig = {}) {
        self.messageStore = messageStore ?: {};
        self.systemMessageStore = systemMessageStore ?: {};
        self.filterConfig = filterConfig ?: {};
    }

    public isolated function get(string sessionId, ai:ChatMessage message) returns ai:ChatMessage[]|ai:MemoryError {
        return error("");
    }

    public isolated function update(string sessionId, ai:ChatMessage message) returns ai:MemoryError? {
        
    }

    public isolated function delete(string sessionId) returns ai:MemoryError? {
        return ();
    }
}
