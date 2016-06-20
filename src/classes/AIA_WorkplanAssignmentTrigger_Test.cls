@isTest
public class AIA_WorkplanAssignmentTrigger_Test{
    public static testmethod void mytest1(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='AIA 200+ Standard User - Custom'];
        User u = new User(Alias = 'TAlias', Email='TestUser2@testorg.com',
        EmailEncodingKey='UTF-8', LastName='TestingUSer', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='TestingUser2@testorg.com');
        system.runAs(u){
            try{
                List<Workplan_Stage__c> wpslst = AIA_TestUtil.createWPS();
                List<PRF__c> prflst = AIA_TestUtil.createPRF();
                List<AIA_Workplan_Assignment__c> waslst = AIA_TestUtil.createWPA(wpslst,prflst);
                List<AIA_Workplan_Assignment__c> upwaslst = AIA_TestUtil.updateWPA(waslst);
                
                List<Workplan_Stage__c> wpslst1 = [select Id from Workplan_Stage__c];
                system.assertequals(6,wpslst1.size());
                
                List<PRF__c> prflst1 = [select Id from PRF__c];
                system.assertequals(3,prflst1.size());
                
                List<AIA_Workplan_Assignment__c> waslst1 = [select Id,status__c,Workplan_Stage__c  from AIA_Workplan_Assignment__c];
                system.assertEquals(6,waslst1.size());
                
                List<AIA_Workplan_Assignment__c> upwaslst1 = [select id,status__c,Workplan_Stage__c from AIA_Workplan_Assignment__c];
                system.assertEquals(6,upwaslst1.size());
                
                AIA_TestUtil.deleteWPA(waslst);
                
           }catch( exception e ){
                RETURN;   
            }
        }
        
        Profile p2 = [SELECT Id FROM Profile WHERE Name='AIA RUL Custom'];
        User u2 = new User(Alias = 'TAlias', Email='TestUser4@testorg.com',
        EmailEncodingKey='UTF-8', LastName='TestingUSer', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p2.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='TestingUser4@testorg.com');
        system.runAs(u2){
            try{
                List<Workplan_Stage__c> wpslst = AIA_TestUtil.createWPS();
                List<PRF__c> prflst = AIA_TestUtil.createPRF();
                List<AIA_Workplan_Assignment__c> waslst = AIA_TestUtil.createWPA(wpslst,prflst);
                List<AIA_Workplan_Assignment__c> upwaslst = AIA_TestUtil.updateWPA(waslst);
                
                List<Workplan_Stage__c> wpslst1 = [select Id from Workplan_Stage__c];
                system.assertequals(12,wpslst1.size());
                
                List<PRF__c> prflst1 = [select Id from PRF__c];
                system.assertequals(6,prflst1.size());
                
                List<AIA_Workplan_Assignment__c> waslst1 = [select Id,status__c,Workplan_Stage__c  from AIA_Workplan_Assignment__c];
                system.assertEquals(6,waslst1.size());
                
                List<AIA_Workplan_Assignment__c> upwaslst1 = [select id,status__c,Workplan_Stage__c from AIA_Workplan_Assignment__c];
                system.assertEquals(6,upwaslst1.size());
                
                AIA_TestUtil.deleteWPA(waslst);
                
           }catch( exception e ){
                RETURN;   
            }
        }
        Test.StopTest();
    }
}