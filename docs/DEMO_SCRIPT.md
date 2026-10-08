# EPICEVENTZ - Complete 22-Step Hackathon Demo Script

## 1. Executive Presentation Overview
This document provides the exact step-by-step live demonstration script, UI clicks, and judge talking points for the **Cognizant NPN Salesforce Hackathon 2027** evaluation of **EPICEVENTZ**.

---

## 2. Step-by-Step Demo Flow & Talking Points

| Step # | Persona | Target UI / App Page | Action Performed | Judge Talking Point |
| :--- | :--- | :--- | :--- | :--- |
| **1** | Organizer | `Venues` Tab | Creates `Grand Convention Center` (Capacity: 1,000). | *"We start on the B2B side where organizers register physical venues with fire-code capacity limits."* |
| **2** | Organizer | `Events` Tab | Creates `Cognizant Tech Summit 2027` in `Draft` status (Capacity: 500). | *"Event records start in Draft status, enforcing date validations declaratively."* |
| **3** | Organizer | Event Record Page | Adds `VIP Ticket` ($250, Qty: 100) & `General Admission` ($100, Qty: 400). | *"Our Roll-Up Capacity Engine validates that 500 total allocated tickets equals max event capacity."* |
| **4** | Organizer | Event Record Page | Clicks **Submit for Approval**. Status becomes `Pending Approval`. | *"Organizers cannot publish unvetted events. Clicking submit triggers native Salesforce Approval."* |
| **5** | System Admin| Items to Approve Widget| Admin reviews venue details and clicks **Approve**. | *"Record lock releases and status transitions to Approved with full audit history."* |
| **6** | Admin | Event Record Page | Changes Status to `Published`. | *"Publication gate validation rule verifies prior approval before public release."* |
| **7** | Attendee | `EpicEventz Portal` LWC | Discovers `Cognizant Tech Summit 2027` via live search. | *"Switching to the B2C Attendee Portal built with modern SLDS LWCs and reactive wire adapters."* |
| **8** | Attendee | `epicEventDiscovery` LWC| Clicks **Select Tickets** on event card. | *"Custom events pass selected event ID to our ticket checkout widget."* |
| **9** | Attendee | `epicTicketSelection` LWC| Selects 2 General Admission tickets ($200 total). | *"Dynamic total price calculator computes line items in real time."* |
| **10**| Attendee | `epicTicketSelection` LWC| Clicks **Complete Checkout**. Registration created (`Pending Payment`). | *"RegistrationService creates booking record after verifying seat inventory with FOR UPDATE row locks."* |
| **11**| System | Background Payment | `PaymentService.processMockPayment()` executes. | *"PCI-DSS compliant mock payment engine generates tokenized transaction IDs without storing card data."* |
| **12**| System | Record-Triggered Flow | `Payment_Status_Sync_Flow` updates Registration to `Confirmed` & `Paid`. | *"Flow automatically synchronizes payment success to registration status without custom code."* |
| **13**| System | Record-Triggered Flow | `Ticket_Inventory_Deduction_Flow` increments `Quantity_Sold__c`. | *"Flow decrements remaining ticket inventory from 400 down to 398 in real time."* |
| **14**| System | Notification Flow | `Registration_Confirmation_Notification_Flow` fires email. | *"Automated email action delivers digital ticket pass to attendee inbox."* |
| **15**| Event Staff | Registration Record | Staff changes status to `Checked-In` at venue entrance. | *"On-site event staff scan and update registration status during event entry."* |
| **16**| Organizer | Event Record Page | Event finishes; Status changes to `Completed`. | *"Event lifecycle reaches completion, opening feedback submission window."* |
| **17**| Attendee | `Feedback` Object | Attendee submits 5-star rating with comments: *"Amazing keynote!"*. | *"Feedback validation rule enforces 1-to-5 star bounds and event completion checks."* |
| **18**| System | Apex Trigger / Service | `FeedbackService` classifies Sentiment as `Positive`. | *"Apex Service layer analyzes comment text keywords and assigns positive sentiment."* |
| **19**| Organizer | `Organizer Dashboard` | Organizer views visual donut charts, revenue totals, & AI insights. | *"Executive dashboards aggregate total revenue, seats sold, and feedback ratings."* |
| **20**| Support Agent| `Cases` Tab | Agent views escalated `Payment Issue` Case (Auto-assigned `High` Priority).| *"Support Case Routing Flow automatically escalates payment tickets to High Priority."* |
| **21**| Partner | Postman / REST Client | Demonstrates `GET /services/apexrest/epiceventz/events`. | *"Custom Apex REST Web Service exposes JSON event catalog for mobile apps and partners."* |
| **22**| Admin | Developer Console | Demonstrates `RegistrationConfirmationQueueable` & `EventPerformanceBatch`.| *"Asynchronous Queueable and Batch Apex execute background receipts & LVD analytics."* |
