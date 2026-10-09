/**
 * @description Unit test suite for EventGuardianAIEngine health scoring & AI functions.
 * @group EpicEventz Testing Framework
 */
@isTest
private class EventGuardianAIEngineTest {

    @isTest
    static void testCalculateEventHealthAndRisks() {
        Venue__c v = TestDataFactory.createVenue('Tech Hub Arena', 1000);
        Event__c evt = TestDataFactory.createEvent('AI Tech Summit', v.Id, 500, 'Published');
        Ticket_Type__c tt = TestDataFactory.createTicketType(evt.Id, 'VIP Pass', 200, 100);
        Contact attendee = TestDataFactory.createAttendee('Alice', 'Smith', 'alice@example.com');

        Registration__c reg = RegistrationService.createAttendeeRegistration(evt.Id, tt.Id, attendee.Id, 2);

        Test.startTest();
        Map<String, Object> healthMap = EventGuardianAIEngine.calculateEventHealthAndRisks(evt.Id);
        Test.stopTest();

        System.assertNotEquals(null, healthMap, 'Health map should not be null.');
        System.assertEquals('AI Tech Summit', healthMap.get('eventName'), 'Event name should match.');
        System.assertNotEquals(null, healthMap.get('healthScore'), 'Health score should be populated.');
        System.assertNotEquals(null, healthMap.get('healthStatus'), 'Health status should be populated.');
    }

    @isTest
    static void testQueryEventAssistant() {
        Venue__c v = TestDataFactory.createVenue('Grand Arena', 1000);
        TestDataFactory.createEvent('Salesforce NPN Hackathon', v.Id, 500, 'Published');

        Test.startTest();
        Map<String, Object> discoveryRes = EventGuardianAIEngine.queryEventAssistant('recommend tech conference');
        Map<String, Object> ticketRes = EventGuardianAIEngine.queryEventAssistant('tell me about VIP tickets');
        Map<String, Object> generalRes = EventGuardianAIEngine.queryEventAssistant('hello assistant');
        Test.stopTest();

        System.assertEquals('EVENT_DISCOVERY', discoveryRes.get('intent'), 'Discovery intent should match.');
        System.assertEquals('TICKET_FAQ', ticketRes.get('intent'), 'Ticket FAQ intent should match.');
        System.assertEquals('GENERAL_ASSISTANCE', generalRes.get('intent'), 'General assistance intent should match.');
    }

    @isTest
    static void testSummarizeEventFeedbackAI() {
        Venue__c v = TestDataFactory.createVenue('Expo Center', 500);
        Event__c evt = TestDataFactory.createEvent('Developer Workshop', v.Id, 200, 'Completed');

        Feedback__c fb = new Feedback__c(
            Event__c = evt.Id,
            Rating__c = 5,
            Comments__c = 'Outstanding workshop!',
            Sentiment__c = 'Positive'
        );
        insert fb;

        Test.startTest();
        Map<String, Object> summaryMap = EventGuardianAIEngine.summarizeEventFeedbackAI(evt.Id);
        Test.stopTest();

        System.assertEquals(1, summaryMap.get('totalFeedbacks'), 'Should return 1 feedback count.');
        System.assertEquals(5.0, summaryMap.get('averageRating'), 'Average rating should be 5.0.');
    }
}
