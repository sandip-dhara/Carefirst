/*------------------------------------------------------------------------------------
 *                      ----===[ HISTORY ]===---
 * Date        Developer        Description
 *------------------------------------------------------------------------------------
 * 06/15/2016 Chida    THis class is called from Benefit  Design Trigger to populate Approvers from Accounts Team Role                                
 * 
  *************************************************************************************
 */
//---------------------------------------------------------------------------------------------------------

/**
* @Author: Chida
* @Purpose: This class is populates Approvers from account team role in Benefit Design
* Input List of Benefit Request's
*/


public Class AIA_BenefitDesignApproversHelper
{

public static final string ERROR1 = 'There is more than one user configured for the Ancillary Analyst role on the Account. Please make sure only one user is configured as  Ancillary Analyst';
public static final string ERROR2 ='The Ancillary Analyst role is not configured on the Account Team. Please assign a user to this role before saving the Benefit Design';
public static final string ERROR3 ='There is more than one user configured for the Contract Tech role on the Account. Please make sure only one user is configured as  Contract Tech' ;
public static final string ERROR4 ='The Benefact Coder role is not configured on the Account Team. Please assign a user to this role before saving the Benefit Design';
public static final string ERROR5 ='There is more than one user configured for the Contract Tech role on the Account. Please make sure only one user is configured as  Contract Tech';
public static final string ERROR6 ='The Contract Tech role is not configured on the Account Team. Please assign a user to this role before saving the Benefit Design';
public static final string ERROR7 ='There is more than one user configured for the QA Auditor role on the Account. Please make sure only one user is configured as  QA Auditor' ;
public static final string ERROR8 = 'The QA Auditor role is not configured on the Account Team. Please assign a user to this role before saving the Benefit Design';
  
    public void beforeInsert(List<AIA_Benefit_Design__c> lstAIABenefitDesign)
    {
        //Set of Accounts from Benifit Design
        Set<Id> setAccountId=new Set<Id>();
        for(AIA_Benefit_Design__c AIABD : lstAIABenefitDesign)
        {
           //Set of Accounts from Benefit Design
            setAccountId.add(AIABD.Account_Name__c);
            
        } 
        //Call Function to Associate account roles to approvesrs
        if(!setAccountId.isEmpty())
        {
            processRecords(setAccountId,lstAIABenefitDesign);
        }
    }
    
    public void beforeUpdate(List<AIA_Benefit_Design__c> lstAIABenefitDesign)
    {
        //Set of Accounts from Benefit Design

        Set<Id> setAccountId=new Set<Id>();
        for(AIA_Benefit_Design__c AIABD : lstAIABenefitDesign)
        {
             //Get Account Id's
            setAccountId.add(AIABD.Account_Name__c);
            
        }
         //Call Function to Associate account roles to approvesrs

        if(!setAccountId.isEmpty())
        {
            processRecords(setAccountId,lstAIABenefitDesign);
        }
    }
    
    public void processRecords(Set<Id> setAccId, List<AIA_Benefit_Design__c> lstAIABenefitDesign)
    {
         //Get Account Team roles for given account Id
         System.Debug('>>>> the value of Accoun id is ' + setAccId); 

        List<AccountTeamMember> lstAcTeamMembr=[select UserId,AccountId,TeamMemberRole from AccountTeamMember where AccountId IN : setAccId and TeamMemberRole IN ('Ancillary Analyst','Benefact Coder','Contract Tech','QA Auditor')];
        if(!lstAcTeamMembr.isEmpty())
        {
            List<AIA_Benefit_Design__c> lstDoc=new List<AIA_Benefit_Design__c>();
            Integer count1 = 0;
            Integer count2 = 0;
            Integer count3 = 0;
            Integer count4 = 0;
            for(AIA_Benefit_Design__c bd : lstAIABenefitDesign)
            {
                for(AccountTeamMember accTeam:lstAcTeamMembr)
                {
                    if(bd.Account_Name__c == accTeam.AccountId)
                    {
                          if(accTeam.TeamMemberRole == 'Ancillary Analyst')
                            {
                               count1=count1+1;
                            }      
                             if(accTeam.TeamMemberRole == 'Benefact Coder')
                            {
                               count2=count2+1;
                            }     
                            
                             if(accTeam.TeamMemberRole == 'Contract Tech')
                            {
                                count3=count3+1;
                            }    
                            
                            if(accTeam.TeamMemberRole == 'QA Auditor')
                            {
                                count4=count4+1;
                            }    
                        
                    }
                }    
                                        
                for(AccountTeamMember accTeam1:lstAcTeamMembr)
                {
                    if(bd.Account_Name__c == accTeam1.AccountId)
                    {
                          //If roles excists assign user id  else throw error 
                          if(count1 == 1 && accTeam1.TeamMemberRole == 'Ancillary Analyst')
                            {
                                bd.Approver_Ancillary_Analyst__c = accTeam1.UserId;
                               
                            }  else if (count1 > 1 && accTeam1.TeamMemberRole == 'Ancillary Analyst'){
                                bd.addError(ERROR1);
                            }else if (count1 < 1){
                            bd.addError(ERROR2);
                            }
                            //If roles excists assign user id  else throw error 

                           if(count2 == 1 && accTeam1.TeamMemberRole == 'Benefact Coder')
                            {
                                bd.Approver_Benefit_Coder__c = accTeam1.UserId;
                            } else if (count2 > 1 && accTeam1.TeamMemberRole == 'Benefact Coder'){
                            bd.addError(ERROR3 );
                            }else if (count2 < 1){
                            bd.addError(ERROR4);
                            }
                            //If roles excists assign user id  else throw error 

                            if(count3 == 1 && accTeam1.TeamMemberRole == 'Contract Tech')
                            {
                                bd.Approver_Contract_Tech__c = accTeam1.UserId;
                            } else if (count3 > 1 && accTeam1.TeamMemberRole == 'Contract Tech'){
                            bd.addError(ERROR5);
                            }else if ( count3 < 1){
                            bd.addError(ERROR6);
                            }   
                             //If roles excists assign user id  else throw error 
                          
                            if(count4 == 1 && accTeam1.TeamMemberRole == 'QA Auditor')
                            {
                                bd.Approver_QA_Auditor__c = accTeam1.UserId;
                            } else if (count4 > 1 && accTeam1.TeamMemberRole == 'QA Auditor'){
                            bd.addError(ERROR7);
                            }else if ( count4 < 1){
                                bd.addError(ERROR8);
                            }     
                        
                    }
                }
            }
            
        }
    }
}