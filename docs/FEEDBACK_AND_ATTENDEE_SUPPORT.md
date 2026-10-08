# EPICEVENTZ - Feedback & Attendee Support Specification

## 1. Overview
The Feedback & Attendee Support module collects post-event attendee ratings (`Feedback__c`), captures text comments for sentiment analysis, and routes attendee support issues using standard Salesforce `Case` management.

## 2. Validation & Support Routing Rules

| Component | Target Object | Condition | Action |
| :--- | :--- | :--- | :--- |
| `Rating_Range_Check` | `Feedback__c` | `Rating__c < 1 \|\| Rating__c > 5` | Blocks record with error: "Feedback Rating must be an integer between 1 and 5." |
| `Feedback_Only_After_Event_Started` | `Feedback__c` | `Event Status != 'In Progress' && Status != 'Completed'` | Blocks record with error: "Feedback can only be submitted for events that are In Progress or Completed." |
| `Support_Case_Routing_Flow` | `Case` | `Type = 'Payment Issue' \|\| Type = 'Registration Issue'` | Automatically sets `Priority` to `'High'`. |

## 3. Feedback Intelligence Pipeline

```
[Attendee Submits Feedback__c]
  ├── Rating__c: 5
  └── Comments__c: "Great speakers and seamless check-in experience!"
               |
               v
  [Validation Rules Checked] ---> PASS
               |
               v
[Sentiment Intelligence Classifier Engine (Phase 12 Apex / Phase 20 AI)]
  └── Sets Sentiment__c = 'Positive'
               |
               v
[Organizer Dashboard Visualizes Average Rating & Sentiment Distribution]
```
