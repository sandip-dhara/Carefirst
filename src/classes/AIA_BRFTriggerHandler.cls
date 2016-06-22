/********************************************************************************
********************************************************************************    
 *  Class            : AIA BRF Trigger Handler
 *  Author           : Rajesh Pennam
 *  Version History  : 1.0
 *  Creation         : 05/09/16
 *  Description      : This class will have the logic for trigger (BRF Trigger). If the BRF form is
 *                     created from Proposal Request form then the Opportunity of the PRF will be 
 *                     populated to the Opportunity of BRF  

 *
 ********************************************************************************
 ********************************************************************************/

public class AIA_BRFTriggerHandler  extends TriggerHandler {
    
     public AIA_BRFTriggerHandler() {}
    
        /* context override */
    protected override void beforeInsert() {
        updateSeniorManagement((list<Benfit_Request_Form__c>) trigger.new);
        AIA_BRFTriggerHelper.accountNameUpdate((list<Benfit_Request_Form__c>) trigger.new,(Map<id,Benfit_Request_Form__c>) trigger.oldMap);
    }
    
    protected override void beforeUpdate() {    
        updateSeniorManagement((list<Benfit_Request_Form__c>) trigger.new);
        ValidateSoldBRF((list<Benfit_Request_Form__c>) trigger.new,(Map<id,Benfit_Request_Form__c>) trigger.newmap,(Map<id,Benfit_Request_Form__c>) trigger.oldmap);
        AIA_BRFTriggerHelper.accountNameUpdate((list<Benfit_Request_Form__c>) trigger.new,(Map<id,Benfit_Request_Form__c>) trigger.oldMap);
    }
        
    
    protected override void afterInsert() {
        ValidateSoldBRF((list<Benfit_Request_Form__c>) trigger.new,(Map<id,Benfit_Request_Form__c>) trigger.newmap,(Map<id,Benfit_Request_Form__c>) trigger.oldmap);
        updateOpportunityOnBRF((list<Benfit_Request_Form__c>) trigger.new);
        //AIA_BRFTriggerHelper.accountNameUpdate((list<Benfit_Request_Form__c>) trigger.new,(Map<id,Benfit_Request_Form__c>) trigger.oldMap);
        if(AIA_BRFTriggerHelper.BRFListForEmail != null && AIA_BRFTriggerHelper.BRFListForEmail.size()>0 && AIA_BRFTriggerHelper.accIDs != null && AIA_BRFTriggerHelper.accIDs.size()>0)
        AIA_BRFTriggerHelper.processEmail(AIA_BRFTriggerHelper.BRFListForEmail,AIA_BRFTriggerHelper.accIDs);
    }
    
    protected override void afterUpdate() {
        
    }
    /**
    * @Author : Rajesh Pennam
    * @param  : This method is used to update the oppotunity of BRF from PRF
    * @param  : List<Benfit_Request_Form__c> brflst
    * @Output : This method inserts the opportunity on BRF from PRF
    * @return the list of lineitem sobjects 
    */  
    public static List<Benfit_Request_Form__c> UpdateBRFLst = new List<Benfit_Request_Form__c>();
    public static set<Id> PRFids = new set<Id>();
    public static List<PRF__c> PRFLst = new List<PRF__c>();
 
   public static void updateOpportunityOnBRF(List<Benfit_Request_Form__c> brflst){
        for(Benfit_Request_Form__c brf: brflst){
            PRFids.add(brf.Proposal_Request_Form__c);
        }
        
        //PRF List will have the id and the Opportunity of PRF
        PRFLst = [select id,Opportunity__c from PRF__c where id IN :PRFids];
        
        //This loop makes the Opportunity of PRF to Populate to Opportunity of BRF
        for(Benfit_Request_Form__c brf: brflst){
            for(PRF__c prf: PRFLst){
                system.debug('PRF opportunity is '+prf.Opportunity__c);
                if(prf.Opportunity__c != null && brf.Proposal_Request_Form__c != null && brf.Proposal_Request_Form__c == prf.id){
                    Benfit_Request_Form__c nbrf = new Benfit_Request_Form__c();
                    nbrf.id = brf.id;
                    nbrf.Proposal_Request_Form__c = prf.id;
                    nbrf.Opportunity__c = prf.Opportunity__c;
                    UpdateBRFLst.add(nbrf);
                }
            }
        }
        
        //Exception Handling
        
        try{
            if(UpdateBRFLst.size()>0 && UpdateBRFLst != null)
                update UpdateBRFLst;
        }catch(DMLException ex){
            system.debug(ex+'');
        }
    }
    
