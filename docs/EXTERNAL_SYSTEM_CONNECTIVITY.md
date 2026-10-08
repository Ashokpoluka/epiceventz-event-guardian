# EPICEVENTZ - External System Connectivity Specification

## 1. Overview
The External System Connectivity module (`MockPaymentGatewayCallout`) demonstrates outbound REST HTTP callout capabilities to external payment gateways or SMS notification providers. It adheres strictly to Salesforce security best practices by utilizing Named Credentials (`callout:EpicEventz_Mock_Gateway`) with zero hardcoded API keys or credentials inside Apex source code.

## 2. Integration Architecture & Security

```
                      OUTBOUND CALLOUT ARCHITECTURE

[Registration Checkout / Payment Trigger]
                   |
                   v
[MockPaymentGatewayCallout.executeMockPaymentCallout()]
                   |
                   v
[Salesforce Named Credential Layer: callout:EpicEventz_Mock_Gateway]
  ├── Secure Endpoint: https://api.epiceventz-mock-gateway.com/v1/payments/charge
  └── Managed Authentication (Zero API keys in Apex code)
                   |
                   v
[Outbound HTTP POST Sent to External Gateway] (LABELLED AS: DEMO / MOCK)
                   |
                   v
[JSON Response Received & Parsed]
  └── Status 200 OK -> Transaction ID: 'TXN-MOCK-CALLOUT-999'
                   |
                   v
[Audit Receipt Written to Integration_Log__c]
```

## 3. Security Principles Enforced
- **Zero Hardcoded Secrets:** Passwords, OAuth tokens, and API secret keys are **NEVER** embedded inside Apex strings or custom settings.
- **Named Credentials Management:** Authentication and endpoint URLs are managed declaratively in Salesforce Setup under Named Credentials.
- **Callout Audit Logging:** Every outbound callout captures endpoint URIs, status codes, and response payloads into `Integration_Log__c`.
- **Demo / Mock Labeling:** Explicitly labeled as a DEMO/MOCK integration framework.
