/*****************************************************************************************************
*Date: 05/31/2016
*Developer: Spandhan Zangam 
*Purpose: AIA_Document
*=========================================================================================
* Update History
* Date         Developer               Description
*==================================================================================
*06-14-2016    Spandhan     Initial Development
*==================================================================================

*******************************************************************************************************/

trigger AIA_DocumentTrigger  on AIA_Document__c (before insert, before update) {
 
   AIA_DocumentTriggerHandler handler=new AIA_DocumentTriggerHandler();
   if(Trigger.isInsert)
   {
       handler.beforeInsert(Trigger.new);
   }
   
   if(Trigger.isUpdate)
   {
       handler.beforeUpdate(Trigger.new,Trigger.oldMap);
   }
}