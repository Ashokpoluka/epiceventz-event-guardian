/**
 * @description Platform Event Trigger Subscriber listening to Registration_Event__e publish events.
 * @group EpicEventz Event-Driven Architecture
 */
trigger RegistrationEventTrigger on Registration_Event__e (after insert) {
    List<Integration_Log__c> eventLogs = new List<Integration_Log__c>();

    for (Registration_Event__e evt : Trigger.new) {
        Integration_Log__c log = new Integration_Log__c(
            Endpoint__c = '/eventbus/Registration_Event__e',
            Status_Code__c = 200,
            Status__c = 'Success',
            Related_Record__c = evt.Registration_Id__c,
            Error_Message__c = 'Platform Event Received via Event Bus! Registration ID: ' + evt.Registration_Id__c + ' | Attendee Email: ' + evt.Attendee_Email__c
        );
        eventLogs.add(log);
    }

    if (!eventLogs.isEmpty()) {
        insert eventLogs;
    }
}
