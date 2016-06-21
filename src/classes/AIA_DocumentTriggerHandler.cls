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
/**
 * Used to instantiate and execute Trigger Handlers associated with sObjects.
**/

public Class AIA_DocumentTriggerHandler{
    /**
     * Returns a subset of id's where there are any records in use.
     *
     * Arguments:   Set<Id> Doctypes - Set of Account Team Members " in Use"
     *
     * Returns:     Set<Id> - mockIdCardTeamRoles Set of Account Team Members that are 'in use'
     */
    
    set<string> docTypes = new set<string>{'Production Id Card','Mock ID Card','Group Structure Document'};
    set<string> prodIdCardTeamRoles = new set<string>{'Implementation PM','Customer Support'};
    set<string> mockIdCardTeamRoles = new set<string>{'Implementation PM','Customer Support','Sales Service Rep','Par Plan'};
    set<string> grpStructDocTeamRoles = new set<string>{'QA Auditor','Billing Tech','Settlements Tech','Implementation PM','Sales Service Rep'};
    
   // EXECUTE BEFORE INSERT LOGIC
    
    public void beforeInsert(List<AIA_Document__c> lstAIADocument){
        Set<Id> setAccountId=new Set<Id>();
        
        // Checking Account value and document type containing a vale for each record.
        for(AIA_Document__c aiaDoc : lstAIADocument){
            if(aiaDoc.Account__c != null && aiaDoc.Document_Type__c != NULL && docTypes.contains(aiaDoc.Document_Type__c)){
                // Condition is true add them to setaccountid 
                setAccountId.add(aiaDoc.Account__c);
            }
        } 
        // if setaccountid variable not null add those records for process records method.
        if(!setAccountId.isEmpty()){
            processRecords(setAccountId,lstAIADocument);
        }
    }
    
   
   // Esecute before Update logic 
    public void beforeUpdate(List<AIA_Document__c> lstAIADocument,Map<Id,AIA_Document__c> mapAIADocument){
        Set<Id> setAccountId=new Set<Id>();
        
        // Checking Account value and document type containing a vale for each record.
        for(AIA_Document__c aiaDoc : lstAIADocument){
            if(aiaDoc.Account__c != null && aiaDoc.Document_Type__c != NULL && docTypes.contains(aiaDoc.Document_Type__c) && aiaDoc.Document_Type__c != mapAIADocument.get(aiaDoc.Id).Document_Type__c){
                // Condition is true add them to setaccountid 
                setAccountId.add(aiaDoc.Account__c);
            }
        }
        
        // if setaccountid variable not null add those records for process records method.
        if(!setAccountId.isEmpty()){
            processRecords(setAccountId,lstAIADocument);
        }
    }
    
   
  // Process the records to match lookup fields on AIA DOcument 
    public void processRecords(Set<Id> setAccId, List<AIA_Document__c> lstAIADocument){
        List<AccountTeamMember> lstAcTeamMembr=[select UserId,AccountId,TeamMemberRole from AccountTeamMember where AccountId IN : setAccId and TeamMemberRole IN ('Implementation PM','Customer Support','Sales Service Rep','Par Plan','Billing Tech','Settlements Tech','QA Auditor')];
        if(!lstAcTeamMembr.isEmpty()){    
            system.debug('INSIDE>> '+ lstAIADocument);
            List<AIA_Document__c> lstDoc = new List<AIA_Document__c>();
            for(AIA_Document__c doc : lstAIADocument){
                system.debug('FOR LOOP>>> '+doc);
                for(AccountTeamMember accTeam:lstAcTeamMembr){ 
                    system.debug('accTeam>> '+accTeam);
                    if(doc.Account__c == accTeam.AccountId){    
                        system.debug('>ACC> '+doc.Document_Type__c);
                        system.debug('>ACC TEAM Role> '+accTeam.TeamMemberRole);
                        if(doc.Document_Type__c == 'Production Id Card' && accTeam.TeamMemberRole != NULL && prodIdCardTeamRoles.contains(accTeam.TeamMemberRole)){
                            system.debug('1111');
                            if(accTeam.TeamMemberRole == 'Implementation PM'){
                                doc.Approver_Implementation_Team__c = accTeam.UserId;
                            }
                            else if(accTeam.TeamMemberRole =='Customer Support'){
                                doc.Approver_Customer_Support__c = accTeam.UserId;
                            }
                        }
                        else if(doc.Document_Type__c == 'Mock ID Card' && accTeam.TeamMemberRole != NULL && mockIdCardTeamRoles.contains(accTeam.TeamMemberRole)){
                            system.debug('2222');
                            if(accTeam.TeamMemberRole == 'Implementation PM'){
                                doc.Approver_Implementation_Team__c = accTeam.UserId;
                            }else if(accTeam.TeamMemberRole =='Customer Support'){
                                doc.Approver_Customer_Support__c = accTeam.UserId;
                            }else if(accTeam.TeamMemberRole =='Sales Service Rep'){
                                doc.Approver_Sales_Service_Rep__c = accTeam.UserId;
                            }else if(accTeam.TeamMemberRole =='Par Plan'){
                                doc.Approver_Par_Plan__c = accTeam.UserId;
                        }
                    }
                    else if(doc.Document_Type__c == 'Group Structure Document' && accTeam.TeamMemberRole != NULL && grpStructDocTeamRoles.contains(accTeam.TeamMemberRole)){
                            system.debug('doc.Document_Type__c>>> '+doc.Document_Type__c);
                            if(accTeam.TeamMemberRole == 'QA Auditor'){
                                doc.Approver_QA_Auditor__c = accTeam.UserId;
                                
                            }
                            if(accTeam.TeamMemberRole == 'Billing Tech'){
                                doc.Approver_Billing_Tech__c = accTeam.UserId;
                                
                            }
                            if(accTeam.TeamMemberRole == 'Settlements Tech'){
                                doc.Approver_Settlements_Tech__c = accTeam.UserId;
                                
                            }
                            if(accTeam.TeamMemberRole == 'Implementation PM'){
                                doc.Approver_Implementation_Team__c = accTeam.UserId;
                                system.debug('HEREEEE');
                            }
                            if(accTeam.TeamMemberRole =='Sales Service Rep'){
                                doc.Approver_Sales_Service_Rep__c = accTeam.UserId;
                            }
                        }
                }
            }
        }
    }
}
}