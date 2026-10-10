/**
 * @description Enterprise Service Layer for Event Operations & Catalog Management.
 * @group EpicEventz Service Layer
 */
public with sharing class EventService {

    @AuraEnabled(cacheable=true)
    public static List<Event__c> getAvailableEventsCatalog() {
        try {
            return EventSelector.getPublishedEvents();
        } catch (Exception e) {
            throw new AuraHandledException('Unable to fetch events catalog: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Event__c getEventDetails(Id eventId) {
        if (eventId == null) {
            throw new AuraHandledException('Event ID cannot be null.');
        }
        return EventSelector.getEventDetailById(eventId);
    }

    @AuraEnabled
    public static void submitEventForApproval(Id eventId) {
        if (eventId == null) {
            throw new AuraHandledException('Event ID is required for approval submission.');
        }
        Event__c evt = [SELECT Id, Status__c, Start_Date_Time__c FROM Event__c WHERE Id = :eventId LIMIT 1];
        if (evt.Start_Date_Time__c != null && evt.Start_Date_Time__c < System.now()) {
            throw new AuraHandledException('Cannot submit past events for approval.');
        }
        evt.Status__c = 'Pending Approval';
        update evt;
    }

    /**
     * @description Computes comprehensive real-time dashboard metrics across all events, tickets,
     * registrations, revenue, feedback, and support cases.
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getEpicEventzDashboardMetrics() {
        Map<String, Object> metrics = new Map<String, Object>();

        // 1. Event Metrics
        List<Event__c> allEvents = [
            SELECT Id, Name, Status__c, Capacity__c, Registration_Count__c, Total_Revenue__c, Average_Rating__c, Start_Date_Time__c, Venue__r.Name 
            FROM Event__c 
            ORDER BY CreatedDate DESC 
            LIMIT 50
        ];

        Integer totalEvents = allEvents.size();
        Integer upcomingEvents = 0;
        Integer atRiskEvents = 0;

        for (Event__c evt : allEvents) {
            if (evt.Start_Date_Time__c != null && evt.Start_Date_Time__c >= System.now()) {
                upcomingEvents++;
            } else if (evt.Status__c == 'Published' || evt.Status__c == 'Registration Open') {
                upcomingEvents++;
            }

            if (evt.Status__c == 'Draft' || evt.Status__c == 'Pending Approval') {
                atRiskEvents++;
            }
        }

        // 2. Registration & Attendance Metrics
        List<Registration__c> allRegs = [
            SELECT Id, Name, Event__c, Event__r.Name, Attendee__r.Name, Quantity__c, Status__c, Payment_Status__c, CreatedDate 
            FROM Registration__c 
            ORDER BY CreatedDate DESC 
            LIMIT 100
        ];

        Integer totalRegistrations = allRegs.size();
        Integer ticketsSold = 0;
        Integer totalAttendance = 0;

        for (Registration__c reg : allRegs) {
            if (reg.Status__c != 'Cancelled' && reg.Quantity__c != null) {
                ticketsSold += Integer.valueOf(reg.Quantity__c);
            }
            if (reg.Status__c == 'Checked-In') {
                totalAttendance++;
            }
        }

        // 3. Payment Revenue
        Decimal totalRevenue = 0.00;
        List<Payment__c> successfulPayments = [
            SELECT Amount__c 
            FROM Payment__c 
            WHERE Payment_Status__c = 'Success'
        ];
        for (Payment__c p : successfulPayments) {
            if (p.Amount__c != null) {
                totalRevenue += p.Amount__c;
            }
        }

        // 4. Feedback Averages
        List<Feedback__c> allFeedback = [
            SELECT Rating__c 
            FROM Feedback__c
        ];
        Decimal sumRating = 0;
        for (Feedback__c fb : allFeedback) {
            if (fb.Rating__c != null) {
                sumRating += fb.Rating__c;
            }
        }
        Decimal avgFeedbackRating = allFeedback.isEmpty() ? 5.0 : (sumRating / allFeedback.size()).setScale(2);

        // 5. Open Support Cases
        Integer openSupportCases = [
            SELECT COUNT() 
            FROM Case 
            WHERE IsClosed = false
        ];

        metrics.put('totalEvents', totalEvents);
        metrics.put('upcomingEvents', upcomingEvents);
        metrics.put('totalRegistrations', totalRegistrations);
        metrics.put('ticketsSold', ticketsSold);
        metrics.put('totalRevenue', totalRevenue);
        metrics.put('totalAttendance', totalAttendance);
        metrics.put('averageFeedbackRating', avgFeedbackRating);
        metrics.put('openSupportCases', openSupportCases);
        metrics.put('atRiskEvents', atRiskEvents);
        metrics.put('recentEvents', allEvents);
        metrics.put('recentRegistrations', allRegs);

        return metrics;
    }
}
