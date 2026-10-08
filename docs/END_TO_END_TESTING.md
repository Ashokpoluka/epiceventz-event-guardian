# EPICEVENTZ - End-to-End Testing Specification

## 1. Testing Framework Strategy
The End-to-End Testing suite verifies business logic, governor limits, data security, and validation rules without relying on hardcoded org data (`seeAllData=false`). Test records are generated dynamically via `TestDataFactory.cls`.

## 2. Unit Test Suite Portfolio

| Test Class Name | Target Service / Trigger | Scenarios Covered | Code Coverage Goal |
| :--- | :--- | :--- | :--- |
| `TestDataFactory.cls` | Framework Utility | Data creation methods for Venue, Event, Ticket, Contact | N/A (Utility) |
| `EventServiceTest.cls` | `EventService.cls` | Catalog retrieval, approval submission, past-date validation | > 85% |
| `RegistrationServiceTest.cls` | `RegistrationService.cls` | Positive booking, inventory overflow rejection, seat locking | > 85% |
| `PaymentServiceTest.cls` | `PaymentService.cls` | PCI-compliant mock payment processing & token generation | > 85% |
| `FeedbackServiceTest.cls` | `FeedbackService.cls` & `FeedbackTrigger` | Automatic positive, negative, and neutral sentiment classification | > 85% |

## 3. Test Execution Standard
- **Isolation:** `seeAllData=false` enforced on all test classes.
- **Context Delimitation:** `Test.startTest()` and `Test.stopTest()` used to isolate governor limit metrics.
- **Assertion Standard:** `System.assertEquals()` and `System.assertNotEquals()` enforce quantitative validation.
