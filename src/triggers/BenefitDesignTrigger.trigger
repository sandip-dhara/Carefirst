//=========================================================================================
//      Date: 05/31/2016
// Developer: Chidananda Nagaraj
//   Purpose: All AIA_Benefir Design trigger events start here
//            It's purpose is to handle all AIA_Implementation trigger events
//=========================================================================================
// Update History
// Date       Developer      Description
//=========================================================================================
// 05/31/16  |  GN    | Initial Version  
//=========================================================================================
trigger BenefitDesignTrigger on AIA_Benefit_Design__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
new AIA_BenefitDesignTriggerHandler().run();  

}