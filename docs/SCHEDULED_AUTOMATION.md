# EPICEVENTZ - Scheduled Automation Architecture Specification

## 1. Overview
The Scheduled Automation module (`EventReminderSchedulable`) provides hands-free daily background processing. It scans for events starting within 24 hours and triggers the nightly `EventPerformanceBatch` job on a CRON schedule.

## 2. CRON Expression & Scheduling Options

| Schedule | CRON Expression | Description |
| :--- | :--- | :--- |
| **Daily at Midnight** | `0 0 0 * * ?` | Runs every day at 12:00 AM midnight. |
| **Daily at 8:00 AM** | `0 0 8 * * ?` | Runs every morning at 8:00 AM for day-of event reminders. |

## 3. Scheduled Automation Flowchart

```
                            SCHEDULED APEX LIFECYCLE

[Salesforce CRON Engine Triggers EventReminderSchedulable at 00:00 AM]
                                       |
                                       v
[execute(SchedulableContext SC) Runs]
  ├── Queries events starting in next 24h WITH USER_MODE
  ├── Logs execution entry into Integration_Log__c
  └── Calls Database.executeBatch(new EventPerformanceBatch(), 200)
                                       |
                                       v
[EventPerformanceBatch Runs Asynchronously in Background]
```
