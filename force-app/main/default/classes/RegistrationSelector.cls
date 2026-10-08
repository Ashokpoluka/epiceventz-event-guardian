/**
 * @description Selector layer for Registration__c object providing SOQL encapsulation with USER_MODE security enforcement.
 * @group EpicEventz Selector Layer
 */
public with sharing class RegistrationSelector {

    public static List<Registration__c> getRegistrationsByIds(Set<Id> registrationIds) {
        if (registrationIds == null || registrationIds.isEmpty()) {
            return new List<Registration__c>();
        }
        return [
            SELECT Id, Name, Event__c, Attendee__c, Ticket_Type__c, Quantity__c, Status__c, Payment_Status__c 
            FROM Registration__c 
            WHERE Id IN :registrationIds 
            WITH USER_MODE
        ];
    }

    public static List<Registration__c> getConfirmedRegistrationsByEventId(Id eventId) {
        return [
            SELECT Id, Name, Attendee__c, Ticket_Type__c, Quantity__c, Status__c 
            FROM Registration__c 
            WHERE Event__c = :eventId AND Status__c = 'Confirmed' 
            WITH USER_MODE
        ];
    }
}
