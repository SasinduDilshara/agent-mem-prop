# HR Policy Chatbot Memory System Demonstration

## Use Case Overview

The HR Policy Chatbot helps employees understand company policies, procedures, and benefits. It maintains different types of memory:

- **Static Memory**: Core HR policies, company guidelines, benefits information
- **Extractive Memory**: Important facts about employee situations and policy interpretations
- **Vector Memory**: Semantic understanding of policy documents and FAQs
- **Agent Memory (STM)**: Active conversation history with overflow management

---

## Demonstration Scenario

### User Conversation Flow

**User**: Hi, I'm Sarah from the Marketing team. I need to understand our remote work policy.

**Assistant**: Hello Sarah! I'm here to help you with HR policies. Our remote work policy allows eligible employees to work remotely up to 3 days per week with manager approval. Would you like me to explain the eligibility criteria or application process?

**User**: What are the eligibility criteria?

**Assistant**: For remote work eligibility, you need to:
1. Have completed at least 6 months with the company
2. Have satisfactory performance ratings
3. Hold a role suitable for remote work (as determined by your manager)
4. Have necessary equipment and reliable internet connection

Are you meeting these criteria, Sarah?

**User**: Yes, I've been here for 2 years and have good performance reviews. How do I apply?

**Assistant**: Great! Since you meet the criteria, here's the application process:
1. Submit Form HR-101 (Remote Work Application)
2. Get manager approval and signature
3. IT department will assess your home office setup
4. HR reviews and approves final arrangement
5. Trial period of 30 days before permanent approval

The form is available on the employee portal under "HR Forms". Would you like me to help with anything specific about the application?

**User**: What if my manager initially says no?

**Assistant**: If your manager declines your request, you have options:
1. Ask for specific feedback on concerns
2. Propose a trial period or modified arrangement
3. Request mediation through HR if you believe the denial is unfair
4. You can reapply after addressing the concerns raised

The policy ensures fair consideration of all requests. Is there a specific concern your manager might have?

**User**: No, just want to be prepared. What about equipment - does the company provide anything?

**Assistant**: Yes, the company provides essential equipment for remote work:
- Laptop/desktop computer
- Monitor (if needed)
- Ergonomic chair allowance up to $300
- Internet allowance of $50/month
- VPN access and security software

You'll need to sign an equipment agreement and return items if you leave the company or end remote work arrangement.

**User**: Perfect! One more question - can I work from abroad occasionally?

**Assistant**: Working from abroad has additional restrictions:
- Maximum 2 weeks per year from international locations
- Must be approved 30 days in advance
- Limited to countries with data protection agreements
- Requires VPN usage and may have tax implications
- Emergency contact information must be provided

HR and Legal teams review international requests due to compliance requirements. Would you like help with the international work request process?

**User**: That's very helpful! I think I have everything I need for now.

**Assistant**: Excellent! I'm glad I could help you understand our remote work policy, Sarah. Remember to submit Form HR-101 when you're ready to apply. Feel free to reach out if you have any other HR policy questions!

---

## Memory System Demonstration

### Scenario 1: Summarization Strategy (Token Limit Reached)

#### Before Summarization (STM Overflow)

```json
STM Chat Messages Array:
[
  {
    "role": "user",
    "content": "Hi, I'm Sarah from the Marketing team. I need to understand our remote work policy.",
    "timestamp": "2025-01-15T10:00:00Z"
  },
  {
    "role": "assistant", 
    "content": "Hello Sarah! I'm here to help you with HR policies. Our remote work policy allows eligible employees to work remotely up to 3 days per week with manager approval. Would you like me to explain the eligibility criteria or application process?",
    "timestamp": "2025-01-15T10:00:15Z"
  },
  {
    "role": "user",
    "content": "What are the eligibility criteria?",
    "timestamp": "2025-01-15T10:00:45Z"
  },
  {
    "role": "assistant",
    "content": "For remote work eligibility, you need to: 1. Have completed at least 6 months with the company 2. Have satisfactory performance ratings 3. Hold a role suitable for remote work (as determined by your manager) 4. Have necessary equipment and reliable internet connection. Are you meeting these criteria, Sarah?",
    "timestamp": "2025-01-15T10:01:00Z"
  },
  {
    "role": "user",
    "content": "Yes, I've been here for 2 years and have good performance reviews. How do I apply?",
    "timestamp": "2025-01-15T10:01:30Z"
  },
  {
    "role": "assistant",
    "content": "Great! Since you meet the criteria, here's the application process: 1. Submit Form HR-101 (Remote Work Application) 2. Get manager approval and signature 3. IT department will assess your home office setup 4. HR reviews and approves final arrangement 5. Trial period of 30 days before permanent approval. The form is available on the employee portal under 'HR Forms'. Would you like me to help with anything specific about the application?",
    "timestamp": "2025-01-15T10:02:00Z"
  },
  {
    "role": "user",
    "content": "What if my manager initially says no?",
    "timestamp": "2025-01-15T10:02:30Z"
  },
  {
    "role": "assistant",
    "content": "If your manager declines your request, you have options: 1. Ask for specific feedback on concerns 2. Propose a trial period or modified arrangement 3. Request mediation through HR if you believe the denial is unfair 4. You can reapply after addressing the concerns raised. The policy ensures fair consideration of all requests. Is there a specific concern your manager might have?",
    "timestamp": "2025-01-15T10:03:00Z"
  }
]
```

