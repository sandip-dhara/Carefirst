/********************************************************************************
********************************************************************************    
 *  Class            : AIA_WP_SubProcess_Controller
 *  Author           : Goutham Rapolu
 *  Version History  : 1.0
 *  Creation         : 06/6/16
 *  Description      : WP Subprocess assignment creation.
 *
 ********************************************************************************
 ********************************************************************************/

public with sharing class AIA_WP_SubProcess_Controller {

    //Variable Declaration 
    public static string wpStageId {get;set;}
    //stores the type of action param: Start SubProcess or Mark as Not required
    public string actionType {get;set;}
    //current wpStage in context
    public static Workplan_Stage__c wpStage {get;set;}
    //information message
    public static string infoMsg = '';
    //string variable to check which process to execute
    public static final string SSP_ACTION = 'ssp'; //Start Sub Process
    public static final string MNR_ACTION = 'mnr'; //Mark Not Required
    static Map<id,Workplan_Stage__c> newwpsmap = new Map<id,Workplan_Stage__c>();                                 // Mapping Workplan Stage and Id's
    static Map<id,id> newwpsmap1 = new Map<id,id>();                                                              // Mapping used for workplan stage Id and Account Id
    static Map<id,id> wpsWptsMap = new Map<id,id>();                                                              // Mapping for workplan_Stage__c and Workplan_Type_Stage__c
    static Map<id,List<AIA_Workplan_Type_Task__c>> wptsTasksMap = new Map<id,List<AIA_Workplan_Type_Task__c>>();  // Map for list of AIA_Workplan_Type_Task__c and Id's
    static Map<id,AIA_Workplan_Type_Task__c> TaskMap = new Map<id,AIA_Workplan_Type_Task__c>();                   // Map for AIA_Workplan_Type_Task__c and Id's
    static List<Workplan_Stage__c> wpsList = new List<Workplan_Stage__c>();                                       //List of workPlan stage's    
    static List<AIA_Workplan_Assignment__c> wpassignments = new List<AIA_Workplan_Assignment__c>();               //list of AIA_Workplan_Assignment__c        
    static List<AccountTeamMember> ateamlist = new List<AccountTeamMember>();                                     // List of AccountTeamMember
    static Set<id> accidSet = new Set<id>();                                                                      // Set of AccountId's
    
    //constructor
    public AIA_WP_SubProcess_Controller(apexPages.StandardController controller){
        wpStageId = apexPages.currentPage().getParameters().get('Id');  
        actionType = apexPages.currentPage().getParameters().get('type');
        wpStage = new Workplan_Stage__c();
    } 
    
    /*
        This method is called from VF page "Action" attribute and based on action type it will invoke the desired process.
        It will query Workplan Stage record based on workplan stage record Id passed in URL. 
        @param: none
        @return: pageReference (null)
    */
    public pageReference onPageLoad(){
        if(string.isNotBlank(wpStageId) && string.isNotBlank(actionType)){
            infoMsg = '';
            Savepoint sp = Database.setSavepoint();
            try{
                //get the Workplan_Stage__c record from the database
                wpStage = getWPstage();
                //setup maps used to create WP assignments
                dataSetup(new list<Workplan_Stage__c>{wpStage});
                //if actionType param is SSP, initiate sup Process
                if(actionType.equalsIgnoreCase(SSP_ACTION))
                    startSubProcess();
                //if actionType param is MNR, initiate mark not required action
                if(actionType.equalsIgnoreCase(MNR_ACTION))
                    MarkNotRequired();
                if(string.isNotBlank(infoMsg))
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.INFO, infoMsg));
            }
            catch(exception e){
                system.debug('Exception Caught'+e);
                ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
                Database.rollback(sp);
            }
            
        }
        return null;
    }
    
    /*
        This method is called from "onPageLoad" method when the actionType param is "ssp". It will create Workplan_Assignment__c records
        from Workplan_Type_Task__c records of Workplan_Type_Stage__c record. It will also set the ownerId of Workplan_Assignment__c records
        based on Assignee_Type__c field on Workplan_Type_Task__c records. It calls "sendEmail" method to send emails to external or internal users.
        @param: none
        @return: none
    */
    public static void startSubProcess(){
        map<string,Workplan_Type_Stage__c> WPTSmap = new map<string,Workplan_Type_Stage__c>();
        set<Id> externalUserIds = new set<Id>();
        set<Id> internalUserIds = new set<Id>();
        list<AIA_Workplan_Assignment__c> newWPAlist = new list<AIA_Workplan_Assignment__c>();
            if(wpStage != NULL && wpStage.Id != NULL){
                infoMsg = '';
                Savepoint sp1 = Database.setSavepoint();
                wpStage.Status__c = 'In Progress';
                AIA_Config__c config = AIA_Config__c.getInstance('AIA_Workplan.createWorkplanAssignments');
                try{
                    for(Workplan_Type_Stage__c wpTs : [Select Id from Workplan_Type_Stage__c where Id =: wpStage.Workplan_Type_Stage__c]){
                        WPTSmap.put(wpTs.Id, wpTs);
                    }
                    
                    if(WPTSmap != NULL && WPTSmap.size() > 0){
                        for(AIA_Workplan_Type_Task__c wptt: getWPTypeAssignments(WPTSmap.keyset())){ //Iterate over all workplan Type assignments
                            AIA_Workplan_Assignment__c wpa = new AIA_Workplan_Assignment__c();
                            wpa.Workplan_Stage__c = wpStageId;
                            wpa.Post_Sales_Implementation__c = wpStage.Implementation__c;
                            wpa.Account__c=wpStage.Implementation__r.Account__c;
                            wpa.Status__c = 'Sent';
                            wpa.System_Generated__c = true;
                            wpa.Assigned_Date_Time__c = system.now();
                            wpa.recordTypeId = getRecordTypeIdByName('Workplan Assignment', AIA_Workplan_Assignment__c.SObjectType);
                            wpa.AIA_Workplan_Type_Task__c   = wptt.id;
                            wpa.Task_Code__c                = wptt.Task_Code__c;
                            wpa.Task_Name__c                = wptt.Task_Name__c;
                            wpa.Stage__c                    = wptt.Workplan_Type_Stage__r.Stage__c;
                            wpa.Task_Description__c         = wptt.Instructions__c;
                            if(wptt.Send_Notification__c){//if true
                                if(wptt.Assgin_To_Non_AIA_Contact__c){ //if true
                                    wpa.External_Assignee__c = wptt.Contact__c;
                                    externalUserIds.add(wptt.Contact__c);
                                }else
                                    internalUserIds.add(wpStage.Workplan_Type__r.ownerId);
                            }
                            
                            //Assignee Type Role Functionality - checking with conditions if wptt.Assignee_Type__c == 'Role' or 'User' or 'Queue' 
                            if(wptt.Assignee_Type__c == 'Queue' && TaskMap.get(wptt.id).Queue_Id__c != null){
                              wpa.ownerId = TaskMap.get(wptt.id).Queue_Id__c;                                  // Assigning The queue Name to Owner
                            }
                            else if(wptt.Assignee_Type__c == 'User' && TaskMap.get(wptt.id).Default_Owner__c != null){
                              wpa.ownerId = TaskMap.get(wptt.id).Default_Owner__c;                            // Assigning The User Name to owner
                            }
                            //If Assignee type is Role as pick list value then look for particular associated - account team and assign it to owner with conditions 
                            else if(wptt.Assignee_Type__c == 'Role' && wptt.Role__c != null){
                                  //Checking if workplan stage Id contains associated Account Id's
                                  if(newwpsmap1.containskey(wpStage.id)){
                                      id Accid = newwpsmap1.get(wpStage.id);  // Assigning the Particular Acount Id to Accid
                                      Integer count = 0;                  //Declared Count 
                                      Id UserId ;
                                      //Looping over AccountTeamMember
                                      for(AccountTeamMember atm: ateamlist){
                                          if(atm.AccountId == Accid && atm.TeamMemberRole == wptt.Role__c ){
                                              count=count+1;
                                              UserId = atm.UserId ;      //Assigning the AccountTeamMember user name to UserID
                                          }
                                      }
                                      //If That role Name is associated to One or more Account Team names then Assigning the present user to Owner field of creating workplan Assignment
                                      if(count == 1 && UserId != null){
                                              wpa.ownerId = UserId;
                                      }
                                      else if(count > 1 && UserId != null){
                                              wpa.Assignment_Error__c = 'This particular Assignment Role has Multiple Names on Account Team/No Name is Assigned, So the Owner of this Record is set to present user';
                                      }             
                                  }
                            }
                            //Assigning Due date to today plus expected days to complete
                            /*Date dt = system.today();
                            if( wptt.Expected_Days_To_Complete__c != null ){ 
                                dt = dt.addDays(integer.valueOf(wptt.Expected_Days_To_Complete__c));                          
                            }*/
                            if(WPstage.implementation__r.Implementation_Plan_Timeline_Days__c=='60'){
                                if(wptt.X60_Day_Offset__c!=null && WPstage.implementation__r.Effective_Date__c!=null)
                                wpa.Due_Date__c = WPstage.implementation__r.Effective_Date__c-integer.valueOf(wptt.X60_Day_Offset__c);                                                                                                                                
                            }
                            
                            if(WPstage.implementation__r.Implementation_Plan_Timeline_Days__c=='90'){
                                if(wptt.X90_Day_Offset__c!=null && WPstage.implementation__r.Effective_Date__c!=null)
                                wpa.Due_Date__c = WPstage.implementation__r.Effective_Date__c-integer.valueOf(wptt.X90_Day_Offset__c);                               
                            }
                            
                            if(WPstage.implementation__r.Implementation_Plan_Timeline_Days__c=='120'){
                                if(wptt.X120_Day_Offset__c!=null && WPstage.implementation__r.Effective_Date__c!=null)
                                wpa.Due_Date__c = WPstage.implementation__r.Effective_Date__c-integer.valueOf(wptt.X120_Day_Offset__c);                                
                            }
                            
                            
                            if(WPstage.implementation__r.Implementation_Plan_Timeline_Days__c=='180'){
                                if(wptt.X180_Day_Offset__c!=null && WPstage.implementation__r.Effective_Date__c!=null)
                                wpa.Due_Date__c = WPstage.implementation__r.Effective_Date__c-integer.valueOf(wptt.X180_Day_Offset__c);                                
                            }
                            
                            
                            
                            //wpa.Due_Date__c = dt;
                            newWPAlist.add(wpa);
                        }//for loop ends
                        system.debug(newWPAlist.size()+'<<newWPAlist>>>'+newWPAlist);
                        if(newWPAlist != NULL && newWPAlist.size() >0){
                            if(config != NULL){
                                config.Run__c = false;
                                update config;
                            }
                            insert newWPAlist;
                            
                            
                            if(externalUserIds != NULL && externalUserIds.size() > 0){
                                sendMail(externalUserIds,newWPAlist);
                            }
                            if(internalUserIds != NULL && internalUserIds.size() > 0){
                                sendMail(internalUserIds,newWPAlist);
                            }
                        }
                        
                        
                    }
                    update wpStage;
                    infoMsg = 'Workplan Sub Process Started!';
                    if(config != NULL){
                        config.Run__c = true;
                        update config;
                    }
                }
                catch(exception e){
                    infoMsg = '';
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
                    Database.rollback(sp1);
                }
                
            }   
    }
    
     /*
        This method is called from "onPageLoad" method when the actionType param is "mnr". It will update the Status of workplan stage to "Not Required".
        @param: none
        @return: none
    */
    public static void MarkNotRequired(){
        infoMsg = '';
        if(wpStage != NULL && wpStage.Id != NULL){
            wpStage.Status__c = 'Not Required';
            update wpStage;
            infoMsg = 'Workplan Sub Process Marked as not Required!';
        }
    }
    
    /*
        Send email to External & Internal Contacts/Users
        @param1: set<Id> - set of unique Ids, either contact or user
        @param2: list<AIA_Workplan_Assignment__c> - list of AIA_Workplan_Assignment__c records which will be used to merge data in email body.
    */
    public static void sendMail(set<Id> idSet, list<AIA_Workplan_Assignment__c> wpAsgnList){
        //Key-UserId, Value-User email
        map<string,string> userToAddr = new map<string,string>();
        //Key-Contact Id, Value-Contact email
        map<string,string> contToAddr = new map<string,string>();
        //list to store single email messages
        list<Messaging.SingleEmailMessage> msgList = new list<Messaging.SingleEmailMessage>();
        boolean isUser = false;
        boolean isContact = false;
        string msgBody = '';
        list<Id> recIds = new list<Id>();
        recIds.addAll(idSet);
        if(recIds != NULL && recIds.size() > 0){
            if(Schema.Contact.SObjectType == Id.valueOf(recIds[0]).getSObjectType()){//if contact Ids are passed
                isContact = true;
                for(Contact cont : [Select Id, email from contact where Id IN : recIds]){
                    if(cont.email != NULL)
                        contToAddr.put(cont.Id, cont.email);
                }
            }
            
            if(Schema.User.SObjectType == Id.valueOf(recIds[0]).getSObjectType()){ //if User Ids are passed
                isUser = true;
                for(User usr : [Select Id, email from User where Id IN : recIds]){
                    if(usr.email != NULL)
                        userToAddr.put(usr.Id, usr.email);
                }
            }
        
        if(wpAsgnList != NULL && wpAsgnList.size() > 0){
            for(AIA_Workplan_Assignment__c wpAsgn : wpAsgnList){
                if(isContact && contToAddr != NULL && contToAddr.size() >0 && contToAddr.containsKey(wpAsgn.External_Assignee__c)){
                    //get email address from contact map
                    string emailAdr = contToAddr.get(wpAsgn.External_Assignee__c);
                    //list of merge fields which will replace placeholders in a custom label to generate email body
                    list<string> replaceVars = new list<string>{wpStage.Account__c, wpAsgn.owner.name, wpAsgn.owner.email, string.valueOf(wpAsgn.Assigned_Date_Time__c),string.valueOf(wpAsgn.Due_Date__c), wpAsgn.Task_Description__c}; 
                    //replace the placeholders with actual content
                    string msg = string.format(system.label.AIA_WP_SubProcess_EmailTemplate,replaceVars);
                    msgList.add(generateEmailMsg(emailAdr,msg));    
                }
                if(isUser && userToAddr != NULL && userToAddr.size() >0 && userToAddr.containsKey(wpAsgn.ownerId)){
                    //get email address from user map
                    string emailAdr = userToAddr.get(wpAsgn.ownerId);
                    //generate link to WPA record
                    string link = '<a href="https://'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+wpAsgn.Id+'">'+'here</a>';
                    //list of merge fields which will replace placeholders in a custom label to generate email body
                    list<string> replaceVars = new list<string>{wpStage.Account__c,link}; 
                    //replace the placeholders with actual content
                    string msg = string.format(system.label.AIA_WP_SubProcess_EmailTemplate_2,replaceVars);
                    msgList.add(generateEmailMsg(emailAdr,msg));    
                }
            
            }
        }   
        
        if(msgList != NULL && msgList.size() > 0)
            Messaging.sendEmail(msgList);  
            
        }
    }
    
    /*
        This method is called from "sendMail" method to generate email content.
        @param1: string - email address
        @param2: string - html body of email
        @return: Messaging.SingleEmailMessage - email message with email address and body
    */
    private static Messaging.SingleEmailMessage generateEmailMsg(string emailAddr, string msgbody){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        list<string> toAddresses = new list<string>();
        toAddresses.add(emailAddr);
        mail.setToAddresses(toAddresses);
        mail.setSubject('Assignment Notification');
        mail.setHtmlBody(msgbody);
       return mail;
    }
    
    /*
        This method will query Workplan_Stage__c record from database based on Workplan_Stage__c record Id passed in the page URL.
        @param: none
        @return: Workplan_Stage__c - Workplan Stage record 
    */
    @testVisible
    private static Workplan_Stage__c getWPstage(){
        list<Workplan_Stage__c> thisWpsList = new list<Workplan_Stage__c>();
        Workplan_Stage__c thisWPstage;
        thisWpsList = [select Id, Workplan_Type__c, Status__c,Account__c,End_Date__c,Start_Date__c,Implementation__c,Implementation__r.Account__c,Implementation__r.Implementation_Plan_Timeline_Days__c,Implementation__r.Effective_Date__c,Workplan_Type_Stage__c,Workplan_Type__r.ownerId from Workplan_Stage__c where Id=: wpStageId];
        if(thisWpsList != NULL && thisWpsList.size() > 0)
            thisWPstage = thisWpsList[0];
        return thisWPstage;
    }
    
    /*
        This method will query AIA_Workplan_Type_Task__c records from database based on Workplan_Type_Stage__c record Ids related to Workplan_Stage__c record.
        @param: set<String> - set of Ids of Workplan_Type_Stage__c records
        @return: list<AIA_Workplan_Type_Task__c> - list of AIA_Workplan_Type_Task__c records 
    */
    @testVisible
    private static list<AIA_Workplan_Type_Task__c> getWPTypeAssignments(set<String> impIds){
        list<AIA_Workplan_Type_Task__c> wpTypeAsgnmntList = new list<AIA_Workplan_Type_Task__c>();
        DescribeSObjectResult describeResult = AIA_Workplan_Type_Task__c.getSObjectType().getDescribe();
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        String query = ' SELECT Workplan_Type_Stage__r.Stage__c, ' + String.join( fieldNames, ',' ) +' FROM ' + describeResult.getName()+
                       ' where Workplan_Type_Stage__c IN : impIds';
        
        wpTypeAsgnmntList = Database.query(query);
        System.debug('wpAsgnmntList>>'+wpTypeAsgnmntList);
        return wpTypeAsgnmntList;
    }
    
    /*
        This method is used to query record types of an object. It will query record types for sObject token passed as param and return
        record type Id for record type name passed as other param.
        @param1: string - record type label name
        @param2: Schema.SObjectType
    */
    public static string getRecordTypeIdByName(string recTypeName, Schema.SObjectType token){
        string recTypeId;
        // Get the Describe Result
        Schema.DescribeSObjectResult obj = token.getDescribe();
        // Obtain the RecordTypeInfos for this SObjectType token
        Map<String,Schema.RecordTypeInfo> recordTypeInfos = obj.getRecordTypeInfosByName();
        recTypeId = recordTypeInfos != NULL && recordTypeInfos.containsKey(recTypeName) ? recordTypeInfos.get(recTypeName).getRecordTypeId() : NULL; 
        return recTypeId;
    }
    
    /*
        This method will setup data in MAPs declared above, which will be used in populating data in WPA records while Starting Sub Process.
    */
    public static void dataSetup(list<Workplan_Stage__c> wpStageList){
        // Get list of workplan stages
        for(Workplan_Stage__c obj: wpStageList){
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
        for(Workplan_Stage__c obj: wpsList){
          if(obj.Account__c != null){
            accidSet.add(obj.Account__c);                           //Got all the  set of Accounts Id's which links to particular workplan stages 
            newwpsmap1.put(obj.id,obj.Account__c);                  //got the Map for workplan stage Id and Account Id's
          }
        }
        //Query the particular set of is from AccountTeamMember 
        if(accidSet != null && accidSet.size()>0){
          ateamlist =[SELECT AccountAccessLevel,AccountId,Id,TeamMemberRole,UserId FROM AccountTeamMember where AccountId in : accidSet];
        }
    
        // If workplan type stage exists, get list of workplan type assignments for that stage
        if(!wpsWptsMap.isEmpty()){
            List<AIA_Workplan_Type_Task__c> wpttlist =[select id,Role__c,Assignee_Type__c,Queue_Id__c,Default_Owner__c,X60_Day_Offset__c,X90_Day_Offset__c,X120_Day_Offset__c,X180_Day_Offset__c,Workplan_Type_Stage__c,Task_Code__c,Task_Name__c,Assignment_Description__c,Workplan_Type_Stage__r.Stage__c, 
                                                        Expected_Days_To_Complete__c from AIA_Workplan_Type_Task__c where Workplan_Type_Stage__c in :wpsWptsMap.values() and Active__c=true];
            // Add workplan type Assignments to map
            for(AIA_Workplan_Type_Task__c obj: wpttlist){
              TaskMap.put(obj.id,obj);
              if(wptsTasksMap.containskey(obj.Workplan_Type_Stage__c )){
                wptsTasksMap.get(obj.Workplan_Type_Stage__c ).add(obj);   //got the list of AIA_Workplan_Type_Task__c Id's
              }
              else{
                wptsTasksMap.put(obj.Workplan_Type_Stage__c, new List<AIA_Workplan_Type_Task__c>{obj});  //else adding new list of Id's 
              }
            }
        }
    }
}