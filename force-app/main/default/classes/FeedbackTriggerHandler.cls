/**
 * @description Trigger Handler for Feedback__c object adhering to Separation of Concerns.
 * @group EpicEventz Trigger Handlers
 */
public with sharing class FeedbackTriggerHandler extends TriggerHandler {

    public static void handleBeforeInsert(List<Feedback__c> newFeedbacks) {
        if (isFirstRun('FeedbackTriggerHandler_BeforeInsert')) {
            FeedbackService.classifySentimentAndProcess(newFeedbacks);
        }
    }
}
