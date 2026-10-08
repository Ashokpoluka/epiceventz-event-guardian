/**
 * @description Selector layer for Event__c object providing SOQL encapsulation with USER_MODE security.
 * @group EpicEventz Selector Layer
 */
public with sharing class EventSelector {

    public static List<Event__c> getPublishedEvents() {
        return [
            SELECT Id, Name, Category__c, Start_Date_Time__c, End_Date_Time__c, Capacity__c, Registration_Count__c, Available_Seats__c, Status__c, Venue__c, Venue__r.Name
            FROM Event__c
            WHERE Status__c = 'Published' OR Status__c = 'Registration Open'
            WITH USER_MODE
            ORDER BY Start_Date_Time__c ASC
        ];
    }

    public static Event__c getEventDetailById(Id eventId) {
        List<Event__c> events = [
            SELECT Id, Name, Description__c, Category__c, Start_Date_Time__c, End_Date_Time__c, Capacity__c, Registration_Count__c, Available_Seats__c, Status__c, Venue__c, Venue__r.Name, Venue__r.Address__c
            FROM Event__c
            WHERE Id = :eventId
            WITH USER_MODE
            LIMIT 1
        ];
        return events.isEmpty() ? null : events[0];
    }
}
