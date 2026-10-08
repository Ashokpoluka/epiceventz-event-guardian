# EPICEVENTZ - Attendee & Registration Management Specification

## 1. Overview
The Attendee & Registration Management module connects attendees (`Contact`) to events (`Event__c`) and selected ticket tiers (`Ticket_Type__c`). It governs registration lifecycle transitions, check-in processing, and status validations.

## 2. Registration Validation Rules

| Rule Name | Target Field | Condition | Error Message |
| :--- | :--- | :--- | :--- |
| `Registration_Quantity_Positive` | `Quantity__c` | `Quantity__c <= 0` | "Registration Ticket Quantity must be strictly greater than 0." |
| `Registration_Event_Status_Check` | Record Level | `Status != 'Published' && Status != 'Registration Open'` | "Registrations can only be submitted for Events in 'Published' or 'Registration Open' status." |
| `Prevent_Registration_Completed_Cancelled` | Record Level | `Status = 'Completed' \|\| Status = 'Cancelled'` | "Registrations cannot be created or modified for events that are Completed or Cancelled." |

## 3. Attendee Registration & Check-In Workflow

```
[Attendee Finds Event__c] (Status: 'Published' or 'Registration Open')
            |
            v
[Attendee Selects Ticket_Type__c & Quantity__c]
            |
            v
[System Evaluates Validation Rules]
  ├── Quantity__c > 0
  ├── Event Status is Published / Open
  └── Event is NOT Completed or Cancelled
            |
            v
[Registration__c Created (Status: 'Draft' / 'Pending Payment')]
            |
            v
[Payment Processed (Phase 7)] ---> Status becomes 'Confirmed'
            |
            v
[On-Site Event Staff Performs Check-In] ---> Status becomes 'Checked-In'
```
