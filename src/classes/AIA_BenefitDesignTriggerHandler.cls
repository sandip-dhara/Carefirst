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
 

public with sharing class AIA_BenefitDesignTriggerHandler extends TriggerHandler {

  protected override void beforeInsert() {
 //Chida - Added for creating the workplan stages on opp
   AIA_BenefitDesignApproversHelper bd = new AIA_BenefitDesignApproversHelper();
    
    bd.beforeinsert((List<AIA_Benefit_Design__c>) Trigger.new);
   //End 
 
 }
 protected override void beforeUpdate() {
 //Chida - Added for creating the workplan stages on opp
    AIA_BenefitDesignApproversHelper bd = new AIA_BenefitDesignApproversHelper();
    
    bd.beforeupdate((List<AIA_Benefit_Design__c>) Trigger.new);
   //End 
 
 }


}