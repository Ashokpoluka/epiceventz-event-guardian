/**
 * @description Single Trigger per object for Feedback__c delegating to FeedbackTriggerHandler.
 * @group EpicEventz Apex Triggers
 */
trigger FeedbackTrigger on Feedback__c (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        FeedbackTriggerHandler.handleBeforeInsert(Trigger.new);
    }
}
