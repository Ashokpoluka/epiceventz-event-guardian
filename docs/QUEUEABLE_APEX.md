# EPICEVENTZ - Queueable Apex Architecture Specification

## 1. Overview
The Queueable Apex module (`RegistrationConfirmationQueueable`) offloads post-checkout ticket confirmation generation, PDF receipt compiling, and external integration logging to an asynchronous background job thread.

## 2. Why Queueable Apex over Synchronous Apex / `@future`?

| Parameter | Synchronous Apex | `@future` Methods | Queueable Apex (EpicEventz) |
| :--- | :--- | :--- | :--- |
| **Execution Context** | Blocks UI checkout thread | Asynchronous background | Asynchronous background |
| **Heap Size Limit** | 6 MB | 12 MB | **12 MB** |
| **SOQL Query Limit** | 100 queries | 200 queries | **200 queries** |
| **Parameter Support** | Primitives & SObjects | Primitives ONLY | **Complex Objects & Collections (`Set<Id>`)** |
| **Job Chaining** | Not supported | Not supported | **Supported (`System.enqueueJob`)** |
| **Monitoring** | N/A | Limited | **Full Job ID Tracking (`AsyncApexJob`)** |

## 3. Queueable Execution Lifecycle

```
[Attendee Completes Checkout in LWC UI]
                   |
                   v
[RegistrationService Inserts Registration__c]
                   |
                   v
[System.enqueueJob(new RegistrationConfirmationQueueable(regIds))]
                   |
                   v (Synchronous checkout UI returns instantly)
[Background Apex Thread Picks Up Queueable Job]
                   |
                   v
[Fetches Registration & Attendee Data WITH USER_MODE]
                   |
                   v
[Generates Confirmation Receipts & Inserts Integration_Log__c Audit Record]
```
