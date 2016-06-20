/*****************************************************************************************************
*Date: 05/31/2016
*Developer: Spandhan Zangam 
*Purpose: AIA_Document trigger Test class
*=========================================================================================
* Update History
* Date         Developer               Description
*==================================================================================
*06-16-2016    Spandhan     Initial Development
*==================================================================================

*******************************************************************************************************/

@isTest
// First test is for positive testing where the code runs as desired.
public class AIA_DocumentTriggerHandlerTest {
    // Run positive test when check testing is false as expected in the Account Process code
    static testMethod void CreateAIADocument() {
        Profile p = [SELECT Id FROM Profile WHERE Name='AIA 200+ Standard User - Custom']; 
                     User u = new User(Alias = 'standt', Email='spmss.process@carefirst.com.xxx', 
                     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                     LocaleSidKey='en_US', ProfileId = p.Id, 
                     TimeZoneSidKey='America/Los_Angeles', UserName='spmss.process@carefirst.com.xxx');


        List<User> lstinsertuser=new List<User>();


            System.runAs(u) {
             Account a = AIA_TestUtil.AIA_createAccount();
             
        List<AccountTeamMember> lstAcctTeamMbr=new List<AccountTeamMember>();
        for(Integer i=0;i<7;i++)
        {
        

            AccountTeamMember member=new AccountTeamMember();
            member.AccountAccessLevel ='Edit';
            member.AccountId =a.Id;
            if(i==0)
            {
                member.TeamMemberRole ='Implementation Coordinator';
            }else if(i==1)
            {
                member.TeamMemberRole ='Sales Consultant';
            }else if(i==2)
            {
                member.TeamMemberRole ='Sales Service Rep';
            }else if(i==3)
            {
                member.TeamMemberRole ='QA Auditor';
            }else if(i==4)
            {
                member.TeamMemberRole ='Billing Tech';
            }else if(i==5)
                        {
                member.TeamMemberRole ='Settlements Tech';
            }else if(i==6)
            {
                member.TeamMemberRole ='Implementation PM';
            }
            member.UserId =lstinsertuser[i].Id;
            lstAcctTeamMbr.add(member);
        }
        
        insert lstAcctTeamMbr;
        List<AccountTeamMember> lstquery=[Select Id,TeamMemberRole from AccountTeamMember Where AccountId =: a.Id];
        for(AccountTeamMember team: lstquery){
            System.debug('\n'+team.TeamMemberRole);
        }
        
        System.debug(lstAcctTeamMbr);
        
        Test.StartTest();
        
            AIA_Document__c doc=new AIA_Document__c();
            doc.Account__c = a.Id;
            doc.Document_Type__c ='Production Id Card';
            insert doc;
            doc.Document_Type__c ='Group Structure Document';
            insert doc;
            doc.Document_Type__c ='Mock ID Card';
            update doc;
            
        Test.StopTest();
    }
}
}