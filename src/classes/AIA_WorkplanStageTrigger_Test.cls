@isTest
public class AIA_WorkplanStageTrigger_Test{
    public static testmethod void mytest1(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='AIA 200+ Standard User - Custom'];
        User u = new User(Alias = 'TAlias', Email='TestUser5@testorg.com',
        EmailEncodingKey='UTF-8', LastName='TestingUSer', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='TestingUser5@testorg.com');
        Account acc = AIA_TestUtil.createAccount('testAcc');
        List<Opportunity> olst = AIA_TestUtil.createOpps(acc.id);
        system.assertequals(2,olst.size());
        System.runAs(u){
             try{
             //The following methods will create the parent record for workplan stage
                 List<Workplan_Stage__c> plst = AIA_TestUtil.createParentWPS();
                 system.assertequals(2,plst.size());
                 // The following method will insert some records for first time (Old Record); old records as differnt scenarios
                 List<Workplan_Stage__c> colst = AIA_TestUtil.createChildOldWPS(plst,olst);
                 system.assertequals(2,colst.size());
   // The following method will insert some records for first time (new Record); new records as different scenarios
                 List<Workplan_Stage__c> cnlst = AIA_TestUtil.createChildWPS(plst);
                 system.assertequals(3,cnlst.size());
  // The follwing method will update the new and old records
                 AIA_TestUtil.updatePWPS(colst,cnlst);
   // This method will delete the new records so based on old records some functionality will execute (Which covers both positive
   // and negative scenarios) 
                 AIA_TestUtil.deleteWPS(colst);                 
             }catch( exception e ){
                RETURN;   
            } 
        }
        Test.StopTest();
    }
}