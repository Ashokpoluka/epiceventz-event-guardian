# EPICEVENTZ - Apex Trigger Architecture Specification

## 1. Enterprise Pattern Overview
The Apex Trigger Layer adheres strictly to Salesforce Separation of Concerns (SoC) principles. No SOQL, DML, or business logic exists inside trigger files.

```
                      APEX TRIGGER ARCHITECTURE PATTERN

+-----------------------------------------------------------------------------------+
|                             APEX TRIGGER ENGINE                                   |
|  - 1 Trigger per Object (e.g. `FeedbackTrigger.trigger`)                          |
|  - Zero Business Logic                                                            |
+-----------------------------------------------------------------------------------+
                                       |
                                       v
+-----------------------------------------------------------------------------------+
|                           TRIGGER HANDLER LAYER                                   |
|  - Extends `TriggerHandler` framework base class                                  |
|  - Enforces Static Re-entrancy & Recursion Guards                                 |
+-----------------------------------------------------------------------------------+
                                       |
                                       v
+-----------------------------------------------------------------------------------+
|                             SERVICE LAYER                                         |
|  - `FeedbackService.cls` (Sentiment analysis engine)                              |
|  - Bulkified processing (accepts `List<SObject>`)                                 |
+-----------------------------------------------------------------------------------+
                                       |
                                       v
+-----------------------------------------------------------------------------------+
|                             SELECTOR LAYER                                        |
|  - `RegistrationSelector.cls`, `EventSelector.cls`                                |
|  - Encapsulates SOQL queries enforcing `WITH USER_MODE`                           |
+-----------------------------------------------------------------------------------+
```

## 2. Best Practices Enforced
1. **One Trigger per Object:** Guaranteed single point of entry per SObject.
2. **Bulkification:** All methods process bulkified collections (`List<SObject>`, `Set<Id>`). Zero SOQL or DML inside loops.
3. **Recursion Protection:** Static `Set<String> reentrancyGuard` prevents infinite trigger loops.
4. **Security Enforcement:** All database selector calls execute with `WITH USER_MODE`.
