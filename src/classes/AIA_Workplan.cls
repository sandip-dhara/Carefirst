/*------------------------------------------------------------------------------------
 *                      ----===[ HISTORY ]===---
 * Date        Developer        Description
 *------------------------------------------------------------------------------------
 * 05/19/2016 Laveen Kattela    This class is the extension point of the All the AIA_workplan Trigger Framework - 
                                 OpportunityTriggerHandler,WorkPlan Stage,Workplan Assignment.
                                 
 * 
  *************************************************************************************
 */
//---------------------------------------------------------------------------------------------------------

/**
* @Author: Laveen Kattela
* @Purpose: This class is completly for AIA -creating assignments,Assisning workplan Type to opportunity,insert and update of Workplan stages for pre-sales implementation. 
*/

public class AIA_Workplan
{

/**
* @This Method is called for Before Insert from OpportunityTriggerHandler class
* @This method - It Input List of opportunity and assigns opp with workplan type based on Business type and Off-cycle Date  
* @param ListOppty - Input the list of opportunity  
* @Output - Assigning the workplan plan type to opportunity  
*/
    // Assiging the Workplan type to opportunity, based on conditions w.r.t Business type and Offcycle Date
    public void assignWorkplan(List<Opportunity> listOppty)
    {
        System.debug('**********************AssignWorkplan Started******************************');
        
        Id opptwohundredplusId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('200+').RecordTypeId; // Record Id for the 200+ Opportunity
        
        List<Id> workplanIds      = new List<Id>();                                            // List of workplan Ids
        List<Opportunity> opplist = new List<Opportunity>();                                   // List of opportunities
        set<String> businessTypeset = new Set<String>();                                       // Holds list of business types
        Map<String,AIA_Workplan_Type__c> wpTMap = new Map<String,AIA_Workplan_Type__c>();      // Map of business type and associated workplan types
        
        /*looping listOppty and checking with the 200+ record type*/
        for(Opportunity opp:listOppty){
        
            // Checking if it is 200+ record type
            if(opp.RecordTypeId == opptwohundredplusId ){
                //Adding all the opportunity to opplist
                opplist.add(opp);
                
                //Checking if Off Cycle date is not null 
                if(opp.Off_Cycle_Term_Date__c != null)
                {
                    //Adding the set of off-cycle values to businessTypeset
                    businessTypeset.add('Off-Cycle');
                }
                else{
                    //Checking business type is not null and Adding all the business type value to set    
                    if(opp.Business_Type__c!=null)
                        businessTypeset.add(opp.Business_Type__c);
                }
            }
        }
        /* Retrieve list of workplan type's and store in map*/
        //Checking if opportunity list, businessTypeset is not null then querying the workplan type's from above businessTypeset's with condition base
        if(!opplist.isEmpty())
        {
            if(!businessTypeset.isEmpty())
            {
                List<AIA_Workplan_Type__c> wpTyplist = [Select id,Workplan_Type__c from AIA_Workplan_Type__c where Workplan_Type__c in : businessTypeset and Used_For__c ='Pre-Sales' and Active__c=true ];
                
                    //looping workplan type with above list
                    for(AIA_Workplan_Type__c wpt:wpTyplist )
                    {
                        wpTMap.put(wpt.Workplan_Type__c , wpt);  // Storing the workplan type in map
                    }    
            }
        }
        /* Loop thru opportunities and associate with workplan type*/
        for(Opportunity opp: opplist){
            // If Off Cycle is not null, then use off-cycle workplan
            if(opp.Off_Cycle_Term_Date__c != null && wpTMap.containskey('Off-Cycle'))
            {
                 opp.Workplan_Type__c = wpTMap.get('Off-Cycle').id;
            }
            // If Off Cycle is null, then use busines type field to determine which workplan should execute
           else if(opp.Business_Type__c!=null && wpTMap.containskey(opp.Business_Type__c))
            {     
                opp.Workplan_Type__c = wpTMap.get(opp.Business_Type__c).id;
            }
            else
            {
                opp.addError('No particular Workplan type is Active/Avaialble for this opportunity');
            }
        }
        System.debug('**********************AssignWorkplan End******************************');
          
    }

    
/**
* @This Method is called from OpportunityTriggerHandler class - AfterInsert Method 
* @This Method that allows workplan stages(Process & Sub-process records) to be created automatically on that Opportunity w.r.t Workplan type Assigned (Refer above method) 
* @param ListOppty - Input the list of opportunity  
* @Output - Creating the Workplan stages(Process & Sub-process records) and updating the sub-process records with their respective parent process(Hint:sub-processes roll up to a particular process) 
*/
    public void createWorkplanStages(List<Opportunity> listOppty)
    {
        //Getting the RecordTypes -Id's of - WorkPlan Type Stage object 
        // TODO: Add comments for each of the variables.
        Schema.DescribeSObjectResult WPTSdSobjres        = Schema.SObjectType.Workplan_Type_Stage__c; 
        Map<String,Schema.RecordTypeInfo> WPTSRecordType = WPTSdSobjres.getRecordTypeInfosByName();
        
        Id ProcesswptsRtid    = WPTSRecordType.get('Process').getRecordTypeId();                          //Getting the Process RecordTypeID
        Id SubProcesswptsRtid = WPTSRecordType.get('Sub-Process').getRecordTypeId();                   //Getting the Sub-Process RecordTypeID
        
        //Getting the RecordTypes -Id's of - WorkPlan Stage  object
        Schema.DescribeSObjectResult WPSdSobjres        = Schema.SObjectType.Workplan_Stage__c; 
        Map<String,Schema.RecordTypeInfo> WPSRecordType = WPSdSobjres.getRecordTypeInfosByName(); 
        
        Id ProcesswpsRtid    = WPSRecordType.get('Process').getRecordTypeId();                             //Getting the Process RecordTypeID
        Id SubProcesswpsRtid = WPSRecordType.get('Sub-Process').getRecordTypeId();                      //Getting the Sub-Process RecordTypeID
            
        // TODO: Add comment for what each of these variables stores and what it is used for
        List<Opportunity> opplist = new List<Opportunity>();                                                  //List of opportunities 
        Map<id,List<Workplan_Type_Stage__c>> wptidwptstagesMap = new Map<id,List<Workplan_Type_Stage__c>>();  //Map for id's and list of WorkPlan Type Stage
        Set<id> wpTypeidset = new Set<id>();                                                                  //set of id's to get opp Id's which has workplan type's
        List<Workplan_Stage__c> tocreate = new List<Workplan_Stage__c>();                                     // List to create WorkPlan Stages for output 
        Map<id,Workplan_Type_Stage__c> wptsMap = new Map<id,Workplan_Type_Stage__c>();                        // Map for workplan Type Stages and their Id's
        
        /* Add all opportunity that have a workplan type to the Opplist list*/
        for(Opportunity opp: listOppty)
        {
            if(opp.Workplan_Type__c !=null)
            {
                opplist.add(opp);                          //Adding all the list of opp where workplan type not equals null
                wpTypeidset.add(opp.Workplan_Type__c);     //Adding all the set of opp Id's which has workplan type's
            }
        }
    
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
        
   
        /*Looping each opportunity,If opp contains particular Workplan type-Then creating Workplan stages underneath opp W.R.T WorkPlan type Stages*/  
        for(Opportunity opp:opplist)
        {
            If(wptidwptstagesMap.containskey(opp.Workplan_Type__c))
            {                              
                //Checking whether opp.Workplan_Type__c  is/Contains in wptidwptstagesMap or not 
                for(Workplan_Type_Stage__c wps:wptidwptstagesMap.get(opp.Workplan_Type__c))
                {      
                    //if it contains Looping WorkPlan type stages and creating Workplan stages with some Mapping
                    //Assigning the Values to Workplan stage from Workplan Type Stage
                    Workplan_Stage__c ws       = new Workplan_Stage__c();
                    ws.Opportunity__c          = opp.id;
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
        
        /*Creating Workplan stage */
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
 
 
/*
* @This Method is invoked from OpportunityTriggerHandler - beforeUpdate & After update Method 
* @This Method which Changes workplan stage status to In-Progress and Start Date to today wrt Opportunity Status change.
* @param Input - Opportunity old and new Map   
* @Output wpslist- update workplan stage Status to Inprogress and start date to today
*/

    //Constant declartion for Workplan Stage.Status__c which has picklist value - Completed and In Progress
    public static final String WPS_Status_Completed = 'Completed';
    public static final String WPS_Status_In_Progress = 'In Progress';
    
    public Static void UpdateWorkplanStages(Map<id,Opportunity> newMap,Map<id,Opportunity> oldMap)
    {
 
        
        Set<id> wptsidset  = new Set<id>();                //set of workplan type stage Id's
        Map<id,id> wpswpts = new Map<id,id>();             //Map for workPlan_Stage__C and Workplan_Type_stage__c
        Set<id> wptsidset2 = new Set<id>();                //set of workplan type stage Id's(used To change the status of workplan stage)
        
        
        // Get list of workplan stages
        List<Workplan_Stage__c> wpslist = [select id,Status__c, Workplan_Type_Stage__c ,Opportunity__c,Start_Date__c 
                                           from Workplan_Stage__c 
                                           where Opportunity__c in :newMap.keyset() 
                                           and Status__c !='WPS_Status_In_Progress ' and Status__c !='WPS_Status_Completed' ];
         system.debug('List Data '+wpslist);
        
         //if above query is not empty  
         if (!wpslist.isEmpty())
         {
             //looping workplan stages with result query
            for(Workplan_Stage__c wps:wpslist){
                wptsidset.add(wps.Workplan_Type_Stage__c);        //Adding set of workplan type stages Id's 
                wpswpts.put(wps.id,wps.Workplan_Type_Stage__c);    //Map of both the Id's i.e. wps and wpts
            }
            
            if(!wptsidset.isEmpty())
            {
                List<Workplan_Type_Stage__c> wptslist =[select id, Stage__c from Workplan_Type_Stage__c where id in : wptsidset];
                Map<id,Workplan_Type_Stage__c> wptsmap = new Map<id,Workplan_Type_Stage__c>();
                wptsmap.putAll(wptslist);
 
                //Looping through opp with new values and checking the particular workplan stage.opp is same opp which is linked to workplan type stage (Checking with the map that we got from above)
                for(Opportunity opp:newMap.values()){
 
                    for(Workplan_Stage__c wps:wpslist){
 
                        if(wps.Opportunity__c  == opp.id && wpswpts.containskey(wps.id)){                   
 
                            ID wptsId = wpswpts.get(wps.id);
                            if(wptsmap.containskey(wptsid))
                            {
                                Workplan_Type_Stage__c wpts = wptsmap.get(wptsid);
                                if(newMap.get(opp.id).StageName == wpts.Stage__c  )
                                {
                                    //wpts.Stage__c = opp.StageName;       //No need to change the stage Name 
                                    wptsidset2.add(wpts.id);
                                }
                            }
                        }
                    }
                }
                try{
                    update wptslist;
                }
                catch(Exception ex)
                {
                
                    System.debug(' \n CLog : '+ex.getMessage());
                }
            }
             //Looping thou opp new value and workplan stage list 
            for(Opportunity opp:newMap.values()){
 
                for(Workplan_Stage__c wps:wpslist){
 
                     //To change the status of workplan stage wrt opp stage - checking workplan stage.opp id the same id which we got as input & checking the specific workplan stage contains its associated  workplan type stage id 
                    if(wps.Opportunity__c  == opp.id && wptsidset2.contains(wps.Workplan_Type_Stage__c )) {                  
 
                        wps.Status__c ='In Progress'; 
                        wps.Start_Date__c = system.now();                
                    }
                }
            }
            try{           
                update wpslist;    //updating the workplan stage status to In progress and start sate to now().
            }
            catch(Exception ex)
            {
                System.debug(' \n CLog : '+ex.getMessage());
            }
            
        }
        
        
    }
    
    
 
/**
* @This Method is invoked from WorkplanStageTrigger - After update Method 
* @This Method which allows to create workplan Assignments automatically when workplan stage status goes to In-Progress
* @checks If Assignee type value on workplan type Assignments is Role then it gets the value form particular opp.account Team and Assigns it to Owner field on Workplan Assignment.  
* @param Input - list of workplan stages   
* @Output wpassignments- creating workplan Assignments with mapping values from workplan type Assignment
*/
    
    public static void createWorkplanAssignments (List<Workplan_Stage__c> toprocess)
    {
        
       // TODO: Add error handling, if stage doesn't exist or stage is spelled incorrectly
       // TODO: Describe each of the variables used and for what purpose
       
       //Checking toprocess - workplan staes is not empty
       if(toprocess != null && toprocess.size()>0)
       {
           Map<id,Workplan_Stage__c> newwpsmap = new Map<id,Workplan_Stage__c>();                                 // Mapping Workplan Stage and Id's
           Map<id,id> newwpsmap1 = new Map<id,id>();                                                              // Mapping used for workplan stage Id and Account Id
           Map<id,id> wpsWptsMap = new Map<id,id>();                                                              // Mapping for workplan_Stage__c and Workplan_Type_Stage__c
           Map<id,List<AIA_Workplan_Type_Task__c>> wptsTasksMap = new Map<id,List<AIA_Workplan_Type_Task__c>>();  // Map for list of AIA_Workplan_Type_Task__c and Id's
           Map<id,AIA_Workplan_Type_Task__c> TaskMap = new Map<id,AIA_Workplan_Type_Task__c>();                   // Map for AIA_Workplan_Type_Task__c and Id's
           
           List<Workplan_Stage__c> wpsList = new List<Workplan_Stage__c>();                                       //List of workPlan stage's    
           List<AIA_Workplan_Assignment__c> wpassignments = new List<AIA_Workplan_Assignment__c>();               //list of AIA_Workplan_Assignment__c        
           List<AccountTeamMember> ateamlist = new List<AccountTeamMember>();                                     // List of AccountTeamMember
           Set<id> accidSet = new Set<id>();                                                                      // Set of AccountId's
          
           
           // Get list of workplan stages
           for(Workplan_Stage__c obj: toprocess)
           {
               //Checks if list workplan type stage is not null
               if(obj.Workplan_Type_Stage__c != null ){
                   wpsWptsMap.put(obj.id,obj.Workplan_Type_Stage__c );      //keeping the Id's- map contains both the Id's or wps and wpts
                   newwpsmap.put(obj.id,obj);                               // Map contains Workplan stage and its Id's
               }
           }
           /* */ 
           //Get the list of workplan stage from the above mapped id's
           wpsList = [select id,Account__c  from Workplan_Stage__c where id in :newwpsmap.keySet() ];
           //Looping Workplan_Stage__c through above query - for Assignee Role functionality
           for(Workplan_Stage__c obj: wpsList)
           {
                if(obj.Account__c != null)
                {
                    accidSet.add(obj.Account__c);                           //Got all the  set of Accounts Id's which links to particular workplan stages 
                    newwpsmap1.put(obj.id,obj.Account__c);                  //got the Map for workplan stage Id and Account Id's
                }
           }
           //Query the particular set of is from AccountTeamMember 
           if(accidSet != null && accidSet.size()>0){
               ateamlist =[SELECT AccountAccessLevel,AccountId,Id,TeamMemberRole,UserId FROM AccountTeamMember where AccountId in : accidSet];
           }
           
           // If workplan type stage exists, get list of workplan type assignments for that stage
           if(!wpsWptsMap.isEmpty())
           {
               List<AIA_Workplan_Type_Task__c> wpttlist =[select Id, Action__c, Role__c,Assignee_Type__c,Queue_Id__c,Default_Owner__c,Workplan_Type_Stage__c,Task_Code__c,Task_Name__c,Assignment_Description__c,Workplan_Type_Stage__r.Stage__c, 
                                                           Expected_Days_To_Complete__c from AIA_Workplan_Type_Task__c where Workplan_Type_Stage__c in :wpsWptsMap.values() and Active__c=true];
               // Add workplan type Assignments to map
               for(AIA_Workplan_Type_Task__c obj: wpttlist)
               {
                    TaskMap.put(obj.id,obj);
                   if(wptsTasksMap.containskey(obj.Workplan_Type_Stage__c ))
                   {
                       wptsTasksMap.get(obj.Workplan_Type_Stage__c ).add(obj);   //got the list of AIA_Workplan_Type_Task__c Id's
                   }
                   else{
                       wptsTasksMap.put(obj.Workplan_Type_Stage__c, new List<AIA_Workplan_Type_Task__c>{obj});  //else adding new list of Id's 
                   }
               }
               
           }
           
           // Add to workplan Assignments
           for(Workplan_Stage__c obj: toprocess)
           {
               if(obj.Workplan_Type_Stage__c != null && wptsTasksMap.containskey(obj.Workplan_Type_Stage__c))
               {
                  for(AIA_Workplan_Type_Task__c wptt: wptsTasksMap.get(obj.Workplan_Type_Stage__c))
                  {
                      Schema.DescribeSObjectResult WPASobjres = Schema.SObjectType.AIA_Workplan_Assignment__c;          //Getting the workplan Assignment records type by schema 
                      Map<String,Schema.RecordTypeInfo> WPARecordType = WPASobjres.getRecordTypeInfosByName();          //recordypeId  by name
                      Id wpaRtid = WPARecordType.get('Workplan Assignment').getRecordTypeId();                               //get the Workplan Assignment recordTypeId 
                          
                      //Mapping of Workplan Type Assignment to workplan Assignment 
                      AIA_Workplan_Assignment__c wpa  = new AIA_Workplan_Assignment__c();
                      wpa.Workplan_Stage__c           = obj.id;
                      wpa.AIA_Workplan_Type_Task__c   = wptt.id;
                      wpa.Task_Code__c                = wptt.Task_Code__c;
                      wpa.Task_Name__c                = wptt.Task_Name__c;
                      wpa.Task_Description__c         = wptt.Assignment_Description__c;
                      wpa.Status__c                   = 'Sent';
                      wpa.Send_Notification__c        = True;
                      wpa.Stage__c                    = wptt.Workplan_Type_Stage__r.Stage__c;
                      wpa.RecordTypeId                = wpaRtid;                                                     //Making  Workplan Assignment record type as defalut while creation
                      wpa.System_Generated__c         = true; 
                      wpa.Action__c                   = wptt.Action__c;                                                       //set to True - To indicate particular records are system geerated 
                      
                      //Assignee Type Role Functionality - checking with conditions if wptt.Assignee_Type__c == 'Role' or 'User' or 'Queue' 
                      if(wptt.Assignee_Type__c == 'Queue' && TaskMap.get(wptt.id).Queue_Id__c != null)
                      {
                        wpa.ownerId = TaskMap.get(wptt.id).Queue_Id__c;                                  // Assigning The queue Name to Owner
                      }
                      else if(wptt.Assignee_Type__c == 'User' && TaskMap.get(wptt.id).Default_Owner__c != null)
                      {
                        wpa.ownerId = TaskMap.get(wptt.id).Default_Owner__c;                            // Assigning The User Name to owner
                      }
                      //If Assignee type is Role as pick list value then look for particular associated - account team and assign it to owner with conditions 
                      else if(wptt.Assignee_Type__c == 'Role' && wptt.Role__c != null)
                      {
                            //Checking if workplan stage Id contains associated Account Id's
                            if(newwpsmap1.containskey(obj.id))       // From Line no :370 Map that contains workplan stage Id and Account Id's
                            {
                                id Accid = newwpsmap1.get(obj.id);  // Assigning the Particular Acount Id to Accid
                                Integer count = 0;                  //Declared Count 
                                Id UserId ;
                                //Looping AccountTeamMember by above query result line: 379
                                for(AccountTeamMember atm: ateamlist)
                                {
                                    if(atm.AccountId == Accid && atm.TeamMemberRole == wptt.Role__c )
                                    {
                                        count=count+1;
                                        UserId = atm.UserId ;      //Assigning the AccountTeamMember user name to UserID
                                    }
                                }
                                //If That role Name is associated to One or more Account Team names then Assigning the present user to Owner field of creating workplan Assignment
                                if(count == 1 && UserId != null)
                                {
                                        wpa.ownerId = UserId;
                                } 
                                else if(count > 1 && UserId != null)
                                {
                                      wpa.Assignment_Error__c = 'This particular Assignment Role has Multiple Names on Account Team/No Names is assigned, So the Owner of this Record is set to present user';

                                }                    
                            }
                      }
                      //Assigning Due date to today plus expected days to complete
                      Date dt = system.today();
                      if( wptt.Expected_Days_To_Complete__c != null )
                      { 
                          dt = dt.addDays(integer.valueOf(wptt.Expected_Days_To_Complete__c));                          
                      }
                      wpa.Due_Date__c = dt;
                      wpassignments.add(wpa);
                  }
                   
               }
           }
           
           // Insert into workplan assignments  if (!wpassignments.isEmpty())
           if (!wpassignments.isEmpty()){
               try{
                       insert wpassignments;
                   }
                   catch(Exception ex)
                   {
                        System.debug(' \n CLog : '+ex.getMessage());
                   }    
               
           }
       
       } 
        
    }

/**
* @This Method is invoked from WorkplanStageTrigger - After update Method 
* @This method makes the parent workplan type stage to "In progress" & start date to today, when Any of its child sub process records are changed to "In progress" 
* @param Input - list of workplan stages   
* @Output pwpsList - Updates the Workplan Stage - process records to In Progress 
*/
    //
    public static void UpdateWorkplanStageStatusToInProgress (List<Workplan_Stage__c> toprocess)
    {
            List<Workplan_Stage__c> parentWPStage = new List<Workplan_Stage__c>();                    //List of Parent workplan stages - process records 
            
            Schema.DescribeSObjectResult WPSdSobjres = Schema.SObjectType.Workplan_Stage__c;          //Getting the workplan stages records type by schema 
            Map<String,Schema.RecordTypeInfo> WPSRecordType = WPSdSobjres.getRecordTypeInfosByName(); //recordypeId  by name
            Id ProcesswpsRtid = WPSRecordType.get('Process').getRecordTypeId();                       //get the Process recordTypeId 
            Id SubProcesswpsRtid = WPSRecordType.get('Sub-Process').getRecordTypeId();                //get Sub-Process recordTypeId
            
            Set<id> pwpsidset = new Set<id>();                                                        //Set of workplan stages process records 
            
            //Loopiing workplan stage's 
            for(Workplan_Stage__c wps:toprocess)
            {
                //checking if workplan stage recordTypeId is Sub-process and Process record is not equals and which has status In progress 
                if(wps.recordTypeId == SubProcesswpsRtid && wps.Parent_Workplan_Stage__c != null && wps.Status__c  == 'In Progress')
                {
                    pwpsidset.add(wps.Parent_Workplan_Stage__c);   //Adding all the  parent records to list
                }
            }
            //Checking if the above list is not empty 
            if(!pwpsidset.isEmpty())
            {
                List<Workplan_Stage__c> pwpsList = [select id,Status__c from Workplan_Stage__c where id in :pwpsidset ];
                //Looping the list of parents records and making  to In progress 
                for(Workplan_Stage__c wps :pwpsList)
                {
                    wps.Status__c ='In Progress';
                    wps.Start_Date__c = system.now();
                }
                try{
                        update pwpsList;   //Updating the same parent records
                    }
                catch(Exception ex)
                {
                    System.debug(' \n CLog : '+ex.getMessage());
                }
            }
    }
   
/**
* @This Method is invoked from WorkplanStageTrigger - After update Method 
* @This method makes the Parent workplan type stage(process records) to "Completed" and End Date to today, when all the sub process records are "completed" or "Not Required"
* @param Input - list of workplan stages   
* @Output pwpsList - Updates the Workplan Stage - process records to In Progress 
*/   
      
     public static void UpdateWorkplanStageStatusToCompleted (List<Workplan_Stage__c> toprocess)
     {
            List<Workplan_Stage__c> parentWPStage = new List<Workplan_Stage__c>(); //To get the list of parent records
            
            Schema.DescribeSObjectResult WPSdSobjres = Schema.SObjectType.Workplan_Stage__c; 
            Map<String,Schema.RecordTypeInfo> WPSRecordType = WPSdSobjres.getRecordTypeInfosByName(); 
            Id ProcesswpsRtid = WPSRecordType.get('Process').getRecordTypeId(); 
            Id SubProcesswpsRtid = WPSRecordType.get('Sub-Process').getRecordTypeId(); 
            
            Set<id> pwpsidset = new Set<id>();
            
            //Looping through workplan stage and getting all the parent records for all sub-process records 
            for(Workplan_Stage__c wps:toprocess)
            {
                if(wps.recordTypeId == SubProcesswpsRtid && wps.Parent_Workplan_Stage__c != null && (wps.Status__c  == 'Completed' || wps.Status__c  == 'Not Required' )) 
                {
                    pwpsidset.add(wps.Parent_Workplan_Stage__c);
                }
            }
            //If above list is not empty 
            if(!pwpsidset.isEmpty())
            {
                //query and get the parent records by above result 
                List<Workplan_Stage__c> cwpsList = [select id,Status__c,Parent_Workplan_Stage__c from Workplan_Stage__c where Parent_Workplan_Stage__c in :pwpsidset ];
                for(Workplan_Stage__c wps :cwpsList)
                {
                    if(wps.Status__c !='Completed' && wps.Status__c != 'Not Required' && pwpsidset.contains(wps.Parent_Workplan_Stage__c) ) 
                    {
                        pwpsidset.remove(wps.Parent_Workplan_Stage__c);
                    }
                }
                
                if(!pwpsidset.isEmpty())
                { 
                    List<Workplan_Stage__c> pwpsList = [select id,Status__c,Parent_Workplan_Stage__c from Workplan_Stage__c where id in :pwpsidset ];
                    //Looping the list of parents records and making  to Completed  
                    for(Workplan_Stage__c wps :pwpsList)
                    {
                        wps.Status__c ='Completed';
                        wps.End_Date__c = system.now();
                    }
                    try{
                            update pwpsList;
                        }
                        catch(Exception ex)
                        {
                            System.debug(' \n CLog : '+ex.getMessage());
                        }
                }
            }
            
            
    }
    
/**
* @This Method is invoked from OpportunityTriggerHandler - beforeUpdate Method 
* @This method Invokes the Error when user tries to change the stage value on opportunity if respective workplan stage Assignemnts Task's are not Completed . 
* @param Input - list of opportunity, OldMap and NewMap   
* @Output - Invoking an Error:Stage cannot be changed because all the Tasks are not Completed for the current Stage.
*/    
    public void  OpportunityNextStageCheck(List<Opportunity> oppList,Map<id,Opportunity> newMap,Map<id,Opportunity> oldMap)
    {
        Map<Id,boolean> mapOfIsOppCanChangeStage = new map<Id,boolean>();       //Map for ID's and Boolean Value
        map<Id,string>  mapOfOppOldStage         = new map<Id,string>();        //Map for old stage Id's and values
        
        Id subProcessRtId = Schema.SObjectType.Workplan_Stage__c.RecordTypeInfosByName.get('Sub-Process').RecordTypeId;  //For Sub-process record type
        
        //Getting all the Opp old map values with Id's
        for(Opportunity Opp : oldmap.Values())
        {
            mapOfOppOldStage.put(Opp.Id,Opp.StageName); 
        }
        
        //Making query to get the exact Workplan stage which associated to opportunity stage value
        for(Workplan_Stage__c WPSObj : [SELECT id,Status__c,Workplan_Stage__c,All_Assignments_Must_Be_Completed__c,Opportunity__c FROM Workplan_Stage__c WHERE Opportunity__c IN:mapOfOppOldStage.KeySet() 
                                        AND RecordTypeId =: subProcessRtId AND Workplan_Stage__c IN: mapOfOppOldStage.Values()])
        {           
            if(WPSObj.All_Assignments_Must_Be_Completed__c)
            {
                if(WPSObj.Status__c != null && WPSObj.Status__c == 'Completed'){
                    mapOfIsOppCanChangeStage.put(WPSObj.Opportunity__c, true);      // If Status is Completed making Boolean value: True 
                }else if(WPSObj.Status__c != null){
                    mapOfIsOppCanChangeStage.put(WPSObj.Opportunity__c, false);     //If Status__c!=completed making Boolean value False
                }
            }else{
                mapOfIsOppCanChangeStage.put(WPSObj.Opportunity__c, true);
            }
        }
        // Invoking the Error by checking conditions with map 
        if(!mapOfIsOppCanChangeStage.isEmpty()){
            for(Opportunity opp:oppList){
                if(mapOfIsOppCanChangeStage.ContainsKey(opp.Id) && !mapOfIsOppCanChangeStage.get(opp.Id)){
                    opp.addError('Stage cannot be changed because all the Tasks are not Completed for the current Stage : '+ mapOfOppOldStage.Values());    
                }   
            }
        }
        /*
        
        for(Opportunity opp:oppList)
        {
            oppMap .add(opp.StageName);
        }
        
        List<Workplan_Stage__c> wpsList =  [select id,Workplan_Stage__c,Status__c,RecordTypeId, Opportunity__c,(select id,Status__c from AIA_Workplan_Assignment__r) from Workplan_Stage__c 
                                                where Opportunity__c in :oppMap.keyset() and Workplan_Stage__c in:oppstageset 
                                                and All_Assignments_Must_Be_Completed__c = true and RecordTypeId =: subProcessRtId];
        for(Workplan_Stage__c wps:wpsList)
        {
            if(wps.AIA_Workplan_Assignment__r != null &&  oppMap.get(wps.Opportunity__c).StageName == wps.Workplan_Stage__c  && wps.RecordTypeId == subProcessRtId)
            { 
                for(AIA_Workplan_Assignment__c obj:wps.AIA_Workplan_Assignment__r)
                {     
                    if(obj.Status__c != 'Completed')
                    {
                        oppidset.add(wps.Opportunity__c);
                    }
                }
            }
        }
        
        for(Opportunity opp:oppList)
        {
            if(oppidset.contains(opp.id))
            {
                opp.addError('Some of the workplans not completed');
            }
        }
        */
        
    }
    
/* This  method invokes when any of the task are made to comleted or not required -  To update all the child tasks to particular parent record/process record count( # no of tasks completed & # no of total tasks)
*  This method is called afterupdate from WorkplanStageTrigger 
*  Need to change the Method Name - to understand it better
*/  
 Public static void TotalSubprocessRecords(List<Workplan_Stage__c> TotalSubProcess){
        system.debug('*************Trigger 3rd');
        set<id> SetOfids = new set<id>();
        if(!TotalSubProcess.IsEmpty()){
            For(Workplan_Stage__c obj: TotalSubProcess){
              if(obj.Parent_Workplan_Stage__c!=null){
                  SetOfids.add(obj.Parent_Workplan_Stage__c);  //Adding all the partent workplan stages to set
              }  
            }
        } 
        
       If(SetOfids!=null && !SetOfids.IsEmpty())
       {
       //Query all the workplan stages from above set and also query the asscociate/related workplan stage(sub-process records)  too
        List<Workplan_Stage__c> WPSList = [Select id,RecordTypeId,of_Total_Tasks__c,of_Completed_Tasks__c,(Select id,Status__c,of_Total_Tasks__c,of_Completed_Tasks__c from Workplan_Stage__r ) from Workplan_Stage__c where id in:SetOfids];
        
        If(WPSList !=null){
            For(Workplan_Stage__c obj: WPSList ){
                Decimal Total = 0;                    // Declaring Total value initially to Zero
                Decimal Totalcompleted = 0;           // Declaring TotalCompleted value initially to Zero
                if(obj.Workplan_Stage__r != null){
                    //looping through workplan stages and its child related workplan stages i.e. process and sub process records and incrementing it accordingly
                    For(Workplan_Stage__c WPS: obj.Workplan_Stage__r ){
                        if(WPS.of_Total_Tasks__c!=null){
                            Total = Total + WPS.of_Total_Tasks__c;
                        }else{
                             Total = Total+0;
                        }
                        if(WPS.of_Completed_Tasks__c!=null){
                            Totalcompleted = Totalcompleted + WPS.of_Completed_Tasks__c; 
                        }else {
                            Totalcompleted = Totalcompleted +0;
                        }                          
                    }
                }
                obj.of_Completed_Tasks__c =  Totalcompleted ;
                obj.of_Total_Tasks__c  =  Total ; 
            }try{
                    Update WPSList; 
                 }
                 catch(Exception ex)
                 {
                     System.debug(' \n CLog : '+ex.getMessage());
                 }
                    
        }
    }        
            
 }
    
    
    /*
    public List<Id> createPostSalesWorkplan(List<Post_Sales_Implementation__c> postSales)
    {
        List<Id> workplanIds = new List<Id>();
        
        // Check if there is an oppty

        // If so, update the existing workplan

        // In not, create a new workplan
        return workplanIds;
    }

    // Initiate workplan stage
    public List<Id> initiateWorkplanStage(List<Id> workplanStageId )
    {
        List<Id> stagesIds = new List<Id>();
        
        // Change stage status to in-process    

        // Initiate workplan tasks
        return stagesIds;
    }

    

    // Method that allows workplan assignments to be created automatically
    public Id createWorkplanAssignment(String taskName, String taskCode, String taskDescription, String taskAction, String AssigneeType, String Assignee, List<String> listPeopleToBeNotified)
    {
        Id assignmentId;
        
        // Create Assignment  
        
        return assignmentId;
    }

    public Boolean checkWorkplanTasksComplete()
    {
        return false;
    }*/

}