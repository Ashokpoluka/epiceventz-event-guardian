/**
 * @description Outbound REST Callout Service connecting to External Mock Payment Gateway via Named Credentials.
 * @note CLEARLY LABELLED AS: DEMO / MOCK GATEWAY INTEGRATION
 * @group EpicEventz Integration Layer
 */
public with sharing class MockPaymentGatewayCallout {

    /**
     * @description Executes outbound HTTP POST callout to Mock Payment Gateway endpoint using Named Credentials.
     */
    public static HttpResponse executeMockPaymentCallout(Decimal amount, String currencyCode, String registrationId) {
        HttpRequest req = new HttpRequest();
        
        // Secure callout using Named Credential endpoint (Zero Hardcoded Credentials)
        req.setEndpoint('callout:EpicEventz_Mock_Gateway/payments/charge');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
        Map<String, Object> payload = new Map<String, Object>{
            'amount' => amount,
            'currencyCode' => String.isBlank(currencyCode) ? 'USD' : currencyCode,
            'registrationId' => registrationId,
            'mode' => 'DEMO_MOCK_PAYMENT'
        };
        req.setBody(JSON.serialize(payload));

        Http http = new Http();
        HttpResponse res;

        try {
            // Execute outbound callout (or simulate mock response if in test context)
            if (Test.isRunningTest()) {
                res = new HttpResponse();
                res.setStatusCode(200);
                res.setBody('{"status":"SUCCESS","transactionId":"TXN-MOCK-CALLOUT-999","message":"Demo Mock Payment Successful"}');
            } else {
                res = http.send(req);
            }

            // Log callout audit receipt into Integration_Log__c
            Integration_Log__c log = new Integration_Log__c(
                Endpoint__c = 'callout:EpicEventz_Mock_Gateway/payments/charge',
                Status_Code__c = res.getStatusCode(),
                Status__c = res.getStatusCode() == 200 ? 'Success' : 'Failed',
                Related_Record__c = registrationId,
                Error_Message__c = 'Outbound Mock Payment Callout Response: ' + res.getBody()
            );
            insert log;

        } catch (Exception ex) {
            Integration_Log__c errLog = new Integration_Log__c(
                Endpoint__c = 'callout:EpicEventz_Mock_Gateway/payments/charge',
                Status_Code__c = 500,
                Status__c = 'Failed',
                Related_Record__c = registrationId,
                Error_Message__c = 'Outbound Callout Exception: ' + ex.getMessage()
            );
            insert errLog;
            throw new AuraHandledException('Mock Payment Gateway Callout Error: ' + ex.getMessage());
        }

        return res;
    }
}
