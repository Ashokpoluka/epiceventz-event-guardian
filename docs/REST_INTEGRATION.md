# EPICEVENTZ - REST Integration Specification

## 1. Overview
The Custom Apex REST Integration layer (`EventRestService`) exposes lightweight RESTful web service endpoints allowing external partners, ticketing portals, and mobile apps to discover events and submit registrations securely.

## 2. API Endpoint Reference

### Endpoint 1: GET Event Catalog / Event Details
- **URI:** `GET /services/apexrest/epiceventz/events` OR `GET /services/apexrest/epiceventz/events/{eventId}`
- **Headers:** `Authorization: Bearer <OAuth_Token>`, `Content-Type: application/json`
- **Response 200 OK Example:**
```json
[
  {
    "Id": "a01...01",
    "Name": "Cognizant Salesforce NPN Hackathon 2027",
    "Category__c": "Conference",
    "Available_Seats__c": 850,
    "Status__c": "Published"
  }
]
```

### Endpoint 2: POST Create External Registration
- **URI:** `POST /services/apexrest/epiceventz/events`
- **Request Body Example:**
```json
{
  "eventId": "a01...01",
  "ticketTypeId": "a02...01",
  "contactId": "003...01",
  "quantity": 2
}
```
- **Response 200 OK Example:**
```json
{
  "status": "success",
  "message": "Registration successfully created via REST API.",
  "registrationId": "a03...01"
}
```

## 3. Security & Exception Handling
- **Authentication:** Standard OAuth 2.0 (Web Server / JWT Bearer flow).
- **HTTP Status Codes:** `200 OK`, `400 Bad Request` (Validation Failure), `404 Not Found`, `500 Internal Server Error`.
- **System Audit Logging:** All successful and failed REST calls create an `Integration_Log__c` record.
