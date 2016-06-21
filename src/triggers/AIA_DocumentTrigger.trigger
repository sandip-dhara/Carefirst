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
/**
 * 
 *
 * Trigger Handler for the AIA_Document SObject. This class implements the ITrigger
 * interface to help ensure the trigger code is bulkified and all in one place.
 */

trigger AIA_DocumentTrigger  on AIA_Document__c (before insert, before update) {
 
  
  // Get a handler appropriate to the object being processed
  
   AIA_DocumentTriggerHandler handler=new AIA_DocumentTriggerHandler();
 
  // Iterate through the records to be inserted passing them to the handler.
   
   if(Trigger.isInsert)
   {
       handler.beforeInsert(Trigger.new);
   }
   
 // Iterate through the records to be updated passing them to the handler.
 
   if(Trigger.isUpdate)
   {
       handler.beforeUpdate(Trigger.new,Trigger.oldMap);
   }
}