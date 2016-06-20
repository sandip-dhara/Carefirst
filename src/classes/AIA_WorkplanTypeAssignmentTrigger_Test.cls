@isTest
public class AIA_WorkplanTypeAssignmentTrigger_Test{
    public static testmethod void mytest1(){
        //create Group for Queues
        List<String> names = new List<string>{'TestQ1','TestQ2','TestQ3','TestQ4','TestQ5','TestQ6'};
        List<Group> Glst = AIA_TestUtil.createGroup(names,'Queue');
        //create Queues with Group Ids
        List<QueuesObject> Qlst= AIA_TestUtil.createQueues(Glst,'Lead');
        
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='AIA 200+ Standard User - Custom'];
         
        User u = new User(Alias = 'TAlias', Email='TestUser1@testorg.com',
        EmailEncodingKey='UTF-8', LastName='TestingUSer', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='TestingUser1@testorg.com');
        
        System.runAs(u){
            //create Work plan Type 
            AIA_Workplan_Type__c WPT = AIA_TestUtil.createWPT();
            //create work plan type stage with work plan type Id
            Workplan_Type_Stage__c WPTS = AIA_TestUtil.createWPTS(WPT.Id);
            
             try{
                //create Work plan Type Task With Work Plan Type Stage Id
                List<AIA_Workplan_Type_Task__c> WPTTlst = AIA_TestUtil.createWPTT(WPTS.Id);
                
                List<AIA_Workplan_Type_Task__c> lst1 = [select Id from AIA_Workplan_Type_Task__c];
                system.assertequals(3,lst1.size());
            
                //update Work Plan Task Type With Existing Records
                List<AIA_Workplan_Type_Task__c> UPWPTTlst = AIA_TestUtil.updateWPTT(WPTTlst);
             }catch( exception e ){
                RETURN;   
            } 
        }
        
        Profile p1 = [SELECT Id FROM Profile WHERE Name='AIA RUL Custom'];
         
        User u1 = new User(Alias = 'TAlias2', Email='TestUser2@testorg.com',
        EmailEncodingKey='UTF-8', LastName='TestingUSer', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p1.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='TestingUser2@testorg.com');
        
        System.runAs(u1){
            //create Work plan Type 
            AIA_Workplan_Type__c WPT = AIA_TestUtil.createWPT();
            //create work plan type stage with work plan type Id
            Workplan_Type_Stage__c WPTS = AIA_TestUtil.createWPTS(WPT.Id);
            
             
             try{
                //create Work plan Type Task With Work Plan Type Stage Id
                List<AIA_Workplan_Type_Task__c> WPTTlst = AIA_TestUtil.createWPTT(WPTS.Id);
                
                List<AIA_Workplan_Type_Task__c> lst1 = [select Id from AIA_Workplan_Type_Task__c];
                system.assertequals(6,lst1.size());
            
                //update Work Plan Task Type With Existing Records
                List<AIA_Workplan_Type_Task__c> UPWPTTlst = AIA_TestUtil.updateWPTT(WPTTlst);
             }catch( exception e ){
                RETURN;   
            }
             
        }
        Test.StopTest();
    }
}