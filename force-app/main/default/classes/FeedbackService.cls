/**
 * @description Service Layer for analyzing Feedback sentiment and updating Event rating metrics.
 * @group EpicEventz Service Layer
 */
public with sharing class FeedbackService {

    public static void classifySentimentAndProcess(List<Feedback__c> feedbacks) {
        if (feedbacks == null || feedbacks.isEmpty()) {
            return;
        }

        for (Feedback__c fb : feedbacks) {
            if (fb.Comments__c != null) {
                String lowerComments = fb.Comments__c.toLowerCase();
                if (lowerComments.contains('great') || lowerComments.contains('awesome') || lowerComments.contains('excellent') || lowerComments.contains('amazing') || lowerComments.contains('loved')) {
                    fb.Sentiment__c = 'Positive';
                } else if (lowerComments.contains('bad') || lowerComments.contains('poor') || lowerComments.contains('horrible') || lowerComments.contains('terrible') || lowerComments.contains('delay')) {
                    fb.Sentiment__c = 'Negative';
                } else {
                    fb.Sentiment__c = 'Neutral';
                }
            } else {
                fb.Sentiment__c = 'Neutral';
            }
        }
    }
}
