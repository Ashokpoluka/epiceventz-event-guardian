# EPICEVENTZ - Ticket Management & Inventory Control Specification

## 1. Overview
The Ticket Management module controls ticket tier creation (VIP, General, Early Bird), pricing validation, inventory allocation, and sales windows. It ensures that organizers cannot over-allocate tickets beyond overall event capacity.

## 2. Validation & Inventory Rules

| Object | Rule Name | Condition | Error Message |
| :--- | :--- | :--- | :--- |
| `Ticket_Type__c` | `Ticket_Price_Non_Negative` | `Price__c < 0` | "Ticket Price must be greater than or equal to 0." |
| `Ticket_Type__c` | `Quantity_Available_Positive`| `Quantity_Available__c <= 0` | "Quantity Available must be strictly greater than 0." |
| `Ticket_Type__c` | `Sale_Start_Before_Sale_End` | `Sale_End_Date__c <= Sale_Start_Date__c` | "Ticket Sale End Date must be strictly after the Sale Start Date." |
| `Event__c` | `Ticket_Quantity_Exceeds_Capacity` | `Total_Ticket_Quantity__c > Capacity__c` | "Total allocated ticket quantity across all ticket types cannot exceed the Event Capacity." |

## 3. Dynamic Roll-Up & Capacity Guard Architecture

```
                                  [Event__c]
                     Capacity__c = 500 (Max Capacity)
                     Total_Ticket_Quantity__c = SUM(Ticket_Type__c.Quantity_Available__c)
                                       |
          +----------------------------+----------------------------+
          |                                                         |
          v                                                         v
 [Ticket_Type__c: General]                                 [Ticket_Type__c: VIP]
 Quantity_Available__c = 400                               Quantity_Available__c = 100
 Total Sum = 400 + 100 = 500  ===> VALID (Total_Ticket_Quantity__c <= Capacity__c)

 If Organizer attempts to add [Ticket_Type__c: Early Bird] with Quantity = 50:
 Total Sum becomes 550 > 500 ===> BLOCKED BY 'Ticket_Quantity_Exceeds_Capacity'
```
