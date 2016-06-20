/********************************************************************************
********************************************************************************    
 *  Class            : AIA_IntermediatController 
 *  Author           : Laveen Kattela
 *  Version History  : 1.0
 *  Creation         : 06/15/16
 *  Description      : WPTS Subprocess RecordType creation to Auto populate Workplan Type.
 *
 ********************************************************************************
 ********************************************************************************/
public with sharing class AIA_IntermediatController {

        public List<SelectOption> options {get;set;}          //List of Select option 
        public string selectedRecordType{get;set;}            //string for selected recordtype
        Id objId;                                             //Id for objectId
        Workplan_Type_Stage__c  wpts = new Workplan_Type_Stage__c ();

    public AIA_IntermediatController(ApexPages.StandardController controller) {
            Workplan_Type_Stage__c obj = (Workplan_Type_Stage__c)controller.getRecord();     //getting the Workplan type stage record
            objId = obj.id;                                                                  // Assigning the obj to declared id
            
            //Query to get the workplan type stages from the above objId
            wpts =[Select id,Name ,Workplan_Type__c,Workplan_Type__r.Name,Parent_Workplan_Type_Stage__c,Parent_Workplan_Type_Stage__r.Name from Workplan_Type_Stage__c where id = : objId];
            options = new  List<SelectOption>();
            
            //Getting the only Sub-process record types for the workplan type stage object
            for(RecordType rt:[select id, name ,Developername from Recordtype where sobjectType ='Workplan_Type_Stage__c' ANd Developername = 'Sub_Process'])
            options.add(new SelectOption(rt.id,rt.name));        //Adding that to select option list
    }
    
    //Cancel button to go back to previous page
    public Pagereference doCancel(){
         PageReference pref = new PageReference('/'+wpts.id);      //Passing  the workplan type stage id to page references 
       pref.setRedirect(true);                                    // Setting it has true
       return pref;
    
    }
    
    //Continue button to proceed with the selected record type
    public Pagereference doContinue(){
         
         //To get the prefix of the partcular object(Workplan type stage)
         String SOPrefix = SObjectType.Workplan_Type_Stage__c .getKeyPrefix(); 
         
        //Redirecting URL to the respective page by inputing the system label for workplan type and parent workplan type stage
       String Url='/'+SOPrefix +'/e?&RecordType='+selectedRecordType+'&'+System.Label.AIA_ParentWPTSName+'='+wpts.Name+
                   '&'+System.Label.AIA_ParentWPTSID+'='+wpts.id+'&'+System.Label.AIA_WPTName+'='+wpts.Workplan_Type__r.Name+'&'+System.Label.AIA_WPTID+'='+wpts.Workplan_Type__c+'&retURL='+wpts.id;
       
       PageReference pref = new PageReference(Url);        //Passing the URL to the page references 
       pref.setRedirect(true);                             // setting it has truw
       return pref;
    
    }

}