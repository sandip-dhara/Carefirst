//=========================================================================================
// Date: 05/18/2016
// Developer: XXX
// Purpose: Used to create test data as necessary for test classes
//=========================================================================================
// Update History
// Date       Developer      Description
// 5/21/2016 Rajesh Pennam    Added test classes for BRFTrigger Handler, regarding  PRF and BRF
// 6/5/2016  Rajesh Pennam    Added test lass for WorkplanTypeAssignment and WorkplanAssignment
//=========================================================================================
//
//=========================================================================================

@IsTest
public class AIA_TestUtil{
    static id accountId;
    static id account2_50_Default;
    static id opportunityId;
    static id contactId;
    static id EngagementId;  
    
    public static AIA_Workplan_Type__c AIA_CreateWorkPlan(){
        AIA_Workplan_Type__c wpt = new AIA_Workplan_Type__c();
        wpt.Used_For__c ='Pre-Sales';
        wpt.Workplan_Type__c = 'Off-Cycle';
        wpt.Active__c=true;
        
        return wpt;
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
    public static Account AIA_createAccount()
    {
        Account acct = new Account(); 
        acct.Name = 'Test10';
        acct.NumberOfEmployees = 45; // Num employees should always be <= 50
        acct.Sic = '0111';
        acct.EIN__c = '123456789'; // Has field validation, cannot be longer than 9 chars
        acct.BillingStreet = '1660 International Drive St. #518 Ste.500e ' +
        '1660 International Drive St. #518 Ste.500e' +
        '1660 International Drive St. #518 Ste.500e';
        acct.BillingCity = 'McLean123456789012345678902345678901';
        acct.BillingState = 'VA';
        acct.BillingPostalCode = '22102-4501'; // Has a validation rule in place 
        acct.Billing_County_Code__c = 'DCMD';
        acct.Renewal_Anniversary_Month__c = 'Nov';
        acct.Account_Legal_Name__c= 'test Account';
        insert acct;
        return acct;
    }  
    
    public static Opportunity AIA_createopportunity(String AccId)
    {
        AIA_Workplan_Type__c wpt = new AIA_Workplan_Type__c();
        wpt.Used_For__c ='Pre-Sales';
        wpt.Workplan_Type__c = 'Renewal';
        wpt.Active__c=true;
        insert wpt;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.FullServiceProducer__c = 'BenefitMall'; // Validation rule where I cannot leave this blank
        opp.StageName = 'Proposal';
        opp.CloseDate = Date.today() + 7;
        opp.AccountId = AccId;
        opp.Market_Segment_New__c = '51-199';
        opp.Business_type__c = 'Renewal';
        opp.Division__c = '51-199 New Business';
        opp.Legal_Account_Name_Verified__c =true;
        opp.Underwriting_Entity__c = 'NCAS';
        opp.Effective_Date__c =  Date.newInstance(2014,10,1);  // validation rule requires effective date be 1st of month
        opp.CloseDate = opp.Effective_Date__c.addDays(-11);  // validation rule requires effective date be after close date i.e. effective > closedate
        opp.Contract_End_Date__c = opp.Effective_Date__c.addMonths(1);  // VR requires contract_end_date > effective_date and contract_end_date be last day of a month
        opp.Contract_End_Date__c = opp.Contract_End_Date__c.addDays(-1);
        opp.Workplan_Type__c = wpt.id;
        insert opp;
        return opp;
     }
    
    public static Account updateAccount(String accountName)
    {
         // Create some test accounts
        Id rt_acc_51 = QueryBase.getRecordtypeId('Account', 'X51');
        //List<Account> accList = new List<Account>();
        Account a = new Account();
        a.Name = accountName + '-' + Date.Today();
        a.Type = 'Customer';
        a.RecordTypeId = rt_acc_51;      
        a.Renewal_Anniversary_Month__c='Jan';
        insert a;
        a.Renewal_Anniversary_Month__c='Feb';
        update a;
        accountId = a.id;
        return a;
    }
    
    public static void createTestAccounts() {
        // Create some test accounts
        Id rt_acc_51 = QueryBase.getRecordtypeId('Account', 'X51');
        List<Account> accList = new List<Account>();
        Account a = new Account();
        a.Name = 'SomeTest' + Date.Today();
        a.Type = 'Customer';
        a.RecordTypeId = rt_acc_51;
        accList.add(a);
        accountId = a.id;
        
        //Create the 2-50 default account for the 
        //Broker Activity Process
        Id rt_acc_2_50 = QueryBase.getRecordtypeId('Account', 'X2_50');
        a = new Account();
        a.Name = '2_50_DEFAULT_ACCOUNT';
        a.Type = 'Partner';
        a.RecordTypeId = rt_Acc_2_50;
        accList.add(a);        
        //Create an account with an entity id for the
        //Broker Activity process that has contacts with 
        //the same entity id
        a = new Account();
        a.Name = 'TestAccount1';
        a.Type = 'Partner';
        a.Entity_ID__c = '123456789';
        a.Entity_Type_AG__c = true;
        a.RecordTypeId = rt_acc_2_50;
        accList.add(a);
        //Create an account that won't have contacts
        //with matching entity id
        a = new Account();
        a.Name = 'TestAccount2';
        a.Type = 'Partner';
        a.Entity_ID__c = '123459999';
        a.Entity_Type_FSP__c = true;
        a.RecordTypeId = rt_acc_2_50;
        accList.add(a);
        //Create an account with an entity id for the
        //Broker Activity process that has contacts with 
        //the same entity id
        a = new Account();
        a.Name = 'TestAccount3';
        a.Type = 'Partner';
        a.Entity_ID__c = '555555555';
        a.Entity_Type_AG__c = true;
        a.RecordTypeId = rt_acc_2_50;
        accList.add(a);                 
        insert acclist;
        
        for(account ac: acclist){
            if ( ac.type=='Customer' ) accountid =ac.id;  
            if ( ac.Type == 'Partner' && ac.Name != '2_50_DEFAULT_ACCOUNT' ) account2_50_Default = ac.Id;
        }    
        
    }
    
    public static void createTestContacts() {
        // Create some test contacts
        // NOTE: Entity_Typed hard coded matches broker import record created in the
        //       CreateBrokerActivityData
        Id rt_Con_2_50 = QueryBase.getRecordtypeId('Contact', 'X2_50');
        Id rt_Con_51 = QueryBase.getRecordtypeId('Contact', 'X51');        
        Insert new Contact[] { new Contact( AccountId = accountId, FirstName = 'ContactTester1', LastName = 'ContactTester1', Email = 'CT1@CT1.com', phone = '123-123-9991', Employer_Group_Portal__c = TRUE, RecordTypeId = rt_Con_51 ),
                               new Contact( AccountId = accountId, FirstName = 'ContactTester2', LastName = 'ContactTester2', Email = 'CT1@CT2.com', phone = '123-123-9992', Employer_Group_Portal__c = FALSE, RecordTypeId = rt_Con_51 ),
                               new Contact( AccountId = accountId, FirstName = 'ContactTester3', LastName = 'ContactTester3', Email = 'CT1@CT3.com', phone = '123-123-9993', Employer_Group_Portal__c = FALSE, RecordTypeId = rt_Con_51 ),
                               new Contact( AccountId = Account2_50_Default, FirstName = 'BrokerTest1',  LastName = 'BrokerTest1', Email = 'ba@ba1.com', phone = '123-123-3838', Employer_Group_Portal__c = FALSE, Entity_Id__c = '123456789', Entity_Type_SB__c=true, RecordTypeId = rt_Con_2_50 ),                            
                               new Contact( AccountId = Account2_50_Default, FirstName = 'BrokerTest2',  LastName = 'BrokerTest2', Email = 'ba@ba2.com', phone = '123-123-1039', Employer_Group_Portal__c = FALSE, Entity_Id__c = '777777777', Entity_Type_SB__c=true, RecordTypeId = rt_Con_2_50 )}; 
    }    
    
    public static void createTestOpportunities() {
        // Create some test opportunities
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity o = new Opportunity();
        o.Name = 'OppTest' + Date.Today();  
        o.AccountId = accountId;
        o.StageName = 'Proposal';
        o.CloseDate = Date.Today();
        o.System__c = 'Facets';
        o.Facets_Grp_Num__c = 'X23A';        
        o.FullServiceProducer__c = 'Direct';        
        oppList.add(o);                
       
        o.Name = 'OppTest' + Date.Today();  
        o.AccountId = accountId;
        o.StageName = 'Sold';
        o.Effective_Date__c = Date.Today();
        o.Contract_End_Date__c = Date.Today() + 365;
        o.CloseDate = Date.Today() - 15;
        o.System__c = 'Facets';
        o.Facets_Grp_Num__c = 'X23B';
        o.FullServiceProducer__c = 'Direct';
        oppList.add(o);
        
        insert o; 
    }    
    
    public static void createTestEngagements() {
        // Create some test Engagements

        Engagements__c test1 = new Engagements__c();
        test1.Name = 'Enagement Test1';
        // Get NCAS Picklist values
//        Schema.DescribeFieldResult F = Engagements__c.NCAS_Segment_Leader__c.getDescribe();
//        List<Schema.PicklistEntry> P = F.getPicklistValues();
        // Add first picklist value to field
//        test1.NCAS_Segment_Leader__c = P[0].getValue();
        
        insert test1;
        
        //
        Engagements__c test2 = new Engagements__c();
        test2.Name = 'Training Enagement Test2';
        // Get NCAS Picklist values
//        Schema.DescribeFieldResult F2 = Engagements__c.NCAS_Segment_Leader__c.getDescribe();
//        List<Schema.PicklistEntry> P2 = F2.getPicklistValues();
        // Add first picklist value to field
//        test2.NCAS_Segment_Leader__c = P2[0].getValue();
        
        insert test2;      
    }
    
       
    /*******************************************
     * Test Data for the Enrollment Process
     ******************************************/    
    public static String createEnrollmentTestData() {
        List<Account> accountList = new List<Account>();
        Set<id> OppIds = new Set<id>(); 
        
        /* Get Dates for testing 
         *  Since we only look at opportunities with effective date from last month
         * back 12 months we need to have our test data set up from last month
        */
        Date LastMonth = Date.today().toStartofMonth()-1; // Get last month
        String MM = String.valueOf(LastMonth.month());
        if ( LastMonth.month() < 10 ) {
            MM = ('0' + String.valueOf(LastMonth.month())); 
        }
        String YYYY = String.valueOf(LastMonth.Year());
        String RptDt = YYYY + MM;               // Format CCYYMM
        String RunDt = Date.Today().format() + ' 5:00:00'; // Format MM/DD/CCYYY HH:MM:SS           
        
       
        /* create user */
        User salesUser = [SELECT Name, Lead_Rep_Number__c 
                          FROM User 
                          WHERE Lead_Rep_Number__c != null Limit 1];
        /* create accounts */  
        Account testacct1 = new Account();
        testacct1.Name = 'TestAccount4';
        testacct1.Type = 'Customer';
        accountList.add(testacct1);
        
        Account testacct2 = new Account();
        testacct2.Name = 'TestAccount44';
        testacct2.Type = 'Partner';
        accountList.add(testacct2);
        
        Account testacct3 = new Account();
        testacct3.Name = 'TestAccount12';
        testacct3.Type = 'Customer';
        accountList.add(testacct3);
        
        Account testacct4 = new Account();
        testacct4.Name = 'TestAccount32';
        testacct4.Type = 'Customer';
        accountList.add(testacct4);
        
        Account testacct5 = new Account();
        testacct5.Name = 'TestAccount75';
        testacct5.Type = 'Partner';
        accountList.add(testacct5);
        
        Account testacct6 = new Account();
        testacct6.Name = 'TestAccount85';
        testacct6.Type = 'Customer';
        accountList.add(testacct6);
        
        insert accountList;        


        /* create opportunities */        
        List<Opportunity> testOppsList = new List<Opportunity>();      
        
        // Opportunity has a NASCO System and an associated NASCO group ID
        Opportunity testOpp1 = new Opportunity();
        testOpp1.Name = 'Test Opportunity1';
        testopp1.AccountId = testacct1.Id;
        testOpp1.StageName ='Proposal';    
        testOpp1.CloseDate = Date.today()-90;
        testOpp1.SBU__c = 'Small/Medium';
        testopp1.Market_Segment_New__c = '51-199';
        testopp1.Business_type__c = 'Renewal';
        testopp1.Division__c = '51-199 Renewals';   
        testopp1.Underwriting_Entity__c = 'MD';
        testopp1.Lead_Rep_Name_User__c = salesUser.Id;
        testOpp1.GeneralProducer__c = 'Direct'; 
        testOpp1.System__c = 'NASCO';    
        testOpp1.NASCO_Acct_ID__c = '12201';   
        testOpp1.Related_Products_Sold__c = 'Test';       
        Date effectiveDate = testOpp1.CloseDate.addDays(35);        
        testOpp1.Effective_Date__c = Date.newInstance(effectiveDate.Year(), effectiveDate.Month(), 1);
        Date contractEndDate = testOpp1.Effective_Date__c+365;
        contractEndDate = Date.newInstance(contractEndDate.Year(), contractEndDate.Month(), 1);
        contractEndDate = contractEndDate.addDays(-1);
        testOpp1.Contract_End_Date__c = contractEndDate;  
        testOpp1.Won_Lost_Reason__c = 'Acquisition';    //TPB 06/06/2014              

        testOppsList.add(testOpp1);
//        OppIds.add(testOpp1.id);

        
        // Opportunity has a Facets System and an associated Facets Group ID       
        Opportunity testOpp2 = new Opportunity();
        testOpp2.Name = 'Test Opportunity12';
        testopp2.AccountId = testacct3.Id;
        testOpp2.StageName ='Proposal'; 
        testOpp2.CloseDate = Date.today()-70;
        testOpp2.SBU__c = 'Large';
        testopp2.Market_Segment_New__c = '200-999';
        testopp2.Business_type__c = 'New';
        testopp2.Division__c = 'Labor Affairs';   
        testopp2.Underwriting_Entity__c = 'MD';
        testopp2.Lead_Rep_Name_User__c = salesUser.Id;
        testOpp2.GeneralProducer__c = 'Direct'; 
        testOpp2.System__c = 'Facets';    
        testOpp2.Facets_Grp_Num__c = 'CE12';
        testOpp2.Related_Products_Sold__c = 'Test';      
        effectiveDate = testOpp2.CloseDate.addDays(35);        
        testOpp2.Effective_Date__c = Date.newInstance(effectiveDate.Year(), effectiveDate.Month(), 1);
        contractEndDate = testOpp2.Effective_Date__c+365;
        contractEndDate = Date.newInstance(contractEndDate.Year(), contractEndDate.Month(), 1);
        contractEndDate = contractEndDate.addDays(-1);
        testOpp2.Contract_End_Date__c = contractEndDate;  
        testOpp2.Won_Lost_Reason__c = 'Acquisition';    //TPB 06/06/2014          

        testOppsList.add(testOpp2);
//        OppIds.add(testOpp2.id); 

        // Opportunity has a Network Lease System and an associated Network Lease ID         
        Opportunity testOpp3 = new Opportunity();
        testOpp3.Name = 'Test Opportunity44';
        testopp3.AccountId = testacct2.Id;
        testOpp3.StageName ='Proposal';   
        testOpp3.CloseDate = Date.today()-90;
        testOpp3.SBU__c = 'Small/Medium';
        testopp3.Market_Segment_New__c = '51-199';
        testopp3.Business_type__c = 'Renewal';
        testopp3.Division__c = '51-199 Renewals';   
        testopp3.Underwriting_Entity__c = 'MD';
        testopp3.Lead_Rep_Name_User__c = salesUser.Id;
        testOpp3.GeneralProducer__c = 'Direct'; 
        testOpp3.System__c = 'Network Lease';    
        testOpp3.Net_Lease_Group_ID__c = 'NWL4444'; 
        testOpp3.Type = 'Network Leasing Local';  
        testOpp3.Related_Products_Sold__c = 'Test';      
        effectiveDate = testOpp3.CloseDate.addDays(35);        
        testOpp3.Effective_Date__c = Date.newInstance(effectiveDate.Year(), effectiveDate.Month(), 1);
        contractEndDate = testOpp3.Effective_Date__c+365;
        contractEndDate = Date.newInstance(contractEndDate.Year(), contractEndDate.Month(), 1);
        contractEndDate = contractEndDate.addDays(-1);
        testOpp3.Contract_End_Date__c = contractEndDate;
        testOpp3.Won_Lost_Reason__c = 'Acquisition';    //TPB 06/06/2014           
                 
        testOppsList.add(testOpp3);
//        OppIds.add(testOpp3.id); 
        
        
        // Opportunity has a Facets System and an associated Facets Group ID    
        Opportunity testOpp4 = new Opportunity();
        testOpp4.Name = 'Test Opportunity32';
        testopp4.AccountId = testacct4.Id;
        testOpp4.StageName ='Proposal';   
        testOpp4.CloseDate = Date.today()-150;
        testOpp4.SBU__c = 'Small/Medium';
        testopp4.Market_Segment_New__c = '51-199';
        testopp4.Business_type__c = 'Renewal';
        testopp4.Division__c = '51-199 Renewals';   
        testopp4.Underwriting_Entity__c = 'MD';
        testopp4.Lead_Rep_Name_User__c = salesUser.Id;
        testOpp4.GeneralProducer__c = 'Direct'; 
        testOpp4.System__c = 'Facets';    
        testOpp4.Facets_Grp_Num__c = 'YZ32';   
        testOpp4.Related_Products_Sold__c = 'Test';      
        effectiveDate = testOpp4.CloseDate.addDays(35);        
        testOpp4.Effective_Date__c = Date.newInstance(effectiveDate.Year(), effectiveDate.Month(), 1);
        contractEndDate = testOpp4.Effective_Date__c+365;
        contractEndDate = Date.newInstance(contractEndDate.Year(), contractEndDate.Month(), 1);
        contractEndDate = contractEndDate.addDays(-1);
        testOpp4.Contract_End_Date__c = contractEndDate;
        testOpp4.Won_Lost_Reason__c = 'Acquisition';    //TPB 06/06/2014            
                
        testOppsList.add(testOpp4);
//        OppIds.add(testOpp4.id);
        
        // Adding another opportunity to the same Account to test the rollup summary
        // capability of the Enrollment_ContractSummary classes sort method that is 
        // in the Enrollment_ContractSummaryHelperClass
        // Opportunity has a Facets System and an associated Facets Group ID    
        Opportunity testOpp4_2 = new Opportunity();
        testOpp4_2.Name = 'Test Opportunity32';
        testopp4_2.AccountId = testacct4.Id;
        testOpp4_2.StageName ='Proposal';   
        testOpp4_2.CloseDate = Date.today()-150;
        testOpp4_2.SBU__c = 'Small/Medium';
        testopp4_2.Market_Segment_New__c = '51-199';
        testopp4_2.Business_type__c = 'Renewal';
        testopp4_2.Division__c = '51-199 Renewals';   
        testopp4_2.Underwriting_Entity__c = 'MD';
        testopp4_2.Lead_Rep_Name_User__c = salesUser.Id;
        testOpp4_2.GeneralProducer__c = 'Direct'; 
        testOpp4_2.System__c = 'Facets';    
        testOpp4_2.Facets_Grp_Num__c = 'YZ3A';   
        testOpp4_2.Related_Products_Sold__c = 'Test';       
        effectiveDate = testOpp4_2.CloseDate.addDays(35);        
        testOpp4_2.Effective_Date__c = Date.newInstance(effectiveDate.Year(), effectiveDate.Month(), 1);
        contractEndDate = testOpp4_2.Effective_Date__c+365;
        contractEndDate = Date.newInstance(contractEndDate.Year(), contractEndDate.Month(), 1);
        contractEndDate = contractEndDate.addDays(-1);
        testOpp4_2.Contract_End_Date__c = contractEndDate; 
        testOpp4_2.Won_Lost_Reason__c = 'Acquisition';    //TPB 06/06/2014             
                
        testOppsList.add(testOpp4_2);
//        OppIds.add(testOpp4_2.id);        
        
        
        // Opportunity has a LuminX System and an associated LuminX Group ID  
        Opportunity testOpp5 = new Opportunity();
        testOpp5.Name = 'Test Opportunity75';
        testopp5.AccountId = testacct5.Id;
        testOpp5.StageName ='Proposal';   
        testOpp5.CloseDate = Date.today()-30;
        testOpp5.SBU__c = 'Small/Medium';
        testopp5.Market_Segment_New__c = '51-199';
        testopp5.Business_type__c = 'Renewal';
        testopp5.Division__c = '51-199 Renewals';   
        testopp5.Underwriting_Entity__c = 'MD';
        testopp5.Lead_Rep_Name_User__c = salesUser.Id;
        testOpp5.GeneralProducer__c = 'Direct'; 
        testOpp5.System__c = 'LuminX';    
        testOpp5.Luminex__c = 'WEE75';  
        testOpp5.Related_Products_Sold__c = 'Test';       
        effectiveDate = testOpp5.CloseDate.addDays(35);        
        testOpp5.Effective_Date__c = Date.newInstance(effectiveDate.Year(), effectiveDate.Month(), 1);
        contractEndDate = testOpp5.Effective_Date__c+365;
        contractEndDate = Date.newInstance(contractEndDate.Year(), contractEndDate.Month(), 1);
        contractEndDate = contractEndDate.addDays(-1);
        testOpp5.Contract_End_Date__c = contractEndDate;  
        testOpp5.Won_Lost_Reason__c = 'Acquisition';    //TPB 06/06/2014            
                 
        testOppsList.add(testOpp5);
//        OppIds.add(testOpp5.id);   
               
        
       // Opportunity has a National Alliance System and an associated National Alliance Group ID  
        Opportunity testOpp6 = new Opportunity();
        testOpp6.Name = 'Test Opportunity85';
        testopp6.AccountId = testacct6.Id;
        testOpp6.StageName ='Proposal';   
        testOpp6.CloseDate = Date.today()-30;
        testOpp6.SBU__c = 'Small/Medium';
        testopp6.Market_Segment_New__c = '51-199';
        testopp6.Business_type__c = 'Renewal';
        testopp6.Division__c = '51-199 Renewals';   
        testopp6.Underwriting_Entity__c = 'MD';
        testopp6.Lead_Rep_Name_User__c = salesUser.Id;
        testOpp6.GeneralProducer__c = 'Direct'; 
        testOpp6.System__c = 'National Alliance';    
        testOpp6.National_Alliance_ID__c = '12345';  
        testOpp6.Related_Products_Sold__c = 'Test';    
        effectiveDate = testOpp6.CloseDate.addDays(35);        
        testOpp6.Effective_Date__c = Date.newInstance(effectiveDate.Year(), effectiveDate.Month(), 1);
        contractEndDate = testOpp6.Effective_Date__c+365;
        contractEndDate = Date.newInstance(contractEndDate.Year(), contractEndDate.Month(), 1);
        contractEndDate = contractEndDate.addDays(-1);
        testOpp6.Contract_End_Date__c = contractEndDate;  
        testOpp6.Won_Lost_Reason__c = 'Acquisition';    //TPB 06/06/2014            
                 
        testOppsList.add(testOpp6);
//        OppIds.add(testOpp6.id);       

        // Perform the Insert of the records just built above        
        Insert testOppsList;
        
        // add related opportunity line item data to the opps just inserted
        for ( Opportunity rec : testOppsList ) {
            oppIds.add(rec.id);
            InsertOpportunityLineItems(rec.id);
        }        
    
        // Update the Stage to sold
        // Have to do this because of VR18
        for ( Opportunity rec : testOppsList ) {
            rec.Incumbent_Successor__c = 'CareFirst';
            rec.StageName = 'Sold';
        }
  
        update testOppsList;

        
        //Product not available in the Standard Price Book and Product is not Active        
        Product2 testProd11 = new Product2();
        testProd11.name = 'HM Select';  
        testProd11.IsActive = False;
        insert testProd11;


        /****************************************
         * Insert some related enrollment records
         ****************************************/        
        List<Enrollment__c> enrList = new List<Enrollment__c>();  
      
        for ( Opportunity opp : [ SELECT id, Account.Name, System__c FROM Opportunity WHERE Id =:OppIds ] ) { 
            Enrollment__c e = new Enrollment__c();
            e.Opportunity__c = opp.id;         
            e.Account_Number__c = 'aed5';        
            e.System__c =  opp.System__c; 
            e.Contracts__c = 100;            
            e.Processed_Type__c = 'M';
            e.Risk__c = 'Risk';
            e.Rpt_dt__c = RptDt;
            e.Run_Dt__c = RunDt;
            e.Product__c = 'BC Advantage';   
            e.Latest_Enrollment__c = 'Y';          
            enrList.add(e); 
        }
        
    
        if  ( enrList.size() > 0 ) {        
            insert enrList;             
        } 


        /* create sample Enrollment Import */
        List <Enrollment_Import__c> enrollmentImportList = new List<Enrollment_Import__c>();
        for(integer i = 0; i<91; i++){
            Enrollment_Import__c EnImp = new Enrollment_Import__c();
    
            //Condition 1 - Happy Path: Correct Account Number and matching System, Correct Opportunity and Active Product. 
            if(i<10){
                EnImp.Account_Name__c = 'TestAccount'+ i;
                EnImp.Account_Number__c = '1220'+i;        
                EnImp.System__c = 'NASCO';
                EnImp.Contracts__c = 50+i;
                EnImp.Processed__c = FALSE;
                EnImp.Processed_Type__c = 'M';
                EnImp.Risk__c = 'Non-Risk';
                EnImp.Rpt_dt__c = RptDt;
                EnImp.Run_Dt__c = RunDt;
                EnImp.SFDC_Product__c = 'BC Advantage';               
                enrollmentImportList.add(EnImp);
            }
    
            //Condition 2: Correct Account Number and matching System, Correct Opportunity and Unavailable Product in system.
            else if(i>10 && i<21){
                EnImp.Account_Name__c = 'TestAccount'+i;
                EnImp.Account_Number__c = 'CE'+i;        
                EnImp.System__c = 'Facets';
                EnImp.Contracts__c = 50+i;
                EnImp.Processed__c = FALSE;
                EnImp.Processed_Type__c = 'M';
                EnImp.Risk__c = 'Non-Risk';
                EnImp.Rpt_dt__c = RptDt;
                EnImp.Run_Dt__c = RunDt;
                EnImp.SFDC_Product__c = 'Dangerous Product';             
                enrollmentImportList.add(EnImp);
            }
    
            //Condition 3: Opportunities with no matching System and Account Numbers.    
            else if (i>20 && i<31){
                EnImp.Account_Name__c = 'TestAccount'+i;
                EnImp.Account_Number__c = 'ABCDE';  
                EnImp.System__c = 'LuminX';
                EnImp.Contracts__c = 50+i;
                EnImp.Processed__c = FALSE;
                EnImp.Processed_Type__c = 'M';
                EnImp.Risk__c = 'Non-Risk';
                EnImp.Rpt_dt__c = RptDt;
                EnImp.Run_Dt__c = RunDt;
                EnImp.SFDC_Product__c = 'HM Select';  
                enrollmentImportList.add(EnImp);
            }  
            
            //Condition 4: Opportunity records that have already been processed.                
            else if (i>30 && i<41){
                EnImp.Account_Name__c = 'TestAccount'+i;
                EnImp.Account_Number__c = 'YZ'+i;        
                EnImp.System__c = 'Facets';
                EnImp.Contracts__c = 50+i;
                EnImp.Processed__c = TRUE;
                EnImp.Processed_Type__c = 'M';
                EnImp.Risk__c = 'Non-Risk';
                EnImp.Rpt_dt__c = RptDt;
                EnImp.Run_Dt__c = RunDt;
                EnImp.SFDC_Product__c = 'BC Advantage';      
                enrollmentImportList.add(EnImp);
            } 
            
            //Condition 5: Correct Account Number and matching Network Lease System, Correct Opportunity and Unavailable Product in system.              
            else if (i>40 && i<51){
                EnImp.Account_Name__c = 'TestAccount'+i;
                EnImp.Account_Number__c = 'NWL44'+i;        
                EnImp.System__c = 'Network Lease';
                EnImp.Contracts__c = 0+i;
                EnImp.Processed__c = FALSE;
                EnImp.Processed_Type__c = 'M';
                EnImp.Risk__c = 'Non-Risk';
                EnImp.Rpt_dt__c = RptDt;
                EnImp.Run_Dt__c = RunDt;
                EnImp.SFDC_Product__c = 'UPNF';             
                enrollmentImportList.add(EnImp);
            }
            
            //Condition 6: Accounts don't exist in Salesforce and all records with i>50 will be kicked to the Enrollment Recycle Object.          
            else if (i>50 && i<61){
                EnImp.Account_Name__c = 'TestAccountXX'+i;
                EnImp.Account_Number__c = 'XYZ'+i;        
                EnImp.System__c = 'Facets';
                EnImp.Contracts__c = 35+i;
                EnImp.Processed__c = FALSE;
                EnImp.Processed_Type__c = 'M';
                EnImp.Risk__c = 'Non-Risk';
                EnImp.Rpt_dt__c = RptDt;
                EnImp.Run_Dt__c = RunDt;
                EnImp.SFDC_Product__c = 'BC Advantage';           
                enrollmentImportList.add(EnImp);
            }
            
            //Condition 7: System doesn't exist in Salesforce.          
            else if (i>60 && i<71){
                EnImp.Account_Name__c = 'TestAccountXY'+i;
                EnImp.Account_Number__c = 'XYZ'+i;        
                EnImp.System__c = 'WRONG SYSTEM';
                EnImp.Contracts__c = 50+i;
                EnImp.Processed__c = FALSE;
                EnImp.Processed_Type__c = 'M';
                EnImp.Risk__c = 'Risk';
                EnImp.Rpt_dt__c = RptDt;
                EnImp.Run_Dt__c = RunDt;
                EnImp.SFDC_Product__c = 'Unavailable Product';             
                enrollmentImportList.add(EnImp);
            }
            
            //Condition 8: Happy Path for LuminX System.          
            else if (i>70 && i<81){
                EnImp.Account_Name__c = 'TestAccount'+i;
                EnImp.Account_Number__c = 'WEE'+i;        
                EnImp.System__c = 'LuminX';
                EnImp.Contracts__c = 1+i;
                EnImp.Processed__c = FALSE;
                EnImp.Processed_Type__c = 'M';
                EnImp.Risk__c = 'Risk';
                EnImp.Rpt_dt__c = RptDt;
                EnImp.Run_Dt__c = RunDt;
                EnImp.SFDC_Product__c = 'BC Advantage';            
                enrollmentImportList.add(EnImp);
            }
            //Condition 8: Happy Path for National Alliance System.          
            else if (i>80 && i<91){
                EnImp.Account_Name__c = 'TestAccount'+i;
                EnImp.Account_Number__c = '1234'+i;        
                EnImp.System__c = 'National Alliance';
                EnImp.Contracts__c = 1+i;
                EnImp.Processed__c = FALSE;
                EnImp.Processed_Type__c = 'M';
                EnImp.Risk__c = 'Non-Risk';
                EnImp.Rpt_dt__c = RptDt;
                EnImp.Run_Dt__c = RunDt;
                EnImp.SFDC_Product__c = 'BC Advantage';            
                enrollmentImportList.add(EnImp);            
            }
            
        }
           
        if (enrollmentImportList.size() > 0){     
            insert enrollmentImportList;
        }        
  
        //Create Enrollment recycle test data  
        List<Enrollment_Recycle__c> erList = new List<Enrollment_Recycle__c>();  
        
        for ( Opportunity opp : [ SELECT Account.Name, System__c FROM Opportunity WHERE Id =:OppIds ] ) { 
            Enrollment_Recycle__c er = new Enrollment_Recycle__c();           
            er.Account_Name__c = opp.Account.Name;
            er.Account_Number__c = 'aed5';        
            er.System__c =  opp.System__c; 
            er.Contracts__c = 100;            
            er.Processed_Type__c = 'M';
            er.Error_Message__c = 'Missing Facets Id';
            er.Opportunity_Name__c = null;
            er.Risk__c = 'Risk';
            er.Rpt_dt__c = RptDt;
            er.Run_Dt__c = RunDt;
            er.Sales_Rep__c = 'Tester';
            er.SFDC_Product__c = 'BC Advantage'; 
            
            if ( opp.System__c == 'Facets' ) er.Error_Number__c = '0004';
            if ( opp.System__c == 'LuminX' ) er.Error_Number__c = '0005';
            if ( opp.System__c == 'NASCO' ) er.Error_Number__c = '0006';
            if ( opp.System__c == 'Network Lease' ) er.Error_Number__c = '0007';
            if ( opp.System__c == 'National Alliance' ) er.Error_Number__c = '0008';
            
            erList.add(er); 
        } 

        // Create a record that has no known product
        Enrollment_Recycle__c er = new Enrollment_Recycle__c();           
        er.Account_Name__c = 'Any Account';
        er.Account_Number__c = 'CE12';        
        er.System__c =  'Facets'; 
        er.Contracts__c = 100;            
        er.Processed_Type__c = 'M';
        er.Error_Message__c = 'No Salesforce Product found! Contact sfdcSupport@carefirst.com';
        er.Error_Number__c = '0001';
        er.Opportunity_Name__c = null;
        er.Risk__c = 'Risk';
        er.Rpt_dt__c = RptDt;
        er.Run_Dt__c = RunDt;
        er.Sales_Rep__c = 'Tester';
        er.SFDC_Product__c = 'NOTFOUND';                 
        erList.add(er);
        
        
        // Create a record that has no known system
        Enrollment_Recycle__c er2 = new Enrollment_Recycle__c();           
        er2.Account_Name__c = 'Any Account';
        er2.Account_Number__c = 'CE12';        
        er2.System__c =  'NoSuchSystem'; 
        er2.Contracts__c = 100;            
        er2.Processed_Type__c = 'M';
        er2.Error_Message__c = 'System not found in Salesforce';
        er2.Error_Number__c = '0002';
        er2.Opportunity_Name__c = null;
        er2.Risk__c = 'Risk';
        er2.Rpt_dt__c = RptDt;
        er2.Run_Dt__c = RunDt;
        er2.Sales_Rep__c = 'Tester';
        er2.SFDC_Product__c = 'BC Advantage';                 
        erList.add(er2);        

        if  ( erList.size() > 0 ) {         
            insert erList; 
        }
        return RptDt;               
    } //END public static void createEnrollmentTestData()
    
    public static void InsertOpportunityLineItems(Id oppId) {
        PricebookEntry[] priceBookEntry = [ Select p.Name,  p.Id , p.IsActive From PricebookEntry p  where p.IsActive = true limit 3];
        List<OpportunityLineItem> oppProducts = new List<OpportunityLineItem>() ;
        OpportunityLineItem oppProduct1 = new OpportunityLineItem();
        oppProduct1.OpportunityId = oppId;
        oppProduct1.PricebookEntryId = priceBookEntry[0].Id;
        oppProduct1.Product_Sold__c = false;
        oppProduct1.Quantity = 10.00 ;
        oppProduct1.TotalPrice = 100.00;
        oppProducts.add(oppProduct1) ;
        
        OpportunityLineItem oppProduct2 = new OpportunityLineItem();
        oppProduct2.OpportunityId = oppId;
        oppProduct2.PricebookEntryId = priceBookEntry[1].Id;
        oppProduct2.Product_Sold__c = true;
        oppProduct2.Quantity = 10.00 ;
        oppProduct2.TotalPrice = 100.00;
        oppProducts.add(oppProduct2) ;
        
        OpportunityLineItem oppProduct3 = new OpportunityLineItem();
        oppProduct3.OpportunityId = oppId;
        oppProduct3.PricebookEntryId = priceBookEntry[2].Id;
        oppProduct3.Product_Sold__c = true;
        oppProduct3.Quantity = 10.00 ;
        oppProduct3.TotalPrice = 100.00;
        oppProducts.add(oppProduct3) ;
             
        insert oppProducts;
    } 
    
    
    
    // Broker_Import__c Data Build     
    public static void CreateBrokerActivityData() {      
        
        // Create Broker Import Data
        List <Broker_Import_2_50__c> biImportList = new List<Broker_Import_2_50__c>();
        Broker_Import_2_50__c bi = new Broker_Import_2_50__c();
        //AG Entity Type
        bi.Account_Name__c = 'TestAccount1';
        bi.Entity_Id__c = '123456789';
        bi.Entity_Type__c = 'AG';
        bi.Phone__c = '123-456-1781';        
        bi.address_Line__c = '123 Happy Lane';  
        bi.Processed__c = FALSE;                              
        biImportList.add(bi);
        //FSP Entity Type same entity id as above
        bi = new Broker_Import_2_50__c();
        bi.Account_Name__c = 'TestAccount1';
        bi.Entity_Id__c = '123456789';
        bi.Entity_Type__c = 'FSP';
        bi.Phone__c = '123-456-0789';        
        bi.address_Line__c = 'SB Happy Lane';  
        bi.Processed__c = FALSE;                              
        biImportList.add(bi);   
        //SB Entity Type same Entity Id as above
        //and mathing an account we created above
        bi = new Broker_Import_2_50__c();
        bi.First_Name__c = 'SB1';
        bi.Entity_Id__c = '123456789';
        bi.Entity_Type__c = 'SB';
        bi.Phone__c = '123-456-2789';        
        bi.address_Line__c = 'SB Happy Lane';  
        bi.Processed__c = FALSE;                              
        biImportList.add(bi); 
        //This record is duplicated from the above record
        //this should now be an update to the Contact object
        bi = new Broker_Import_2_50__c();
        bi.First_Name__c = 'SB1';
        bi.Entity_Id__c = '123456789';
        bi.Entity_Type__c = 'SB';
        bi.Phone__c = '123-456-7789';        
        bi.address_Line__c = 'SB Happy Lane';  
        bi.Processed__c = FALSE;                              
        biImportList.add(bi);         
        //Create another Entity Type 'SB to test
        //where a Contact does not exists in SF
        //and an account with matching entity id
        //also does not exist
        bi = new Broker_Import_2_50__c();
        bi.First_Name__c = 'SB2';
        bi.Entity_Id__c = '666666666';
        bi.Entity_Type__c = 'SB';
        bi.Phone__c = '678-456-4123';        
        bi.address_Line__c = 'SB2 Happy Lane';  
        bi.Processed__c = FALSE;                              
        biImportList.add(bi); 
        //Create an entity id that matches
        //an existing contact record
        bi = new Broker_Import_2_50__c();
        bi.First_Name__c = 'SB2';
        bi.Entity_Id__c = '777777777';
        bi.Entity_Type__c = 'SB';
        bi.Phone__c = '678-456-9123';        
        bi.address_Line__c = 'SB2 Happy Lane';  
        bi.Processed__c = FALSE;                              
        biImportList.add(bi);    
        //Create a contact that has a matching Account
        //with the same entity id but make sure
        //we don't have an existing contact with the same
        // matching entity id in sf
        //Create an entity id that matches
        //an existing contact record
        bi = new Broker_Import_2_50__c();
        bi.First_Name__c = 'SB2';
        bi.Entity_Id__c = '555555555';
        bi.Entity_Type__c = 'SB';
        bi.Phone__c = '678-456-1233';        
        bi.address_Line__c = 'SB2 Happy Lane';  
        bi.Processed__c = FALSE;                              
        biImportList.add(bi); 
        //Setup for default 2-50 account record
        bi = new Broker_Import_2_50__c();        
        bi.Account_Name__c = 'TestAccount';
        bi.Entity_Id__c = '123456780';
        bi.Entity_Type__c = 'AG';
        bi.Phone__c = '123-456-789';        
        bi.address_Line__c = 'AG Happy Lane';  
        bi.Processed__c = FALSE;                              
        biImportList.add(bi); 
        insert biImportList;
    }   
     // Broker_Import__c Data Build For Deletion   
    // Set Processed Flag = True 
    public static void DeleteBrokerActivityData() {      
        
        // Create Broker Import Data
        List <Broker_Import_2_50__c> biImportList = new List<Broker_Import_2_50__c>();
        Broker_Import_2_50__c bi = new Broker_Import_2_50__c();
        //AG Entity Type
        bi.Account_Name__c = 'TestAccount1';
        bi.Entity_Id__c = '123456789';
        bi.Entity_Type__c = 'AG';
        bi.Phone__c = '123-456-1781';        
        bi.address_Line__c = '123 Happy Lane';  
        bi.Processed__c = true;                              
        biImportList.add(bi);
        //FSP Entity Type same entity id as above
        bi = new Broker_Import_2_50__c();
        bi.Account_Name__c = 'TestAccount1';
        bi.Entity_Id__c = '123456789';
        bi.Entity_Type__c = 'FSP';
        bi.Phone__c = '123-456-0789';        
        bi.address_Line__c = 'SB Happy Lane';  
        bi.Processed__c = true;                              
        biImportList.add(bi);   
        //SB Entity Type same Entity Id as above
        //and matching an account we created above
        bi = new Broker_Import_2_50__c();
        bi.First_Name__c = 'SB1';
        bi.Entity_Id__c = '123456789';
        bi.Entity_Type__c = 'SB';
        bi.Phone__c = '123-456-2789';        
        bi.address_Line__c = 'SB Happy Lane';  
        bi.Processed__c = true;                              
        biImportList.add(bi); 
        //This record is duplicated from the above record
        //this should now be an update to the Contact object
        bi = new Broker_Import_2_50__c();
        bi.First_Name__c = 'SB1';
        bi.Entity_Id__c = '123456789';
        bi.Entity_Type__c = 'SB';
        bi.Phone__c = '123-456-7789';        
        bi.address_Line__c = 'SB Happy Lane';  
        bi.Processed__c = true;                              
        biImportList.add(bi);         
        //Create another Entity Type 'SB to test
        //where a Contact does not exists in SF
        //and an account with matching entity id
        //also does not exist
        bi = new Broker_Import_2_50__c();
        bi.First_Name__c = 'SB2';
        bi.Entity_Id__c = '666666666';
        bi.Entity_Type__c = 'SB';
        bi.Phone__c = '678-456-4123';        
        bi.address_Line__c = 'SB2 Happy Lane';  
        bi.Processed__c = true;                              
        biImportList.add(bi); 
        //Create an entity id that matches
        //an existing contact record
        bi = new Broker_Import_2_50__c();
        bi.First_Name__c = 'SB2';
        bi.Entity_Id__c = '777777777';
        bi.Entity_Type__c = 'SB';
        bi.Phone__c = '678-456-9123';        
        bi.address_Line__c = 'SB2 Happy Lane';  
        bi.Processed__c = true;                              
        biImportList.add(bi);    
        //Create a contact that has a matching Account
        //with the same entity id but make sure
        //we don't have an existing contact with the same
        // matching entity id in sf
        //Create an entity id that matches
        //an existing contact record
        bi = new Broker_Import_2_50__c();
        bi.First_Name__c = 'SB2';
        bi.Entity_Id__c = '555555555';
        bi.Entity_Type__c = 'SB';
        bi.Phone__c = '678-456-1233';        
        bi.address_Line__c = 'SB2 Happy Lane';  
        bi.Processed__c = true;                              
        biImportList.add(bi); 
        //Setup for default 2-50 account record
        bi = new Broker_Import_2_50__c();        
        bi.Account_Name__c = 'TestAccount';
        bi.Entity_Id__c = '123456780';
        bi.Entity_Type__c = 'AG';
        bi.Phone__c = '123-456-789';        
        bi.address_Line__c = 'AG Happy Lane';  
        bi.Processed__c = true;                              
        biImportList.add(bi); 
        insert biImportList;
    }   
    // Ashish Ojha Changes
    // Data Build for Enrollment 2-50
    public static void Create_Enrolment_Import_2_50_Data() {
        //createTestAccounts();
        
        Id rt_acc_2_50 = QueryBase.getRecordtypeId('Account', 'X2_50');
        Account a = new Account();
        a.Name = 'SomeTest' + Date.Today();
        a.Type = 'Customer';
        a.RecordTypeId = rt_acc_2_50;
        a.AccountNumber = '12345';
        a.Facets_Account_Number__c = 'Abc1';
        a.Entity_Id__c = '12345566';
        a.sic = 'SicTest';
        a.Rating_State__c = 'MD';
        
        insert a;
        
        Account b = New Account();
        b.Name = 'SomeTest1' + Date.Today();
        b.Type = 'Customer';
        b.RecordTypeId = rt_acc_2_50;
        b.AccountNumber = '012345';
        b.Facets_Account_Number__c = 'WXY1';
        b.Entity_Id__c = '12345548';
        b.sic = 'SicTest';
        b.Rating_State__c = 'MD';
        insert b;
        
        Account c = New Account();
        c.Name = 'SomeTest2' + Date.Today();
        c.Type = 'Partner';
        c.entity_id__c = '12345678';
        c.RecordTypeId = rt_acc_2_50;
        c.AccountNumber = '012345';
        c.Facets_Account_Number__c = 'PQRS';
        c.sic = 'SicTest';
        c.Rating_State__c = 'MD';
        insert c;
        
        Contact con = new Contact();
        con.LastName = 'Test';
        con.Entity_Id__c = '1234567898';
        insert con;
        
        //Create Enrollment_Import_2_50 Data
        List<Enrollment_Import_2_50__c> enrList2_50 = new List<Enrollment_Import_2_50__c>();
        Enrollment_Import_2_50__c enrl              = new Enrollment_Import_2_50__c();
        enrl.Account_Effective_Date__c              = system.today();
        enrl.Account_Number__c                      = '1111';
        enrl.Account_Name__c                        = 'Test';
        enrl.Sic__c                                 = 'SicTest';
        enrl.Rating_State__c                        = 'MD';
        enrl.AE_ID__c                               = 'test';
        enrl.AE_Name__c                             = 'test';
        enrl.External_Key__c                        = '1234test';
        enrl.Processed__c                           = false;
        enrl.Term_Date__c                           = system.today();
        enrl.Contracts__c                           = 23;
        enrl.Processed_Type__c                      = 't';
        enrl.Risk__c                                = 'tst';
        enrl.Rpt_dt__c                              = '201412';
        enrl.Run_Dt__c                              = '201221';
        enrl.SFDC_Product__c                        = 'test';
        enrl.System__c                              = 'atest';
        enrl.AG_Id__c                               = '12345548';
        enrl.GP_Id__c                               = '12345566';
        enrl.Contract_Effective_Date__c             = system.today().addDays(-300);
        enrl.Renewal_date__C                        = system.today().addDays(100);
        enrList2_50.add(enrl);
        
        enrl                                        = new Enrollment_Import_2_50__c();
        enrl.Account_Effective_Date__c              = system.today();
        enrl.GP_Id__c                               = '12345566';
        enrl.Account_Number__c                      = '3333';
        enrl.Account_Name__c                        = 'Test';
        enrl.Sic__c                                 = 'SicTest';
        enrl.Rating_State__c                        = 'MD';
        enrl.AE_ID__c                               = 'test';
        enrl.AE_Name__c                             = 'test';
        enrl.Processed__c                           = false;
        enrl.External_Key__c                        = '1234test1';
        enrl.Contracts__c                           = 23;
        enrl.Processed_Type__c                      = 't';
        enrl.Risk__c                                = 'tst';
        enrl.Rpt_dt__c                              = '201411';
        enrl.Run_Dt__c                              = '201221';
        enrl.SFDC_Product__c                        = 'test';
        enrl.System__c                              = 'atest';
        enrl.Contract_Effective_Date__c             = system.today().addDays(-300);
        enrl.Renewal_date__C                        = system.today().addDays(100);
        enrList2_50.add(enrl);
        
         enrl                                       = new Enrollment_Import_2_50__c();
        enrl.Account_Effective_Date__c              = system.today();
        enrl.Account_Number__c                      = '2222';
        enrl.Account_Name__c                        = 'Test';
        enrl.AE_ID__c                               = 'test';
        enrl.AE_Name__c                             = 'test';
        enrl.External_Key__c                        = '1234test';
        enrl.Processed__c                           = false;
        enrl.Term_Date__c                           = system.today();
        enrl.Contracts__c                           = 23;
        enrl.Processed_Type__c                      = 't';
        enrl.Risk__c                                = 'tst';
        enrl.Rpt_dt__c                              = '201412';
        enrl.Run_Dt__c                              = '201221';
        enrl.SFDC_Product__c                        = 'test';
        enrl.System__c                              = 'atest';
        enrl.Ag_id__c                               = '12345678';
        enrl.FSP_id__c                              = '12345678';
        enrl.GP_id__c                               = '12345678';
        enrl.sic__c                                 = 'SicTest';
        enrl.Rating_State__c                        = 'MD';
        enrl.Processed_Opportunity__c               = false;
        enrl.SB_id__c                               = '1234567898';
        enrl.Contract_Effective_Date__c             = system.today().addDays(-300);
        enrl.Renewal_date__C                        = system.today().addDays(100);
        enrList2_50.add(enrl);

      
        
        insert enrList2_50;
    }
    
     // Ashish Ojha Changes
   /*
    // Data Build for Enrollment__c
    public static void Create_Enrollment_2_50_Data() {
        //Create Enrollment_2_50 Data        
        Id rt_acc_2_50 = QueryBase.getRecordtypeId('Account', 'X2_50');
        Account a = new Account();
        a.Name = 'SomeTest' + Date.Today();
        a.Type = 'Customer';
        a.RecordTypeId = rt_acc_2_50;
        a.AccountNumber = '12345';
        insert a;
               
        Id rt_Con_2_50 = QueryBase.getRecordtypeId('Contact', 'X2_50');
        Contact con         = new Contact(); 
        con.LastName        = 'LastName';
        con.phone           ='123456789';
        con.RecordTypeId    = rt_Con_2_50;
        con.email           ='con@email.con';
        con.AccountId       = a.id;
        insert con;
        
        
        List<Enrollment_2_50__c> enrList2_50 = new List<Enrollment_2_50__c>();
        Enrollment_2_50__c enrl                     = new Enrollment_2_50__c();
        enrl.Account_Effective_Date__c              = system.today();
        enrl.Account_Number__c                      = '12345';
        enrl.Contracts__c                           = 2345678;
        enrl.External_Key__c                        = '1234test';        
        enrl.Status__c                              = 'Active';
        enrl.GP__c                                  = a.id;
        enrl.FSP__c                                 = a.id;
        enrl.AG__c                                  = a.id;
        enrl.SB__c                                  = con.id;        
        enrl.Rpt_Dt__c                              = '201412';
        enrl.Processed_Type__c                      = 'M';    //TPB 09/19/2014       
        enrList2_50.add(enrl);
        
        enrl                                        = new Enrollment_2_50__c();
        enrl.Account_Effective_Date__c              = system.today();
        enrl.Account_Number__c                      = '12345';
        enrl.Contracts__c                           = 23456781;
        enrl.External_Key__c                        = '1234test1';
        enrl.Status__c                              = 'Active';
        enrl.GP__c                                  = a.Id;
        enrl.FSP__c                                 = a.Id;
        enrl.AG__c                                  = a.Id;
        enrl.SB__c                                  = con.id;
        enrl.Rpt_Dt__c                              = '201411';
        enrl.Processed_Type__c                      = 'M';    
        
        enrList2_50.add(enrl);
        
        insert enrList2_50;
    }    
    */
         // Ashish Ojha Changes
    // Data Build for Enrollment__c
    public static void Create_Enrollment_Data() {
        //Create Enrollment_2_50 Data        
        Id rt_acc_2_50 = QueryBase.getRecordtypeId('Account', 'X2_50');
        Account a = new Account();
        a.Name = 'SomeTest' + Date.Today();
        a.Type = 'Customer';
        a.RecordTypeId = rt_acc_2_50;
        a.AccountNumber = '12345';
        insert a;
               
        Id rt_Con_2_50 = QueryBase.getRecordtypeId('Contact', 'X2_50');
        Contact con         = new Contact(); 
        con.LastName        = 'LastName';
        con.phone           ='123456789';
        con.RecordTypeId    = rt_Con_2_50;
        con.email           ='con@email.con';
        con.AccountId       = a.id;
        insert con;
        
        Opportunity o = new Opportunity();
        o.Name = 'OppTest' + Date.Today();  
        o.AccountId = a.id;
        o.StageName = 'Proposal';
        o.CloseDate = Date.Today();
        o.System__c = 'Facets';
        o.Facets_Grp_Num__c = 'X23C';        
        o.FullServiceProducer__c = 'Direct';        
        o.Contract_End_Date__c = Date.Today() + 365;
        insert o; 
        
        Id enr_acc_2_50 = QueryBase.getRecordtypeId('Enrollment__c', 'X2_50');
        List<Enrollment__c> enrList = new List<Enrollment__c>();
        Enrollment__c enrl                     = new Enrollment__c();
        enrl.Account_Number__c                      = '12345';
        enrl.Contracts__c                           = 2345678;
        enrl.Status__c                              = 'Active';
        enrl.GP__c                                  = a.id;
        enrl.FSP__c                                 = a.id;
        enrl.AG__c                                  = a.id;
        enrl.SB__c                                  = con.id;        
        enrl.Rpt_Dt__c                              = '201412';
        enrl.Processed_Type__c                      = 'M';    
        enrl.Opportunity__c                         = o.id;   
        enrl.RecordTypeId                           = enr_acc_2_50;   
        enrList.add(enrl);
        
        enrl                                        = new Enrollment__c();
        enrl.Account_Number__c                      = '12345';
        enrl.Contracts__c                           = 23456781;
        enrl.Status__c                              = 'Active';
        enrl.GP__c                                  = a.Id;
        enrl.FSP__c                                 = a.Id;
        enrl.AG__c                                  = a.Id;
        enrl.SB__c                                  = con.id;
        enrl.Rpt_Dt__c                              = '201411';
        enrl.Processed_Type__c                      = 'M';    
        enrl.Opportunity__c                         = o.id;
        enrl.RecordTypeId                           = enr_acc_2_50;
        enrList.add(enrl);
        
        insert enrList;
    }    
// Ashish Ojha Changes
    // Data Build for Enrollment__c
    public static void Create_Enrollment_Data_Shift() {
        //Create Enrollment_2_50 Data        
        Id rt_acc_2_50 = QueryBase.getRecordtypeId('Account', 'X2_50');
        Account a = new Account();
        a.Name = 'SomeTest' + Date.Today();
        a.Type = 'Customer';
        a.RecordTypeId = rt_acc_2_50;
        a.AccountNumber = '12345';
        insert a;
               
        Id rt_Con_2_50 = QueryBase.getRecordtypeId('Contact', 'X2_50');
        Contact con         = new Contact(); 
        con.LastName        = 'LastName';
        con.phone           ='123456789';
        con.RecordTypeId    = rt_Con_2_50;
        con.email           ='con@email.con';
        con.AccountId       = a.id;
        insert con;
        
        Opportunity o = new Opportunity();
        o.Name = 'OppTest' + Date.Today();  
        o.AccountId = a.id;
        o.StageName = 'Proposal';
        o.CloseDate = Date.Today();
        o.System__c = 'Facets';
        o.Facets_Grp_Num__c = 'X23D';        
        o.FullServiceProducer__c = 'Direct';        
        o.Contract_End_Date__c = Date.Today() + 365;
        insert o; 
        
        Id enr_acc_2_50 = QueryBase.getRecordtypeId('Enrollment__c', 'X2_50');
        Id enr_acc_51 = QueryBase.getRecordtypeId('Enrollment__c', 'X51+');
        List<Enrollment__c> enrList = new List<Enrollment__c>();
        Enrollment__c enrl                     = new Enrollment__c();
        enrl.Account_Number__c                      = '12345';
        enrl.Contracts__c                           = 2345678;
        enrl.Am_Name__c                             = 'Tester';
        enrl.Status__c                              = 'Active';
        enrl.GP__c                                  = a.id;
        enrl.FSP__c                                 = a.id;
        enrl.AG__c                                  = a.id;
        enrl.SB__c                                  = con.id;        
        enrl.Rpt_Dt__c                              = '201401';
        enrl.Processed_Type__c                      = 'M';    
        enrl.Opportunity__c                         = o.id;   
        enrl.RecordTypeId                           = enr_acc_2_50;   
        enrList.add(enrl);
        
        enrl                                        = new Enrollment__c();
        enrl.Account_Number__c                      = '12345';
        enrl.Contracts__c                           = 23456781;
        enrl.Status__c                              = 'Active';
        enrl.GP__c                                  = a.Id;
        enrl.FSP__c                                 = a.Id;
        enrl.AG__c                                  = a.Id;
        enrl.SB__c                                  = con.id;
        enrl.Rpt_Dt__c                              = '201403';
        enrl.Processed_Type__c                      = 'M';    
        enrl.Opportunity__c                         = o.id;
        enrl.Curr_Fiscal_Year__c                    =  '2014_Baseline';                
        enrl.Curr_Baseline_Compensation_Owner__c    = 'tester';
        enrl.Curr_Baseline_Contracts__c             = 2345668;

        enrList.add(enrl);
        
        
        insert enrList;
    }
// Data Build for Enrollment__c 51 + record type 
    public static void Create_Enrollment_Data_51() {
        //Create Enrollment_2_50 Data        
        Id rt_acc_2_50 = QueryBase.getRecordtypeId('Account', 'X51');
        Account a = new Account();
        a.Name = 'SomeTest' + Date.Today();
        a.Type = 'Customer';
        a.RecordTypeId = rt_acc_2_50;
        a.AccountNumber = '12345';
        insert a;
               
        Id rt_Con_2_50 = QueryBase.getRecordtypeId('Contact', 'X51');
        Contact con         = new Contact(); 
        con.LastName        = 'LastName';
        con.phone           ='123456789';
        con.RecordTypeId    = rt_Con_2_50;
        con.email           ='con@email.con';
        con.AccountId       = a.id;
        insert con;
        
        Opportunity o = new Opportunity();
        o.Name = 'OppTest' + Date.Today();  
        o.AccountId = a.id;
        o.StageName = 'Proposal';
        o.CloseDate = Date.Today();
        o.System__c = 'Facets';
        o.Facets_Grp_Num__c = 'X23E';        
        o.FullServiceProducer__c = 'Direct';        
        o.Contract_End_Date__c = Date.Today() + 365;
        insert o; 
        
        Id enr_acc_2_50 = QueryBase.getRecordtypeId('Enrollment__c', 'X2_50');
        Id enr_acc_51 = QueryBase.getRecordtypeId('Enrollment__c', 'X51');
        List<Enrollment__c> enrList = new List<Enrollment__c>();
        Enrollment__c enrl                     = new Enrollment__c();
        enrl.Account_Number__c                      = '12345';
        enrl.Contracts__c                           = 2345678;
        enrl.Status__c                              = 'Active';
        enrl.GP__c                                  = a.id;
        enrl.FSP__c                                 = a.id;
        enrl.AG__c                                  = a.id;
        enrl.SB__c                                  = con.id;        
        enrl.Rpt_Dt__c                              = '201401';
        enrl.Processed_Type__c                      = 'M';    
        enrl.Opportunity__c                         = o.id;   
        enrl.RecordTypeId                           = enr_acc_51;   
        enrList.add(enrl);
        
        enrl                                        = new Enrollment__c();
        enrl.Account_Number__c                      = '12345';
        enrl.Contracts__c                           = 23456781;
        enrl.Status__c                              = 'Active';
        enrl.GP__c                                  = a.Id;
        enrl.FSP__c                                 = a.Id;
        enrl.AG__c                                  = a.Id;
        enrl.SB__c                                  = con.id;
        enrl.Rpt_Dt__c                              = '201201';
        enrl.Processed_Type__c                      = 'M';    
        enrl.Opportunity__c                         = o.id;
        enrl.RecordTypeId                           = enr_acc_51;
        enrList.add(enrl);
        
        
        insert enrList;
    }
    // Data Build for Enrollment__c
    public static void Create_Enrollment_Data_EXC() {
        //Create Enrollment_2_50 Data        
        Id rt_acc_2_50 = QueryBase.getRecordtypeId('Account', 'X51');
        Account a = new Account();
        a.Name = 'SomeTest' + Date.Today();
        a.Type = 'Customer';
        a.RecordTypeId = rt_acc_2_50;
        a.AccountNumber = '12345';
        insert a;
               
        Id rt_Con_2_50 = QueryBase.getRecordtypeId('Contact', 'X51');
        Contact con         = new Contact(); 
        con.LastName        = 'LastName';
        con.phone           ='123456789';
        con.RecordTypeId    = rt_Con_2_50;
        con.email           ='con@email.con';
        con.AccountId       = a.id;
        insert con;
        
        Opportunity o = new Opportunity();
        o.Name = 'OppTest' + Date.Today();  
        o.AccountId = a.id;
        o.StageName = 'Proposal';
        o.CloseDate = Date.Today();
        o.System__c = 'Facets';
        o.Facets_Grp_Num__c = 'X23F';        
        o.FullServiceProducer__c = 'Direct';        
        o.Contract_End_Date__c = Date.Today() + 365;
        insert o; 
        
        Id enr_acc_2_50 = QueryBase.getRecordtypeId('Enrollment__c', 'X2_50');
        Id enr_acc_51 = QueryBase.getRecordtypeId('Enrollment__c', 'X51');
        List<Enrollment__c> enrList = new List<Enrollment__c>();
        Enrollment__c enrl                     = new Enrollment__c();
        enrl.Account_Number__c                      = '12345';
        enrl.Contracts__c                           = 2345678;
        enrl.Status__c                              = 'Active';
        enrl.GP__c                                  = a.id;
        enrl.FSP__c                                 = a.id;
        enrl.AG__c                                  = a.id;
        enrl.SB__c                                  = con.id;        
        enrl.Rpt_Dt__c                              = '201501';
        enrl.Processed_Type__c                      = 'M';    
        enrl.Opportunity__c                         = o.id;   
        enrl.RecordTypeId                           = enr_acc_51;   
        enrList.add(enrl);
        
        enrl                                        = new Enrollment__c();
        enrl.Account_Number__c                      = '12345';
        enrl.Contracts__c                           = 23456781;
        enrl.Status__c                              = 'Active';
        enrl.GP__c                                  = a.Id;
        enrl.FSP__c                                 = a.Id;
        enrl.AG__c                                  = a.Id;
        enrl.SB__c                                  = con.id;
        enrl.Rpt_Dt__c                              = '201501';
        enrl.Processed_Type__c                      = 'M';    
        enrl.Opportunity__c                         = o.id;
        enrl.RecordTypeId                           = enr_acc_51;
        enrList.add(enrl);
        
        
        insert enrList;
    }
    // Data Build for Account for Setting Ranking fields
  public static void createTestAccountsForRanking() {
        // Create some test accounts
        List<Account> accList = new List<Account>();
        Id rt_acc_2_50 = QueryBase.getRecordtypeId('Account', 'X2_50');
        Account a = new Account();
        a.Name = 'TestAccount1';
        a.Type = 'Partner';
        a.Entity_ID__c = '123456789';
        a.Entity_Type_AG__c = true;
        a.RecordTypeId = rt_acc_2_50;
        a.AG_Contracts_for_Year__c = 20;
        accList.add(a);
        
        a = new Account();
        a.Name = 'TestAccount2';
        a.Type = 'Partner';
        a.Entity_ID__c = '123459999';
        a.Entity_Type_FSP__c = true;
        a.RecordTypeId = rt_acc_2_50;
        accList.add(a);
        
        a = new Account();
        a.Name = 'TestAccount3';
        a.Type = 'Partner';
        a.Entity_ID__c = '555555555';
        a.Entity_Type_AG__c = true;
        a.RecordTypeId = rt_acc_2_50;
        accList.add(a);        
        insert acclist;            
        
    }
        // Data Build for Contact for Setting Ranking fields

    public static void createTestContactsForRanking() {
        // Create some test contacts
        
        Id rt_Con_2_50 = QueryBase.getRecordtypeId('Contact', 'X2_50');
        Id rt_Con_51 = QueryBase.getRecordtypeId('Contact', 'X51');        
        Insert new Contact[] { new Contact( AccountId = Account2_50_Default, FirstName = 'BrokerTest1',  LastName = 'BrokerTest1', Email = 'ba@ba1.com', phone = '123-123-3838', Employer_Group_Portal__c = FALSE, Entity_Id__c = '123456789', Entity_Type_SB__c=true, RecordTypeId = rt_Con_2_50,SB_Rank__C = 2,Contracts_for_Year__c = 20 ,Groups_for_Year__c = 10 ),                            
                               new Contact( AccountId = Account2_50_Default, FirstName = 'BrokerTest2',  LastName = 'BrokerTest2', Email = 'ba@ba2.com', phone = '123-123-1039', Employer_Group_Portal__c = FALSE, Entity_Id__c = '777777777', Entity_Type_SB__c=true, RecordTypeId = rt_Con_2_50 ,SB_Rank__C = 5, Contracts_for_Year__c = 30 , Groups_for_Year__c = 5)}; 
    }    
      
    // Data Build for Enrollment__c for Setting Ranking fields
    public static void createTestenrollmentsForRanking() {
        
        //Create Enrollment_2_50 Data   
        
             
        Id rt_acc_2_50 = QueryBase.getRecordtypeId('Account', 'X2_50');
        Account a = new Account();
        a.Name = 'SomeTest' + Date.Today();
        a.Type = 'Customer';
        a.RecordTypeId = rt_acc_2_50;
        a.AccountNumber = '12345';
        insert a;
               
        Id rt_Con_2_50 = QueryBase.getRecordtypeId('Contact', 'X2_50');
        Contact con         = new Contact(); 
        con.LastName        = 'LastName';
        con.phone           ='123456789';
        con.RecordTypeId    = rt_Con_2_50;
        con.email           ='con@email.con';
        con.AccountId       = a.id;
        insert con;
        
        Opportunity o = new Opportunity();
        o.Name = 'OppTest' + Date.Today();  
        o.AccountId = a.id;
        o.StageName = 'Proposal';
        o.CloseDate = Date.Today();
        o.System__c = 'Facets';
        o.Facets_Grp_Num__c = 'X23G';        
        o.FullServiceProducer__c = 'Direct';        
        o.Contract_End_Date__c = Date.Today() + 365;
        insert o; 
        
        Id enr_acc_2_50 = QueryBase.getRecordtypeId('Enrollment__c', 'X2_50');
        Id enr_acc_51 = QueryBase.getRecordtypeId('Enrollment__c', 'X51+');
        List<Enrollment__c> enrList = new List<Enrollment__c>();
        Enrollment__c enrl                     = new Enrollment__c();
        enrl.Account_Number__c                      = '12345';
        enrl.Contracts__c                           =  78;
        enrl.Status__c                              = 'Active';
        enrl.GP__c                                  = a.id;
        enrl.FSP__c                                 = a.id;
        enrl.AG__c                                  = a.id;
        enrl.SB__c                                  = con.id;        
        enrl.Rpt_Dt__c                              = '201601';
        enrl.Processed_Type__c                      = 'M';    
        enrl.Opportunity__c                         = o.id;   
        enrl.RecordTypeId                           = enr_acc_2_50;   
        enrList.add(enrl);
        
        enrl                                        = new Enrollment__c();
        enrl.Account_Number__c                      = '12345';
        enrl.Contracts__c                           = 23;
        enrl.Status__c                              = 'Active';
        enrl.GP__c                                  = a.Id;
        enrl.FSP__c                                 = a.Id;
        enrl.AG__c                                  = a.Id;
        enrl.SB__c                                  = con.id;
        enrl.Rpt_Dt__c                              = '201601';
        enrl.Processed_Type__c                      = 'M';    
        enrl.Opportunity__c                         = o.id;
        enrl.RecordTypeId                           = enr_acc_2_50;
        enrList.add(enrl);
        insert enrList;
     }
     // Ashish Ojha Changes
    // Data Build for Enrollment__c
    public static void Create_Enrollment_Data_OffAndOnCycle() {
        //Create Enrollment_2_50 Data        
        Id rt_acc_2_50 = QueryBase.getRecordtypeId('Account', 'X2_50');
        Account a = new Account();
        a.Name = 'SomeTest' + Date.Today();
        a.Type = 'Customer';
        a.RecordTypeId = rt_acc_2_50;
        a.AccountNumber = '12345';
        insert a;
               
        Id rt_Con_2_50 = QueryBase.getRecordtypeId('Contact', 'X2_50');
        Contact con         = new Contact(); 
        con.LastName        = 'LastName';
        con.phone           ='123456789';
        con.RecordTypeId    = rt_Con_2_50;
        con.email           ='con@email.con';
        con.AccountId       = a.id;
        insert con;
        
        Opportunity o = new Opportunity();
        o.Name = 'OppTest' + Date.Today();  
        o.AccountId = a.id;
        o.StageName = 'Proposal';
        o.CloseDate = Date.Today();
        o.System__c = 'Facets';
        o.Facets_Grp_Num__c = 'X23H';        
        o.FullServiceProducer__c = 'Direct';        
        o.Contract_End_Date__c = Date.Today() + 365;
        insert o; 
        
        Id enr_acc_2_50 = QueryBase.getRecordtypeId('Enrollment__c', 'X2_50');
        Id enr_acc_51 = QueryBase.getRecordtypeId('Enrollment__c', 'X51+');
        List<Enrollment__c> enrList = new List<Enrollment__c>();
        Enrollment__c enrl                     = new Enrollment__c();
        enrl.Account_Number__c                      = '12345';
        enrl.Contracts__c                           = 2345678;
        enrl.Am_Name__c                             = 'Tester';
        enrl.GP__c                                  = a.id;
        enrl.FSP__c                                 = a.id;
        enrl.AG__c                                  = a.id;
        enrl.SB__c                                  = con.id;        
        enrl.Rpt_Dt__c                              = '201401';
        enrl.Processed_Type__c                      = 'M';    
        enrl.Opportunity__c                         = o.id;
        enrl.Status__c                              = 'Termed';
        enrl.Termination_Date__c                    = Date.Today();
        enrl.On_cycle__c                            = False;   
        enrl.Reporting_checkbox_off_cycle__c         = TRUE;
        enrl.Reporting_checkbox__c                   = False;
        enrl.RecordTypeId                           = enr_acc_2_50;   
        enrList.add(enrl);
        
        enrl                                        = new Enrollment__c();
        enrl.Account_Number__c                      = '12345';
        enrl.Contracts__c                           = 23456781;
        enrl.Status__c                              = 'Termed';
        enrl.Termination_Date__c                    = Date.Today();
        enrl.On_cycle__c                            = TRUE;
        enrl.GP__c                                  = a.Id;
        enrl.FSP__c                                 = a.Id;
        enrl.AG__c                                  = a.Id;
        enrl.SB__c                                  = con.id;
        enrl.Rpt_Dt__c                              = '201411';
        enrl.Processed_Type__c                      = 'M';    
        enrl.Opportunity__c                         = o.id;
        enrl.Curr_Fiscal_Year__c                    =  '2014_Baseline';                
        enrl.Curr_Baseline_Compensation_Owner__c    = 'tester';
        enrl.Curr_Baseline_Contracts__c             = 2345668;
        enrl.Reporting_checkbox_off_cycle__c         = False;
        enrl.Reporting_checkbox__c                   = TRUE;
        enrList.add(enrl);
        
        
        insert enrList;
    }
     public static void createChatterGroups(){
        CollaborationGroup cgrp = new CollaborationGroup();
        cgrp.Name = 'SFDC ProcessesX';
        cgrp.CollaborationType = 'public';      
        insert cgrp;              
    }
     /*******************************************
     * Test Data for population of opportunity
       from 
        to BRF. IF BRF is created from
       PRF
     ******************************************/
     
     
    /*-----------------------------------------------------        
                        Rajesh Changes Starts
    -------------------------------------------------------*/
    //The Following Test Methods tests BRFTrigger And AIA_BRFTriggerHandler class.
    
    /*-----------------------Test Methods Starts Here for BRF Trigger------------------*/
    public static Account createAccount(String accountName)
    {
         // Create some test accounts
        Id rt_acc_51 = QueryBase.getRecordtypeId('Account', 'X51');
        //List<Account> accList = new List<Account>();
        Account a = new Account();
        a.Name = accountName;
        a.Type = 'Customer';
        a.RecordTypeId = rt_acc_51;      
        a.Renewal_Anniversary_Month__c='Jan';
        a.Account_Legal_Name__c= 'test Account';
        insert a;
        return a;
    }
    
    public static Opportunity CreateOpportunity(string aid){
        Opportunity opp = new Opportunity();
        opp.Name = 'Testopp';
        opp.AccountId = aid;
        opp.FullServiceProducer__c = 'testpro';
        opp.Legal_Account_Name_Verified__c=true;
        opp.Effective_Date__c = system.today().toStartofMonth();
        opp.CloseDate = opp.Effective_Date__c - 1;
        opp.Contract_End_Date__c = opp.Effective_Date__c.addMonths(1)-1;
        opp.StageName = 'test';
        insert opp;
        return opp;
    }
    public static PRF__c CreatePRF(string oid){
        PRF__c prf = new PRF__c();
        prf.Name = 'testprf';
        prf.Opportunity__c = oid;
        insert prf;
        return prf;
    }
    public static AIA_Implementation__c CreateImp(string oid){
        AIA_Implementation__c Imp = new AIA_Implementation__c();
        Imp.Name__c = 'testprf';
        Imp.Opportunity__c = oid;
        Imp.Generate_Workplan_Stages__c = true;
        Imp.Effective_Date__c = system.today();
        Imp.Implementation_Plan_Timeline_Days__c = '60';
        insert Imp;
        return Imp;
    }
    public static Benfit_Request_Form__c CreateBRF(string pid,string aid){
        Benfit_Request_Form__c nbrf = new Benfit_Request_Form__c();
        if(pid != null)
        nbrf.Proposal_Request_Form__c = pid;
        nbrf.Contract_Count__c = 123;
        nbrf.Benefit_Effective_Date__c = system.today();
        nbrf.Account__c = aid;
        nbrf.ARC_Approval_Status__c = 'Approved by Committee';
        nbrf.Escalated_to_Senior_Management__c = true;
        nbrf.Status__c = 'new';
        insert nbrf;
        return nbrf;
    }
    //Create FileNet document
    public static void createAIADocument(Benfit_Request_Form__c brf){
        AIA_Document__c fileNetDoc = new AIA_Document__c();
        fileNetDoc.Document_Type__c='Signed Quote';
        fileNetDoc.Benefit_Request_Form__c = brf.id;
        insert fileNetDoc;
    }
    public static Benfit_Request_Form__c updateBRF(string pid,string aid,string brfid){
        Benfit_Request_Form__c ubrf = new Benfit_Request_Form__c();
        ubrf.Id = brfid;
        ubrf.Proposal_Request_Form__c = pid;
        ubrf.Contract_Count__c = 123;
        ubrf.Benefit_Effective_Date__c = system.today();
        ubrf.Account__c = aid;
        ubrf.ARC_Approval_Status__c = 'Approved by Committee';
        ubrf.Escalated_to_Senior_Management__c = true;
        ubrf.Status__c = 'sold';
        insert ubrf;
        return ubrf;
    }
    /*-----------------------Test Methods End Here for BRF Trigger------------------*/
    
    //This Test Methods tests WorkplanStageTrigger And its Handler Classes
    
    /*-----------------------Test Methods Starts Here for WorkplanStageTrigger------------------*/
    
    public static List<Opportunity> createOpps(string aid){       
        List<Opportunity> opplst =new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = 'Testopp';
        opp.AccountId = aid;
        opp.FullServiceProducer__c = 'testpro';
        opp.Legal_Account_Name_Verified__c=true;
        opp.Effective_Date__c = system.today().toStartofMonth();
        opp.CloseDate = opp.Effective_Date__c - 1;
        opp.Contract_End_Date__c = opp.Effective_Date__c.addMonths(1)-1;
        opp.StageName = 'test';
        opplst.add(opp);
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Testopp1';
        opp1.AccountId = aid;
        opp1.FullServiceProducer__c = 'testpro';
        opp1.Legal_Account_Name_Verified__c=true;
        opp1.Effective_Date__c = system.today().toStartofMonth();
        opp1.CloseDate = opp.Effective_Date__c - 1;
        opp1.Contract_End_Date__c = opp.Effective_Date__c.addMonths(1)-1;
        opp1.StageName = 'test';
        opplst.add(opp1);
        insert opplst;
        return opplst;
    }
    public static List<Workplan_Stage__c> createParentWPS(){
        List<Workplan_Stage__c> pwpslst = new List<Workplan_Stage__c>();
        Workplan_Stage__c ws = new Workplan_Stage__c();
        ws.Status__c = 'Not Started';
        pwpslst.add(ws);
        
        Workplan_Stage__c ws1 = new Workplan_Stage__c();
        ws1.Status__c = 'Not Started';
        pwpslst.add(ws1);
        insert pwpslst;
        return pwpslst;
    }
    public static List<Workplan_Stage__c> createChildOldWPS(List<Workplan_Stage__c> pwpslst1,List<Opportunity> olst){
        Schema.DescribeSObjectResult WPSdSobjres = Schema.SObjectType.Workplan_Stage__c; 
        Map<String,Schema.RecordTypeInfo> WPSRecordType = WPSdSobjres.getRecordTypeInfosByName(); 
        Id SubProcesswpsRtid = WPSRecordType.get('Sub-Process').getRecordTypeId();
        
        List<Workplan_Stage__c> cowpslst = new List<Workplan_Stage__c>();
        
        Workplan_Stage__c ws2 = new Workplan_Stage__c();
        ws2.Status__c = 'Not Started';
        ws2.RecordTypeID = SubProcesswpsRtid;
        ws2.Parent_Workplan_Stage__c = pwpslst1[0].Id;
        ws2.of_Total_Tasks__c = 2;
        ws2.of_Completed_Tasks__c = 1;
        ws2.Opportunity__c = olst[0].Id;
        cowpslst.add(ws2);
        
        Workplan_Stage__c ws3 = new Workplan_Stage__c();
        ws3.Status__c = 'Not Started';
        ws3.RecordTypeID = SubProcesswpsRtid;
        ws3.Parent_Workplan_Stage__c = pwpslst1[1].Id;
        ws3.of_Total_Tasks__c = null;
        ws3.of_Completed_Tasks__c = null;
        ws3.Opportunity__c = olst[1].Id;
        cowpslst.add(ws3);
        insert cowpslst;
        return cowpslst;
    }
    public static List<Workplan_Stage__c> createChildWPS(List<Workplan_Stage__c> pwpslst1){
        Schema.DescribeSObjectResult WPSdSobjres = Schema.SObjectType.Workplan_Stage__c; 
        Map<String,Schema.RecordTypeInfo> WPSRecordType = WPSdSobjres.getRecordTypeInfosByName(); 
        Id ProcesswpsRtid = WPSRecordType.get('Process').getRecordTypeId();
        List<Workplan_Stage__c> cwpslst = new List<Workplan_Stage__c>();
        Workplan_Stage__c ws4 = new Workplan_Stage__c();
        ws4.Status__c = 'Not Started';
        ws4.RecordTypeID = ProcesswpsRtid;
        ws4.Parent_Workplan_Stage__c = pwpslst1[0].Id;
        ws4.of_Total_Tasks__c = 3;
        ws4.of_Completed_Tasks__c = 1;
        cwpslst.add(ws4);
        
        Workplan_Stage__c ws5 = new Workplan_Stage__c();
        ws5.Status__c = 'Not Started';
        ws5.RecordTypeID = ProcesswpsRtid;
        ws5.Parent_Workplan_Stage__c = pwpslst1[1].Id;
        ws5.of_Total_Tasks__c = null;
        ws5.of_Completed_Tasks__c = null;
        cwpslst.add(ws5);
        
        Workplan_Stage__c ws6 = new Workplan_Stage__c();
        ws6.Status__c = 'Not Started';
        ws6.RecordTypeID = ProcesswpsRtid;
        ws6.Parent_Workplan_Stage__c = pwpslst1[1].Id;
        ws6.of_Total_Tasks__c = null;
        ws6.of_Completed_Tasks__c = null;
        cwpslst.add(ws6);
        insert cwpslst;
        return cwpslst;
    }
    public static void updatePWPS(list<Workplan_Stage__c> colst,list<Workplan_Stage__c> cnlst){
        colst[0].Status__c = 'Completed';
        colst[1].Status__c = 'Not Required';
        cnlst[0].Status__c = 'Completed';
        cnlst[1].Status__c = 'Not Required';
        cnlst[2].Status__c = 'In Progress';
        update colst;
        update cnlst;
    }
    public static void deleteWPS(list<Workplan_Stage__c> dnlst){
        delete dnlst;
    }
    /*-----------------------Test Methods Ends Here for WorkplanStageTrigger------------------*/
    
 
    //This Test Methods tests WorkplanAssignmentTrigger And AIA_WorkplanAssignmentTriggerHandler Class. 
    
    /*-----------------------Test Methods starts Here for WorkplanAssignmentTrigger------------------*/
    public static List<Workplan_Stage__c> createWPS(){
        List<Workplan_Stage__c> wpslst = new List<Workplan_Stage__c>();
        Workplan_Stage__c ws = new Workplan_Stage__c();
        ws.Status__c = 'Not Started';
        ws.End_Date__c = system.today();
        wpslst.add(ws);
        
        Workplan_Stage__c ws1 = new Workplan_Stage__c();
        ws1.Status__c = 'Not Started';
        ws1.End_Date__c = system.today();
        wpslst.add(ws1);
        
        Workplan_Stage__c ws2 = new Workplan_Stage__c();
        ws2.Status__c = 'Not Started';
        ws2.End_Date__c = system.today();
        wpslst.add(ws2);
        
        Workplan_Stage__c ws3 = new Workplan_Stage__c();
        ws3.Status__c = 'Not Started';
        ws3.End_Date__c = system.today();
        wpslst.add(ws3);
        
        Workplan_Stage__c ws4 = new Workplan_Stage__c();
        ws4.Status__c = 'Not Started';
        ws4.End_Date__c = system.today();
        wpslst.add(ws4);
        
        Workplan_Stage__c ws5 = new Workplan_Stage__c();
        ws5.Status__c = 'Not Started';
        ws5.End_Date__c = system.today();
        wpslst.add(ws5);
        insert wpslst;
        return wpslst;
    }
    public static List<PRF__c> createPRF(){
        List<PRF__c> prflst = new List<PRF__c>();
        
        PRF__c prf1 = new PRF__c();
        prf1.Name = 'testprf1';
        prflst.add(prf1);
        
        PRF__c prf2 = new PRF__c();
        prf2.Name = 'testprf2';
        prflst.add(prf2);
        
        PRF__c prf3 = new PRF__c();
        prf3.Name = 'testprf3';
        prflst.add(prf3);
        
        insert prflst;
        return prflst;
    }
    public static List<AIA_Workplan_Assignment__c> createWPA(List<Workplan_Stage__c> wpslst,List<PRF__c> prflst){
        List<AIA_Workplan_Assignment__c>  walst = new List<AIA_Workplan_Assignment__c>();
        
        AIA_Workplan_Assignment__c wa = new AIA_Workplan_Assignment__c();
        wa.Status__c = 'In Progress';
        wa.Workplan_Stage__c = wpslst[0].Id;
        wa.Proposal_Request_form__c = prflst[0].Id;
        walst.add(wa);
        
        AIA_Workplan_Assignment__c wa1 = new AIA_Workplan_Assignment__c();
        wa1.Status__c = 'In Progress';
        wa1.Workplan_Stage__c = wpslst[1].Id;
        wa1.Proposal_Request_form__c = prflst[1].Id;
        walst.add(wa1);
        
        AIA_Workplan_Assignment__c wa2 = new AIA_Workplan_Assignment__c();
        wa2.Status__c = 'In Progress';
        wa2.Workplan_Stage__c = wpslst[2].Id;
        wa2.Proposal_Request_form__c = prflst[2].Id;
        walst.add(wa2);
        
        AIA_Workplan_Assignment__c wa3 = new AIA_Workplan_Assignment__c();
        wa3.Status__c = 'In Progress';
        wa3.Workplan_Stage__c = wpslst[3].Id;
        wa3.Proposal_Request_form__c = prflst[0].Id;
        walst.add(wa3);
        
        AIA_Workplan_Assignment__c wa4 = new AIA_Workplan_Assignment__c();
        wa4.Status__c = 'In Progress';
        wa4.Workplan_Stage__c = wpslst[4].Id;
        wa4.Proposal_Request_form__c = prflst[1].Id;
        walst.add(wa4);
        
        AIA_Workplan_Assignment__c wa5 = new AIA_Workplan_Assignment__c();
        wa5.Status__c = 'In Progress';
        wa5.Workplan_Stage__c = wpslst[5].Id;
        wa5.Proposal_Request_form__c = prflst[2].Id;
        walst.add(wa5);
        
        insert walst;
        return walst;
    }
    public static List<AIA_Workplan_Assignment__c> updateWPA(List<AIA_Workplan_Assignment__c> wpalst){
        wpalst[0].Status__c = 'In Progress';
        wpalst[1].Status__c = 'Sent';        
        wpalst[2].Status__c = 'Accepted';
        wpalst[3].Status__c = 'Completed';        
        wpalst[4].Status__c = 'Not Required';
        wpalst[5].Status__c = 'Completed';
        
        update wpalst;
        return wpalst; 
    }
    public static void deleteWPA(List<AIA_Workplan_Assignment__c> wpalst){
        delete wpalst;
    }
    /*-----------------------Test Methods Ends Here for WorkplanAssignmentTrigger------------------*/
 
 
    //This Test Method tests WorkplanTypeAssignmentTrigger And AIA_WorkplanTypeAssignmentTriggerHandler Class.
    
    /*-----------------------Test Methods starts Here for WorkplanTypeAssignmentTrigger------------------*/
    public static List<Group> createGroup(List<string> stn,string typ){
        List<Group> Glst = new List<Group>();
        for(string s:stn){
            Group g = new Group();
            g.Name = s;
            g.type = typ;
            Glst.add(g);
        }
        insert Glst;
        return Glst;
    }
    public static List<QueuesObject> createQueues(List<Group> gids,string typ){
        List<QueuesObject> Qlst = new List<QueuesObject>();
        for(Group g:gids){
            QueuesObject q = new QueueSObject();
            q.QueueID = g.id;
            q.SobjectType = typ;
            Qlst.add(q);
        }
        insert Qlst;
        return Qlst;
    }
    public static AIA_Workplan_Type__c createWPT(){
        AIA_Workplan_Type__c wpt = new AIA_Workplan_Type__c();
        insert wpt;
        return wpt;
    }
    public static Workplan_Type_Stage__c createWPTS(string wptid){
        Workplan_Type_Stage__c wpts = new Workplan_Type_Stage__c();
        wpts.Workplan_Type__c = wptid;
        insert wpts;
        return wpts;
    }
    public static List<AIA_Workplan_Type_Task__c> createWPTT(string wptsid){
        List<AIA_Workplan_Type_Task__c> wpttlst = new List<AIA_Workplan_Type_Task__c>();
        AIA_Workplan_Type_Task__c wptt1 = new AIA_Workplan_Type_Task__c();
        wptt1.Workplan_Type_Stage__c = wptsid;
        wptt1.Queue_Name__c = '';
        wpttlst.add(wptt1);
            
        AIA_Workplan_Type_Task__c wptt2 = new AIA_Workplan_Type_Task__c();
        wptt2.Workplan_Type_Stage__c = wptsid;
        wptt2.Queue_Name__c = 'TestQ2';
        wpttlst.add(wptt2);
            
        AIA_Workplan_Type_Task__c wptt3 = new AIA_Workplan_Type_Task__c();
        wptt3.Workplan_Type_Stage__c = wptsid;
        wptt3.Queue_Name__c = 'TestQ3';
        wpttlst.add(wptt3);
        
        insert wpttlst;
        return wpttlst;
    }
    public static List<AIA_Workplan_Type_Task__c> updateWPTT(List<AIA_Workplan_Type_Task__c> ulst){
        ulst[0].Queue_Name__c = '';
        ulst[1].Queue_Name__c = 'TestQ5';
        ulst[2].Queue_Name__c = 'TestQ6';
        update ulst;
        return ulst;
    }
    /*-----------------------Test Methods Ends Here for WorkplanTypeAssignmentTrigger------------------*/
    
    /*-----------------------------------------------------        
                        Rajesh Changes Ends
    -------------------------------------------------------*/
    
      //Goutham Changes
    //This Test Method tests BRFTrigger And AIA_BRFCloneWithProductsCX class.
    public static void AIA_BRFCloneWithProductsCX_Test(){
    
        // setup account and opportunity
        Account acct = new Account(); 
        acct.Name = 'TestAccount';
        acct.NumberOfEmployees = 45; // Num employees should always be <= 50
        acct.Sic = '0111';
        acct.EIN__c = '123456789'; // Has field validation, cannot be longer than 9 chars
        acct.BillingStreet = '1660 International Drive St. #518 Ste.500e ' +
        '1660 International Drive St. #518 Ste.500e' +
        '1660 International Drive St. #518 Ste.500e';
        acct.BillingCity = 'McLean123456789012345678902345678901';
        acct.BillingState = 'VA';
        acct.BillingPostalCode = '22102-4501'; // Has a validation rule in place 
        acct.Billing_County_Code__c = 'DCMD';
        acct.Renewal_Anniversary_Month__c = 'Nov';
        acct.Account_Legal_Name__c= 'test Account';
        insert acct;
        
        //Insert Test Record For Opportunity
        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.FullServiceProducer__c = 'BenefitMall'; // Validation rule where I cannot leave this blank
        opp.StageName = 'Proposal';
        opp.CloseDate = Date.today() + 7;
        opp.AccountId = acct.Id;
        opp.Market_Segment_New__c = '51-199';
        opp.Business_type__c = 'Renewal';
        opp.Division__c = '51-199 New Business';
        opp.Legal_Account_Name_Verified__c =true;
        opp.Underwriting_Entity__c = 'NCAS';
        opp.Effective_Date__c =  Date.newInstance(2014,10,1);  // validation rule requires effective date be 1st of month
        opp.CloseDate = opp.Effective_Date__c.addDays(-11);  // validation rule requires effective date be after close date i.e. effective > closedate
        opp.Contract_End_Date__c = opp.Effective_Date__c.addMonths(1);  // VR requires contract_end_date > effective_date and contract_end_date be last day of a month
        opp.Contract_End_Date__c = opp.Contract_End_Date__c.addDays(-1);
        insert opp;

        // create a Benfit_Request_Form__c
        Benfit_Request_Form__c BRF = new Benfit_Request_Form__c();
        BRF.Opportunity__c = opp.id;
        BRF.Benefit_Effective_Date__c = system.today();
        BRF.Contract_Count__c = 14;
        BRF.Broker_Commission__c =31.0;
        BRF.Renewal_Date__c = system.today();
        BRF.Account__c = acct.id;
        BRF.Funding_Arrangements__c = 'Other';
        insert BRF;

        // create a BRF Proposed Products record
        Proposed_Products__c pp = new Proposed_Products__c();
        pp.Benefit_Request_Form__c = BRF.id;
        insert pp;

}       
    //Chida to test implemenation
    
    public static void AIA_Implemenation_Test (){ 
    
    Account acc = new Account();
        acc.Name = 'testAcc';
        acc.Type = 'testType';
        acc.Account_Legal_Name__c='Legal';
        insert acc;

    //Insert Test Record For Opportunity
        Opportunity opp = new Opportunity();
        opp.Name = 'Testopp';
        opp.AccountId = acc.id;
        opp.FullServiceProducer__c = 'testpro';
        opp.Legal_Account_Name_Verified__c=true;
        opp.Effective_Date__c = system.today().toStartofMonth();
        Integer numberOfDays = Date.daysInMonth(Date.Today().year(), Date.Today().month());     
        opp.Contract_End_Date__c = Date.newInstance(Date.Today().year(), Date.Today().month(), numberOfDays);
        opp.CloseDate = Date.Today() - 34;
        opp.StageName = 'test';
        insert opp;    
    //Insert test Account for Opportunity
      //  Account acc = new Account();
      AIA_Implementation__c Imp=new AIA_Implementation__c();
    //    acc.Name = 'testAcc';
     //   acc.Type = 'testType';
        Imp.Name__c = 'Test10';
        Imp.Opportunity__c = opp.id;
        AIA_Workplan_Type__c wpt = AIA_CreateWorkPlan();
        Imp.Workplan_Type__c =wpt.id;
        Imp.Generate_Workplan_Stages__c = true;
        insert Imp;
        
        
        event e =new event();
        e.recordTypeId=QueryBase.getRecordtypeId('Event', 'AIA_Open_Enrollment_Meeting');
        e.Implementation__c = imp.id;
        e.whatId = imp.id;
        e.durationinminutes=90;
        e.activityDateTime =system.now();
        e.subject='TestOpenEvent';
        e.capacity__C=1;        
        insert e;       
        
    }
    
    public static void AIA_CreateEvents(){
        Account acc =createAccount('TestOEMAcc');
        Opportunity opp =AIA_createopportunity(acc.id);
        AIA_Implementation__c imp = CreateImplementation(opp.id);
        list<event> eventList = new list<event>();
        event e =new event();
        e.recordTypeId=QueryBase.getRecordtypeId('Event', 'AIA_Open_Enrollment_Meeting');
        e.Implementation__c = imp.id;
        e.whatId = imp.id;
        e.durationinminutes=90;
        e.activityDateTime =system.now();
        e.subject='TestOpenEvent';
        e.capacity__C=1;
        e.Meeting_Status1__c='Open';
        eventList.add(e);
        
        e =new event();
        e.recordTypeId=QueryBase.getRecordtypeId('Event', 'AIA_Open_Enrollment_Meeting');
        e.Implementation__c = imp.id;
        e.whatId = imp.id;
        e.durationinminutes=90;
        e.activityDateTime =system.now();
        e.subject='TestFullEvent';
        e.capacity__C=1;
        e.Meeting_Status1__c='Full';
        eventList.add(e);
        
        e =new event();
        e.recordTypeId=QueryBase.getRecordtypeId('Event', 'AIA_Open_Enrollment_Meeting');
        e.Implementation__c = imp.id;
        e.whatId = imp.id;
        e.durationinminutes=90;
        e.activityDateTime =system.now();
        e.subject='TestCompletedEvent';
        e.capacity__C=1;
        e.Meeting_Status1__c='Completed';
        eventList.add(e);
        insert eventList;
    }
    
    public static void createContract(){
        //Create Account
        Account acc =createAccount('TestOEMAcc');
        //Create Opportunity
        Opportunity opp =AIA_createopportunity(acc.id);     
        //Create testusers
        List<user> userList = new list<user>();
        user u1 = AIA_createUser('alias1');
        userList.add(u1);
        user u2 = AIA_createUser('alias2');
        userList.add(u2);        
        user u3 = AIA_createUser('alias3');
        userList.add(u3);        
        user u4 = AIA_createUser('alias4');
        userList.add(u4);        
        user u5 = AIA_createUser('alias5');
        userList.add(u5); 
        insert userList;       
        
        //Create Account teams for all the relevant roles
        AIA_createAccountTeamMember(acc.Id, u1.id, 'Audit');
        AIA_createAccountTeamMember(acc.Id, u2.id, 'C&C Contact');
        AIA_createAccountTeamMember(acc.Id, u3.id, 'Contract Supervisor');
        AIA_createAccountTeamMember(acc.Id, u4.id, 'Legal');
        AIA_createAccountTeamMember(acc.Id, u5.id, 'Sales Service Rep');        
        
        //Create an Implementation
        AIA_Implementation__c Imp = new AIA_Implementation__c();
        Imp.Name__c = 'testprf';
        Imp.Opportunity__c = opp.Id;
        Imp.account__c = acc.id;
        Imp.Generate_Workplan_Stages__c = true;
        Imp.Effective_Date__c = system.today();
        Imp.Implementation_Plan_Timeline_Days__c = '60';
        insert Imp;
        
        //Create the contract
        contract contractRec = new contract();
        contractRec.accountId=acc.Id;
        contractRec.StartDate=system.today();
        contractRec.ContractTerm=3;
        contractRec.Implementation__c=imp.id;
        insert contractRec;
    }
        
     
    public static User createTestUser(){ 
        Profile pro = [SELECT Id FROM Profile WHERE Name='AIA 200+ Standard User - Custom']; 
        User u = new User(Alias = 'TAlias', Email='TestUserBRF@testorg.com',
        EmailEncodingKey='UTF-8', LastName='TestingUSer', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = pro.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='TestingUserBRF@testorg.com');
        return u;
     }  
     public static AIA_Document__c createAIADocument(){ 
        AIA_Document__c aiaDoc = new AIA_Document__c();
        aiaDoc.Document_Status__c = 'Complete';
        aiaDoc.Document_Type__c = 'Additional Documentation';
        aiaDoc.Active__c = True;
        aiaDoc.Start_Date__c = System.today();
        aiaDoc.End_Date__c = System.today()+10;
        aiaDoc.Approval_Status__c = 'Pending';
        insert aiaDoc;
        return aiaDoc;
     } 
     
     public static Proposed_Products__c createProposedProducts(string BRFID){ 
        Proposed_Products__c pp = new Proposed_Products__c();
        pp.Benefit_Request_Form__c = BRFID;
        pp.Blue_Rewards__c ='No';
        insert pp;
        return pp;
     } 
     
      public static List<Proposed_Products__c> createListProposedProducts(string BRFID,string testResult){ 
        List<Proposed_Products__c> ppList = new List<Proposed_Products__c>();
        for(integer i=1;i<10;i++){
            Proposed_Products__c pp = new Proposed_Products__c();
            pp.Benefit_Request_Form__c = BRFID;
            pp.Blue_Rewards__c ='No';
            pp.MHP_Test_Result__c = testResult;
            ppList.add(pp);
        }
        insert ppList;
        return ppList;
     } 
     
     public static AIA_Benefit_Design__c createBenefitDesign(string oppId){ 
        AIA_Implementation__c Imp = new AIA_Implementation__c();
        Imp.Name__c = 'testprf';
        Imp.Opportunity__c = oppId;
        Imp.Generate_Workplan_Stages__c = true;
        Imp.Effective_Date__c = system.today();
        Imp.Implementation_Plan_Timeline_Days__c = '60';
        insert Imp;
        
        AIA_Benefit_Design__c aiaBD = new AIA_Benefit_Design__c();
        aiaBD.Implementation__c = Imp.id;
        insert aiaBD;
        return aiaBD;
     }  
     
     public static AIA_Workplan_Assignment__c createWPAssignment(List<Workplan_Stage__c> wpslst,string prfId){
        
        AIA_Workplan_Assignment__c wa = new AIA_Workplan_Assignment__c();
        wa.Status__c = 'In Progress';
        wa.Workplan_Stage__c = wpslst[0].Id;
        wa.Proposal_Request_form__c = prfId;
        insert wa;
        return wa;
     }
     
     public static List<AIA_Implementation__c> CreateImpList(string oid){
        AIA_Workplan_Type__c wpt = new AIA_Workplan_Type__c();
        wpt.Used_For__c ='Pre-Sales';
        wpt.Workplan_Type__c = 'Renewal';
        wpt.Used_For__c = 'Implementation';
        wpt.Active__c=true;
        insert wpt;
        
        Workplan_Type_Stage__c wpts = new Workplan_Type_Stage__c();
        wpts.Workplan_Type__c = wpt.id;
        wpts.Active__c = true;
        insert wpts; 
        
        List<AIA_Implementation__c> ImpList = new List<AIA_Implementation__c>();
        for(integer i=1;i<10;i++){
            AIA_Implementation__c Imp = new AIA_Implementation__c();
            Imp.Name__c = 'testprf';
            Imp.Opportunity__c = oid;
            Imp.Generate_Workplan_Stages__c = true;
            Imp.Effective_Date__c = system.today();
            Imp.Implementation_Plan_Timeline_Days__c = '60';
            Imp.Workplan_Type__c = wpt.id;
            Imp.Generate_Workplan_Stages__c = true;
            ImpList.add(Imp);
        }
        insert ImpList;
        return ImpList;
    } 
    
    public static AIA_Implementation__c CreateImplementation(string oid){
      
        AIA_Workplan_Type__c wpt = new AIA_Workplan_Type__c();
        wpt.Used_For__c ='Pre-Sales';
        wpt.Workplan_Type__c = 'Renewal';
        wpt.Used_For__c = 'Implementation';
        wpt.Active__c=true;
        insert wpt;
        
        Workplan_Type_Stage__c wptsObj = new Workplan_Type_Stage__c();
        wptsObj.Workplan_Type__c = wpt.id;
        wptsObj.Active__c = true;
        insert wptsObj; 
        
        Id wps_RTID = QueryBase.getRecordtypeId('Workplan_Stage__c', 'Process');
        AIA_Implementation__c Imp = new AIA_Implementation__c();
        Imp.Name__c = 'testprf';
        Imp.Opportunity__c = oid;
        Imp.Generate_Workplan_Stages__c = true;
        Imp.Effective_Date__c = system.today();
        Imp.Implementation_Plan_Timeline_Days__c = '60';
        Imp.Workplan_Type__c = wpt.id;
        Imp.Generate_Workplan_Stages__c = true;
        insert Imp;
        
        Workplan_Stage__c wpts = new Workplan_Stage__c();
        wpts.Workplan_Type__c = wpt.id;
        wpts.Workplan_Type_Stage__c = wptsObj.id;
        wpts.Implementation__c = Imp.id;
        wpts.Status__c = 'Completed';
        wpts.recordTypeId =wps_RTID;
        insert wpts; 
        
        Workplan_Stage__c wpts1 = new Workplan_Stage__c();
        wpts1.Workplan_Type__c = wpt.id;
        wpts1.Workplan_Type_Stage__c = wptsObj.id;
        wpts1.Implementation__c = Imp.id; 
        wpts1.Parent_Workplan_Stage__c = wpts.id;
        wpts1.Status__c = 'Not Started';
        insert wpts1; 
        
        return Imp;
    } 
    public static AccountTeamMember AIA_createAccountTeamMember(string accId, string usrId, string strRole){
        AccountTeamMember acctMbr = new AccountTeamMember(); 
        acctMbr.AccountId = accId;
        acctMbr.TeamMemberRole = strRole;
        acctMbr.UserId = usrId;
        insert acctMbr;
        return acctMbr;
    }   
}