#### After Summarization

```json
STM Chat Messages Array:
[
  {
    "role": "system",
    "content": "CONVERSATION SUMMARY: Sarah from Marketing team inquired about remote work policy. Key discussion points: Remote work allows 3 days/week with approval. Sarah meets eligibility criteria (2+ years experience, good performance). Discussed application process using Form HR-101, manager approval requirement, and options if manager declines (feedback, trial periods, HR mediation). All processes and requirements explained comprehensively.",
    "timestamp": "2025-01-15T10:03:15Z"
  },
  {
    "role": "user",
    "content": "No, just want to be prepared. What about equipment - does the company provide anything?",
    "timestamp": "2025-01-15T10:03:45Z"
  },
  {
    "role": "assistant",
    "content": "Yes, the company provides essential equipment for remote work: - Laptop/desktop computer - Monitor (if needed) - Ergonomic chair allowance up to $300 - Internet allowance of $50/month - VPN access and security software. You'll need to sign an equipment agreement and return items if you leave the company or end remote work arrangement.",
    "timestamp": "2025-01-15T10:04:00Z"
  },
  {
    "role": "user",
    "content": "Perfect! One more question - can I work from abroad occasionally?",
    "timestamp": "2025-01-15T10:04:30Z"
  },
  {
    "role": "assistant",
    "content": "Working from abroad has additional restrictions: - Maximum 2 weeks per year from international locations - Must be approved 30 days in advance - Limited to countries with data protection agreements - Requires VPN usage and may have tax implications - Emergency contact information must be provided. HR and Legal teams review international requests due to compliance requirements. Would you like help with the international work request process?",
    "timestamp": "2025-01-15T10:05:00Z"
  },
  {
    "role": "user",
    "content": "That's very helpful! I think I have everything I need for now.",
    "timestamp": "2025-01-15T10:05:30Z"
  },
  {
    "role": "assistant",
    "content": "Excellent! I'm glad I could help you understand our remote work policy, Sarah. Remember to submit Form HR-101 when you're ready to apply. Feel free to reach out if you have any other HR policy questions!",
    "timestamp": "2025-01-15T10:06:00Z"
  }
]
```

---

### Scenario 2: Flush to LTM Strategy

#### STM Chat Messages Array (Token Limit Reached)

