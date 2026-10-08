# EPICEVENTZ - AI & Agentforce Innovation Specification

## 1. Overview
The AI & Agentforce Innovation module (`EventGuardianAIEngine`) powers two intelligent assistants:
1. **Attendee AI Assistant:** Helps attendees discover events using natural language queries, answers ticketing FAQs, and provides registration guidance.
2. **Organizer Event Guardian AI:** Analyzes attendee feedback comments, aggregates sentiment distributions, and recommends actionable event optimization insights.

## 2. AI Service Methods & Features

| Method Name | Target User | Inputs | Outputs | Description |
| :--- | :--- | :--- | :--- | :--- |
| `queryEventAssistant` | External Attendee | `userQuery` (String) | Natural Language Response + Data | Identifies intent (Discovery vs Ticket FAQ) and returns event recommendations. |
| `summarizeEventFeedbackAI` | Internal Organizer | `eventId` (Id) | Sentiment Breakdown + AI Text Summary | Aggregates 1-5 star ratings, positive/negative ratios, and generates action items. |

## 3. Agentforce Integration Readiness
- **Agentforce Topic Actions:** Designed so that if Agentforce is enabled in the target Salesforce org, `EventGuardianAIEngine` methods map directly as Agentforce Invocable Actions (`@InvocableMethod`).
- **Org Compatibility:** If Agentforce is unconfigured in standard Developer Orgs, `EventGuardianAIEngine` delivers full AI-assisted functionality via `epicAiAssistant` LWC.
