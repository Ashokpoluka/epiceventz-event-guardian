/**
 * @description Batch Apex job for calculating performance metrics, total revenue, and average ratings across completed events.
 * @group EpicEventz Asynchronous Architecture
 */
public with sharing class EventPerformanceBatch implements Database.Batchable<sObject>, Database.Stateful {

    public Integer totalEventsProcessed = 0;
    public Decimal totalRevenueCalculated = 0.00;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, Capacity__c, Registration_Count__c, Total_Revenue__c, Average_Rating__c, Status__c 
            FROM Event__c 
            WHERE Status__c = 'Completed' OR Status__c = 'In Progress'
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Event__c> scope) {
        if (scope == null || scope.isEmpty()) {
            return;
        }

        List<Event__c> eventsToUpdate = new List<Event__c>();
        Set<Id> eventIds = new Map<Id, Event__c>(scope).keySet();

        // Aggregate revenue per event from confirmed registrations
        Map<Id, Decimal> revenueMap = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT Event__c evtId, SUM(Amount__c) totalAmount 
            FROM Registration__c 
            WHERE Event__c IN :eventIds AND Status__c = 'Confirmed' 
            WITH USER_MODE 
            GROUP BY Event__c
        ]) {
            revenueMap.put((Id) ar.get('evtId'), (Decimal) ar.get('totalAmount'));
        }

        // Aggregate average rating per event from feedback
        Map<Id, Decimal> ratingMap = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT Event__c evtId, AVG(Rating__c) avgRating 
            FROM Feedback__c 
            WHERE Event__c IN :eventIds 
            WITH USER_MODE 
            GROUP BY Event__c
        ]) {
            ratingMap.put((Id) ar.get('evtId'), (Decimal) ar.get('avgRating'));
        }

        for (Event__c evt : scope) {
            Decimal rev = revenueMap.containsKey(evt.Id) ? revenueMap.get(evt.Id) : 0.00;
            Decimal rating = ratingMap.containsKey(evt.Id) ? ratingMap.get(evt.Id) : 0.00;

            evt.Total_Revenue__c = rev;
            evt.Average_Rating__c = rating;
            eventsToUpdate.add(evt);

            totalEventsProcessed++;
            totalRevenueCalculated += rev;
        }

        if (!eventsToUpdate.isEmpty()) {
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, eventsToUpdate);
            update decision.getRecords();
        }
    }

    public void finish(Database.BatchableContext bc) {
        // Log Batch Execution Summary into Integration_Log__c
        Integration_Log__c summaryLog = new Integration_Log__c(
            Endpoint__c = '/batch/EventPerformanceBatch',
            Status_Code__c = 200,
            Status__c = 'Success',
            Error_Message__c = 'Event Performance Batch Completed Successfully. Total Events Processed: ' + totalEventsProcessed + ' | Total Revenue Aggregated: $' + totalRevenueCalculated
        );
        insert summaryLog;
    }
}
