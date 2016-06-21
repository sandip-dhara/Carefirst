/*------------------------------------------------------------------------------------
 *                      ----===[ HISTORY ]===---
 * Date        Developer         Version        Description
 *------------------------------------------------------------------------------------
 * 06/12/2016   Rajesh Pennam     1.0           Test Class For AIA_Workplan
 * 06/17/2016   Laveen Kattela    2.0           This Test class is AIA_Workplan Which inculeds all the methos as mentioned below - 
                                                Creating assignments,Assisning workplan Type to opportunity,insert and update of Workplan stages for pre-sales implementation.
                                 
 * 
  *************************************************************************************
 */

@isTest
public class AIA_Workplan_Test{
    
     public static testmethod void PositiveAIA_WorkplanTesting(){            
        User currentUser=AIA_TestUtil.AIA_createUser('AIA');
        insert currentUser;     
        System.runAs (currentUser) {
			
			AIA_Config__c config = new AIA_Config__c();
			config.Name='AIA_Workplan.createWorkplanAssignments';
			config.Run__c = true;
			insert config;
            Account TestAcc = AIA_Testutil.createAccount('Test Account');   
            AccountTeamMember atm = new AccountTeamMember ();
            atm.TeamMemberRole = 'Implementation Coordinator';
            atm.AccountAccessLevel ='Edit';
            atm.AccountId =TestAcc.id;
            atm.UserId = userinfo.getUserId();
            insert atm;
            AIA_Workplan_Type__c WpType =AIA_Testutil.AIA_CreateWorkPlan();
            insert WpType;
            System.debug('test'+wpType);
            Schema.DescribeSObjectResult WPTSdSobjres        = Schema.SObjectType.Workplan_Type_Stage__c; 
            Map<String,Schema.RecordTypeInfo> WPTSRecordType = WPTSdSobjres.getRecordTypeInfosByName();
        
            Id ProcesswptsRtid    = WPTSRecordType.get('Process').getRecordTypeId();                          //Getting the Process RecordTypeID
            Id SubProcesswptsRtid = WPTSRecordType.get('Sub-Process').getRecordTypeId();  
            
            Workplan_Type_Stage__c process = AIA_CreateWorkTypeStage(ProcesswptsRtid,WpType.id);
            insert process;
            Workplan_Type_Stage__c subprocess = AIA_CreateWorkTypeStage(SubProcesswptsRtid,WpType.id);
            subprocess.Parent_Workplan_Type_Stage__c =process.id;
            insert subprocess;
            Workplan_Type_Stage__c subprocess2 = AIA_CreateWorkTypeStage(SubProcesswptsRtid,WpType.id);
            subprocess2.Parent_Workplan_Type_Stage__c =process.id;
            insert subprocess2;
            
            AIA_Workplan_Type_Task__c wptt =AIA_CreateWorkTypeTask(subprocess.id); 
            insert wptt;
            
            AIA_Workplan_Type_Task__c wptt1 =AIA_CreateWorkTypeTask1(subprocess.id); 
            wptt1.Default_Owner__c = userinfo.getUserId();
            insert wptt1;
            AIA_Workplan_Type_Task__c wptt2 =AIA_CreateWorkTypeTask1(subprocess.id); 
            wptt2.Default_Owner__c = userinfo.getUserId();
            wptt2.Assignee_Type__c = 'Role';
            wptt2.Role__c ='Implementation Coordinator';
            insert wptt2;
            
            Opportunity opp = new Opportunity();
            opp.Name = 'Test opp';
            opp.FullServiceProducer__c = 'BenefitMall'; // Validation rule where I cannot leave this blank
            opp.StageName = 'RFP';
            opp.CloseDate = Date.today() + 7;
            opp.AccountId = TestAcc.id;
            opp.Market_Segment_New__c = '51-199';
            // opp.Business_type__c = 'Off-Cycle';
            opp.Division__c = '51-199 New Business';
            opp.Legal_Account_Name_Verified__c =true;
            opp.Underwriting_Entity__c = 'NCAS';
            Date tday = system.today();
            opp.Effective_Date__c =Date.newInstance(tday.Year(),tday.month(),1);  //Date.newInstance(2014,10,1);  // validation rule requires effective date be 1st of month
            opp.CloseDate = opp.Effective_Date__c.addDays(-11);  // validation rule requires effective date be after close date i.e. effective > closedate
            opp.Contract_End_Date__c = opp.Effective_Date__c.addMonths(1);  // VR requires contract_end_date > effective_date and contract_end_date be last day of a month
            opp.Contract_End_Date__c = opp.Contract_End_Date__c.addDays(-1);            
            opp.Off_Cycle_Term_Date__c = opp.Effective_Date__c.addDays(-1);
            
            Id opptwohundredplusId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('200+').RecordTypeId;
            opp.RecordTypeId = opptwohundredplusId;
            
            Test.startTest();
            insert opp;
            opp.Workplan_Type__c = WpType.id;
            update opp;
            System.assertEquals(opp.Workplan_Type__c, WpType.id);
            
            System.debug('***'+opp.Workplan_Type__c);
            System.debug('***'+WpType.id);
            opp.StageName ='ARC Approval';
            
		    Schema.DescribeSObjectResult WPSdSobjres = Schema.SObjectType.Workplan_Stage__c; 
            Map<String,Schema.RecordTypeInfo> WPSRecordType = WPSdSobjres.getRecordTypeInfosByName(); 
            Id ProcesswpsRtid = WPSRecordType.get('Process').getRecordTypeId(); 
            Id SubProcesswpsRtid = WPSRecordType.get('Sub-Process').getRecordTypeId(); 
            
            List<Workplan_Stage__c> wpstages=[select id,name,Parent_Workplan_Stage__c,All_Assignments_Must_Be_Completed__c,RecordType.Name from Workplan_Stage__c where  Opportunity__c=:opp.id and RecordTypeid=:SubProcesswpsRtid ];
            system.assertequals(wpstages.size(),2 );
            Set<id> wpsidset = new Set<id>();
            Set<id> Parentwpsidset = new Set<id>();
            for(Workplan_Stage__c obj:wpstages)
                wpsidset.add(obj.id);
            System.debug('***'+wpstages);
            for(Workplan_Stage__c obj:wpstages) 
            	Parentwpsidset.add(obj.Parent_Workplan_Stage__c);
            System.debug('***'+Parentwpsidset);
            List<AIA_Workplan_Assignment__c> wpas=[select id,Status__c,Workplan_Stage__c from AIA_Workplan_Assignment__c where Workplan_Stage__c in :wpsidset];
            List<Workplan_Stage__c> parentwpas=[select id,Status__c,Parent_Workplan_Stage__c,Workplan_Stage__c from Workplan_Stage__c where Workplan_Stage__c in :Parentwpsidset];
			
            System.debug('***'+parentwpas);
            for(AIA_Workplan_Assignment__c obj:wpas)
            {
           	 	obj.Status__c ='Accepted';
            	update obj;
            }
            for(AIA_Workplan_Assignment__c obj:wpas)
            {
           	 	obj.Status__c ='Completed';
            	update obj;
            }
            
            System.debug('***'+wpas);
            for(Workplan_Stage__c obj:wpstages)
                obj.All_Assignments_Must_Be_Completed__c = true;
            update wpstages;
            
            for(Workplan_Stage__c obj:wpstages)
                obj.All_Assignments_Must_Be_Completed__c = False;
            update wpstages;
           
            opp.StageName ='Quote Delivered';
            update opp;
            
            for(Workplan_Stage__c obj:parentwpas){
                obj.Status__c ='Completed';	
            }
            update parentwpas;
            System.debug('***'+parentwpas);
            
            Test.stopTest();
            
        }
    } 
    public static testmethod void NegitiveTestAIA_WorkplanTesting(){            
        User currentUser=AIA_TestUtil.AIA_createUser('AIA');
        insert currentUser;     
        System.runAs (currentUser) {
           
            AIA_Config__c config = new AIA_Config__c();
			config.Name='AIA_Workplan.createWorkplanAssignments';
			config.Run__c = true;
			insert config;
            Account TestAcc = AIA_Testutil.createAccount('Test Account');   
            AccountTeamMember atm = new AccountTeamMember ();
            atm.TeamMemberRole = 'Implementation Coordinator';
            atm.AccountAccessLevel ='Edit';
            atm.AccountId =TestAcc.id;
            atm.UserId = userinfo.getUserId();
            insert atm;
            AIA_Workplan_Type__c WpType =AIA_Testutil.AIA_CreateWorkPlan();
            wptype.Workplan_Type__c = 'New';
            insert WpType;
            System.debug('test'+wpType);
            Schema.DescribeSObjectResult WPTSdSobjres        = Schema.SObjectType.Workplan_Type_Stage__c; 
            Map<String,Schema.RecordTypeInfo> WPTSRecordType = WPTSdSobjres.getRecordTypeInfosByName();
        
            Id ProcesswptsRtid    = WPTSRecordType.get('Process').getRecordTypeId();                          //Getting the Process RecordTypeID
            Id SubProcesswptsRtid = WPTSRecordType.get('Sub-Process').getRecordTypeId();  
            
            Workplan_Type_Stage__c process = AIA_CreateWorkTypeStage(ProcesswptsRtid,WpType.id);
            insert process;
            Workplan_Type_Stage__c subprocess = AIA_CreateWorkTypeStage(SubProcesswptsRtid,WpType.id);
            subprocess.Parent_Workplan_Type_Stage__c =process.id;
            insert subprocess;
            Workplan_Type_Stage__c subprocess2 = AIA_CreateWorkTypeStage(SubProcesswptsRtid,WpType.id);
            subprocess2.Parent_Workplan_Type_Stage__c =process.id;
            insert subprocess2;
            
            AIA_Workplan_Type_Task__c wptt =AIA_CreateWorkTypeTask(subprocess.id); 
            insert wptt;
            
            AIA_Workplan_Type_Task__c wptt1 =AIA_CreateWorkTypeTask1(subprocess.id); 
            wptt1.Default_Owner__c = userinfo.getUserId();
            insert wptt1;
            AIA_Workplan_Type_Task__c wptt2 =AIA_CreateWorkTypeTask1(subprocess.id); 
            wptt2.Default_Owner__c = userinfo.getUserId();
            wptt2.Assignee_Type__c = 'Role';
            wptt2.Role__c ='Implementation Coordinator';
            insert wptt2;
            
            Opportunity opp = new Opportunity();
            opp.Name = 'Test opp';
            opp.FullServiceProducer__c = 'BenefitMall'; // Validation rule where I cannot leave this blank
            opp.StageName = 'RFP';
            opp.CloseDate = Date.today() + 7;
            opp.AccountId = TestAcc.id;
            opp.Market_Segment_New__c = '51-199';
             opp.Business_type__c = '';
            opp.Division__c = '51-199 New Business';
            opp.Legal_Account_Name_Verified__c =true;
            opp.Underwriting_Entity__c = 'NCAS';
            Date tday = system.today();
            opp.Effective_Date__c =Date.newInstance(tday.Year(),tday.month(),1);  //Date.newInstance(2014,10,1);  // validation rule requires effective date be 1st of month
            opp.CloseDate = opp.Effective_Date__c.addDays(-11);  // validation rule requires effective date be after close date i.e. effective > closedate
            opp.Contract_End_Date__c = opp.Effective_Date__c.addMonths(1);  // VR requires contract_end_date > effective_date and contract_end_date be last day of a month
            opp.Contract_End_Date__c = opp.Contract_End_Date__c.addDays(-1);            
            opp.Off_Cycle_Term_Date__c = null;
            
            Id opptwohundredplusId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('200+').RecordTypeId;
            opp.RecordTypeId = opptwohundredplusId;
            
            Test.startTest();
            try{
            	insert opp;
                opp.Workplan_Type__c = WpType.id;
            	update opp;
            	System.assertEquals(opp.Workplan_Type__c, WpType.id);
            }catch(Exception ex){
                opp.Business_type__c = 'New';   
            }
            
            
            
            
            Test.stopTest();
        }
    } 
    
