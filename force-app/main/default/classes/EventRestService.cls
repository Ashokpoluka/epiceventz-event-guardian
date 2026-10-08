/**
 * @description Custom Apex REST API Web Service exposing GET & POST endpoints for external system event discovery and registration.
 * @group EpicEventz Integration Layer
 */
@RestResource(urlMapping='/epiceventz/events/*')
global with sharing class EventRestService {

    /**
     * @description GET endpoint returning published events or specific event details.
     * URI: /services/apexrest/epiceventz/events OR /services/apexrest/epiceventz/events/{eventId}
     */
    @HttpGet
    global static void getEvents() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        try {
            String requestURI = req.requestURI;
            String eventId = requestURI.substring(requestURI.lastIndexOf('/') + 1);

            if (String.isNotBlank(eventId) && eventId != 'events') {
                Event__c evt = EventSelector.getEventDetailById((Id) eventId);
                if (evt != null) {
                    res.statusCode = 200;
                    res.responseBody = Blob.valueOf(JSON.serialize(evt));
                } else {
                    res.statusCode = 404;
                    res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, String>{
                        'status' => 'error',
                        'message' => 'Event record not found for ID: ' + eventId
                    }));
                }
            } else {
                List<Event__c> events = EventSelector.getPublishedEvents();
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(events));
            }
        } catch (Exception ex) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, String>{
                'status' => 'error',
                'message' => 'Internal REST Error: ' + ex.getMessage()
            }));
        }
    }

    /**
     * @description POST endpoint for external registration creation.
     * Body: { "eventId": "a01...", "ticketTypeId": "a02...", "contactId": "003...", "quantity": 2 }
     */
    @HttpPost
    global static void createExternalRegistration() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        try {
            String body = req.requestBody.toString();
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(body);

            Id eventId = (Id) params.get('eventId');
            Id ticketTypeId = (Id) params.get('ticketTypeId');
            Id contactId = (Id) params.get('contactId');
            Integer quantity = Integer.valueOf(params.get('quantity'));

            Registration__c reg = RegistrationService.createAttendeeRegistration(eventId, ticketTypeId, contactId, quantity);

            // Audit log REST transaction
            Integration_Log__c log = new Integration_Log__c(
                Endpoint__c = req.requestURI,
                Status_Code__c = 200,
                Status__c = 'Success',
                Related_Record__c = String.valueOf(reg.Id),
                Error_Message__c = 'External REST Registration Successfully Created: ' + reg.Name
            );
            insert log;

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'status' => 'success',
                'message' => 'Registration successfully created via REST API.',
                'registrationId' => reg.Id
            }));

        } catch (Exception ex) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, String>{
                'status' => 'error',
                'message' => 'REST Registration Failed: ' + ex.getMessage()
            }));
        }
    }
}
