public Class AIA_DocumentTriggerHandler{
    set<string> docTypes = new set<string>{'Production Id Card','Mock ID Card','Group Structure Document'};
    set<string> prodIdCardTeamRoles = new set<string>{'Implementation PM','Customer Support'};
    set<string> mockIdCardTeamRoles = new set<string>{'Implementation PM','Customer Support','Sales Service Rep','Par Plan'};
    set<string> grpStructDocTeamRoles = new set<string>{'QA Auditor','Billing Tech','Settlements Tech','Implementation PM','Sales Service Rep'};
    public void beforeInsert(List<AIA_Document__c> lstAIADocument){
        Set<Id> setAccountId=new Set<Id>();
        for(AIA_Document__c aiaDoc : lstAIADocument){
            if(aiaDoc.Account__c != null && aiaDoc.Document_Type__c != NULL && docTypes.contains(aiaDoc.Document_Type__c)){
                setAccountId.add(aiaDoc.Account__c);
            }
        } 
        
        if(!setAccountId.isEmpty()){
            processRecords(setAccountId,lstAIADocument);
        }
    }
    
    public void beforeUpdate(List<AIA_Document__c> lstAIADocument,Map<Id,AIA_Document__c> mapAIADocument){
        Set<Id> setAccountId=new Set<Id>();
        for(AIA_Document__c aiaDoc : lstAIADocument){
            if(aiaDoc.Account__c != null && aiaDoc.Document_Type__c != NULL && docTypes.contains(aiaDoc.Document_Type__c) && aiaDoc.Document_Type__c != mapAIADocument.get(aiaDoc.Id).Document_Type__c){
                setAccountId.add(aiaDoc.Account__c);
            }
        }
        if(!setAccountId.isEmpty()){
            processRecords(setAccountId,lstAIADocument);
        }
    }
    
    public void processRecords(Set<Id> setAccId, List<AIA_Document__c> lstAIADocument){
        List<AccountTeamMember> lstAcTeamMembr=[select UserId,AccountId,TeamMemberRole from AccountTeamMember where AccountId IN : setAccId and TeamMemberRole IN ('Implementation PM','Customer Support','Sales Service Rep','Par Plan')];
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
                                
                            }else if(accTeam.TeamMemberRole == 'Billing Tech'){
                                doc.Approver_Billing_Tech__c = accTeam.UserId;
                                
                            }else if(accTeam.TeamMemberRole == 'Settlements Tech'){
                                doc.Approver_Settlements_Tech__c = accTeam.UserId;
                                
                            }else if(accTeam.TeamMemberRole == 'Implementation PM'){
                                doc.Approver_Implementation_Team__c = accTeam.UserId;
                                system.debug('HEREEEE');
                            }else if(accTeam.TeamMemberRole =='Sales Service Rep'){
                                doc.Approver_Sales_Service_Rep__c = accTeam.UserId;
                            }
                        }
                }
            }
        }
    }
}
}