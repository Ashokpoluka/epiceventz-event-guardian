import { LightningElement, api, wire, track } from 'lwc';
import getTicketTypesForEvent from '@salesforce/apex/TicketInventoryService.getTicketTypesForEvent';
import processMockPayment from '@salesforce/apex/PaymentService.processMockPayment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EpicTicketSelection extends LightningElement {
    @api eventId;
    @track ticketTypes;
    @track selectedTicketId;
    @track selectedPrice = 0;
    @track quantity = 1;
    @track isLoading = false;

    @wire(getTicketTypesForEvent, { eventId: '$eventId' })
    wiredTickets({ error, data }) {
        if (data) {
            this.ticketTypes = data;
        } else if (error) {
            this.ticketTypes = null;
        }
    }

    handleSelectTier(event) {
        this.selectedTicketId = event.target.dataset.id;
        this.selectedPrice = parseFloat(event.target.dataset.price);
    }

    get calculatedTotal() {
        return (this.selectedPrice * this.quantity).toFixed(2);
    }

    handleCheckout() {
        this.isLoading = true;
        // Mock checkout simulation
        setTimeout(() => {
            this.isLoading = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Checkout Successful!',
                message: 'Your ticket registration and payment have been confirmed.',
                variant: 'success'
            }));
        }, 1200);
    }
}
