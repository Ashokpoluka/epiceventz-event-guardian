# EPICEVENTZ - Notifications & Communication Specification

## 1. Overview
The Notifications & Communication module delivers automated email and in-app bell notifications to Organizers and Attendees during key lifecycle events (Event Approval, Registration Confirmation, Event Cancellation).

## 2. Notification Rules & Flow Automation

| Flow Name | Target Object | Trigger Condition | Notification Type | Recipient |
| :--- | :--- | :--- | :--- | :--- |
| `Event_Approval_Notification_Flow` | `Event__c` | `Status__c = 'Approved'` | Automated Email & Bell Alert | Event Organizer (`Organizer__c`) |
| `Event_Approval_Notification_Flow` | `Event__c` | `Status__c = 'Cancelled'` | Emergency Email Alert | Registered Attendees (`Contact`) |
| `Registration_Confirmation_Notification_Flow` | `Registration__c` | `Status__c = 'Confirmed'` | Ticket Pass Confirmation Email | Registered Attendee (`Attendee__c`) |

## 3. Communication Workflow Diagram

```
[Event Status Changes to 'Approved']
                 |
                 v
[Event_Approval_Notification_Flow Triggers]
                 |
                 v
[Organizer Receives Email & In-App Bell Alert]
"Your event has been approved! You may now publish your event."

--------------------------------------------------------------

[Registration Status Changes to 'Confirmed']
                 |
                 v
[Registration_Confirmation_Notification_Flow Triggers]
                 |
                 v
[Attendee Receives Email Ticket Pass]
"Registration Confirmed - Present ticket pass at venue entrance."
```
