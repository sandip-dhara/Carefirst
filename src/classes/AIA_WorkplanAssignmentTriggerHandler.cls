/*=========================================================================================
 * Date     : 05/10/2016
 * Developer    : Laveen Kattela(LK)
 * Purpose      : This class is the extension point of the Trigger Framework for adding WorkplanAssignment trigger handlers.
 *                
 *               
 *
 *=========================================================================================
 *                                 Update History
 *                                 ---------------
 * Date       Developer         Description
 *===========+============+================================================================
 * 05/10/16  |  LK    | Initial Version                                         
 *           |        | 
 *===========+============+================================================================
 */
 
/**
* @This class is invoked from WorkplanAssignmentTrigger 
*/ 
 
public with sharing class AIA_WorkplanAssignmentTriggerHandler extends TriggerHandler  {

//Constant declartion for Workplan Stage.Status__c which has picklist value - Completed and Not Required
public static final String WPA_Status_Completed = 'Completed';
public static final String WPA_Status_Not_Required = 'Not Required';

public static boolean firstRun=false;

List<AIA_Workplan_Assignment__c > wpaList = new List<AIA_Workplan_Assignment__c>();   //list of workplan Assigment's
Set<id> wpsidset = new set<id>();                                                     //Set of Workplan Assignment Id's
    
public AIA_WorkplanAssignmentTriggerHandler() {}

/* This Methos invokes when particular task is deleted from workplan stage (Sub process record - Tasks)
*  To which it updates the count of total task and Completed task as well
*/
protected override void afterDelete(){

     Set<id> WPSsetId = New set<id>();
    for(AIA_Workplan_Assignment__c  obj: (list<AIA_Workplan_Assignment__c >)Trigger.old){
        IF(Obj.Workplan_Stage__c!= null){
            WPSsetId .add(obj.Workplan_Stage__c);
        }    
    }
    if(!WPSsetId.IsEmpty()){
        TotalCountofTask(WPSsetId);
    }
    
}

/* This method (After insert) invokes when new workplan assignemnts record is inserted - to which it updates the count of total task and Completed task as well */
protected override void afterInsert() {
    if(!firstRun)
    populatePRFEmail((list<AIA_Workplan_Assignment__c>)Trigger.new);
    Set<id> WPSsetId = New set<id>();
    for(AIA_Workplan_Assignment__c  obj: (list<AIA_Workplan_Assignment__c >)Trigger.new){
        IF(Obj.Workplan_Stage__c!= null){
            WPSsetId .add(obj.Workplan_Stage__c);
        }    
    }
    if(!WPSsetId.IsEmpty()){
        TotalCountofTask(WPSsetId);                 // Calling the method to update the Total and completed Taks count
    }
}

/* This is generic method where it counts the Total no of task and no of completed tasks in workplan stage and updates accordingly 
*  This method is called afterInsert , afterDelete and afterUpdate of the same class. 
*/
Public static void TotalCountofTask(set<id> SetOfIds){
    If(SetOfIds!=null && !SetOfIds.IsEmpty())
    {   //query all the parameter setofids from workplan stage and get the child id's(workplan assignments) too 
        List<Workplan_Stage__c> WPSList = [Select id,RecordTypeId,of_Total_Tasks__c,of_Completed_Tasks__c,(Select id,Status__c from AIA_Workplan_Assignment__r ) from Workplan_Stage__c where id in:SetOfIds];
        
        //If above query list is not empty 
        If(WPSList !=null){
            For(Workplan_Stage__c obj: WPSList ){
                Integer Total = 0;                        // Defaulting to Zero initially 
                Integer Totalcompleted = 0;               // Defaulting to Zero initially
                
                //if child object is not null
                if(obj.AIA_Workplan_Assignment__r != null){
                    //looping workplan stages and their child tasks
                    For(AIA_Workplan_Assignment__C WPS: obj.AIA_Workplan_Assignment__r){
                        Total = Total+1;                                                                //Incrementing Total plus one
                        if(WPS.Status__C == 'Completed' || WPS.Status__C == 'Not Required'){
                            Totalcompleted = Totalcompleted +1;                                         //Incrementing Total completed to plus one only when status is Completed or Not Requried 
                        }                            
                    }
                }
                //Assigning to respective fields
                obj.of_Completed_Tasks__c =  Totalcompleted ;
                obj.of_Total_Tasks__c  =  Total ; 
            }
            try{
                    Update WPSList; 
                }
                catch(Exception ex){
                System.debug(' \n CLog : '+ex.getMessage());
            }
        }
    }
}


/*
*This method is to change the Status of workplan Stage.Status to Completed, when all its assignemnts are made to Completed or Not Required
*/

 protected override void afterUpdate(){
 if(!firstRun)
 populatePRFEmail((list<AIA_Workplan_Assignment__c>)Trigger.new);
 
 Set<id> wpasetOfids = new set<id>();
 
 for(AIA_Workplan_Assignment__c  obj: (list<AIA_Workplan_Assignment__c >)Trigger.new){
        if((obj.Status__c == 'Completed' || obj.Status__c == 'Not Required') && (obj.Workplan_Stage__c != null))   
        {
           wpsidset.add(obj.Workplan_Stage__c);                             //Adding all the workplan Assignments's Id's to set
           wpasetOfids .add(obj.Workplan_Stage__c);                         //Adding all the workplan Assignments's Id's to set
        }
    }
    if(!wpasetOfids.IsEmpty()){
         TotalCountofTask(wpasetOfids);                     // Calling the method to update the Total and completed Taks count
         
     }
     System.debug('****wpasetOfids****'+wpasetOfids);
    
    // Removing work plan stage id's which are not completed or Not Required from the above step
    if(wpsidset != null && wpsidset.size()>0){
        for(AIA_Workplan_Assignment__c  obj:[select id ,Status__c,Workplan_Stage__c  from AIA_Workplan_Assignment__c where Workplan_Stage__c in :wpsidset  ]){
            if(wpsidset.contains(obj.Workplan_Stage__c) && obj.Status__c != 'Completed' && obj.Status__c != 'Not Required') 
            {
                wpsidset.remove(obj.Workplan_Stage__c);
            }
        }
    }
    //wpsidset contains all workplan stage id's,for these workplan assignments records are completed  
    if(wpsidset != null && wpsidset.size()>0)
    {
        List<Workplan_Stage__c> wpslist =[select id,Status__c,End_Date__c from Workplan_Stage__c where id in :wpsidset ];
        
        for(Workplan_Stage__c obj: wpsList)
        {
            obj.Status__c ='Completed';                //Making Status as Completed when all its Assignments are completed         
            obj.End_Date__c = system.now();            // And populating end date as now
        }
        try{
                update wpslist ;                      //updating the workplan stage
           }
           catch(Exception ex){
                System.debug(' \n CLog : '+ex.getMessage());
            }
    }
  }

 public static void populatePRFEmail(list<AIA_Workplan_Assignment__c> wpList){
        set<id> PRFIdSet = new set<id>();
    for(AIA_Workplan_Assignment__c  wp: wpList){
        if(wp.Proposal_Request_form__c!=null)
        PRFIdSet.add(wp.Proposal_Request_form__c);
    }
    Map<id,PRF__c> PRFMap =new  Map<id,PRF__c>([select id,name,owner.email from PRF__c]);
    list<AIA_Workplan_Assignment__c> finalWPList = [select id,name,PRF_Owner_Email__c,Proposal_Request_form__c from AIA_Workplan_Assignment__c where id in:wpList];
    for(AIA_Workplan_Assignment__c  wp: finalWPList){
        if(wp.Proposal_Request_form__c!=null)
        wp.PRF_Owner_Email__c=PRFMap.get(wp.Proposal_Request_form__c).owner.email;
    }
    firstRun=true;
    update finalWPList;
    }
}