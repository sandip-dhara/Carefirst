@isTest
public with sharing class AIA_BRFCloneWithProductsCX_Test {

    static testMethod void testBRFCloneWithProductsCX() {

       // setup a reference to the page the controller is expecting with the parameters
        PageReference pref = Page.AIA_BRFCloneWithProducts;
        Test.setCurrentPage(pref);

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
        insert BRF;

        // create a BRF Products record
        Proposed_Products__c pp = new Proposed_Products__c();
        pp.Benefit_Request_Form__c = BRF.id;
        insert pp;

        // Construct the standard controller
        ApexPages.StandardController con = new ApexPages.StandardController(BRF);

        // create the controller
        AIA_BRFCloneWithProductsCX ext = new AIA_BRFCloneWithProductsCX(con);

        // Switch to test context
        Test.startTest();

        // call the cloneWithProducts method
        PageReference ref = ext.cloneWithProducts();
        // create the matching page reference
        PageReference redir = new PageReference('/'+ext.newBRF.id+'/e?retURL=%2F'+ext.newBRF.id);

        // make sure the user is sent to the correct url
        System.assertEquals(ref.getUrl(),redir.getUrl());

        // check that the new Benfit_Request_Form__c was created successfully
        Benfit_Request_Form__c newBRF = [select id from Benfit_Request_Form__c where id = :ext.newBRF.id];
        System.assertNotEquals(newBRF, null);
        // check that the line item was created
        List<Proposed_Products__c> newItems = [Select p.Id From Proposed_Products__c p where Benefit_Request_Form__c = :newBRF.id];
        System.assertEquals(newItems.size(),1);

        // Switch back to runtime context
        Test.stopTest();

    }

}