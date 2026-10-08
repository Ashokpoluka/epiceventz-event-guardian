# EPICEVENTZ - Master Interview & Viva Preparation Guide (27 Technical Questions)

## 1. Why Salesforce?
Salesforce provides a multi-tenant, cloud-native enterprise platform with built-in security, scalable data modeling, declarative automation engines (Flows, Approvals), advanced Apex/LWC development frameworks, native AI (Agentforce), and analytics dashboards out of the box, reducing time-to-market by 80%.

## 2. Why this data model?
Our data model separates internal B2B event management (`Event__c`, `Venue__c`, `Ticket_Type__c`) from external B2C customer transactions (`Registration__c`, `Payment__c`, `Feedback__c`). This architecture ensures data integrity, enforces capacity limits via roll-ups, and isolates attendee PII data.

## 3. Why standard vs custom objects?
We used standard Salesforce objects where native capabilities exist (e.g., `Contact` for Attendees, `Case` for Support, `Account` for Corporate Sponsors) to leverage native CRM functionality. We built custom objects (`Event__c`, `Registration__c`) only for domain-specific event ticketing entities.

## 4. Why Lookup vs Master-Detail?
We used **Master-Detail** for `Ticket_Type__c` → `Event__c` and `Registration__c` → `Event__c` because child records cannot exist without an event parent and require automatic security inheritance and roll-up summary capability. We used **Lookup** for `Registration__c` → `Contact` and `Payment__c` → `Registration__c` to prevent accidental cascading deletion of customer contacts or payment audit logs if an event is cancelled.

## 5. Why Flow?
Flow provides fast, declarative automation for simple field updates, status notifications, and case routing without requiring Apex code, maintaining the Salesforce **Declarative First** best practice.

## 6. Why Apex?
Apex is used when business logic exceeds declarative capabilities—such as issuing `FOR UPDATE` row locks to prevent flash-sale overbooking, executing complex sentiment analysis, parsing custom REST payloads, and running asynchronous batch/queueable jobs.

## 7. Why Apex Triggers?
We use single triggers per object (`FeedbackTrigger.trigger`) delegating to a `TriggerHandler` framework to execute complex before/after logic safely with static recursion guards.

## 8. Why Queueable Apex?
Queueable Apex (`RegistrationConfirmationQueueable`) offloads post-checkout ticket pass generation and audit logging to a background thread. It provides double the heap size (12MB), allows complex parameter passing (`Set<Id>`), returns a trackable job ID, and keeps the attendee checkout UI instantaneous.

## 9. Why Batch Apex?
Batch Apex (`EventPerformanceBatch`) processes large volumes of completed events across batched 200-record chunks. It resets governor limits for every chunk execution, avoiding the 50,000 SOQL query limit when processing millions of historical records.

## 10. Why Scheduled Apex?
Scheduled Apex (`EventReminderSchedulable`) automates hands-free daily background processing via Salesforce CRON expressions, scanning for events starting within 24 hours and chaining nightly batch analytics.

## 11. Why Platform Events?
Platform Events (`Registration_Event__e`) decouple event publishers from event subscribers across an asynchronous event bus. Downstream subscribers (Apex triggers, Flows, external Pub/Sub API consumers) react independently without creating transaction dependencies.

## 12. How did you prevent overbooking?
We enforced a multi-layered guard: (1) `Event__c.Available_Seats__c` and `Ticket_Type__c.Remaining_Quantity__c` formula fields, (2) declarative validation rules (`Registration_Quantity_Exceeds_Inventory`), (3) Roll-Up Summary capacity checks (`Ticket_Quantity_Exceeds_Capacity`), and (4) Apex `FOR UPDATE` database row locks during checkout.

## 13. How did you handle governor limits?
We implemented a strict 5-layer Apex framework (Trigger → Handler → Service → Selector → Utility). Zero SOQL or DML statements exist inside loops. All queries run in Selectors using `WITH USER_MODE`, and heavy operations are offloaded to Queueable and Batch Apex.

