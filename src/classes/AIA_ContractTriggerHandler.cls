/*=========================================================================================
 * Date     : 06/16/2016
 * Developer    : Sree Harsha Akkala
 * Purpose      : This class is the extension point of the Trigger Framework for adding Contract trigger handlers.
 *                
 *               
 *
 *=========================================================================================
 *                                 Update History
 *                                 ---------------
 * Date       Developer         Description
 *===========+============+================================================================
 * 06/16/2016  |  HA    | Initial Version                                         
 *           |        | 
 *===========+============+================================================================
 */
 
/**
* @This class is invoked from ContractTrigger 
*/ 
 
public with sharing class AIA_ContractTriggerHandler extends TriggerHandler {
public AIA_ContractTriggerHandler() {}
public static boolean firstRun=false;
 protected override void afterInsert(){
     if(!firstRun)
     validateContract((list<contract>) trigger.new);
 }
 protected override void afterUpdate(){
     if(!firstRun)
     validateContract((list<contract>) trigger.new);
 }
 
 public static void validateContract(list<contract> contractList){
 system.debug('@@ in validateContract list'+contractList);
     set<id>implementationIdSet = new set<id>();
     for(contract contractRec: contractList){
         if(contractRec.Implementation__c!=null){
             implementationIdSet.add(contractRec.Implementation__c);
         }
     }
     //Map<id,Implementation__c> implementationAccMap = new Map<id,implementation__c>([select id,name,account__c from implementation__c where id in:implementationIdSet]);
     List<contract> finalContractList = [select id,name,implementation__c,implementation__r.account__c from contract where id  in:contractList];
      system.debug('@@ in finalContractList '+finalContractList );
     set<id> accIdSet = new set<id>();
    for(contract cont: finalContractList){
        if(cont.implementation__r.account__c!=null)
        accIdSet.add(cont.implementation__r.account__c);        
    }
    //Map<id, Account> acctsWithTeams = new Map<id, Account>([Select Id, (Select Id, AccountId From AccountTeamMembers ) From Account Where Id in :accIdSet]);
    list<AccountTeamMember> accountTeamList = [select id,AccountId,TeamMemberRole,UserId from AccountTeamMember where accountId in :accIdSet];
    system.debug('@@accountTeamList'+accountTeamList);
    Map<id,AccountTeamMember> accountTeamMemberMap = new Map<id,AccountTeamMember>();   
    for(accountTeamMember atm: accountTeamList){
        accountTeamMemberMap.put(atm.AccountId,atm);
    }
    Map<id,boolean> contractAccountTeamMap = new Map<id,boolean>();
    Map<id,string> contractMissedRolesMap = new Map<id,string>();
    Map<id,string> contractExcessRolesMap = new Map<id,string>();
    Map<id,boolean> countAccountTeamMap = new Map<id,boolean>();
             boolean hasCompleteAccountTeam;
    for(contract con:finalContractList){
        hasCompleteAccountTeam = false;     
        integer AuditCount=0;
        integer CCCount=0;
        integer ContractSupervisorCount=0;
        integer LegalCount=0;
        integer SalesServiceRepCount=0;
        for(AccountTeamMember atm: accountTeamList){ 
        if(atm.AccountId==con.implementation__r.account__c){
            con.AccountId=con.implementation__r.account__c;
            if(atm.TeamMemberRole=='Audit'){
                system.debug('@@ in teamRole Audit');
                con.Approver_Audit__c=atm.UserId;
                AuditCount++;               
            }           
            if(atm.TeamMemberRole=='C&C Contact'){  
                con.Approver_C_C__c=atm.UserId;
                CCCount++;
            }
            if(atm.TeamMemberRole=='Contract Supervisor'){
                con.Approver_Contract_Supervisor__c=atm.UserId;
                ContractSupervisorCount++;
            }
            if(atm.TeamMemberRole=='Legal'){
                con.Approver_Legal__c=atm.UserId;    
                LegalCount++;
            }
            
            if(atm.TeamMemberRole=='Sales Service Rep'){
                con.Approver_Sales_Service_Rep__c=atm.UserId;   
                SalesServiceRepCount++;
            }}
        }
        if( AuditCount==1 && CCCount==1 && ContractSupervisorCount==1 && LegalCount==1 && SalesServiceRepCount==1){
            hasCompleteAccountTeam=true;
            contractAccountTeamMap.put(con.id,hasCompleteAccountTeam);
        }
        else{
            string missedRoles='';
            if(AuditCount==0)
            missedRoles='Audit';
            if(CCCount==0){
                if(missedRoles!=null)
                missedRoles=missedRoles+',C&C Contact';
                else
                missedRoles='C&C Contact';
            }
            if(ContractSupervisorCount==0){
                if(missedRoles!=null)
                missedRoles=missedRoles+',Contract Supervisor';
                else
                missedRoles='Contract Supervisor';
            }
            if(LegalCount==0){
                if(missedRoles!=null)
                missedRoles=missedRoles+',Legal';
                else
                missedRoles='Legal';
            }
            if(SalesServiceRepCount==0){
                if(missedRoles!=null)
                missedRoles=missedRoles+',Sales Service Rep';
                else
                missedRoles='Sales Service Rep';
            }
            if(missedRoles!=null)
            contractMissedRolesMap.put(con.id,missedRoles);
        }
        string excessRoles='';
        if(AuditCount>1)
        excessRoles='Audit';
        if(CCCount>1){
            if(excessRoles!=null)
            excessRoles=excessRoles+',C&C Contact';
            else
            excessRoles='C&C Contact';
        }
        if(ContractSupervisorCount>1){
            if(excessRoles!=null)
            excessRoles=excessRoles+',Contract Supervisor';
            else
            excessRoles='Contract Supervisor';
        }
        if(LegalCount>1){
            if(excessRoles!=null)
            excessRoles=excessRoles+',Legal';
            else
            excessRoles='Legal';
        }
        if(SalesServiceRepCount>1){
            if(excessRoles!=null)
            excessRoles=excessRoles+',Sales Service Rep';
            else
            excessRoles='Sales Service Rep';
        }
        if(excessRoles!=null)
        contractexcessRolesMap.put(con.id,excessRoles);
            
    }           
    
    for(contract finalCon:contractList){
        system.debug('@@missedRoleMap'+contractMissedRolesMap.get(finalCon.id));
        system.debug('@@excessRoleMap'+contractexcessRolesMap.get(finalCon.id));
        if(contractMissedRolesMap.get(finalCon.id)!=null)
        finalCon.addError('The'+ contractMissedRolesMap.get(finalCon.id) +' role/roles is not configured on the Account Team. Please assign a user to this role before saving the Benefit Design');
        if(contractexcessRolesMap.get(finalCon.id)!='' || !(string.isBlank(contractexcessRolesMap.get(finalCon.id))))
        finalCon.addError('There is more than one user configured for the'+ contractexcessRolesMap.get(finalCon.id) +' role/roles on the Account. Please make sure only one user is configured for the'+ contractexcessRolesMap.get(finalCon.id) +'role/roles');
    }
    if(hasCompleteAccountTeam)
    {
        firstRun=true;
        update finalContractList;
    }
    
 }
}