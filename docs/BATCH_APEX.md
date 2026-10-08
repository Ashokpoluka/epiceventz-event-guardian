# EPICEVENTZ - Batch Apex Architecture Specification

## 1. Overview
The Batch Apex module (`EventPerformanceBatch`) processes large volumes of completed events asynchronously across small record chunks (default batch size: 200), calculating aggregate revenue, average attendee ratings, and attendance performance without hitting governor limits.

## 2. Why Batch Apex?

| Parameter | Standard Synchronous Apex | Batch Apex (`EventPerformanceBatch`) |
| :--- | :--- | :--- |
| **Max Records Processed** | 50,000 SOQL query limit | **50,000,000 Records** |
| **Execution Chunk Size** | 1 monolithic transaction | **Batched chunks (e.g. 200 records per chunk)** |
| **Governor Limit Reset** | Shared across entire operation | **Resets governor limits per chunk execution** |
| **State Retention** | N/A | **`Database.Stateful` tracks cumulative totals** |
| **Audit Logging** | Instant | **Logs execution summary in `finish()` method** |

## 3. Batch Execution Lifecycle

```
                             BATCH APEX LIFECYCLE

[System.database.executeBatch(new EventPerformanceBatch(), 200)]
                                       |
                                       v
[start() Method]
Queries all Event__c records with Status__c = 'Completed' or 'In Progress'
Returns Database.QueryLocator
                                       |
                                       v
[execute() Method - Chunk 1 (200 Records)]
  ├── Calculates Aggregate Revenue via Registration__c SOQL
  ├── Calculates Aggregate Average Rating via Feedback__c SOQL
  └── Updates Event__c records (Governor limits reset for next chunk)
                                       |
                                       v
[execute() Method - Chunk 2, 3... N]
                                       |
                                       v
[finish() Method]
Executes final audit summary insert into Integration_Log__c:
"Event Performance Batch Completed Successfully. Processed: 50 | Revenue: $125,000.00"
```
