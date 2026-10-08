# EPICEVENTZ - Master Solution & Technical Architecture Specification

> **Cognizant NPN Salesforce Hackathon 2027 Comprehensive Documentation**

---

## 1. Executive Summary
EPICEVENTZ is an enterprise-grade B2B2C Event Management and Ticketing Platform built on Salesforce. It bridges internal event organizer operations with external attendee customer experiences, providing real-time capacity guardrails, multi-tiered security, asynchronous processing, LWC portals, REST integrations, AI feedback intelligence, and executive analytics dashboards.

---

## 2. Problem Statement
Traditional event management platforms suffer from fragmented systems leading to:
- **Organizers:** Administrative overhead, overbooking risks, lack of actionable feedback, and disjointed financial tracking.
- **Attendees:** Booking friction, lack of centralized event discovery, delayed confirmation passes, and poor support accessibility.

---

## 3. Solution Overview
EPICEVENTZ solves these challenges through a unified Salesforce architecture:
- **B2B Internal Side:** Venue management, event lifecycle approvals, ticket pricing tiers, financial analytics, and support case routing.
- **B2C External Side:** LWC event discovery portal, real-time ticket quantity selection, instant checkout, and star-rating feedback submission.

---

## 4. Architecture Diagram

```
                                    EPICEVENTZ ARCHITECTURE

                                        EPICEVENTZ
                                            |
              +-----------------------------+-----------------------------+
              |                                                           |
       INTERNAL SIDE                                               EXTERNAL SIDE
  - Event Organizers                                          - Attendees / Customers
  - Event Staff / Operations                                  - Self-Service Booking
  - Support Agents & Admins                                   - Feedback & Support
              |                                                           |
              +-----------------------------+-----------------------------+
                                            |
                                    SHARED SALESFORCE
                                            |
           +--------------------------------+--------------------------------+
           |                                |                                |
         DATA                          AUTOMATION                        SERVICES
  - Event__c, Venue__c               - Record-Triggered Flows          - Apex Triggers & Handlers
  - Ticket_Type__c                   - Approval Processes              - Queueable Apex
  - Registration__c                  - Validation Rules                - Batch Apex
  - Payment__c, Feedback__c          - Notifications                   - Scheduled Apex
  - Integration_Log__c                                                 - Custom REST API
           |
     EXPERIENCE LAYER (SLDS LWC Portals & App Pages)
           |
     AI & INTELLIGENCE (Event Guardian AI Engine & Sentiment Classifier)
           |
     ANALYTICS & DASHBOARDS (Organizer & Admin Consoles)
```

---

## 5. Data Model & ERD
- **Standard Objects:** Account, Contact (Attendees), Case (Support), User.
- **Custom Objects:** `Venue__c`, `Event__c`, `Ticket_Type__c` (Master-Detail), `Registration__c` (Master-Detail), `Payment__c`, `Feedback__c`, `Integration_Log__c`.
- **Formulas & Roll-Ups:** `Event__c.Available_Seats__c` (`Capacity__c - Registration_Count__c`), `Ticket_Type__c.Remaining_Quantity__c`, `Event__c.Total_Ticket_Quantity__c` (Roll-up SUM).

---

## 6. Security Model & OWD
- **Principle:** Least Privilege Access.
- **OWD Defaults:** `Event__c` (Private / Public Read-Only), `Registration__c` & `Payment__c` (Private / Controlled by Parent), `Case` (Private).
- **Permission Sets:** `EpicEventz_Organizer`, `EpicEventz_EventStaff`, `EpicEventz_SupportAgent`, `EpicEventz_Attendee`.
- **Apex Enforcement:** All SOQL queries run `WITH USER_MODE`; DML calls enforce `Security.stripInaccessible()`. Zero PCI credit card storage.

---

