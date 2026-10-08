/**
 * @description Enterprise Service Layer for Processing Payments & Mock Gateway Integrations.
 * @group EpicEventz Service Layer
 */
public with sharing class PaymentService {

    @AuraEnabled
    public static Payment__c processMockPayment(Id registrationId, Decimal amount, String paymentMethod) {
        if (registrationId == null || amount == null || amount <= 0) {
            throw new AuraHandledException('Valid registration ID and positive payment amount required.');
        }

        // Generate tokenized mock transaction ID (PCI-DSS compliant)
        String mockTxnId = 'TXN-MOCK-' + String.valueOf(System.currentTimeMillis());

        Payment__c payment = new Payment__c(
            Registration__c = registrationId,
            Amount__c = amount,
            Payment_Status__c = 'Success',
            Payment_Method__c = String.isBlank(paymentMethod) ? 'Mock Gateway' : paymentMethod,
            Transaction_Id__c = mockTxnId
        );

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, new List<Payment__c>{ payment });
        insert decision.getRecords();

        return (Payment__c) decision.getRecords()[0];
    }
}
