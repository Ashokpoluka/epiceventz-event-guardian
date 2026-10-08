# EPICEVENTZ - Solution Architecture Document

## 1. Executive Architecture Overview
EPICEVENTZ is an enterprise B2B2C Event Management Platform built on Salesforce. It separates internal B2B event management operations (Organizers, Staff, Support, Admins) from external B2C attendee experiences (Discovery, Registration, Ticketing, Feedback).

```
+-----------------------------------------------------------------------------------+
|                                 EPICEVENTZ USERS                                  |
|  +-------------------------------------+   +-----------------------------------+  |
|  |           INTERNAL USERS            |   |          EXTERNAL USERS            |  |
|  | System Admin \| Event Organizer     |   | Attendee \| Customer              |  |
|  | Event Staff  \| Support Agent       |   |                                   |  |
|  +-------------------------------------+   +-----------------------------------+  |
+------------------------------------------+----------------------------------------+
                                           |
                                           v
+-----------------------------------------------------------------------------------+
|                                 EXPERIENCE LAYER                                  |
|  Internal App: Lightning App Builder   |   External App: LWC Portal / App Page    |
|  (EpicEventz Console & Workspaces)     |   (Public / Guest / User-facing LWC)     |
+------------------------------------------+----------------------------------------+
                                           |
                                           v
+-----------------------------------------------------------------------------------+
|                               BUSINESS LOGIC LAYER                                |
|  - Concurrency & Inventory Control Engine (Prevent Overbooking)                   |
|  - Registration & Ticket Lifecycle Management                                     |
|  - Event Guardian Health & Sentiment Engine                                       |
+------------------------------------------+----------------------------------------+
                                           |
                                           v
+-----------------------------------------------------------------------------------+
|                                 AUTOMATION LAYER                                  |
|  - Record-Triggered Flows (State transitions & notifications)                     |
|  - Multi-Step Approval Processes (Event Publish Gate)                             |
|  - Validation Rules & Formulas (Capacity & Data Integrity)                        |
+------------------------------------------+----------------------------------------+
                                           |
                                           v
+-----------------------------------------------------------------------------------+
|                                   APEX SERVICES                                   |
|  - Trigger Framework (Single Trigger + Handler per object)                        |
|  - Queueable Apex (Async PDF Ticket & Confirmation Processing)                    |
|  - Batch Apex (Event Performance Analytics Aggregator)                            |
|  - Scheduled Apex (Daily Event Reminders & Inventory Maintenance)                 |
+------------------------------------------+----------------------------------------+
                                           |
                                           v
+-----------------------------------------------------------------------------------+
|                                DATA & SECURITY LAYER                              |
|  Standard: Account, Contact, User, Case                                           |
|  Custom:   Event__c, Venue__c, Ticket_Type__c, Registration__c, Payment__c,       |
|            Feedback__c, Integration_Log__c                                        |
|  Security: Private/Read-Only OWD, Role Hierarchy, Permission Sets, FLS            |
+------------------------------------------+----------------------------------------+
                                           |
                                           v
+-----------------------------------------------------------------------------------+
|                            INTEGRATION & EVENT-DRIVEN                             |
|  - Custom REST API Endpoints (`/services/apexrest/epiceventz/*`)                  |
|  - Mock External Payment Gateway (Named Credentials)                              |
|  - Platform Events (`Registration_Event__e`)                                      |
+------------------------------------------+----------------------------------------+
                                           |
                                           v
+-----------------------------------------------------------------------------------+
|                                ANALYTICS & INSIGHTS                               |
|  - Organizer Dashboard & Revenue Reports                                          |
|  - System Admin Health Dashboard                                                  |
|  - AI Feedback Sentiment Classification Insights                                  |
+-----------------------------------------------------------------------------------+
```

## 2. User Persona Matrix & Access Strategy

| Persona | Type | License / Access Profile | System Role & Responsibilities |
| :--- | :--- | :--- | :--- |
| **System Administrator** | Internal | System Administrator | Full platform setup, approval overrides, security governance, integration setup. |
| **Event Organizer** | Internal | Standard User + `Event_Organizer_PSG` | Creates venues, events, ticket types, submits for approval, views organizer dashboards. |
| **Event Staff** | Internal | Standard User + `Event_Staff_PSG` | Manages day-of-event check-ins, registration validation, on-site attendee lookup. |
| **Support Agent** | Internal | Standard User + `Event_Support_PSG` | Resolves attendee cases, processes cancellations, issues refunds, monitors support queue. |
| **Attendee / Customer** | External | Platform / Guest / App Page | Discovers events, views ticket pricing, submits registrations, processes payments, leaves feedback. |

## 3. Experience Layer Decision & Org License Compatibility
- **Experience Cloud Evaluation:** Experience Cloud (Digital Experiences) provides native Customer Communities. However, in many Trailhead Playgrounds and standard Developer Orgs, Experience Cloud digital experience domain setup or Customer Community licenses may be limited or unconfigured.
- **Architectural Fallback:** To ensure 100% compatibility across **ALL** Salesforce org types without assuming unavailable licenses, EPICEVENTZ provides a dual-access design:
  1. **Primary Experience:** Lightning App Pages with custom standalone LWCs (`epicEventDiscovery`, `epicTicketSelection`, `epicAttendeePortal`) accessible to external users via lightweight apps or guest pages.
  2. **Community Ready:** All LWCs are fully packaged and decoupled so they can be dropped into Experience Cloud Lightning Web App pages instantly if community licenses are present.
