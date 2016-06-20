/*=========================================================================================
 * Date     : 05/31/2016
 * Developer    : chidananda Nagaaj
  * Purpose      : This class is the extension point of the Trigger Framework for adding Implementation trigger handlers.
 *                
 *               
 *
 *=========================================================================================
 *                                 Update History
 *                                 ---------------
 * Date       Developer         Description
 *===========+============+================================================================
 * 05/31/16  |  GN   | Initial Version                                         
 *           |        | 
 *===========+============+================================================================
 */
 

public with sharing class AIA_ImplementationTriggerHandler extends TriggerHandler {

protected override void afterInsert() {
 //Chida - Added for creating the workplan stages on opp
            AIA_Workplan_Implementation wp = new AIA_Workplan_Implementation();
            wp.createWorkplanStages((List<AIA_Implementation__c>) Trigger.new);
    //End 
 
 }
 
 protected override void afterUpdate() {
 //Chida - Added for creating the workplan stages on opp
            AIA_Workplan_Implementation wp = new AIA_Workplan_Implementation();
            wp.createWorkplanStages((List<AIA_Implementation__c>) Trigger.new);
    //End 
 
 }
}