/**
 * @description Enterprise Service Layer for Event Operations & Catalog Management.
 * @group EpicEventz Service Layer
 */
public with sharing class EventService {

    @AuraEnabled(cacheable=true)
    public static List<Event__c> getAvailableEventsCatalog() {
        try {
            return EventSelector.getPublishedEvents();
        } catch (Exception e) {
            throw new AuraHandledException('Unable to fetch events catalog: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Event__c getEventDetails(Id eventId) {
        if (eventId == null) {
            throw new AuraHandledException('Event ID cannot be null.');
        }
        return EventSelector.getEventDetailById(eventId);
    }

    @AuraEnabled
    public static void submitEventForApproval(Id eventId) {
        if (eventId == null) {
            throw new AuraHandledException('Event ID is required for approval submission.');
        }
        Event__c evt = [SELECT Id, Status__c, Start_Date_Time__c FROM Event__c WHERE Id = :eventId LIMIT 1];
        if (evt.Start_Date_Time__c != null && evt.Start_Date_Time__c < System.now()) {
            throw new AuraHandledException('Cannot submit past events for approval.');
        }
        evt.Status__c = 'Pending Approval';
        update evt;
    }
}
