# EPICEVENTZ - Event Approval & Lifecycle Automation Specification

## 1. Overview
The Event Approval & Lifecycle Automation module governs an event's state machine, enforcing administrative approval gates before an event can be published to external attendees.

## 2. Event Lifecycle State Machine

```
[Draft] ---> (Organizer Submits) ---> [Pending Approval]
                                             |
                   +-------------------------+-------------------------+
                   | (Admin Approves)                                  | (Admin Rejects)
                   v                                                   v
              [Approved]                                            [Draft]
                   |
                   v (Organizer/Admin Publishes)
              [Published]
                   |
                   v (Reg Window Opens)
         [Registration Open]
                   |
                   v (Reg Close Date Reached)
        [Registration Closed]
                   |
                   v (Event Date Reached)
             [In Progress]
                   |
                   v (Event Ends)
              [Completed]
```

## 3. Approval Actions & Validation Rules

| Component | Target Object | Logic Condition | Action |
| :--- | :--- | :--- | :--- |
| `Only_Approved_Events_Can_Publish` | `Event__c` | `Status = 'Published' && PriorStatus != 'Approved'` | Blocks publication with error: "Only Approved events can be Published to the public portal." |
| `Prevent_Past_Event_Approval_Submission` | `Event__c` | `Status = 'Pending Approval' && Start_Date_Time__c < NOW()` | Blocks submission with error: "Cannot submit an Event for approval if the Start Date & Time is in the past." |
| `Event_Approval_Process` | `Event__c` | Administrative Approval Flow | `Initial Submission` → Sets Status to `Pending Approval`. `Approval` → Sets Status to `Approved`. `Rejection` → Sets Status to `Draft`. |
