//=========================================================================================
//      Date: 06/05/2016
// Developer: Laveen Kattela (LK)
//   Purpose: All Workplan_Type_Stage__c trigger events start here
//            It's purpose is to handle all Workplan_Type_Stage__c trigger events
//=========================================================================================
//                                 Update History
// Date       Developer              Description
//=========================================================================================
// 04/27/16  |  Laveen Kattela    | Initial Version  
//=========================================================================================


trigger WorkplanTypeStageTrigger on Workplan_Type_Stage__c(after delete, after insert, after undelete, after update, before delete, before insert, before update) {
new AIA_WorkplanTypeStageTriggerHandler().run();
}