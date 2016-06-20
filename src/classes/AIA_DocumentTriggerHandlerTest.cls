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
private class AIA_DocumentTriggerHandlerTest {
    static testMethod void CreateAIADocument() {
        Account a = new Account();
        a.Name = 'SomeTest' + Date.Today();
        a.Type = 'Customer';
        a.billingstate = 'MD';
        a.billingCountry = 'United States';
        a.billing_County_Code__c = 'CA-Carroll';
        a.shippingstate = 'MD';
        a.shippingcountry = 'USA';        
        insert a;
        
        Id AdminPID = [select id from profile where Name = 'System Administrator'].Id;
        List<User> lstinsertuser=new List<User>();
        for(Integer i=0;i<4;i++)
        {
            User admin = new User();
            admin.FirstName = 'MrX';
            admin.LastName = 'LastMrx';
            admin.email = 'mrxzz@mytest.com';
            admin.alias = 'zzts';
            admin.communityNickname = 'MrXLastMrx'+i;
            admin.username = 'mrxzzt'+i+'@mytest.com';
            admin.EmailEncodingKey = 'ISO-8859-1';
            admin.LanguageLocaleKey = 'en_US';
            admin.LocaleSidKey = 'en_US';
            admin.TimeZoneSidKey = 'America/New_York';
            admin.ProfileId = AdminPID;
            lstinsertuser.add(admin);
        }        
        
        insert lstinsertuser;
        
        List<AccountTeamMember> lstAcctTeamMbr=new List<AccountTeamMember>();
        for(Integer i=0;i<4;i++)
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
                member.TeamMemberRole ='Implementation PM';
            }
            member.UserId =lstinsertuser[i].Id;
            lstAcctTeamMbr.add(member);
        }
        
        insert lstAcctTeamMbr;
        List<AccountTeamMember> lstquery=[Select Id,TeamMemberRole from AccountTeamMember Where AccountId =: a.Id];
        for(AccountTeamMember tesam: lstquery){
            System.debug('\n'+tesam.TeamMemberRole);
        }
        
        System.debug(lstAcctTeamMbr);
        
        Test.StartTest();
        
            AIA_Document__c doc=new AIA_Document__c();
            doc.Account__c = a.Id;
            doc.Document_Type__c ='Production Id Card';
            insert doc;

            doc.Document_Type__c ='Mock ID Card';
            update doc;
            
        Test.StopTest();
    }
}