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
            
            AIA_Workplan_Type__c WpType =AIA_Testutil.AIA_CreateWorkPlan();
            insert WpType;
            Schema.DescribeSObjectResult WPTSdSobjres        = Schema.SObjectType.Workplan_Type_Stage__c; 
            Map<String,Schema.RecordTypeInfo> WPTSRecordType = WPTSdSobjres.getRecordTypeInfosByName();
        
            Id ProcesswptsRtid    = WPTSRecordType.get('Process').getRecordTypeId();                          //Getting the Process RecordTypeID
            Id SubProcesswptsRtid = WPTSRecordType.get('Sub-Process').getRecordTypeId();  
            
            Workplan_Type_Stage__c process = AIA_CreateWorkTypeStage(ProcesswptsRtid,WpType.id);
            insert process;
            Workplan_Type_Stage__c subprocess = AIA_CreateWorkTypeStage(SubProcesswptsRtid,WpType.id);
            subprocess.Parent_Workplan_Type_Stage__c =process.id;
            insert subprocess;
            
            AIA_Workplan_Type_Task__c wptt =AIA_CreateWorkTypeTask(subprocess.id);
            insert wptt;
            
            
            Opportunity opp = new Opportunity();
            opp.Name = 'Test opp';
            opp.FullServiceProducer__c = 'BenefitMall'; // Validation rule where I cannot leave this blank
            opp.StageName = 'Dead';
            opp.CloseDate = Date.today() + 7;
            opp.AccountId = TestAcc.id;
            opp.Market_Segment_New__c = '51-199';
            opp.Business_type__c = 'Off-Cycle';
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
            insert opp;
			/*
			Schema.DescribeSObjectResult WPSdSobjres = Schema.SObjectType.Workplan_Stage__c; 
            Map<String,Schema.RecordTypeInfo> WPSRecordType = WPSdSobjres.getRecordTypeInfosByName(); 
            Id ProcesswpsRtid = WPSRecordType.get('Process').getRecordTypeId(); 
            Id SubProcesswpsRtid = WPSRecordType.get('Sub-Process').getRecordTypeId(); 
			Workplan_Stage__c wpsprocess = new Workplan_Stage__c();
			wpsprocess.Status__c = 'Not Started';
			//wpsprocess.Workplan_Type_Stage__c = subprocess.Id;
			wpsprocess.Opportunity__c = opp.Id;
			wpsprocess.RecordTypeId = ProcesswpsRtid;
			insert wpsprocess;
			wpsprocess.Status__c = 'In Progress';			
			//update wpsprocess;
			Workplan_Stage__c wpssubprocess = new Workplan_Stage__c();
			wpssubprocess.Status__c = 'Not Started';
			//wpssubprocess.Workplan_Type_Stage__c = subprocess.Id;
			wpssubprocess.Opportunity__c = opp.Id;
			wpssubprocess.Parent_Workplan_Stage__c = wpsprocess.id;
			wpssubprocess.RecordTypeId = SubProcesswpsRtid;
			insert wpssubprocess;
			wpssubprocess.Status__c = 'Completed';			
			update wpsprocess;
			
			//AIA_WorkPlan.UpdateWorkplanStageStatusToCompleted(new List<Workplan_Stage__c>{wpssubprocess});
            
			
			*/
            Opportunity opp2 = opp.clone(false,true,false,false);
            opp2.Off_Cycle_Term_Date__c = null;
            insert opp2;
           // subprocess.Status__c = 'Completed';
		//update subprocess;
            
            try{
                Opportunity opp3 = opp.clone(false,true,false,false);
                opp3.Off_Cycle_Term_Date__c = null;
                opp.Business_type__c = 'Renewal';
                insert opp3;
            }
            catch(Exception ex){
                
            }
            
            
            
        }
    } 
    
    
 public static testmethod void PositiveTesting2(){            
        User currentUser=AIA_TestUtil.AIA_createUser('AIA');
        insert currentUser;     
        System.runAs (currentUser) {
            
            //Insert Work Plan Types
        List<AIA_Workplan_Type__c> wptlst = new List<AIA_Workplan_Type__c>();
        AIA_Workplan_Type__c wpt1 = new AIA_Workplan_Type__c();
        wpt1.Active__c = true;
        wpt1.Workplan_Type__c = 'Renewal';
        wpt1.Used_For__c = 'Pre-Sales';
        wptlst.add(wpt1);
        
        AIA_Workplan_Type__c wpt2 = new AIA_Workplan_Type__c();
        wpt2.Active__c = true;
        wpt2.Workplan_Type__c = 'Off-Cycle';
        wpt2.Used_For__c = 'Pre-Sales';
        wptlst.add(wpt2);
        
        insert wptlst;
        
        List<AIA_Workplan_Type__c> count = [select Id From AIA_Workplan_Type__c];
        system.assertequals(2,count.size());
        
        //Get RecordTypes For Workplan Type Stage
        Schema.DescribeSObjectResult WPTSdSobjres        = Schema.SObjectType.Workplan_Type_Stage__c; 
        Map<String,Schema.RecordTypeInfo> WPTSRecordType = WPTSdSobjres.getRecordTypeInfosByName();
        
        Id ProcesswptsRtid    = WPTSRecordType.get('Process').getRecordTypeId();                          
        Id SubProcesswptsRtid = WPTSRecordType.get('Sub-Process').getRecordTypeId();
        
        //Insert Records For Work Plan Type Stages
        List<Workplan_Type_Stage__c> wpslst = new List<Workplan_Type_Stage__c>();
        
        Workplan_Type_Stage__c wpts1 = new Workplan_Type_Stage__c();
        wpts1.Workplan_Type__c = wpt1.Id;
        wpts1.RecordTypeId = ProcesswptsRtid;
        wpts1.Stage__c = 'RFP';
        wpts1.Active__c = true;
        wpslst.add(wpts1);
        
        Workplan_Type_Stage__c wpts2 = new Workplan_Type_Stage__c();
        wpts2.Workplan_Type__c = wpt2.Id;
        wpts2.RecordTypeId = SubProcesswptsRtid;
        wpts1.Stage__c = 'Benefit Request';
        wpts2.Active__c = true;
        wpslst.add(wpts2);
        
        Workplan_Type_Stage__c wpts3 = new Workplan_Type_Stage__c();
        wpts3.Workplan_Type__c = wpt1.Id;
        wpts3.RecordTypeId = ProcesswptsRtid;
        wpts1.Stage__c = 'ARC Approval';
        wpts3.Active__c = true;
        wpslst.add(wpts3);
        
        Workplan_Type_Stage__c wpts4 = new Workplan_Type_Stage__c();
        wpts4.Workplan_Type__c = wpt2.Id;
        wpts4.RecordTypeId = SubProcesswptsRtid;
        wpts1.Stage__c = 'Sold';
        wpts4.Active__c = true;
        wpslst.add(wpts4);
        
        insert wpslst;
        
        //Insert Account Record
        Account acc = new Account();
        acc.Name = 'testAcc';
        acc.Type = 'testType';
        insert acc;
        
        //Get Opportunity RecordType Id
        Id oppRecTyId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('200+').RecordTypeId; 
        
        //Insert Opportunities
        List<Opportunity> opplst = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = oppRecTyId;
        opp.Name = 'Testopp';
        opp.AccountId = acc.id;
        opp.FullServiceProducer__c = 'testpro';
        opp.Effective_Date__c = Date.Today() - 11;
        opp.Contract_End_Date__c = Date.Today() + 18;
        opp.CloseDate = Date.Today() - 12;
        opp.StageName = 'test';
        opp.SBU__c = 'Large';
        opp.Market_Segment_New__c = '200-999';
        opp.Division__c = 'Labor Affairs';
        opp.Business_Type__c = 'Renewal';
        opp.Off_Cycle_Term_Date__c = Date.Today();
        opplst.add(opp);
        
        Opportunity opp1 = new Opportunity();
        opp1.RecordTypeId = oppRecTyId;
        opp1.Name = 'Testopp1';
        opp1.AccountId = acc.id;
        opp1.FullServiceProducer__c = 'testpro';
        opp1.Effective_Date__c = Date.Today() - 11;
        opp1.Contract_End_Date__c = Date.Today() + 18;
        opp1.CloseDate = Date.Today() - 12;
        opp1.StageName = 'test';
        opp1.SBU__c = 'Large';
        opp1.Market_Segment_New__c = '200-999';
        opp1.Division__c = 'Labor Affairs';
        opp1.Business_Type__c = 'Renewal';
        opp1.Off_Cycle_Term_Date__c = Date.Today();
        opplst.add(opp1);
        
        Opportunity opp2 = new Opportunity();
        opp2.RecordTypeId = oppRecTyId;
        opp2.Name = 'Testopp2';
        opp2.AccountId = acc.id;
        opp2.FullServiceProducer__c = 'testpro';
        opp2.Effective_Date__c = Date.Today() - 11;
        opp2.Contract_End_Date__c = Date.Today() + 18;
        opp2.CloseDate = Date.Today() - 12;
        opp2.StageName = 'test';
        opp2.SBU__c = 'Large';
        opp2.Market_Segment_New__c = '200-999';
        opp2.Division__c = 'Labor Affairs';
        opp2.Business_Type__c = 'Renewal';
        opplst.add(opp2);
        
        Opportunity opp3 = new Opportunity();
        opp3.RecordTypeId = oppRecTyId;
        opp3.Name = 'Testopp3';
        opp3.AccountId = acc.id;
        opp3.FullServiceProducer__c = 'testpro';
        opp3.Effective_Date__c = Date.Today() - 11;
        opp3.Contract_End_Date__c = Date.Today() + 18;
        opp3.CloseDate = Date.Today() - 12;
        opp3.StageName = 'test';
        opp3.SBU__c = 'Large';
        opp3.Market_Segment_New__c = '200-999';
        opp3.Division__c = 'Labor Affairs';
        opp3.Business_Type__c = 'Renewal';
        opplst.add(opp3);
        
        Opportunity opp4 = new Opportunity();
        opp4.RecordTypeId = oppRecTyId;
        opp4.Name = 'Testopp4';
        opp4.AccountId = acc.id;
        opp4.FullServiceProducer__c = 'testpro';
        opp4.Effective_Date__c = Date.Today() - 11;
        opp4.Contract_End_Date__c = Date.Today() + 18;
        opp4.CloseDate = Date.Today() - 12;
        opp4.StageName = 'test';
        opp4.SBU__c = 'Large';
        opp4.Market_Segment_New__c = '200-999';
        opp4.Division__c = 'Labor Affairs';
        opp4.Business_Type__c = 'Renewal';
        opplst.add(opp4);
        
        insert opplst;
        
        List<Opportunity> ocount = [select Id From Opportunity];
        system.assertequals(5,ocount.size());
        
        List<Opportunity> updateopplst = new List<Opportunity>();
        opp.StageName = 'RFP';
        updateopplst.add(opp);
        opp1.StageName = 'Benefit Request';
        updateopplst.add(opp1);
        opp2.StageName = 'ARC Approval';
        updateopplst.add(opp2);
        opp3.StageName = 'ARC Approval';
        updateopplst.add(opp3);
        opp4.StageName = 'RFP';
        updateopplst.add(opp4);
        
       
                
        List<AIA_Workplan_Type_Task__c> wpttlst = new List<AIA_Workplan_Type_Task__c>();
        
        AIA_Workplan_Type_Task__c wptt1 = new AIA_Workplan_Type_Task__c();
        wptt1.Active__c = true;
        wptt1.Task_Code__c = 'TestCode1';
        wptt1.Task_Name__c = 'TestName1';
        wptt1.Assignment_Description__c = 'TestDesc1'; 
        wptt1.Workplan_Type_Stage__c = wpts1.Id;
        wptt1.Assignee_Type__c = 'User';
        wptt1.Queue_Name__c = 'Benefits Core Team';
        wptt1.Role__c = 'Sales Consultant';
        wpttlst.add(wptt1);
        
        AIA_Workplan_Type_Task__c wptt2 = new AIA_Workplan_Type_Task__c();
        wptt2.Active__c = true;
        wptt2.Task_Code__c = 'TestCode2';
        wptt2.Task_Name__c = 'TestName2';
        wptt2.Assignment_Description__c = 'TestDesc2'; 
        wptt2.Workplan_Type_Stage__c = wpts2.Id;
        wptt2.Assignee_Type__c = 'Queue';
        wptt2.Queue_Name__c = 'Broker Compliance';
        wptt2.Role__c = 'Account Manager';
        wpttlst.add(wptt2);
        
        AIA_Workplan_Type_Task__c wptt3 = new AIA_Workplan_Type_Task__c();
        wptt3.Active__c = true;
        wptt3.Task_Code__c = 'TestCode3';
        wptt3.Task_Name__c = 'TestName3';
        wptt3.Assignment_Description__c = 'TestDesc3'; 
        wptt3.Workplan_Type_Stage__c = wpts3.Id;
        wptt3.Assignee_Type__c = 'Role';
        wptt3.Queue_Name__c = 'Broker Escalation';
        wptt3.Role__c = 'Sales Service Rep';
        wpttlst.add(wptt3);
        
        insert wpttlst;
            Schema.DescribeSObjectResult WPSdSobjres        = Schema.SObjectType.Workplan_Stage__c; 
        Map<String,Schema.RecordTypeInfo> WPSRecordType = WPSdSobjres.getRecordTypeInfosByName(); 
        Id ProcesswpsRtid = WPSRecordType.get('Process').getRecordTypeId(); 
        Id SubProcesswpsRtid = WPSRecordType.get('Sub-Process').getRecordTypeId();
        
        List<Workplan_Stage__c> wpslst1 = new List<Workplan_Stage__c>();
        Workplan_Stage__c parent1 = new Workplan_Stage__c();
        //parent.Status__c = 'Not Started';
        //parent1.Parent_Workplan_Stage__c = '';
        parent1.Workplan_Type_Stage__c = wpts1.Id;
        parent1.Opportunity__c = opp1.Id;
        parent1.RecordTypeId = ProcesswpsRtid;
        insert parent1;
        
        Workplan_Stage__c wps = new Workplan_Stage__c();
        wps.Status__c = 'Not Started';
        wps.Workplan_Type_Stage__c = wpts1.Id;
        wps.Opportunity__c = opp1.Id;
        wpslst1.add(wps);
        
        Workplan_Stage__c wps1 = new Workplan_Stage__c();
        wps1.Status__c = 'Not Started';
        wps.Workplan_Type_Stage__c = wpts2.Id;
        wps.Opportunity__c = opp2.Id;
        wpslst1.add(wps1);
      
        Workplan_Stage__c wps2 = new Workplan_Stage__c();
        wps2.Status__c = 'Not Started';
        wps.Workplan_Type_Stage__c = wpts3.Id;
        wps.Opportunity__c = opp3.Id;
        wps.Parent_Workplan_Stage__c =parent1.id;
        wps.RecordTypeId =SubProcesswpsRtid;
        wpslst1.add(wps2);
        
        insert wpslst1;
        AIA_Config__c config = new AIA_Config__c();
        config.Name='AIA_Workplan.createWorkplanAssignments';
        config.Run__c = true;
        insert config;
        for(Workplan_Stage__c wps3: wpslst1){
            wps3.Status__c = 'In Progress';
        }
        update wpslst1;
         wps2.Status__c = 'Completed';
        update wps2;
         update updateopplst;   
            
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