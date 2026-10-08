# EPICEVENTZ - Lightning Web Components (LWC) Specification

## 1. Overview
The LWC Experience Layer provides modern, responsive UI portals built with Salesforce Lightning Design System (SLDS) styling for both B2C Attendees (Event Discovery & Checkout) and B2B Organizers (Performance Dashboard).

## 2. Component Portfolio

| Component Name | Target User | Target Location | Description |
| :--- | :--- | :--- | :--- |
| `epicEventDiscovery` | External Attendee | App Page / Portal | Real-time event catalog, category badges, seat indicators, and live search. |
| `epicTicketSelection` | External Attendee | Event Record Page | Interactive ticket tier selection, dynamic total calculation, and mock checkout. |
| `epicOrganizerDashboard`| Internal Organizer | Home / Console Page | Visual metrics cards displaying total events, revenue, seats sold, and average rating. |

## 3. UI/UX Features
- **SLDS Tokens:** Clean grid layouts (`slds-grid`), cards (`lightning-card`), badges (`slds-badge`), and buttons (`lightning-button`).
- **Loading & Empty States:** `lightning-spinner` during Apex wire transfers; empty state illustrations when queries return 0 events.
- **Wire Adapters:** Reactive `@wire` bindings to `EventService.getAvailableEventsCatalog` and `TicketInventoryService.getTicketTypesForEvent`.
