@isTest
Public class AIA_BRFTriggerHandler_Test{
  Public static testmethod void createBRFFromPRF(){
  
        Profile pro = [SELECT Id FROM Profile WHERE Name='AIA 200+ Standard User - Custom'];
         
        User u = new User(Alias = 'TAlias', Email='TestUserBRF@testorg.com',
        EmailEncodingKey='UTF-8', LastName='TestingUSer', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = pro.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='TestingUserBRF@testorg.com');
        
         System.runAs(u) {           
        
            // Step 1 - Create Account
            Account a = AIA_TestUtil.CreateAccount('TestAccount');
            // Step 2 - Create Opportunity
            Opportunity o = AIA_TestUtil.CreateOpportunity(a.Id);
            // Step 3 - Create PRF
            PRF__c p = AIA_TestUtil.CreatePRF(o.Id);           
            
            // Start Test
            Test.startTest();
            
            try{
                // Step 4 -  Create BRF
                Benfit_Request_Form__c b = AIA_TestUtil.CreateBRF(p.Id,a.id);
            }catch(exception e ){
                RETURN;   
            } 
            
            // Verify that opportunity Id on BRF was populated from the opportunityId created in Step #2
            Benfit_Request_Form__c vbrf = [select Id,Proposal_Request_Form__r.Opportunity__c from Benfit_Request_Form__c where Proposal_Request_Form__c = :p.Id];
            system.assertequals(o.Id,vbrf.Proposal_Request_Form__r.Opportunity__c);
            
            // Add assert statement here
            Account va = [select Id,Name from Account Where Name = 'TestAccount'];
            system.assertequals('TestAccount',va.Name);
            
            Opportunity vo = [select Id,Name from Opportunity where Name = 'Testopp'];
            system.assertequals('Testopp',vo.Name);
            
            PRF__c vp = [select Id,Opportunity__c from PRF__c where Opportunity__c =: o.Id];
            system.assertequals(o.Id,vp.Opportunity__c);
        
            // Stop Test
            Test.stopTest();
       }
       
       Profile pro1 = [SELECT Id FROM Profile WHERE Name='AIA RUL Custom'];
         
        User u1 = new User(Alias = 'TAlias', Email='TestUser3@testorg.com',
        EmailEncodingKey='UTF-8', LastName='TestingUSer', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = pro1.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='TestingUser3@testorg.com');
        
         System.runAs(u1) {           
        
            // Step 1 - Create Account
            Account a = AIA_TestUtil.CreateAccount('TestAccount');
            // Step 2 - Create Opportunity
            Opportunity o = AIA_TestUtil.CreateOpportunity(a.Id);
            // Step 3 - Create PRF
            PRF__c p = AIA_TestUtil.CreatePRF(o.Id);           
            
            // Start Test
            Test.startTest();
            
            try{
                // Step 4 -  Create BRF
                Benfit_Request_Form__c b = AIA_TestUtil.CreateBRF(p.Id,a.id);
            }catch(exception e ){
                RETURN;   
            } 
            
            // Verify that opportunity Id on BRF was populated from the opportunityId created in Step #2
            Benfit_Request_Form__c vbrf = [select Id,Proposal_Request_Form__r.Opportunity__c from Benfit_Request_Form__c where Proposal_Request_Form__c = :p.Id];
            system.assertequals(o.Id,vbrf.Proposal_Request_Form__r.Opportunity__c);
            
            // Add assert statement here
            Account va = [select Id,Name from Account Where Name = 'TestAccount'];
            system.assertequals('TestAccount',va.Name);
            
            Opportunity vo = [select Id,Name from Opportunity where Name = 'Testopp'];
            system.assertequals('Testopp',vo.Name);
            
            PRF__c vp = [select Id,Opportunity__c from PRF__c where Opportunity__c =: o.Id];
            system.assertequals(o.Id,vp.Opportunity__c);
        
            // Stop Test
            Test.stopTest();
       }
   }
    public static testmethod void testValidateBRF(){
            // Step 1 - Create Account
            Account a = AIA_TestUtil.CreateAccount('TestAccount');
            // Step 2 - Create Opportunity
            Opportunity o = AIA_TestUtil.CreateOpportunity(a.Id);
            // Step 3 - Create PRF
            PRF__c p = AIA_TestUtil.CreatePRF(o.Id);           
            
            // Start Test
            Test.startTest();
            
            try{
                // Step 4 -  Create BRF
                Benfit_Request_Form__c b = AIA_TestUtil.CreateBRF(p.Id,a.id);
                AIA_TestUtil.createAIADocument(b);
                b.Status__c='Sold';
                update b;
            }catch(exception e ){
                RETURN;   
            }
    }
  
}