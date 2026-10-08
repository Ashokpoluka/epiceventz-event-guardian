# EPICEVENTZ - Event-Driven Architecture Specification

## 1. Overview
The Event-Driven Architecture module uses Salesforce Platform Events (`Registration_Event__e`) to decouple event publishers from event subscribers across an asynchronous event bus.

## 2. Why Platform Events over Direct Synchronous Calls?

| Parameter | Synchronous Direct Calls | Platform Events (`Registration_Event__e`) |
| :--- | :--- | :--- |
| **Coupling** | Tightly coupled dependency | **100% Decoupled Publisher/Subscriber** |
| **Multi-Subscriber**| Hardcoded method invocations | **Multiple Subscribers (Apex, Flow, Pub/Sub API)** |
| **Publish Behavior**| Fails transaction if downstream fails| **`PublishAfterCommit` (Transaction boundary safety)** |
| **External Integration**| Synchronous HTTP Callouts | **Streamed to external systems via Pub/Sub API** |

## 3. Event Bus Interaction Diagram

```
[Registration Confirmed / Created]
               |
               v
[EventBus.publish(new Registration_Event__e(...))]
               |
               v (Event Bus Stream)
   +-----------+-----------+
   |                       |
   v (Apex Subscriber)     v (External Pub/Sub API Subscriber)
[RegistrationEventTrigger] [External Analytics / SMS Engine]
   |
   v
[Inserts Integration_Log__c Audit Receipt]
```
