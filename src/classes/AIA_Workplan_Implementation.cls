/*=========================================================================================
 * Date     : 05/31/2016
 * Developer    : chidananda Nagaaj
  * Purpose      : This class is the extension point of the All the AIA_Implementation Trigger Framework - 
                                 ImplementationTriggerHandler..
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
* @This Method is called from ImplementationTriggerHandler class - AfterInsert Method 
* @This Method that allows workplan stages(Process & Sub-process records) to be created automatically on that Implementation w.r.t Workplan type Assigned (Refer above method) 
* @param ListImp - Input the list of Implementations 
* @Output - Creating the Workplan stages(Process & Sub-process records) and updating the sub-process records with their respective parent process(Hint:sub-processes roll up to a particular process) 
*/

public class AIA_Workplan_Implementation
{

public void createWorkplanStages(List<AIA_Implementation__c> listImp)
    {
    
     
        //Getting the RecordTypes -Id's of - WorkPlan Type Stage object 
        // TODO: Add comments for each of the variables.
        Schema.DescribeSObjectResult WPTSdSobjres = Schema.SObjectType.Workplan_Type_Stage__c; 
        Map<String,Schema.RecordTypeInfo> WPTSRecordType = WPTSdSobjres.getRecordTypeInfosByName();
        Id ProcesswptsRtid = WPTSRecordType.get('Process').getRecordTypeId();                          //Getting the Process RecordTypeID
        Id SubProcesswptsRtid = WPTSRecordType.get('Sub-Process').getRecordTypeId();                   //Getting the Sub-Process RecordTypeID
        
        //Getting the RecordTypes -Id's of - WorkPlan Stage  object
        Schema.DescribeSObjectResult WPSdSobjres = Schema.SObjectType.Workplan_Stage__c; 
        Map<String,Schema.RecordTypeInfo> WPSRecordType = WPSdSobjres.getRecordTypeInfosByName(); 
        Id ProcesswpsRtid = WPSRecordType.get('Process').getRecordTypeId();                             //Getting the Process RecordTypeID
        Id SubProcesswpsRtid = WPSRecordType.get('Sub-Process').getRecordTypeId();                      //Getting the Sub-Process RecordTypeID
            
        // TODO: Add comment for what each of these variables stores and what it is used for
        List<AIA_Implementation__c> opplist = new List<AIA_Implementation__c>();                                                  //List of opportunities 
        Map<id,List<Workplan_Type_Stage__c>> wptidwptstagesMap = new Map<id,List<Workplan_Type_Stage__c>>();  //Map for id's and list of WorkPlan Type Stage
        Set<id> wpTypeidset = new Set<id>();                                                                  //set of id's to get opp Id's which has workplan type's
        List<Workplan_Stage__c> tocreate = new List<Workplan_Stage__c>();                                     // List to create WorkPlan Stages for output 
        Map<id,Workplan_Type_Stage__c> wptsMap = new Map<id,Workplan_Type_Stage__c>();                        // Map for workplan Type Stages and their Id's
        
        /* Add all AIA_Implementation__c that have a workplan type to the Opplist list*/
        for(AIA_Implementation__c opp: listImp)
        {
            if(opp.Workplan_Type__c !=null)
            {
                opplist.add(opp);                          //Adding all the list of opp where workplan type not equals null
                wpTypeidset.add(opp.Workplan_Type__c);     //Adding all the set of opp Id's which has workplan type's
            }
        }
        
        // If list is not empty  --- Make changes to All ****************************check this Line***********************
        //if(wpTypeidset != null && wpTypeidset.size()>0)
        if (!wpTypeIdset.isEmpty())
        {
            //Query the particular set of workPlan type Stage id's  from above "wpTypeidset"
            List<Workplan_Type_Stage__c> wptstages=[Select id,RecordTypeId,Display_Order__c,Workplan_Type__c,All_Assignments_Must_Be_Completed__c,Parent_Workplan_Type_Stage__c from Workplan_Type_Stage__c where Workplan_Type__c in :wpTypeidset and Active__c=true ];
            // Add all Workplan Type Stages field values to Map
            wptsMap.putAll(wptstages);
            
            //Looping WorkPlan Type Stage from above list -"wptstages" and adding them to map
            for(Workplan_Type_Stage__c obj:wptstages){
                if(wptidwptstagesMap.containskey(obj.Workplan_Type__c))
                {
                    wptidwptstagesMap.get(obj.Workplan_Type__c).add(obj);                                  //Getting workplan type into Map
                }
                else{
                    wptidwptstagesMap.put(obj.Workplan_Type__c,new List<Workplan_Type_Stage__c>{obj});     // Else creating the new list of Workplan type Stages into Map
                }
            }
        }
        
   
        /*Looping each AIA_Implementation__c,If opp contains particular Workplan type-Then creating Workplan stages underneath opp W.R.T WorkPlan type Stages*/  
        for(AIA_Implementation__c opp:opplist)
        {
         if(opp.Generate_Workplan_Stages__c)
         {
            If(wptidwptstagesMap.containskey(opp.Workplan_Type__c))
            {                              
                //Checking whether opp.Workplan_Type__c  is/Contains in wptidwptstagesMap or not 
                for(Workplan_Type_Stage__c wps:wptidwptstagesMap.get(opp.Workplan_Type__c))
                {      
                    //if it contains Looping WorkPlan type stages and creating Workplan stages with some Mapping
                    //Assigning the Values to Workplan stage from Workplan Type Stage
                    Workplan_Stage__c ws       = new Workplan_Stage__c();
                    ws.Opportunity__c          = opp.Opportunity__c;
                    ws.Implementation__c       = opp.id;
                    ws.Workplan_Type_Stage__c  = wps.id;
                    ws.Workplan_Type__c        = wps.Workplan_Type__c;
                    ws.Status__c               = 'Not Started';
                    ws.All_Assignments_Must_Be_Completed__c = wps.All_Assignments_Must_Be_Completed__c;
                    ws.Display_Order__c        = wps.Display_Order__c;
                    
                    //Assigning the Process RecordTypeId's of (Workplan_Type_Stage__c) to  process RecordTypeId's - WS(workplan_stage__c)
                    if(wps.RecordTypeId ==ProcesswptsRtid )
                    {
                        ws.RecordTypeId = ProcesswpsRtid ;
                    }
                    //Assigning the Sub-Process RecordTypeId's of (Workplan_Type_Stage__c) to  sub-process RecordTypeId's-(workplan stage)
                    else if(wps.RecordTypeId ==SubProcesswptsRtid )
                    {
                        ws.RecordTypeId = SubProcesswpsRtid ;
                    }
                    tocreate.add(ws);        //Adding the list of Workplan stages
                }
            }
            }
        }
        
        /*Creating Workplan stage */
        //if(tocreate != null && tocreate.size()>0)
        if (!toCreate.isEmpty())
        {
            insert tocreate;
            Map<id,id> parentMap = new Map<id,id>();
            for(Workplan_Stage__c ws:tocreate)
            {
                if(ws.RecordTypeId == ProcesswpsRtid)
                {
                    parentMap.put(ws.Workplan_Type_Stage__c, ws.id);
                }
            }
            //Updating the Sub-Processes records with their parent workplan type stages
            for(Workplan_Stage__c ws:tocreate){
                if(ws.RecordTypeId == SubProcesswpsRtid  && ws.Workplan_Type_Stage__c != null && wptsMap.containskey(ws.Workplan_Type_Stage__c) )
                {
                    ws.Parent_Workplan_Stage__c = parentMap.get(wptsMap.get(ws.Workplan_Type_Stage__c).Parent_Workplan_Type_Stage__c);
                }
            }
            
            try{
                update tocreate; 
            }
            catch(Exception ex){
                System.debug(' \n CLog : '+ex.getMessage());
            }
        }
      }
  }