# EPICEVENTZ - Payment & Revenue Management Specification

## 1. Overview
The Payment & Revenue Management module handles payment tracking, financial audit logging, and payment-to-registration status synchronization via a Record-Triggered Flow.

## 2. Validation & Flow Automation Rules

| Component | Target Object | Logic Condition | Action |
| :--- | :--- | :--- | :--- |
| `Payment_Amount_Positive` | `Payment__c` | `Amount__c <= 0` | Blocks transaction with error: "Payment Amount must be strictly greater than 0." |
| `Transaction_Id_Required_On_Success` | `Payment__c` | `Status = 'Success' && ISBLANK(Transaction_Id__c)` | Blocks transaction with error: "Transaction Id is required when Payment Status is Success." |
| `Payment_Status_Sync_Flow` | `Payment__c` | `Payment_Status__c = 'Success'` | Record-Triggered Flow updates parent `Registration__c.Status__c` to `'Confirmed'` and `Registration__c.Payment_Status__c` to `'Paid'`. |

## 3. PCI-DSS Security & Mock Payment Engine
- **Zero Credentials Policy:** `Payment__c` strictly stores non-sensitive transaction attributes: `Amount__c`, `Payment_Date__c`, `Payment_Status__c`, `Payment_Method__c`, and tokenized `Transaction_Id__c`.
- **Cardholder Security:** Credit card numbers, CVV codes, passwords, and banking PINs are **NEVER** persisted inside Salesforce.
- **Mock Payment Gateway:** The demo framework simulates external gateway response tokens (e.g. `TXN-MOCK-994812`).

## 4. Payment Synchronization Workflow

```
[Attendee Completes Mock Payment]
               |
               v
[Payment__c Record Inserted]
  ├── Amount__c: $150.00
  ├── Payment_Status__c: 'Success'
  └── Transaction_Id__c: 'TXN-MOCK-994812'
               |
               v
  [Validation Rules Evaluated] ---> PASS
               |
               v
[Payment_Status_Sync_Flow Triggers (After Save)]
               |
               v
[Parent Registration__c Updated]
  ├── Status__c = 'Confirmed'
  └── Payment_Status__c = 'Paid'
```
