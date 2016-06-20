//===================================================================================
//Date: 05/31/2016
//Developer: Sree Harsha Akkala
//Purpose: EventTrigger.
//=========================================================================================
// Update History
// Date         Developer               Description
//==================================================================================
//05/31/2016    Sree Harsha Akkala      Initial Development
//==================================================================================
trigger EventTrigger on event(after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    //Invokes the run method in the TriggerHandler class
      new AIA_EventTriggerHandler().run();
}