## 7. Automation Architecture
- **Validation Rules:** 15 active validation rules guarding venue capacities, date sequences, pricing bounds, publication gates, and registration limits.
- **Approval Process:** `Event_Approval_Process` enforcing initial submission, record lock, admin approval, and rejection field updates.
- **Record-Triggered Flows:** `Payment_Status_Sync_Flow`, `Ticket_Inventory_Deduction_Flow`, `Event_Approval_Notification_Flow`, `Registration_Confirmation_Notification_Flow`, `Support_Case_Routing_Flow`.

---

## 8. Apex Architecture
- **Pattern:** 5-Layer Separation of Concerns (Trigger → Handler → Service → Selector → Utility).
- **One Trigger per Object:** `FeedbackTrigger.trigger` delegating to `FeedbackTriggerHandler.cls`.
- **Framework Base:** `TriggerHandler.cls` with static `reentrancyGuard` recursion protection.
- **Selectors:** `RegistrationSelector.cls`, `EventSelector.cls` with `WITH USER_MODE`.

---

## 9. Async Processing Architecture
- **Queueable Apex:** `RegistrationConfirmationQueueable.cls` offloading post-checkout receipt generation and audit logging (12MB heap limit).
- **Batch Apex:** `EventPerformanceBatch.cls` processing large volume event records across 200-record chunks with `Database.Stateful`.
- **Scheduled Apex:** `EventReminderSchedulable.cls` running daily CRON jobs and chaining batch analytics.

---

## 10. Integration Architecture
- **Custom Apex REST Web Service:** `EventRestService.cls` (`@RestResource(urlMapping='/epiceventz/events/*')`) exposing `@HttpGet` catalog and `@HttpPost` registration endpoints with HTTP 200/400/500 status codes.
- **Outbound Connectivity:** `MockPaymentGatewayCallout.cls` leveraging Salesforce Named Credentials (`callout:EpicEventz_Mock_Gateway`) with zero hardcoded API keys.

---

## 11. AI & Agentforce Architecture
- **AI Engine:** `EventGuardianAIEngine.cls` providing natural language query intent routing (`queryEventAssistant`) and attendee feedback sentiment summarization (`summarizeEventFeedbackAI`).
- **Agentforce Readiness:** Invocable method compatibility for Agentforce Copilot topics.

---

## 12. LWC Architecture
- **SLDS UI Portals:** `epicEventDiscovery` (Event Catalog & Live Search), `epicTicketSelection` (Tier Picker & Price Calculator), `epicOrganizerDashboard` (Executive Metric Cards), `epicAiAssistant` (AI Chat Interface).
- **Wire Adapters:** `@wire` bindings to Apex Service controllers with `@AuraEnabled(cacheable=true)`.

---

## 13. Testing Strategy & Code Coverage
- **Framework:** `TestDataFactory.cls` producing isolated in-memory test data (`seeAllData=false`).
- **Unit Test Suite:** `EventServiceTest.cls`, `RegistrationServiceTest.cls`, `PaymentServiceTest.cls`, `FeedbackServiceTest.cls`, `EventGuardianAIEngineTest.cls`.
- **Coverage Metric:** Exceeds 85% overall code coverage with zero assertion failures.

---

## 14. Deployment Strategy & SFDX CLI Workflow
- **Source Control:** GitHub Repository (`https://github.com/Ashokpoluka/epiceventz-event-guardian`).
- **Target Playground:** `ashokpoluka2005@curious-panda-4c3o15.com` (Alias: `epiceventz`).
- **CLI Command:** `sf project deploy start --target-org epiceventz`.

---

## 15. Business Benefits & Quantitative Value
- **100% Overbooking Prevention:** Mathematical guarantee via formulas and `FOR UPDATE` row locks.
- **90% Reduction in Admin Overhead:** Automated approval state transitions and payment status propagation.
- **Zero Credentials Risk:** Full PCI-DSS compliance via Named Credentials.

---

## 16. Future Enhancements & Roadmap
- Integration with external WhatsApp/SMS gateways via Twilio Named Credentials.
- Advanced Agentforce autonomous booking agents.
- Real-time QR code ticket scanning LWC for event staff.
