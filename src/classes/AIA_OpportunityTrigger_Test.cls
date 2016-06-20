/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AIA_OpportunityTrigger_Test{
    static testMethod void testMarkOpportunitySold(){
        Test.startTest();       
        Account testacct1 = new Account();
        testacct1.Name = 'TestAccount4';
        testacct1.Type = 'Customer';
        insert testacct1;
        
        Id rt_opp_200= QueryBase.getRecordtypeId('Opportunity', 'AIA_200');
                
         // Opportunity has a NASCO System and an associated NASCO group ID
        Opportunity testOpp1 = new Opportunity();
        testOpp1.RecordTypeId = rt_opp_200;

         
        testOpp1.Name = 'Test Opportunity1';
        testopp1.AccountId = testacct1.Id;
        testOpp1.StageName ='Proposal';    
        testOpp1.CloseDate = Date.today()-90;
        testOpp1.SBU__c = 'Small/Medium';
        testopp1.Market_Segment_New__c = '51-199';
        testopp1.Business_type__c = 'Renewal';
        testopp1.Division__c = '51-199 Renewals';   
        testopp1.Underwriting_Entity__c = 'MD';
        //testopp1.Lead_Rep_Name_User__c = salesUser.Id;
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
        insert testopp1;

        //testOppsList.add(testOpp1);
        
        //insert test record for Proposal Request Form
        PRF__c prf = new PRF__c();
        prf.Name = 'testprf';
        prf.Opportunity__c = testOpp1.id;
        insert prf;
        
        //insert test record for Benefit Request Form
        Benfit_Request_Form__c nbrf = new Benfit_Request_Form__c();
        nbrf.Proposal_Request_Form__c = prf.id;
        nbrf.Opportunity__c = testOpp1.id;
        nbrf.Contract_Count__c = 123;
        nbrf.Benefit_Effective_Date__c = system.today();
        nbrf.Renewal_Date__c = system.today();
        nbrf.Status__c='Sold';
        insert nbrf;
        
         //Update Opportunity to Sold
                             
        Opportunity QueriedOpp = [Select Id,name from Opportunity where id=:testOpp1.Id];
        QueriedOpp.StageName = 'Sold';
        Update QueriedOpp;
        
         Test.stopTest();
               
        }
}