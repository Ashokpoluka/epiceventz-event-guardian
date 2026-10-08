/**
 * @description Unit test suite for EventService methods & positive/negative scenarios.
 * @group EpicEventz Unit Testing
 */
@isTest
private class EventServiceTest {

    @isTest
    static void testGetAvailableEventsCatalog() {
        Venue__c v = TestDataFactory.createVenue('Grand Arena', 1000);
        Event__c evt = TestDataFactory.createEvent('Salesforce NPN Hackathon', v.Id, 500, 'Published');

        Test.startTest();
        List<Event__c> catalog = EventService.getAvailableEventsCatalog();
        Test.stopTest();

        System.assertNotEquals(0, catalog.size(), 'Catalog should return published events.');
        System.assertEquals('Salesforce NPN Hackathon', catalog[0].Name, 'Event name should match.');
    }

    @isTest
    static void testSubmitEventForApproval() {
        Venue__c v = TestDataFactory.createVenue('Convention Center', 500);
        Event__c evt = TestDataFactory.createEvent('Draft Tech Expo', v.Id, 300, 'Draft');

        Test.startTest();
        EventService.submitEventForApproval(evt.Id);
        Test.stopTest();

        Event__c updatedEvt = [SELECT Status__c FROM Event__c WHERE Id = :evt.Id];
        System.assertEquals('Pending Approval', updatedEvt.Status__c, 'Event status should transition to Pending Approval.');
    }
}
