# EPICEVENTZ - Apex Service Layer Specification

## 1. Service Layer Overview
The Service Layer encapsulates all business operations of EpicEventz (`EventService`, `TicketInventoryService`, `RegistrationService`, `PaymentService`). Service methods are fully reusable by Apex Triggers, Flows, REST APIs, and Lightning Web Components (`@AuraEnabled`).

```
                      APEX SERVICE LAYER ARCHITECTURE

+-----------------------------------------------------------------------------------+
|                            CONSUMERS LAYER                                        |
|  - Lightning Web Components (`@AuraEnabled`)                                      |
|  - Custom REST API Endpoints                                                      |
|  - Async Queueables / Batch Jobs                                                  |
+-----------------------------------------------------------------------------------+
                                       |
                                       v
+-----------------------------------------------------------------------------------+
|                             SERVICE LAYER                                         |
|  - `EventService.cls`: Catalog fetching & approval submission                     |
|  - `TicketInventoryService.cls`: `FOR UPDATE` row locking & inventory verifier    |
|  - `RegistrationService.cls`: Attendee booking pipeline                           |
|  - `PaymentService.cls`: PCI-compliant mock payment processing                    |
+-----------------------------------------------------------------------------------+
                                       |
                                       v
+-----------------------------------------------------------------------------------+
|                        SECURITY & PERSISTENCE                                     |
|  - `Security.stripInaccessible(AccessType.CREATABLE/UPDATABLE)`                   |
|  - `WITH USER_MODE` query enforcement                                             |
+-----------------------------------------------------------------------------------+
```

## 2. Deployed Service Classes & Methods

| Class Name | Method Name | `@AuraEnabled` | Access Level | Description |
| :--- | :--- | :--- | :--- | :--- |
| `EventService` | `getAvailableEventsCatalog()` | Yes (Cacheable) | `with sharing` | Queries published events for public catalog. |
| `EventService` | `submitEventForApproval(eventId)`| Yes | `with sharing` | Submits event for administrative review. |
| `TicketInventoryService` | `getTicketTypesForEvent(eventId)` | Yes (Cacheable) | `with sharing` | Fetches active ticket tiers for an event. |
| `TicketInventoryService` | `lockAndVerifyTicketInventory(id, qty)` | No (Internal) | `with sharing` | Issues `FOR UPDATE` row lock & verifies inventory. |
| `RegistrationService` | `createAttendeeRegistration(...)` | Yes | `with sharing` | Creates registration record in `Pending Payment`. |
| `PaymentService` | `processMockPayment(regId, amount, method)` | Yes | `with sharing` | Generates tokenized transaction & creates Payment log. |
