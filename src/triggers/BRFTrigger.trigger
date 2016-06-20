//===================================================================================
//Date: 05/31/2016
//Developer: Sree Harsha Akkala
//Purpose: BRFTrigger.
//=========================================================================================
// Update History
// Date         Developer               Description
//==================================================================================
//05/31/2016    Sree Harsha Akkala      Initial Development
//==================================================================================
trigger BRFTrigger on Benfit_Request_Form__c(after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    //Invokes the run method in the TriggerHandler class
    new AIA_BRFTriggerHandler().run();
}