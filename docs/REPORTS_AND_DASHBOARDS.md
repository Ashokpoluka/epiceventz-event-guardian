# EPICEVENTZ - Reports & Dashboards Specification

## 1. Overview
The Reports & Dashboards module turns transactional data across events, registrations, tickets, payments, feedback, and support cases into real-time executive metrics for Event Organizers and System Administrators.

## 2. Standard & Custom Reports Portfolio

| Report Name | Object Source | Report Type | Summary Grouping | Target Dashboard Component |
| :--- | :--- | :--- | :--- | :--- |
| **Events by Status** | `Event__c` | Summary | `Status__c` | Donut Chart (Active vs Completed Events) |
| **Revenue by Event** | `Event__c` | Summary | `Name` | Bar Chart (Financial Revenue Breakdown) |
| **Registrations by Event** | `Registration__c` | Summary | `Event__r.Name` | Bar Chart (Attendance Volume) |
| **Tickets Sold by Type** | `Ticket_Type__c` | Summary | `Name` | Pie Chart (Tier Distribution) |
| **Payment Status Distribution**| `Payment__c` | Summary | `Payment_Status__c` | Funnel Chart (Paid vs Pending vs Refunded) |
| **Feedback Rating Analysis** | `Feedback__c` | Matrix | `Event__r.Name` x `Rating__c` | Line Chart (Average Satisfaction Ratings) |
| **Open Support Cases** | `Case` | Summary | `Priority` | Gauge Chart (High Priority Support Tickets) |

## 3. Executive Dashboards

### 1. ORGANIZER DASHBOARD
- **Metrics:** Active Events, Registrations, Tickets Sold, Total Revenue, Avg Rating, Open Support Cases.
- **Visual Charts:** Donut Chart (`Events by Status`), Bar Chart (`Revenue by Event`), Gauge (`Attendance Rate`).

### 2. SYSTEM ADMIN DASHBOARD
- **Metrics:** Total Organizers, Active Events, Total Attendees, Total Platform Revenue, Failed Payments, Open Support Cases.
- **Visual Charts:** Funnel Chart (`Payment Status`), Bar Chart (`Platform Revenue by Organizer`), Gauge (`Open High-Priority Support Cases`).
