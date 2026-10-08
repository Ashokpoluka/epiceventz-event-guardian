import { LightningElement, wire, track } from 'lwc';
import getAvailableEventsCatalog from '@salesforce/apex/EventService.getAvailableEventsCatalog';

export default class EpicEventDiscovery extends LightningElement {
    @track events = [];
    @track searchTerm = '';
    @track isLoading = true;

    @wire(getAvailableEventsCatalog)
    wiredEvents({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.events = data.map(evt => ({
                ...evt,
                Venue_Name: evt.Venue__r ? evt.Venue__r.Name : 'TBD',
                FormattedStart: new Date(evt.Start_Date_Time__c).toLocaleString()
            }));
        } else if (error) {
            this.events = [];
        }
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value.toLowerCase();
    }

    get filteredEvents() {
        if (!this.searchTerm) {
            return this.events;
        }
        return this.events.filter(evt => 
            evt.Name.toLowerCase().includes(this.searchTerm) || 
            (evt.Category__c && evt.Category__c.toLowerCase().includes(this.searchTerm))
        );
    }

    get hasEvents() {
        return this.filteredEvents.length > 0;
    }

    handleSelectEvent(event) {
        const selectedId = event.target.dataset.id;
        const selectEvt = new CustomEvent('eventselect', { detail: { eventId: selectedId } });
        this.dispatchEvent(selectEvt);
    }
}
