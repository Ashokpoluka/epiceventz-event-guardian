/**
 * @description Enterprise Service Layer for Attendee Booking & Registration Lifecycle Operations.
 * @group EpicEventz Service Layer
 */
public with sharing class RegistrationService {

    @AuraEnabled
    public static Registration__c createAttendeeRegistration(Id eventId, Id ticketTypeId, Id contactId, Integer quantity) {
        if (eventId == null || ticketTypeId == null || contactId == null || quantity == null || quantity <= 0) {
            throw new AuraHandledException('All registration parameters (Event, Ticket, Contact, Quantity > 0) are required.');
        }

        // Lock & verify inventory via TicketInventoryService
        TicketInventoryService.lockAndVerifyTicketInventory(ticketTypeId, quantity);

        // Fetch ticket price
        Ticket_Type__c ticket = [SELECT Price__c FROM Ticket_Type__c WHERE Id = :ticketTypeId WITH USER_MODE LIMIT 1];
        Decimal totalAmount = ticket.Price__c * quantity;

        Registration__c reg = new Registration__c(
            Event__c = eventId,
            Ticket_Type__c = ticketTypeId,
            Attendee__c = contactId,
            Quantity__c = quantity,
            Status__c = 'Pending Payment',
            Payment_Status__c = 'Unpaid'
        );

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, new List<Registration__c>{ reg });
        insert decision.getRecords();

        return (Registration__c) decision.getRecords()[0];
    }
}
