//=========================================================================================
//      Date: 06/16/2016
// Developer: Sree Harsha Akkala
//   Purpose: All Contract trigger events start here
//            It's purpose is to handle all Contract trigger events
//=========================================================================================
//  Update History
// Date       Developer      Description
//=========================================================================================
// 05/10/16  |  HA    | Initial Version  
//=========================================================================================


trigger ContractTrigger on Contract (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
new AIA_ContractTriggerHandler().run();
}