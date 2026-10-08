# EPICEVENTZ - Ticket Inventory & Registration Automation Specification

## 1. Overview
The Ticket Inventory & Registration Automation module enforces real-time overbooking prevention logic and updates ticket inventory counts automatically upon registration confirmation.

## 2. Inventory Protection & Automation Rules

| Component | Target Object | Logic Condition | Action |
| :--- | :--- | :--- | :--- |
| `Registration_Quantity_Exceeds_Inventory` | `Registration__c` | `Quantity__c > Ticket_Type__r.Remaining_Quantity__c` | Blocks registration with error: "Requested ticket quantity exceeds remaining available inventory for this ticket type." |
| `Ticket_Inventory_Deduction_Flow` | `Registration__c` | `Status = 'Confirmed' \|\| Payment_Status = 'Paid'` | Record-Triggered Flow increments `Ticket_Type__c.Quantity_Sold__c` by `Registration__c.Quantity__c`. |

## 3. High-Concurrency & Race-Condition Prevention Strategy
- **Declarative Baseline:** The `Registration_Quantity_Exceeds_Inventory` validation rule blocks overbooking requests immediately at transaction start.
- **Apex Row Locking (`FOR UPDATE`):** When thousands of attendees attempt to buy the last remaining tickets simultaneously during a high-demand flash sale, Apex controllers issue SOQL queries with `FOR UPDATE` on `Ticket_Type__c` records. This locks the database row until the current transaction commits or rolls back, completely eliminating race conditions.

## 4. Inventory Deduction Flowchart

```
[Attendee Requests 2 Tickets]
              |
              v
[Validation Rule Checks Inventory]
  Remaining_Quantity__c = 10
  Requested Quantity = 2
  2 <= 10 ===> PASS
              |
              v
[Registration Saved & Confirmed]
              |
              v
[Ticket_Inventory_Deduction_Flow Triggers]
              |
              v
[Ticket_Type__c Updated]
  Quantity_Sold__c = Previous (50) + Requested (2) = 52
  Remaining_Quantity__c = Available (60) - Sold (52) = 8
```