    /**
* @Author: Sree Harsha Akkala
* @This Method is called from BRFTrigger during insertion or updation of BRF
* @This method - The method tracks who has set the ARC approval status 
* @param -  list<Benfit_Request_Form__c> 
* @Output - Sets the Senior Management Approved by to the current user
*/    
public static void updateSeniorManagement(list<Benfit_Request_Form__c> brfList){
     for(Benfit_Request_Form__c brf:brfList){        
        if((brf.ARC_Approval_Status__c == AIA_Constants.APPROVED_BY_COMMITTEE || brf.ARC_Approval_Status__c==AIA_Constants.REJECTED_BY_COMMITTEE) &&(brf.Escalated_to_Senior_Management__c)){            
            brf.Senior_Management_Approved_By__c = userinfo.getuserId(); //Sets the seniormanagement approved by to current user
        }
        if(brf.status__c=='Sold')
        brf.Who_Marks_Sold__c   = userinfo.getuserid(); //tracks who has set the brf to Sold(used in email alert of approval process) 
                
    }
}


/**
* @Author: Sree Harsha Akkala
* @This Method is called from BRFTrigger during insertion or updation of BRF
* @This method - The method validates when the BRF has to be set to sold
* @param -  list<Benfit_Request_Form__c> 
* @Output - Display an error message if set to sold without signed Quote or Approved Unsigned quote
*/
public static void ValidateSoldBRF(list<Benfit_Request_Form__c> newbrfList,Map<id,Benfit_Request_Form__c> newBRFMap,Map<id,Benfit_Request_Form__c> oldBRFMap){
    list<Benfit_Request_Form__c> brfList = new list<Benfit_Request_Form__c>();
    set<id> brfIdSet = new set<id>();
    for(Benfit_Request_Form__c brf:newbrfList){
        if(oldBRFMap!=null){
        if(oldBRFMap.get(brf.id).status__c=='Sold'){
                brf.addError('You cannot  edit the sold BRF record');
        }
        }
        if(brf.Status__c=='Sold'){          
        brfList.add(brf);
        brfIdSet.add(brf.id);
        }
    }
        
    list<Benfit_Request_Form__c> existingBRFList = [select id,name,ARC_Approval_Required__c,ARC_Approval_Status__c,(select id,name,Document_Type__c,Approval_Status__c from File_Net_Documents__r where Document_Type__c!=null) from Benfit_Request_Form__c where id in:BRFIdSet];
    if(existingBRFList.size()>0){        
        for(Benfit_Request_Form__c brf:existingBRFList){ 
            boolean setToSold=false;
            if(brf.File_Net_Documents__r.size()>0){        
                for(AIA_Document__c fd:brf.File_Net_Documents__r){
                    if((fd.Document_Type__c=='Signed Quote' ||  (fd.Document_Type__c=='Unsigned Quote' && fd.Approval_Status__c=='Approved')) ){
                        if((newBRFMap.get(brf.id).ARC_Approval_Required__c==true && newBRFMap.get(brf.id).ARC_Approval_Status__c==AIA_Constants.APPROVED_BY_COMMITTEE)|| newBRFMap.get(brf.id).ARC_Approval_Required__c==false){
                            brf.File_Net_Doc_Id__c=fd.id;
                            newBRFMap.get(brf.id).File_Net_Doc_Id__c=fd.id;
                            setToSold=true;
                        }                       
                    }                    
                }
                if(setToSold==false){
                    newBRFMap.get(brf.id).addError('You cannot set the BRF to sold');
                }
                    
            }
            else{                
                newBRFMap.get(brf.id).addError('You cannot set the BRF to sold');
            }
              
        }
          
    }
}
}