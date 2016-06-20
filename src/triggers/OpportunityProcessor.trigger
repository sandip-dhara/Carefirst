/*------------------------------------------------------------------------------------
 *                      ----===[ HISTORY ]===---
 * Date        Developer        Description
 *------------------------------------------------------------------------------------
 * 12/04/2012 Varun Nagarajan   Modified code where Business__c has been replaced with
                                Business_Type__c matching today's world requirements 
 *
 * 10/29/2014 Tom Barrett (TPB) Added logic to prevent this trigger from executing code
 *                              if it is a 2-50 record type opportunity
  *************************************************************************************
 */
 
/*
 *  @Author: Acumen Solutions
 *  @Purpose: Trigger for Opportunity related processes (after update, before update)
 */

trigger OpportunityProcessor on Opportunity (after update, before update) {

    //Begin Change TPB 10/29/2014
    string RtId = querybase.getRecordtypeId('Opportunity', 'X2_50');
    //End Change TPB 10/29/2014
    

/* Instantiate  OpportunityProcessorManager to access its public methods in the trigger. */ 
    OpportunityProcessorManager  oppManager = new OpportunityProcessorManager();
    
    if(trigger.isBefore){
/*
 * @Purpose: Change'Lead Rep Name'when Opportunity owner changed for Opportunity with Stage='Proposal'. Also marked opportunity as Transitioned.
 * @Description : When Opportunity owner changes, if that owner is a Lead_Rep (checked in the User Record), then the 'Lead Rep Name' 
 * field in the opp record will be populated by the new owner , otherwise set to null.Also marked the opportunity as Transitioned.
 */ 
        System.debug('****** Within OpportunityProcessor Trigger : Before Update ****** ');
        Set<Id> ownerIds = new Set<Id>();
         Map<Id, User > userMap = new Map<Id, User > ();
        /* looping over the Opportunity to create the set of Owner Ids*/
        for (Opportunity opp: Trigger.new){
        
            //Begin Change TPB 10/29/2014
            system.debug('%%%%%%%%%%%%' + RtId);
            system.debug('%%%%%%%%%%%%' + opp.RecordtypeId);
            if ( opp.RecordTypeId == RtId ) continue;
            
            system.debug('%%%%%%%this thing continues at isBefore');
            //End Change TPB 10/29/2014
            
            Opportunity beforeUpdate = System.Trigger.oldMap.get(opp.Id);
            if(beforeUpdate.OwnerId !=  opp.OwnerId && opp.StageName =='Proposal'){
                ownerIds.add(opp.OwnerId) ;
                opp.Transitioned__c = true; 
            }
        }
        /* get the User information for the ownerIds set*/
        if(ownerIds.size()>0){
            List<User> userList = [select id , name, Lead_Rep__c from user where id in:ownerIds];
            for(User user:userList){
                userMap.put(user.id, user);
            }
        }
        /* looping over the Opportunity to update the 'Lead Rep Name'*/
        for (Opportunity opp: Trigger.new){
        
            //Begin Change TPB 10/29/2014
            if ( opp.RecordTypeId == RtId ) continue;
            //End Change TPB 10/29/2014  
                  
            if(userMap.size()>0){
                if(userMap.containsKey(opp.OwnerId)){
                    User user = userMap.get(opp.OwnerId);
                    System.debug('****** Within OpportunityProcessor Trigger : User is ****** ' + user);
                        if(user.Lead_Rep__c){
                            opp.Lead_Rep_Name_User__c = user.id;
                        }
                        else{
                            opp.Lead_Rep_Name_User__c = null;
                        }
                    
                }
            }
        }
    }
    if(trigger.isAfter){
        System.debug('****** Within OpportunityProcessor Trigger : After Update ****** ');
        
/*
 * @Purpose: Change Account Owner when Opportunity owner changed for Opportunity with Stage='Proposal'. 
 * @Description : When Opportunity owner changes , the corresponding Account owner will be changed. Also the New Account owner will received 
 * an email notification for the account assignment. 
 * @ Method : Public method changeAccountOwnerForOpportunityOwnerChange() of Apex Class: OpportunityProcessorManager.cls has been implemented to hold the 
 * logic for this process. 
 *
 */ 
         Set<Id> accountId = new Set<Id>();
         Map <id , Opportunity> accIdOpportunityMap = new Map< id ,Opportunity>();
         /* looping over the Opportunity to create the accountId set and accIdOpportunityMap Map */
         for (Opportunity opp: Trigger.new){
            Opportunity beforeUpdate = System.Trigger.oldMap.get(opp.Id);
            if(beforeUpdate.OwnerId !=  opp.OwnerId && opp.StageName =='Proposal'){
                accountId.add(opp.AccountId);
                accIdOpportunityMap.put(opp.AccountId, opp);
            }
        }
        /* Called public method changeAccountOwnerForOpportunityOwnerChange() */  
         if(accountId.size()> 0){ 
            oppManager.changeAccountOwnerForOpportunityOwnerChange(accountId ,accIdOpportunityMap) ;
        }
/*
 * @Purpose: Clone Opportunity when Opportunity stage changes to 'Sold'and Business Type not equal to 'New'.
 * @Description : When opportunity stage changes to 'Sold', then the opportunity and its related records of - OpportunityLineItem,OpportunityContactRole,
 * OpportunityPartner will be cloned. 
 * @ Method : Public method cloneOpportunityOnOpportunityStageUpdate() of Apex Class: OpportunityProcessorManager.cls has been implemented to hold the 
 * logic for this cloning process.
 */   
 
    List<Opportunity> oppList = new List<Opportunity>();
    for (Opportunity opp: Trigger.new){
   
        //Begin Change TPB 10/29/2014
        system.debug('%%%%%%%%%%%% on update' +RtId);
        system.debug('%%%%%%%%%%%% on update' +opp.RecordtypeId);
        if ( opp.RecordTypeId == RtId ) continue;
        
        system.debug('%%%%%%%this thing continues at isAfter');
        //End Change TPB 10/29/2014

        Opportunity beforeUpdate = System.Trigger.oldMap.get(opp.Id);
    
        if(beforeUpdate.StageName != opp.StageName && opp.StageName =='Sold' && opp.Business_Type__c <> 'New'){
            oppList.add(opp);
        }
}
/*NOTE: As discussed with Bill on 16th Dec'10, we are restricting the clone functionality for only one record , not for bulk update. */          
        if(oppList.size()== 1){
            Opportunity oppToClone;
            for( Opportunity opp:oppList){
            
                oppToClone = opp;
            }   
            /* Called public method cloneOpportunityOnOpportunityStageUpdate() */  
            if(oppToClone != null){
            
                oppManager.cloneOpportunityOnOpportunityStageUpdate(oppToClone);
            }                    
        }        
    } 
}