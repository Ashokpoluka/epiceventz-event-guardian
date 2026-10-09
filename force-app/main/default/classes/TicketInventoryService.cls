/**
 * @description Enterprise Service Layer for Ticket Inventory Locks & Capacity Calculations.
 * @group EpicEventz Service Layer
 */
public with sharing class TicketInventoryService {

    @AuraEnabled(cacheable=true)
    public static List<Ticket_Type__c> getTicketTypesForEvent(Id eventId) {
        if (eventId == null) {
            return new List<Ticket_Type__c>();
        }
        return [
            SELECT Id, Name, Price__c, Quantity_Available__c, Quantity_Sold__c, Remaining_Quantity__c, Active__c
            FROM Ticket_Type__c
            WHERE Event__c = :eventId AND Active__c = true
            ORDER BY Price__c ASC
        ];
    }

    public static Ticket_Type__c lockAndVerifyTicketInventory(Id ticketTypeId, Integer requestedQty) {
        if (ticketTypeId == null || requestedQty == null || requestedQty <= 0) {
            throw new IllegalArgumentException('Invalid ticket type or quantity.');
        }

        // Issue exclusive row lock to prevent race conditions during flash sales
        Ticket_Type__c ticket = [
            SELECT Id, Name, Quantity_Available__c, Quantity_Sold__c, Remaining_Quantity__c 
            FROM Ticket_Type__c 
            WHERE Id = :ticketTypeId 
            FOR UPDATE
        ];

        if (ticket.Remaining_Quantity__c < requestedQty) {
            throw new AuraHandledException('Requested ticket quantity (' + requestedQty + ') exceeds remaining inventory (' + ticket.Remaining_Quantity__c + ').');
        }
        return ticket;
    }
}
