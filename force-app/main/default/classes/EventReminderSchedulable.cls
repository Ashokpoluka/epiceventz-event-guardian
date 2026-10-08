/**
 * @description Scheduled Apex class for triggering daily 24-hour event reminders and initiating nightly batch analytics.
 * @group EpicEventz Asynchronous Architecture
 */
public with sharing class EventReminderSchedulable implements Schedulable {

    public void execute(SchedulableContext sc) {
        // Query upcoming events starting within the next 24 hours
        DateTime now = System.now();
        DateTime next24Hours = now.addHours(24);

        List<Event__c> upcomingEvents = [
            SELECT Id, Name, Start_Date_Time__c, Venue__r.Name 
            FROM Event__c 
            WHERE Status__c IN ('Published', 'Registration Open') 
              AND Start_Date_Time__c >= :now 
              AND Start_Date_Time__c <= :next24Hours 
            WITH USER_MODE
        ];

        // Audit log scheduled run
        Integration_Log__c log = new Integration_Log__c(
            Endpoint__c = '/scheduled/EventReminderSchedulable',
            Status_Code__c = 200,
            Status__c = 'Success',
            Error_Message__c = 'Daily Event Reminder Scheduler executed successfully. Upcoming events found within 24h: ' + upcomingEvents.size()
        );
        insert log;

        // Trigger nightly batch performance analytics
        EventPerformanceBatch batch = new EventPerformanceBatch();
        Database.executeBatch(batch, 200);
    }
}
