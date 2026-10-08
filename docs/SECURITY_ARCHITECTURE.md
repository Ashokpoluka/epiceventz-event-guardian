# EPICEVENTZ - Security Architecture & Data Access Blueprint

## 1. Security Pyramid Strategy

```
                                  +-----------------------+
                                  |    RECORD SHARING     |
                                  | Sharing Rules, Manual |
                                  +-----------------------+
                                              |
                                  +-----------------------+
                                  |    ROLE HIERARCHY     |
                                  | Executives > Organizers|
                                  +-----------------------+
                                              |
                                  +-----------------------+
                                  | PERMISSION SET GROUPS |
                                  | Persona Access Grants |
                                  +-----------------------+
                                              |
                                  +-----------------------+
                                  | OBJECT & FLS ACCESS   |
                                  | Minimum Viable Access |
                                  +-----------------------+
                                              |
                                  +-----------------------+
                                  |  ORG-WIDE DEFAULTS    |
                                  | Private / Read-Only   |
                                  +-----------------------+
```

## 2. Org-Wide Defaults (OWD) Matrix

| Object API Name | Default Internal Access | Default External Access | Architectural Rationale |
| :--- | :--- | :--- | :--- |
| **Event__c** | Private | Public Read-Only | Internal users only see events they own or manage; external attendees can view published events. |
| **Venue__c** | Public Read-Only | Public Read-Only | Venues are shared resources; all organizers and attendees can view venue location details. |
| **Ticket_Type__c** | Controlled by Parent | Controlled by Parent | Inherits security from parent `Event__c`. |
| **Registration__c** | Controlled by Parent | Controlled by Parent | Inherits security from parent `Event__c`; attendee access restricted via Apex `WITH USER_MODE`. |
| **Payment__c** | Private | Private | Strict isolation. Attendees can only see their own payment receipts. |
| **Feedback__c** | Private | Private | Feedback is restricted to the event organizer and submitting attendee. |
| **Case** | Private | Private | Support cases are isolated to the assigned Support Agent and submitting Attendee. |

## 3. Role Hierarchy

```
                      [System Administrator / VP Operations]
                                        |
                                        v
                            [Event Operations Director]
                                        |
                   +--------------------+--------------------+
                   |                                         |
         [Lead Event Organizer]                    [Customer Support Manager]
                   |                                         |
         [Event Organizer / Staff]                 [Support Agent]
```

- **Inheritance Rule:** Users higher in the role hierarchy automatically inherit Read/Edit access to records owned by or shared with subordinates in custom objects where *Grant Access Using Hierarchies* is enabled.

## 4. Permission Set Matrix

| Object | Organizer PermSet | Event Staff PermSet | Support Agent PermSet | Attendee PermSet |
| :--- | :--- | :--- | :--- | :--- |
| **Event__c** | Read / Create / Edit / Delete | Read Only | Read Only | Read Only (Published) |
| **Venue__c** | Read / Create / Edit / Delete | Read Only | Read Only | Read Only |
| **Ticket_Type__c** | Read / Create / Edit / Delete | Read Only | Read Only | Read Only |
| **Registration__c** | Read / Edit | Read / Edit (Check-In) | Read / Edit (Cancel/Refund) | Read / Create (Own) |
| **Payment__c** | Read Only | No Access | Read Only | Read / Create (Own) |
| **Feedback__c** | Read Only | No Access | No Access | Read / Create (Own) |
| **Case** | No Access | No Access | Read / Create / Edit | Read / Create (Own) |

## 5. Field-Level Security (FLS) & Data Protection Rules
- **PCI-DSS Compliance Rule:** `Payment__c` NEVER stores credit card numbers, CVVs, expiration dates, or bank credentials. Only mock/tokenized `Transaction_Id__c` and status codes are retained.
- **Strict FLS Enforcement:** Fields like `Total_Revenue__c` and `Quantity_Sold__c` are hidden from Attendee profiles and restricted to Organizers/Admins.
- **Apex Security Enforcement:** All custom Apex controllers execute SOQL/DML using `WITH USER_MODE` or `Security.stripInaccessible()` to enforce FLS and OWD at runtime.
