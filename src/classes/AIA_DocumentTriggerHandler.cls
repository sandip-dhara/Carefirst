/*****************************************************************************************************
*Date: 06/15/2016
*Developer: Spandhan Zangam 
*Purpose: AIA_Document
*=========================================================================================
* Update History
* Date         Developer               Description
*==================================================================================
*05-31-2016    Spandhan     Initial Development
*==================================================================================

*******************************************************************************************************/

public Class AIA_DocumentTriggerHandler
{
    public void beforeInsert(List<AIA_Document__c> lstAIADocument)
    {
        Set<Id> setAccountId=new Set<Id>();
        for(AIA_Document__c aiaDoc : lstAIADocument)
        {
            if(aiaDoc.Account__c != null && aiaDoc.Document_Type__c == 'Production Id Card' || aiaDoc.Document_Type__c == 'Mock ID Card')
            {
                setAccountId.add(aiaDoc.Account__c);
            }
        } 
        
        if(!setAccountId.isEmpty())
        {
            processRecords(setAccountId,lstAIADocument);
        }
    }
    
    public void beforeUpdate(List<AIA_Document__c> lstAIADocument,Map<Id,AIA_Document__c> mapAIADocument)
    {
        Set<Id> setAccountId=new Set<Id>();
        for(AIA_Document__c aiaDoc : lstAIADocument)
        {
            if(aiaDoc.Account__c != null && aiaDoc.Document_Type__c == 'Production Id Card' || aiaDoc.Document_Type__c == 'Mock ID Card' && (aiaDoc.Document_Type__c != mapAIADocument.get(aiaDoc.Id).Document_Type__c))
            {
                setAccountId.add(aiaDoc.Account__c);
            }
        }
        if(!setAccountId.isEmpty())
        {
            processRecords(setAccountId,lstAIADocument);
        }
    }
    
    public void processRecords(Set<Id> setAccId, List<AIA_Document__c> lstAIADocument)
    {
        List<AccountTeamMember> lstAcTeamMembr=[select UserId,AccountId,TeamMemberRole from AccountTeamMember where AccountId IN : setAccId and TeamMemberRole IN ('Implementation PM','Sales Consultant','Sales Service Rep','Implementation Coordinator')];
        if(!lstAcTeamMembr.isEmpty())
        {
            List<AIA_Document__c> lstDoc=new List<AIA_Document__c>();
            for(AIA_Document__c doc : lstAIADocument)
            {
                for(AccountTeamMember accTeam:lstAcTeamMembr)
                {
                    if(doc.Account__c == accTeam.AccountId)
                    {
                        if(doc.Document_Type__c == 'Production Id Card' && (accTeam.TeamMemberRole == 'Implementation PM' || accTeam.TeamMemberRole =='Sales Consultant'))
                        {
                            if(accTeam.TeamMemberRole == 'Implementation PM')
                            {
                                doc.Approver_Implementation_Team__c = accTeam.UserId;
                            }else if(accTeam.TeamMemberRole =='Sales Consultant'){
                                doc.Approver_Customer_Support__c = accTeam.UserId;
                            }
                        }else if(doc.Document_Type__c == 'Mock ID Card' && (accTeam.TeamMemberRole == 'Implementation PM' || accTeam.TeamMemberRole =='Sales Consultant' || accTeam.TeamMemberRole =='Sales Service Rep' || accTeam.TeamMemberRole =='Implementation Coordinator')){
                            if(accTeam.TeamMemberRole == 'Implementation PM')
                            {
                                doc.Approver_Implementation_Team__c = accTeam.UserId;
                            }else if(accTeam.TeamMemberRole =='Sales Consultant'){
                                doc.Approver_Customer_Support__c = accTeam.UserId;
                            }else if(accTeam.TeamMemberRole =='Sales Service Rep'){
                                doc.Approver_Sales_Service_Rep__c = accTeam.UserId;
                            }else if(accTeam.TeamMemberRole =='Implementation Coordinator'){
                                doc.Approver_Par_Plan__c = accTeam.UserId;
                            }
                        }
                    }
                }
            }
        }
    }
}