```json
[
  {
    "role": "user",
    "content": "Hi, I'm Sarah from the Marketing team. I need to understand our remote work policy.",
    "timestamp": "2025-01-15T10:00:00Z"
  },
  {
    "role": "assistant", 
    "content": "Hello Sarah! I'm here to help you with HR policies. Our remote work policy allows eligible employees to work remotely up to 3 days per week with manager approval. Would you like me to explain the eligibility criteria or application process?",
    "timestamp": "2025-01-15T10:00:15Z"
  },
  {
    "role": "user",
    "content": "What are the eligibility criteria?",
    "timestamp": "2025-01-15T10:00:45Z"
  },
  {
    "role": "assistant",
    "content": "For remote work eligibility, you need to: 1. Have completed at least 6 months with the company 2. Have satisfactory performance ratings 3. Hold a role suitable for remote work (as determined by your manager) 4. Have necessary equipment and reliable internet connection. Are you meeting these criteria, Sarah?",
    "timestamp": "2025-01-15T10:01:00Z"
  },
  {
    "role": "user",
    "content": "Yes, I've been here for 2 years and have good performance reviews. How do I apply?",
    "timestamp": "2025-01-15T10:01:30Z"
  },
  {
    "role": "assistant",
    "content": "Great! Since you meet the criteria, here's the application process: 1. Submit Form HR-101 (Remote Work Application) 2. Get manager approval and signature 3. IT department will assess your home office setup 4. HR reviews and approves final arrangement 5. Trial period of 30 days before permanent approval. The form is available on the employee portal under 'HR Forms'. Would you like me to help with anything specific about the application?",
    "timestamp": "2025-01-15T10:02:00Z"
  },
  {
    "role": "user",
    "content": "What if my manager initially says no?",
    "timestamp": "2025-01-15T10:02:30Z"
  },
  {
    "role": "assistant",
    "content": "If your manager declines your request, you have options: 1. Ask for specific feedback on concerns 2. Propose a trial period or modified arrangement 3. Request mediation through HR if you believe the denial is unfair 4. You can reapply after addressing the concerns raised. The policy ensures fair consideration of all requests. Is there a specific concern your manager might have?",
    "timestamp": "2025-01-15T10:03:00Z"
  },
  {
    "role": "user",
    "content": "No, just want to be prepared. What about equipment - does the company provide anything?",
    "timestamp": "2025-01-15T10:03:45Z"
  },
  {
    "role": "assistant",
    "content": "Yes, the company provides essential equipment for remote work: - Laptop/desktop computer - Monitor (if needed) - Ergonomic chair allowance up to $300 - Internet allowance of $50/month - VPN access and security software. You'll need to sign an equipment agreement and return items if you leave the company or end remote work arrangement.",
    "timestamp": "2025-01-15T10:04:00Z"
  },
  {
    "role": "user",
    "content": "Perfect! One more question - can I work from abroad occasionally?",
    "timestamp": "2025-01-15T10:04:30Z"
  },
  {
    "role": "assistant",
    "content": "Working from abroad has additional restrictions: - Maximum 2 weeks per year from international locations - Must be approved 30 days in advance - Limited to countries with data protection agreements - Requires VPN usage and may have tax implications - Emergency contact information must be provided. HR and Legal teams review international requests due to compliance requirements. Would you like help with the international work request process?",
    "timestamp": "2025-01-15T10:05:00Z"
  },
  {
    "role": "user",
    "content": "That's very helpful! I think I have everything I need for now.",
    "timestamp": "2025-01-15T10:05:30Z"
  },
  {
    "role": "assistant",
    "content": "Excellent! I'm glad I could help you understand our remote work policy, Sarah. Remember to submit Form HR-101 when you're ready to apply. Feel free to reach out if you have any other HR policy questions!",
    "timestamp": "2025-01-15T10:06:00Z"
  }
]
```

#### Long Term Memory Blocks (After Flushing)

```xml
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
  - Status: Eligible for remote work based on criteria discussed
  - Concerns: Prepared for potential manager objections, interested in equipment provision
</extractive_memory>

<vector_memory>
  - conversation history
</vector_memory>
</memory>
```

#### STM After Flushing

```json
[
  {
    "role": "user",
    "content": "Perfect! One more question - can I work from abroad occasionally?",
    "timestamp": "2025-01-15T10:04:30Z"
  },
  {
    "role": "assistant",
    "content": "Working from abroad has additional restrictions: - Maximum 2 weeks per year from international locations - Must be approved 30 days in advance - Limited to countries with data protection agreements - Requires VPN usage and may have tax implications - Emergency contact information must be provided. HR and Legal teams review international requests due to compliance requirements. Would you like help with the international work request process?",
    "timestamp": "2025-01-15T10:05:00Z"
  },
  {
    "role": "user",
    "content": "That's very helpful! I think I have everything I need for now.",
    "timestamp": "2025-01-15T10:05:30Z"
  },
  {
    "role": "assistant",
    "content": "Excellent! I'm glad I could help you understand our remote work policy, Sarah. Remember to submit Form HR-101 when you're ready to apply. Feel free to reach out if you have any other HR policy questions!",
    "timestamp": "2025-01-15T10:06:00Z"
  }
]
```
