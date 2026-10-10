import { LightningElement, track, wire } from 'lwc';
import getEpicEventzDashboardMetrics from '@salesforce/apex/EventService.getEpicEventzDashboardMetrics';
import calculateEventHealthAndRisks from '@salesforce/apex/EventGuardianAIEngine.calculateEventHealthAndRisks';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EpicEventz extends LightningElement {
    @track isLoading = true;
    @track metrics = {
        totalEvents: 0,
        upcomingEvents: 0,
        totalRegistrations: 0,
        ticketsSold: 0,
        totalRevenue: 0.00,
        totalAttendance: 0,
        averageFeedbackRating: 5.0,
        openSupportCases: 0,
        atRiskEvents: 0,
        recentEvents: [],
        recentRegistrations: []
    };

    @track selectedEventId = '';
    @track eventOptions = [];
    @track guardianData = null;
    wiredMetricsResult;

    @wire(getEpicEventzDashboardMetrics)
    wiredMetrics(result) {
        this.wiredMetricsResult = result;
        const { data, error } = result;
        if (data) {
            this.metrics = data;
            this.isLoading = false;

            // Generate event options for Event Guardian dropdown
            if (data.recentEvents && data.recentEvents.length > 0) {
                this.eventOptions = data.recentEvents.map(evt => ({
                    label: evt.Name + ' (' + evt.Status__c + ')',
                    value: evt.Id
                }));

                // Auto-select first event
                if (!this.selectedEventId) {
                    this.selectedEventId = data.recentEvents[0].Id;
                    this.loadGuardianData(this.selectedEventId);
                }
            }
        } else if (error) {
            this.isLoading = false;
            this.showToast('Error Loading Metrics', error.body ? error.body.message : error.message, 'error');
        }
    }

    get formattedRevenue() {
        return Number(this.metrics.totalRevenue || 0).toLocaleString('en-US', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });
    }

    get healthClass() {
        if (!this.guardianData) return '';
        const score = this.guardianData.healthScore;
        if (score >= 90) return 'health-excellent';
        if (score >= 75) return 'health-healthy';
        if (score >= 50) return 'health-atrisk';
        return 'health-critical';
    }

    handleEventSelection(event) {
        this.selectedEventId = event.detail.value;
        this.loadGuardianData(this.selectedEventId);
    }

    runGuardianAnalysis() {
        if (this.selectedEventId) {
            this.loadGuardianData(this.selectedEventId);
        }
    }

    loadGuardianData(eventId) {
        if (!eventId) return;
        this.isLoading = true;
        calculateEventHealthAndRisks({ eventId: eventId })
            .then(result => {
                this.guardianData = result;
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Event Guardian Error', error.body ? error.body.message : error.message, 'error');
            });
    }

    handleRefresh() {
        this.isLoading = true;
        refreshApex(this.wiredMetricsResult).finally(() => {
            if (this.selectedEventId) {
                this.loadGuardianData(this.selectedEventId);
            } else {
                this.isLoading = false;
            }
        });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
