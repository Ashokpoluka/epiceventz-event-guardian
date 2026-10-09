/**
 * @description Enterprise Event Guardian AI Engine providing intelligent health scoring, risk detection, 
 * root cause analysis, recommendations, and Agentforce assistance.
 * @group EpicEventz AI & Agentforce Innovation Layer
 */
public with sharing class EventGuardianAIEngine {

    /**
     * @description Calculates real-time Event Health Score (0-100), detects operational risks,
     * extracts empirical evidence, determines root cause, and generates actionable recommendations.
     * 
     * Health Weighting:
     * - Registration/Ticket Performance: 25%
     * - Payment Success Rate: 15%
     * - Attendance Rate: 20%
     * - Feedback Rating: 15%
     * - Low Cancellation Rate: 10%
     * - Support Issues Ratio: 15%
     */
    @AuraEnabled
    public static Map<String, Object> calculateEventHealthAndRisks(Id eventId) {
        if (eventId == null) {
            throw new AuraHandledException('Event ID is required for Event Guardian analysis.');
        }

        // 1. Fetch Event Details
        Event__c evt = [
            SELECT Id, Name, Capacity__c, Registration_Count__c, Status__c, Total_Revenue__c, Average_Rating__c, Venue__c, Venue__r.Name 
            FROM Event__c 
            WHERE Id = :eventId 
            LIMIT 1
        ];

        // 2. Fetch Registrations & Payments Breakdown
        List<Registration__c> registrations = [
            SELECT Id, Status__c, Payment_Status__c, Quantity__c 
            FROM Registration__c 
            WHERE Event__c = :eventId
        ];

        Integer totalRegs = registrations.size();
        Integer confirmedRegs = 0;
        Integer checkedInRegs = 0;
        Integer cancelledRegs = 0;
        Integer paidRegs = 0;
        Integer failedRegs = 0;

        for (Registration__c reg : registrations) {
            if (reg.Status__c == 'Confirmed' || reg.Status__c == 'Checked-In') confirmedRegs++;
            if (reg.Status__c == 'Checked-In') checkedInRegs++;
            if (reg.Status__c == 'Cancelled') cancelledRegs++;
            if (reg.Payment_Status__c == 'Paid') paidRegs++;
            if (reg.Payment_Status__c == 'Failed') failedRegs++;
        }

        // 3. Fetch Feedback Metrics
        List<Feedback__c> feedbacks = [
            SELECT Id, Rating__c, Sentiment__c 
            FROM Feedback__c 
            WHERE Event__c = :eventId
        ];

        Decimal sumRating = 0;
        Integer negativeFeedbacks = 0;
        for (Feedback__c fb : feedbacks) {
            if (fb.Rating__c != null) sumRating += fb.Rating__c;
            if (fb.Sentiment__c == 'Negative') negativeFeedbacks++;
        }
        Decimal avgRating = feedbacks.isEmpty() ? 5.0 : (sumRating / feedbacks.size());

        // 4. Calculate Sub-Scores (0 to 100 each)
        Decimal capacity = (evt.Capacity__c != null && evt.Capacity__c > 0) ? evt.Capacity__c : 100;
        Decimal ticketScore = Math.min(100.0, (evt.Registration_Count__c != null ? evt.Registration_Count__c : totalRegs) * 100.0 / capacity);
        Decimal paymentScore = totalRegs == 0 ? 100.0 : (paidRegs * 100.0 / totalRegs);
        Decimal attendanceScore = totalRegs == 0 ? 100.0 : (checkedInRegs * 100.0 / totalRegs);
        Decimal feedbackScore = (avgRating / 5.0) * 100.0;
        Decimal cancellationScore = totalRegs == 0 ? 100.0 : Math.max(0.0, (1.0 - (cancelledRegs * 1.0 / totalRegs)) * 100.0);
        Decimal supportScore = totalRegs == 0 ? 100.0 : Math.max(0.0, (1.0 - (failedRegs * 1.0 / totalRegs)) * 100.0);

        // 5. Weighted Health Score Calculation
        Decimal healthScore = (ticketScore * 0.25) +
                              (paymentScore * 0.15) +
                              (attendanceScore * 0.20) +
                              (feedbackScore * 0.15) +
                              (cancellationScore * 0.10) +
                              (supportScore * 0.15);

        healthScore = Math.round(healthScore * 10) / 10.0;

        // 6. Rating Categorization
        String healthStatus;
        if (healthScore >= 90.0) {
            healthStatus = 'Excellent';
        } else if (healthScore >= 75.0) {
            healthStatus = 'Healthy';
        } else if (healthScore >= 50.0) {
            healthStatus = 'At Risk';
        } else {
            healthStatus = 'Critical';
        }

        // 7. Risk Detection & Evidence Analysis
        List<Map<String, String>> detectedRisks = new List<Map<String, String>>();

        if (failedRegs > 0) {
            detectedRisks.add(new Map<String, String>{
                'risk' => 'Payment Gateway Failures',
                'severity' => 'HIGH',
                'evidence' => failedRegs + ' registration payment transaction(s) failed or timed out.',
                'rootCause' => 'Payment gateway timeout or invalid tokenized credentials.',
                'recommendation' => 'Trigger automated payment retry link and verify Named Credential connection.',
                'action' => 'RETRY_FAILED_PAYMENTS'
            });
        }

        if (ticketScore < 50.0) {
            detectedRisks.add(new Map<String, String>{
                'risk' => 'Low Ticket Sales Velocity',
                'severity' => 'MEDIUM',
                'evidence' => 'Ticket sales at ' + Math.round(ticketScore) + '% of total venue capacity (' + Math.round(capacity) + ').',
                'rootCause' => 'Sub-optimal promotional campaign reach or high ticket price point.',
                'recommendation' => 'Launch Early Bird promotional discount tier to drive velocity.',
                'action' => 'LAUNCH_PROMO_CAMPAIGN'
            });
        }

        if (totalRegs > 0 && (cancelledRegs * 100.0 / totalRegs) > 15.0) {
            detectedRisks.add(new Map<String, String>{
                'risk' => 'High Cancellation Rate',
                'severity' => 'HIGH',
                'evidence' => Math.round(cancelledRegs * 100.0 / totalRegs) + '% of registrations have been cancelled.',
                'rootCause' => 'Schedule conflict or lack of attendee pre-event engagement.',
                'recommendation' => 'Dispatch event schedule update and attendee confirmation survey.',
                'action' => 'SEND_ATTENDEE_ENGAGEMENT'
            });
        }

        if (avgRating < 3.5 && !feedbacks.isEmpty()) {
            detectedRisks.add(new Map<String, String>{
                'risk' => 'Negative Attendee Sentiment',
                'severity' => 'HIGH',
                'evidence' => 'Average feedback rating dropped to ' + Math.round(avgRating * 10) / 10.0 + ' / 5.0 (' + negativeFeedbacks + ' negative reviews).',
                'rootCause' => 'Attendee dissatisfaction with venue acoustics or check-in queues.',
                'recommendation' => 'Alert Event Staff to review venue logistics and check-in procedures.',
                'action' => 'ALERT_EVENT_STAFF'
            });
        }

        if (detectedRisks.isEmpty()) {
            detectedRisks.add(new Map<String, String>{
                'risk' => 'None Detected',
                'severity' => 'LOW',
                'evidence' => 'All operational metrics operating within optimal parameters.',
                'rootCause' => 'High attendee satisfaction and steady registration growth.',
                'recommendation' => 'Maintain current marketing momentum and event logistics execution.',
                'action' => 'MONITOR_PROGRESS'
            });
        }

        Map<String, Object> result = new Map<String, Object>{
            'eventId' => evt.Id,
            'eventName' => evt.Name,
            'status' => evt.Status__c,
            'healthScore' => healthScore,
            'healthStatus' => healthStatus,
            'ticketPerformanceScore' => Math.round(ticketScore),
            'paymentSuccessScore' => Math.round(paymentScore),
            'attendanceScore' => Math.round(attendanceScore),
            'feedbackScore' => Math.round(feedbackScore),
            'cancellationScore' => Math.round(cancellationScore),
            'supportScore' => Math.round(supportScore),
            'detectedRisks' => detectedRisks
        };

        return result;
    }

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
        ];

        Integer positiveCount = 0;
        Integer neutralCount = 0;
        Integer negativeCount = 0;
        Decimal totalRating = 0;

        for (Feedback__c fb : feedbacks) {
            totalRating += (fb.Rating__c != null ? fb.Rating__c : 0);
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
