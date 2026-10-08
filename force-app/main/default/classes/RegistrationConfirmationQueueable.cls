/**
 * @description Queueable Apex job for processing asynchronous ticket receipts, confirmation logs, and audit entries.
 * @group EpicEventz Asynchronous Architecture
 */
public with sharing class RegistrationConfirmationQueueable implements Queueable, Database.AllowsCallouts {

    private Set<Id> registrationIds;

    public RegistrationConfirmationQueueable(Set<Id> regIds) {
        this.registrationIds = regIds;
    }

    public void execute(QueueableContext context) {
        if (registrationIds == null || registrationIds.isEmpty()) {
            return;
        }

        List<Integration_Log__c> logsToInsert = new List<Integration_Log__c>();

        try {
            List<Registration__c> registrations = [
                SELECT Id, Name, Event__r.Name, Attendee__r.Name, Attendee__r.Email, Ticket_Type__r.Name, Quantity__c, Status__c 
                FROM Registration__c 
                WHERE Id IN :registrationIds 
                WITH USER_MODE
            ];

            for (Registration__c reg : registrations) {
                // Generate asynchronous integration audit record for receipt confirmation
                Integration_Log__c log = new Integration_Log__c(
                    Endpoint__c = '/services/apexrest/epiceventz/confirmations',
                    Status_Code__c = 200,
                    Status__c = 'Success',
                    Related_Record__c = String.valueOf(reg.Id),
                    Error_Message__c = 'Asynchronous Ticket Confirmation & Audit Receipt Processed for Registration: ' + reg.Name + ' (Attendee: ' + reg.Attendee__r.Name + ')'
                );
                logsToInsert.add(log);
            }

            if (!logsToInsert.isEmpty()) {
                SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, logsToInsert);
                insert decision.getRecords();
            }

        } catch (Exception ex) {
            // Error handling & exception logging
            Integration_Log__c errorLog = new Integration_Log__c(
                Endpoint__c = '/services/apexrest/epiceventz/confirmations',
                Status_Code__c = 500,
                Status__c = 'Failed',
                Error_Message__c = 'Queueable Processing Error: ' + ex.getMessage() + '\n' + ex.getStackTraceString()
            );
            insert errorLog;
        }
    }
}
