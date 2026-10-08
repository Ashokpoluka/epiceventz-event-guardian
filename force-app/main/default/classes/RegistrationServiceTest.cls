/**
 * @description Unit test suite for RegistrationService & TicketInventoryService methods.
 * @group EpicEventz Unit Testing
 */
@isTest
private class RegistrationServiceTest {

    @isTest
    static void testCreateAttendeeRegistrationPositive() {
        Venue__c v = TestDataFactory.createVenue('Tech Hub', 500);
        Event__c evt = TestDataFactory.createEvent('Dev Summit', v.Id, 200, 'Published');
        Ticket_Type__c tt = TestDataFactory.createTicketType(evt.Id, 'VIP Pass', 150.00, 50);
        Contact attendee = TestDataFactory.createAttendee('John', 'Doe', 'john@example.com');

        Test.startTest();
        Registration__c reg = RegistrationService.createAttendeeRegistration(evt.Id, tt.Id, attendee.Id, 2);
        Test.stopTest();

        System.assertNotEquals(null, reg.Id, 'Registration record should be created.');
        System.assertEquals('Pending Payment', reg.Status__c, 'Status should be Pending Payment.');
    }

    @isTest
    static void testRegistrationInventoryOverflowNegative() {
        Venue__c v = TestDataFactory.createVenue('Tech Hub', 500);
        Event__c evt = TestDataFactory.createEvent('Dev Summit', v.Id, 200, 'Published');
        Ticket_Type__c tt = TestDataFactory.createTicketType(evt.Id, 'Limited Pass', 100.00, 2);
        Contact attendee = TestDataFactory.createAttendee('Jane', 'Smith', 'jane@example.com');

        Boolean exceptionCaught = false;
        Test.startTest();
        try {
            RegistrationService.createAttendeeRegistration(evt.Id, tt.Id, attendee.Id, 5);
        } catch (Exception ex) {
            exceptionCaught = true;
        }
        Test.stopTest();

        System.assert(exceptionCaught, 'Exception should be thrown when requesting quantity greater than remaining inventory.');
    }
}
