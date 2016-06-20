//=========================================================================================
//      Date:  05/10/2016
// Developer:  Laveen Kattela (LK)
//   Purpose:  All OpportunityTrigger  trigger events start here
//             It's purpose is to handle all Opportunity trigger events
//=========================================================================================
// Update History
// Date       Developer      Description
//=========================================================================================
// 05/10/16  |  LK    | Initial Version  
//=========================================================================================
trigger OpportunityTrigger on Opportunity(after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

    new OpportunityTriggerHandler().run();
}