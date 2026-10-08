# EPICEVENTZ - Data Model & Schema Specification

## 1. Entity Relationship Diagram (ERD)

```
                       +-------------------+
                       |      Account      |
                       +-------------------+
                                 | 1:N
                                 v
                       +-------------------+
                       |      Contact      |
                       +-------------------+
                                 | 1:N
                                 | (Attendee)
                                 v
+-------------------+  1:N   +-------------------+  1:N   +-------------------+
|     Venue__c      |<------ |      Event__c     |<------ | Ticket_Type__c    |
+-------------------+        +-------------------+        +-------------------+
                                 | 1:N                        | 1:N
                                 | (Master-Detail)            | (Lookup)
                                 v                            v
                             +------------------------------------+
                             |           Registration__c          |
                             +------------------------------------+
                                 | 1:N                        | 1:N
                                 v                            v
                             +-------------------+    +-------------------+
                             |     Payment__c    |    |    Feedback__c    |
                             +-------------------+    +-------------------+
```

## 2. Objects & Relationships Summary

| Object API Name | Type | Primary Parent | Relationship Type | Delete Behavior | Sharing Model |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Venue__c** | Custom | N/A | Standalone | N/A | ReadWrite |
| **Event__c** | Custom | Venue__c | Lookup | Set Null | Private |
| **Ticket_Type__c** | Custom | Event__c | Master-Detail | Cascade Delete | ControlledByParent |
| **Registration__c** | Custom | Event__c | Master-Detail | Cascade Delete | ControlledByParent |
| **Registration__c** | Custom | Contact | Lookup (Attendee) | Set Null | ControlledByParent |
| **Registration__c** | Custom | Ticket_Type__c | Lookup | Restricted | ControlledByParent |
| **Payment__c** | Custom | Registration__c | Lookup | Clear / Prevent | ReadWrite |
| **Feedback__c** | Custom | Event__c | Lookup | Clear | ReadWrite |
| **Integration_Log__c**| Custom | N/A | Audit Log | N/A | ReadWrite |
| **Case** | Standard| Account/Contact | Standard Lookup | Cascade | Private / ReadWrite |

## 3. Custom Field & Data Type Index

### `Event__c`
- `Name` (Text, 255) - Standard Event Title
- `Event_Code__c` (AutoNumber: `EVT-{0000}`)
- `Status__c` (Picklist: `Draft`, `Pending Approval`, `Approved`, `Published`, `Registration Open`, `Registration Closed`, `In Progress`, `Completed`, `Cancelled`)
- `Category__c` (Picklist: `Conference`, `Webinar`, `Workshop`, `Concert`, `Corporate`, `Exhibition`, `Other`)
- `Capacity__c` (Number, 18, 0)
- `Registration_Count__c` (Number, updated via triggers/rollups)
- `Available_Seats__c` (Formula Number: `Capacity__c - Registration_Count__c`)
- `Venue__c` (Lookup to `Venue__c`)

### `Ticket_Type__c`
- `Name` (Text, 255) - e.g., General Admission, VIP, Early Bird
- `Event__c` (Master-Detail to `Event__c`)
- `Price__c` (Currency, 18, 2)
- `Quantity_Available__c` (Number, 18, 0)
- `Quantity_Sold__c` (Number, 18, 0)
- `Remaining_Quantity__c` (Formula: `Quantity_Available__c - Quantity_Sold__c`)

### `Registration__c`
- `Name` (AutoNumber: `REG-{00000}`)
- `Event__c` (Master-Detail to `Event__c`)
- `Attendee__c` (Lookup to `Contact`)
- `Ticket_Type__c` (Lookup to `Ticket_Type__c`)
- `Quantity__c` (Number, default 1)
- `Status__c` (Picklist: `Draft`, `Pending Payment`, `Confirmed`, `Checked-In`, `Cancelled`)

### `Payment__c`
- `Name` (AutoNumber: `PAY-{00000}`)
- `Registration__c` (Lookup to `Registration__c`)
- `Amount__c` (Currency, 18, 2)
- `Payment_Status__c` (Picklist: `Pending`, `Success`, `Failed`, `Refunded`)

### `Feedback__c`
- `Name` (AutoNumber: `FBD-{00000}`)
- `Event__c` (Lookup to `Event__c`)
- `Rating__c` (Number, 1 to 5)
- `Comments__c` (Long Text Area)
- `Sentiment__c` (Picklist: `Positive`, `Neutral`, `Negative`)
