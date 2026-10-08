# EPICEVENTZ - Event & Venue Management Specification

## 1. Overview
The Event & Venue Management module allows Event Organizers to register physical or virtual venues, create structured events, and enforce physical and temporal data validation rules before events can proceed through the approval lifecycle.

## 2. Validation Engine Rules

| Rule Name | Target Field | Logic Condition | Error Message |
| :--- | :--- | :--- | :--- |
| `End_Date_After_Start_Date` | `End_Date_Time__c` | `End_Date_Time__c <= Start_Date_Time__c` | "Event End Date & Time must be strictly after the Start Date & Time." |
| `Reg_Close_Before_Start_Date` | `Registration_Close_Date__c` | `Registration_Close_Date__c >= Start_Date_Time__c` | "Registration Close Date & Time must be before the Event Start Date & Time." |
| `Event_Capacity_Exceeds_Venue` | `Capacity__c` | `Capacity__c > Venue__r.Capacity__c` | "Event Capacity cannot exceed the maximum physical capacity of the assigned Venue." |

## 3. Venue & Event Lifecycle Workflow

```
[Organizer Creates Venue__c] (e.g., Grand Convention Center, Capacity: 1,000)
             |
             v
[Organizer Creates Event__c]
  ├── Sets Start: Oct 15, 2026 09:00 AM
  ├── Sets End: Oct 17, 2026 05:00 PM
  ├── Sets Reg Close: Oct 14, 2026 11:59 PM
  └── Sets Capacity: 800 (Validates: 800 <= 1,000)
             |
             v
[System Executes Declarative Validations] ---> PASS
             |
             v
[Event Saved in Draft Status]
```
