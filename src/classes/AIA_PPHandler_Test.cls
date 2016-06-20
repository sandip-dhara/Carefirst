//===================================================================================
//Date: 05/09/2016
//Developer: Sree Harsha Akkala
//Purpose: Test class for PPhandler.
//=========================================================================================
// Update History
// Date         Developer               Description
// 5/25/2016     PR                     Commented on line 44,35,37
//==================================================================================
//05/09/2016    Sree Harsha Akkala      Initial Development
//==================================================================================
@isTest
private class AIA_PPHandler_Test{
    static testmethod void testupdateMHPTest(){
            test.startTest();
            
            Benfit_Request_Form__c brf = new Benfit_Request_Form__c();
            brf.Request_Type__c='Prospect/New';
            brf.Benefit_Effective_Date__c   = system.today();
            brf.Benefit_Period__c='Calendar';
            brf.Jurisdiction__c ='VA';
            brf.Sales_Segment_Size__c = 'Labor';
            brf.Contract_Period__c = 'Standard 12 months';
            brf.Grandfathered_Status__c  = 'Grandfathered';
            brf.Broker_Commission__c = 3.5;
            brf.Contract_Count__c = 20;
            brf.Funding_Arrangements__c = 'Both';   
            
            insert brf;
            
            Proposed_Products__c pp = new Proposed_Products__c();
            pp.Benefit_Request_Form__c  = brf.id;
            pp.Integrated_Non_Integrated__c = 'Integrated';
            
           // pp.Blue_Rewards_Wellness__c = 'Yes';
            pp.Funding_Arrangement__c = 'ASO';
           // pp.FSA_BlueFund__c  = 'Yes';
            pp.Deductible__c = 'Stacked';
            pp.CDH__c = 'Yes';
            pp.MHP_Test_Result__c = 'Pass';
            insert pp;
                        
           // pp.Blue_Rewards_Wellness__c = 'No';
            update pp;  
            
            test.stopTest();
        
        
    }
}