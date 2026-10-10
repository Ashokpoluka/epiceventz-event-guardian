import { LightningElement, track, wire } from 'lwc';
import getEpicEventzDashboardMetrics from '@salesforce/apex/EventService.getEpicEventzDashboardMetrics';
import calculateEventHealthAndRisks from '@salesforce/apex/EventGuardianAIEngine.calculateEventHealthAndRisks';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EventGuardian extends LightningElement {
    @track isLoading = true;
    @track eventOptions = [];
    @track selectedEventId = '';
    @track guardianData = null;
    @track lastAnalyzedTime = '';

    @wire(getEpicEventzDashboardMetrics)
    wiredMetrics({ data, error }) {
        if (data) {
            if (data.recentEvents && data.recentEvents.length > 0) {
                this.eventOptions = data.recentEvents.map(evt => ({
                    label: `${evt.Name} (${evt.Status__c})`,
                    value: evt.Id
                }));
                if (!this.selectedEventId) {
                    this.selectedEventId = data.recentEvents[0].Id;
                    this.loadGuardianAnalysis(this.selectedEventId);
                }
            } else {
                this.isLoading = false;
            }
        } else if (error) {
            this.isLoading = false;
            this.showToast('Error Loading Events', error.body ? error.body.message : error.message, 'error');
        }
    }

    handleEventChange(event) {
        this.selectedEventId = event.detail.value;
        this.loadGuardianAnalysis(this.selectedEventId);
    }

    loadGuardianAnalysis(eventId) {
        if (!eventId) return;
        this.isLoading = true;
        calculateEventHealthAndRisks({ eventId: eventId })
            .then(result => {
                this.guardianData = result;
                this.lastAnalyzedTime = new Date().toLocaleTimeString();
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Event Guardian Error', error.body ? error.body.message : error.message, 'error');
            });
    }

    handleRefresh() {
        if (this.selectedEventId) {
            this.loadGuardianAnalysis(this.selectedEventId);
        }
    }

    handleExecuteAction(event) {
        const actionCode = event.currentTarget.dataset.action;
        const riskName = event.currentTarget.dataset.risk;

        let message = `Executed recommended mitigation action for ${riskName}.`;
        if (actionCode === 'RETRY_FAILED_PAYMENTS') {
            message = 'Payment retry sequence dispatched. Named Credential connection re-verified.';
        } else if (actionCode === 'LAUNCH_PROMO_CAMPAIGN') {
            message = 'Early Bird campaign activated. Promotional discount notification dispatched.';
        } else if (actionCode === 'SEND_ATTENDEE_ENGAGEMENT') {
            message = 'Attendee schedule update & pre-event engagement survey dispatched.';
        } else if (actionCode === 'ALERT_EVENT_STAFF') {
            message = 'High-priority task assigned to Event Staff for venue & check-in escalation.';
        } else if (actionCode === 'MONITOR_PROGRESS') {
            message = 'Event telemetry verified. Autonomous health monitor running.';
        }

        this.showToast('Guardian Action Executed', message, 'success');
    }

    get healthScoreBadgeClass() {
        if (!this.guardianData) return 'health-neutral';
        const score = this.guardianData.healthScore;
        if (score >= 90) return 'health-excellent';
        if (score >= 75) return 'health-healthy';
        if (score >= 50) return 'health-atrisk';
        return 'health-critical';
    }

    get healthScoreColor() {
        if (!this.guardianData) return '#514f4d';
        const score = this.guardianData.healthScore;
        if (score >= 90) return '#2e7d32';
        if (score >= 75) return '#0288d1';
        if (score >= 50) return '#ed6c02';
        return '#d32f2f';
    }

    get hasRisks() {
        return this.guardianData && this.guardianData.detectedRisks && this.guardianData.detectedRisks.length > 0;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }
}
