//=========================================================================================
//      Date: 04/27/2016
// Developer: Laveen Kattela (LK)
//   Purpose: All AIA_Workplan_Type_Task__c trigger events start here
//            It's purpose is to handle all AIA_Workplan_Type_Task__c trigger events
//=========================================================================================
//                                 Update History
// Date       Developer      Description
//=========================================================================================
// 04/27/16  |  LK    | Initial Version  
//=========================================================================================


trigger WorkplanTypeAssignmentTrigger on AIA_Workplan_Type_Task__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
new AIA_WorkplanTypeAssignmentTriggerHandler().run();
}