    public static AIA_Workplan_Type__c AIA_CreateWorkPlan(){
        AIA_Workplan_Type__c wpt = new AIA_Workplan_Type__c();
        wpt.Used_For__c ='Pre-Sales';
        wpt.Workplan_Type__c = 'Off-Cycle';
        wpt.Active__c=true;
        
        return wpt;
    }
    public static Workplan_Type_Stage__c AIA_CreateWorkTypeStage(Id recordTypeId,Id wptId){
        Workplan_Type_Stage__c wpts = new Workplan_Type_Stage__c();
        wpts.Active__c=true;
        wpts.stage__c = 'RFP';
        wpts.recordTypeId = recordTypeId;
        wpts.Workplan_Type__c = wptId;
 
        return wpts;
    }
    public static AIA_Workplan_Type_Task__c AIA_CreateWorkTypeTask(Id wptsId){
        AIA_Workplan_Type_Task__c wptt = new AIA_Workplan_Type_Task__c();
        //wptt.Active__c=true;
        //wptt.stage__c = 'RFP';
        wptt.Workplan_Type_Stage__c = wptsid;
        wptt.Assignee_Type__c = 'Queue';
        wptt.Queue_Name__c = 'AIA Default Queue';       
 
        return wptt;
    }
    public static AIA_Workplan_Type_Task__c AIA_CreateWorkTypeTask1(Id wptsId){
        AIA_Workplan_Type_Task__c wptt1 = new AIA_Workplan_Type_Task__c();
        //wptt.Active__c=true;
        //wptt.stage__c = 'RFP';
        wptt1.Workplan_Type_Stage__c = wptsid;
        wptt1.Assignee_Type__c = 'User';     
 
        return wptt1;
    }
    
    public static User AIA_createUser(String alias )
    {
         
        Integer max = 5; 
        String randomString = EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(1,max).toUpperCase();
        Profile profile = [select id from profile where name='System Administrator'];
        User user = new User(alias = alias, email=alias + '@test.com', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = profile.Id, 
            timezonesidkey='Europe/London', username=alias +randomString+ '@test.com'
            );
        return user;      
        
    }
     
    
}