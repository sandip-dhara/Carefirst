/*=========================================================================================
 * Date     : 06/05/2016
 * Developer    : Laveen Kattela(LK)
 * Purpose      : This class is the extension point of the Trigger Framework for adding WorkplanTypeStage trigger handlers.
 *                
 *               
 *
 *=========================================================================================
 *                                 Update History
 *                                 ---------------
 * Date       Developer         Description
 *===========+============+================================================================
 * 04/27/16  |  LK    | Initial Version                                         
 *           |        | 
 *===========+============+================================================================
 */
 
/*@Author: Laveen Kattela
* @Purpose: This class is completly for AIA- workplan Type stage trigger framework
*This class invokes all the below functionalities: 
*To auto-populate the workplan type when user tries to create a sub process record on workplan stage 
*/
 
 
public with sharing class AIA_WorkplanTypeStageTriggerHandler extends TriggerHandler {

// constructor
public AIA_WorkplanTypeStageTriggerHandler () {}

// before inssert
protected override void beforeInsert() {  

    //Getting the sub process records of workplan type stage
    Schema.DescribeSObjectResult WPTSdSobjres = Schema.SObjectType.Workplan_Type_Stage__c; 
    Map<String,Schema.RecordTypeInfo> WPTSRecordType = WPTSdSobjres.getRecordTypeInfosByName(); 
    // Get Record Type for Sub-Process
    // TODO: Change this to use the API Name - Laveen to check
    Id SubProcesswptsRtid = WPTSRecordType.get('Sub-Process').getRecordTypeId();
    // Get Record Type for Process
    Id ProcesswptsRtid = WPTSRecordType.get('Process').getRecordTypeId();
    
    // Initialize list of workplan type
    List<Workplan_Type_Stage__c> WPTSlist = new list<Workplan_Type_Stage__c>();           //List of workplan Type stages 
    set<id> WPTid = new set<id>();                                                        // set for Workplan Type id's
    
    // Loop thru workplan stages
    For(Workplan_Type_Stage__c obj:(list<Workplan_Type_Stage__c>)Trigger.new ){
        // If the record type = subprocess, set the workplan type id
        if(obj.RecordTypeId == SubProcesswptsRtid){
            WPTSlist.add(obj);                                            //Checking if sub process record and addling it to list
            WPTid .add(obj.Workplan_Type__c); 
            system.debug('****WPTid ****'+WPTid );  
                                       
        }
        
    }
    
    
   
      
}

}