## 14. How did you secure attendee data?
We configured Private Org-Wide Defaults (OWD) for `Registration__c` and `Payment__c`, assigned granular access via 4 custom Permission Sets (`EpicEventz_Attendee`, etc.), enforced `WITH USER_MODE` in Apex, and stored zero credit card credentials.

## 15. How does the approval process work?
Organizers create events in `Draft` status and click **Submit for Approval**. The record locks and transitions to `Pending Approval`. An Admin reviews venue capacity and approves or rejects the event. Once approved, the record unlocks and can be set to `Published`.

## 16. How does payment processing work?
Our `PaymentService` processes mock payments by generating tokenized transaction IDs (`TXN-MOCK-...`). `Payment_Status_Sync_Flow` automatically updates parent `Registration__c` records to `Confirmed` and `Paid` upon successful payment execution.

## 17. How does the REST API work?
`EventRestService.cls` is annotated with `@RestResource(urlMapping='/epiceventz/events/*')`. It supports `GET` (returning event JSON catalogs) and `HttpPost` (processing external registration payloads and returning HTTP 200/400/500 status codes with `Integration_Log__c` auditing).

## 18. Why LWC?
Lightning Web Components (LWC) are built on modern W3C web standards, offering faster DOM rendering, lower memory footprint, reactive `@wire` adapters, and SLDS design token styling compared to legacy Aura components.

## 19. What is the AI capability?
`EventGuardianAIEngine.cls` powers natural language event discovery (`queryEventAssistant`) and analyzes attendee feedback text comments to aggregate sentiment ratios (`Positive`, `Neutral`, `Negative`) and generate actionable organizer insights.

## 20. What makes EpicEventz innovative?
EpicEventz combines core Salesforce CRM with roll-up capacity guards, 5-layer Apex framework, async Queueables/Batches, custom REST endpoints, Platform Events, Agentforce AI sentiment engine, and LWC portals.

## 21. How is the architecture scalable?
The platform scales horizontally: Batch Apex handles 50M+ records, Queueable Apex offloads heavy receipts, Platform Events stream via Pub/Sub API, and `FOR UPDATE` row locks serialize concurrent checkout transactions.

## 22. How did you test the solution?
We built `TestDataFactory.cls` producing isolated in-memory test data (`seeAllData=false`). Our test suite (`EventServiceTest`, `RegistrationServiceTest`) covers positive happy paths, negative validation errors, and bulk scenarios, achieving > 85% code coverage.

## 23. What happens if an integration fails?
Outbound callouts catch exceptions and write failure details (`Status_Code__c = 500`) into `Integration_Log__c`. The UI catches the exception, displays an alert, and rolls back uncommitted DML statements.

## 24. What happens if payment fails?
`Payment__c` records `Payment_Status__c = 'Failed'`, leaving parent `Registration__c` in `Pending Payment` status. The ticket inventory is not decremented, allowing the attendee to retry checkout.

## 25. What happens if two users try to purchase the last ticket?
Our Apex service issues a `SELECT ... FOR UPDATE` query on `Ticket_Type__c`. The database locks the record for the first user. When the second user's query evaluates, `Remaining_Quantity__c` is 0, triggering `Registration_Quantity_Exceeds_Inventory` to reject the second transaction cleanly.

## 26. What would you change for production?
In a production deployment, we would integrate a real Stripe/PayPal payment gateway via External Credentials, enable Experience Cloud Customer Community portals, and deploy automated CI/CD GitHub Actions pipelines.

## 27. What part of the project did YOU personally build?
As the Technical Solution Architect and Lead Developer, I designed the B2B2C architecture, built the custom objects and validation rules, authored the 5-layer Apex framework, constructed the Record-Triggered Flows, developed the LWC bundles, implemented the REST API and AI engines, and wrote the complete unit test suite.
