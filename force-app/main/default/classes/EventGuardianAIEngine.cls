/**
 * @description AI Service Layer providing intelligent event discovery, attendee support assistance, and feedback sentiment summarization.
 * @group EpicEventz AI & Agentforce Innovation Layer
 */
public with sharing class EventGuardianAIEngine {

    /**
     * @description AI Assistant endpoint for natural language event discovery & FAQ guidance.
     */
    @AuraEnabled
    public static Map<String, Object> queryEventAssistant(String userQuery) {
        if (String.isBlank(userQuery)) {
            throw new AuraHandledException('Query string cannot be empty.');
        }

        String lowerQuery = userQuery.toLowerCase();
        Map<String, Object> response = new Map<String, Object>();

        if (lowerQuery.contains('recommend') || lowerQuery.contains('find') || lowerQuery.contains('search') || lowerQuery.contains('conference')) {
            List<Event__c> events = EventSelector.getPublishedEvents();
            response.put('intent', 'EVENT_DISCOVERY');
            response.put('aiResponse', 'Based on your query, here are the top recommended upcoming events on EpicEventz:');
            response.put('data', events);
        } else if (lowerQuery.contains('ticket') || lowerQuery.contains('vip') || lowerQuery.contains('price')) {
            response.put('intent', 'TICKET_FAQ');
            response.put('aiResponse', 'EpicEventz offers multiple ticket tiers (General, Early Bird, VIP). VIP tickets include priority seating and exclusive lounge access.');
        } else {
            response.put('intent', 'GENERAL_ASSISTANCE');
            response.put('aiResponse', 'I am your EpicEventz AI Assistant! I can help you discover events, answer ticketing questions, or check your registration status.');
        }

        return response;
    }

    /**
     * @description Organizer AI endpoint for summarizing attendee feedback sentiment & generating optimization insights.
     */
    @AuraEnabled
    public static Map<String, Object> summarizeEventFeedbackAI(Id eventId) {
        if (eventId == null) {
            throw new AuraHandledException('Event ID is required for AI feedback analysis.');
        }

        List<Feedback__c> feedbacks = [
            SELECT Id, Rating__c, Comments__c, Sentiment__c 
            FROM Feedback__c 
            WHERE Event__c = :eventId 
            WITH USER_MODE
        ];

        Integer positiveCount = 0;
        Integer neutralCount = 0;
        Integer negativeCount = 0;
        Decimal totalRating = 0;

        for (Feedback__c fb : feedbacks) {
            totalRating += fb.Rating__c;
            if (fb.Sentiment__c == 'Positive') positiveCount++;
            else if (fb.Sentiment__c == 'Negative') negativeCount++;
            else neutralCount++;
        }

        Decimal avgRating = feedbacks.isEmpty() ? 0 : (totalRating / feedbacks.size()).setScale(2);

        String aiSummary = 'AI FEEDBACK INSIGHT SUMMARY:\n' +
                           '- Total Reviews Analyzed: ' + feedbacks.size() + '\n' +
                           '- Positive Sentiment: ' + positiveCount + ' (' + (feedbacks.isEmpty() ? 0 : (positiveCount*100/feedbacks.size())) + '%)\n' +
                           '- Negative Sentiment: ' + negativeCount + ' (' + (feedbacks.isEmpty() ? 0 : (negativeCount*100/feedbacks.size())) + '%)\n' +
                           '- Average Attendee Rating: ' + avgRating + ' / 5.0\n\n' +
                           'RECOMMENDED ACTIONABLE INSIGHTS:\n';

        if (negativeCount > positiveCount) {
            aiSummary += '⚠️ High negative sentiment detected. Inspect venue acoustics and check-in queue bottlenecks.';
        } else {
            aiSummary += '✅ Strong positive sentiment! Attendees praised session content and check-in speed.';
        }

        Map<String, Object> result = new Map<String, Object>{
            'totalFeedbacks' => feedbacks.size(),
            'averageRating' => avgRating,
            'positiveCount' => positiveCount,
            'negativeCount' => negativeCount,
            'aiSummaryText' => aiSummary
        };

        return result;
    }
}
