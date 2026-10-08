/**
 * @description Centralized Test Data Factory for generating test records across unit test classes.
 * @group EpicEventz Testing Framework
 */
@isTest
public class TestDataFactory {

    public static Venue__c createVenue(String name, Integer capacity) {
        Venue__c v = new Venue__c(
            Name = name,
            Capacity__c = capacity,
            Address__c = '100 Innovation Way, Tech Park',
            Active__c = true
        );
        insert v;
        return v;
    }

    public static Event__c createEvent(String name, Id venueId, Integer capacity, String status) {
        Event__c evt = new Event__c(
            Name = name,
            Venue__c = venueId,
            Capacity__c = capacity,
            Start_Date_Time__c = System.now().addDays(5),
            End_Date_Time__c = System.now().addDays(7),
            Registration_Close_Date__c = System.now().addDays(4),
            Status__c = status,
            Category__c = 'Conference'
        );
        insert evt;
        return evt;
    }

    public static Ticket_Type__c createTicketType(Id eventId, String name, Decimal price, Integer qty) {
        Ticket_Type__c tt = new Ticket_Type__c(
            Event__c = eventId,
            Name = name,
            Price__c = price,
            Quantity_Available__c = qty,
            Active__c = true
        );
        insert tt;
        return tt;
    }

    public static Contact createAttendee(String firstName, String lastName, String email) {
        Contact c = new Contact(
            FirstName = firstName,
            LastName = lastName,
            Email = email
        );
        insert c;
        return c;
    }
}
