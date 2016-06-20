/*=========================================================================================
 * Date     : 06/05/2016
 * Developer    : Laveen Kattela(LK)
 * Purpose      : This class is the extension point of the Trigger Framework for adding WorkplanStage trigger handlers.
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
* @Purpose: This class is completly for AIA- workplan stage trigger framework
*This class invokes all the below functionalities: 
*To auto-populate the workplan type when user tries to create a sub process record on workplan stage
*Update the total and completed Task count -when user deletes the sub-process record of workplan stage on opportunity
*creating the WorkplanAssignments when workplan stage.status is updated to In progress
*Updating the parent WorkplanStageStatusToInProgress
*Updating the parent WorkplanStageStatusToCompleted  
*Updation on Counts the total task it as and no of tasks completed for that workplan stages 
*/
 
 
public with sharing class AIA_WorkplanStageTriggerHandler extends TriggerHandler {

public AIA_WorkplanStageTriggerHandler () {}

protected override void beforeUpdate() {  
      
}

/*This method invokes when user deletes the sub-process record of workplan stage on opportunity
* To which It updates the calulated Total no of records & no of completed records
* Output - Updates the No of total tasks and completed tasks
*/
protected override void afterDelete(){
    
    //Getting the sub process records of workplan stage
    Schema.DescribeSObjectResult WPSdSobjres = Schema.SObjectType.Workplan_Stage__c; 
    Map<String,Schema.RecordTypeInfo> WPSRecordType = WPSdSobjres.getRecordTypeInfosByName(); 
    Id SubProcesswpsRtid = WPSRecordType.get('Sub-Process').getRecordTypeId();                //set of workplan stage id's
    Set<id> WPSsetid = New set<id>();
    
    //looping the workplan stage old values
    For(Workplan_Stage__c obj:(list<Workplan_Stage__c >)Trigger.old ){
        if(obj.RecordTypeId == SubProcesswpsRtid){
            WPSsetid.add(obj.Parent_Workplan_Stage__c);               //Adding all the parent workplan stage values to a set
        }
    }
    
    // If workplan stage is not empty
    if(!WPSsetid.IsEmpty()){
         // Get list of tasks associated with each workplan stage     
         List<Workplan_Stage__c> WPSList = [Select id,RecordTypeId,of_Total_Tasks__c,of_Completed_Tasks__c,(Select id,Status__c,of_Total_Tasks__c,of_Completed_Tasks__c from Workplan_Stage__r ) from Workplan_Stage__c where id IN : WPSsetid];
         // If there are tasks for the workplan stage, 
         If(WPSList !=null){
            For(Workplan_Stage__c obj: WPSList ){
                Decimal Total = 0;                    // Declaring Total value initially to Zero
                Decimal Totalcompleted = 0;           // Declaring TotalCompleted value initially to Zero
                if(obj.Workplan_Stage__r != null){
                    //looping through workplan stages and its child related workplan stages i.e. process and sub process records and incrementing it accordingly
                    For(Workplan_Stage__c WPS: obj.Workplan_Stage__r ){
                        // Get Total Tasks for each stage
                        if(WPS.of_Total_Tasks__c!=null){                        
                            Total = Total + WPS.of_Total_Tasks__c;
                        }else{
                            Total = Total+0;
                        }
                        // Get Completed Tasks for each stage
                        if(WPS.of_Completed_Tasks__c!=null){
                            Totalcompleted = Totalcompleted + WPS.of_Completed_Tasks__c; 
                        }else {
                            Totalcompleted = Totalcompleted +0;
                        }                          
                    }
                }
                // Assigning the values to respective fields
                obj.of_Completed_Tasks__c =  Totalcompleted ;                
                obj.of_Total_Tasks__c  =  Total ; 
            }
            
            // Update total tasks & total tasks completed for each stage
            try{
                    Update WPSList; 
                 }
                 catch(Exception ex)
                 {
                     System.debug(' \n CLog : '+ex.getMessage());
                 }
                    
        }
    }

}

/* This Method is used to auto-populate the workplan type when user tries to create a sub process record on workplan stage
* Output - Assignes workplan Type to subprocess records when inserted
*/
// TODO: To be removed
protected override void beforeInsert() {
    
    //Getting the sub process records of workplan stage
    Schema.DescribeSObjectResult WPSdSobjres = Schema.SObjectType.Workplan_Stage__c; 
    Map<String,Schema.RecordTypeInfo> WPSRecordType = WPSdSobjres.getRecordTypeInfosByName(); 
    Id SubProcesswpsRtid = WPSRecordType.get('Sub-Process').getRecordTypeId();
    
    List<Workplan_Stage__c> WPSlist = new list<Workplan_Stage__c>();           //List of workplan stages 
    set<id> oppId = new set<id>();                                             // set for opportunity id's
    
    For(Workplan_Stage__c obj:(list<Workplan_Stage__c >)Trigger.new ){
        if(obj.RecordTypeId == SubProcesswpsRtid){
            WPSlist.add(obj);                                            //Checking if sub process record and addling it to list
            oppId.add(obj.Opportunity__c);                               // adding all the workplan stage associated opp id's to set
        }
    }
    //checking if list is null 
    if(!WPSlist.IsEmpty()){
        List<Opportunity> OppList = [Select id,Workplan_Type__c from opportunity where id in : oppId]; //querying the particular opp id from set
        Map<id,opportunity> OppMap= new Map<id,opportunity>();                                         // Map of opportunity and id's
        oppMap.putAll(OppList);
        
        //Looping through workplan stage list
        For(Workplan_Stage__c obj : WPSlist ){
            //if that above particular oppmap contains the respective opp 
            if(OppMap.ContainsKey(obj.opportunity__c)){
                obj.Workplan_Type__c = OppMap.get(obj.Opportunity__c).workplan_Type__c;              // Assigning the value to workplan type
                
            }
        }
        
    }
}

protected override void afterInsert() {
}




//This method invokes for Four functionalities 
// a)creating the WorkplanAssignments when workplan stage.status is updated to In progress
// b)Updating the parent WorkplanStageStatusToInProgress
// c) Updating the parent WorkplanStageStatusToCompleted  
// d)Updation on Counts the total task it as and no of tasks completed for that workplan stages 


protected override void afterUpdate() {
   
   List<Workplan_Stage__c> toprocess     = new List<Workplan_Stage__c>();  // List of workplan stages to create Workplan Assignments
   List<Workplan_Stage__c> swpsProcess   = new List<Workplan_Stage__c>();  // List of workplan stages to update parent workplan stage - process records to In-progress
   List<Workplan_Stage__c> swpsCompleted = new List<Workplan_Stage__c>();  // List of workplan stages to update parent workplan stage - process records to Completed
   List<Workplan_Stage__c> TotalSubProcess = New List<Workplan_Stage__c>(); // List of workplan stages to Count the total task & completed tasks 
   
        Map<id,Workplan_Stage__c> tnewMap = new Map<id,Workplan_Stage__c>();        //opp Mapping for new value
        Map<id,Workplan_Stage__c> toldMap = new Map<id,Workplan_Stage__c>();        //opp Mapping for old value
        
        tnewMap  = (Map<id,Workplan_Stage__c>)Trigger.newMap;
        toldMap  = (Map<id,Workplan_Stage__c>)Trigger.oldMap;
   
    Schema.DescribeSObjectResult WPSdSobjres        = Schema.SObjectType.Workplan_Stage__c; 
    Map<String,Schema.RecordTypeInfo> WPSRecordType = WPSdSobjres.getRecordTypeInfosByName(); 
    Id ProcesswpsRtid = WPSRecordType.get('Process').getRecordTypeId(); 
    Id SubProcesswpsRtid = WPSRecordType.get('Sub-Process').getRecordTypeId(); 
    
   for(Workplan_Stage__c obj : (list<Workplan_Stage__c>) Trigger.new){
       if((Obj.Status__c != tOldMap.get(obj.id).Status__c) && (obj.Status__c  == 'In Progress')){
           toprocess.add(obj);
       }
       if((Obj.Status__c != tOldMap.get(obj.id).Status__c) && (obj.Status__c  == 'In Progress') && (obj.RecordTypeID == SubProcesswpsRtid) ){
           swpsProcess.add(obj);
       }  
       if((Obj.Status__c != tOldMap.get(obj.id).Status__c) && (obj.Status__c  == 'Completed' || obj.Status__c == 'Not Required')  && (obj.RecordTypeID == SubProcesswpsRtid) ){
           swpsCompleted.add(obj);
       }
       if((Obj.of_Total_Tasks__c!= toldMap.get(obj.id).of_Total_Tasks__c)||(Obj.of_Completed_Tasks__c!= tOldMap.get(obj.id).of_Completed_Tasks__c) ){
           TotalSubProcess.add(obj);
           system.debug('*************Trigger 1st');
       }
       
   }
   
   AIA_Config__c config = AIA_Config__c.getInstance('AIA_Workplan.createWorkplanAssignments');
   //creating the WorkplanAssignments when workplan stage.status is updated to In progress
   if(toprocess != null && toprocess.size()>0 && config != NULL && config.Run__c){
   AIA_Workplan.createWorkplanAssignments(toprocess);
   }
   
   // Updating the parent WorkplanStageStatusToInProgress
   if(swpsProcess != null && swpsProcess.size()>0){
   AIA_Workplan.UpdateWorkplanStageStatusToInProgress(swpsProcess);
   }
   
   // Updating the parent WorkplanStageStatusToCompleted
   if(swpsCompleted != null && swpsCompleted.size()>0){
   AIA_Workplan.UpdateWorkplanStageStatusToCompleted(swpsCompleted);
   }
   
   //This Method Counts the total task it as and no of tasks completed for that workplan stages 
   if(TotalSubProcess!=null && TotalSubProcess.size()>0){
   AIA_Workplan.TotalSubprocessRecords(TotalSubProcess);
   system.debug('*************Trigger 2st');
   }
}




}