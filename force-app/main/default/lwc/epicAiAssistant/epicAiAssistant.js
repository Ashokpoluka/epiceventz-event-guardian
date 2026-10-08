import { LightningElement, track } from 'lwc';
import queryEventAssistant from '@salesforce/apex/EventGuardianAIEngine.queryEventAssistant';

export default class EpicAiAssistant extends LightningElement {
    @track queryText = '';
    @track aiResult;
    @track isLoading = false;

    handleQueryChange(event) {
        this.queryText = event.target.value;
    }

    handleAskAI() {
        if (!this.queryText) return;
        this.isLoading = true;
        queryEventAssistant({ userQuery: this.queryText })
            .then(result => {
                this.aiResult = result;
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                this.aiResult = { aiResponse: 'Error connecting to AI service: ' + error.body.message };
            });
    }
}
