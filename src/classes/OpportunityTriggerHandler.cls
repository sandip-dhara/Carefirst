/*=========================================================================================
 * Date         : 10/21/2014
 * Developer    : Ken Gill
 * Purpose      : This class is the extension point of the Trigger Framework for adding Opportunity trigger handlers.
 *                
 *               
 *
 *=========================================================================================
 *  Update History
 *  ---------------
 * Date       Developer         Description
 *===========+============+================================================================
 * 11/17/14  |  KG    | Initial Version                                         
 * 12/18/15  |  TPB   | Added functionality to update the account.type field based on the
 *                    | latest opportunity.stage
 *===========+============+================================================================
 */


public with sharing class OpportunityTriggerHandler extends TriggerHandler {

public OpportunityTriggerHandler() {}
        
/**
* @This Method is called when user changes from one opp recordtype to 200+ record type, and to assign workplan type to that opportunity and create the workplan stages as well  
* @Output - List if opp with Recordtypechange, newMap and oldMap - calling methods from AIA_Workplan class for assigning the workplan type to opp,creating stages and update of stages too  
*/    
    protected override void beforeUpdate() 
    {
        Map<id,Opportunity> tnewMap = new Map<id,Opportunity>();        //opp Mapping for new value
        Map<id,Opportunity> toldMap = new Map<id,Opportunity>();        //opp Mapping for old value
        
        tnewMap  = (Map<id,Opportunity>)Trigger.newMap;
        toldMap  = (Map<id,Opportunity>)Trigger.oldMap;
        
        Id opptwohundredplusId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('200+').RecordTypeId;  //To get 200+ recordTypeId
        List<Opportunity> recordTypeChange = new List<Opportunity>();                                            //recordTypeChange Opplist
        List<Opportunity> OpportunityStageChange = new List<Opportunity>();                                      //list of opp To check wheather user is allowed to change the opp stage or no
        
        //Looping opp with the newmap values
        for(Opportunity opp:tnewMap.values())
        {
            if(opp.RecordTypeId == opptwohundredplusId   && opp.RecordTypeId != toldMap.get(opp.id).RecordTypeId && opp.Workplan_Type__c == Null)
            {
                //adding all the opp with 200+ recordType,and checking the above condition
                recordTypeChange.add(opp);
            }
            if(opp.StageName != toldMap.get(opp.id).StageName){
                OpportunityStageChange.add(opp);          //Checking stage old and new values and adding them to opp list  
            }   
        }
        
        //This loop is for when user changes record type to 200+ is assigning worplan Type, creating workplan stages & update on workplan stages 
        if(recordTypeChange != null && recordTypeChange.size()>0)
           {
                AIA_Workplan wp = new AIA_Workplan();
                wp.assignWorkplan(recordTypeChange);
                wp.createWorkplanStages(recordTypeChange);
                AIA_Workplan.UpdateWorkplanStages(tnewMap,toldMap);
            }
        //This loop is to check for change of opp stage and allow users accordingly     
        if(OpportunityStageChange != null && OpportunityStageChange.size()>0){
              AIA_Workplan wp = new AIA_Workplan();
             wp.OpportunityNextStageCheck(OpportunityStageChange,tnewMap,toldMap);
            
        }
            
    }
    
    
    
    //Laveen-Added for assigning the workplan type to respective opp
    protected override void beforeInsert() 
    {
        AIA_Workplan wp = new AIA_Workplan();
        wp.assignWorkplan((List<Opportunity>) Trigger.new);     
    }
    //End
    
    protected override void afterInsert() {
            if(!firstRun)
            createImplementation((List<Opportunity>) Trigger.new);
            Map<id,Opportunity> tnewMap = new Map<id,Opportunity>();        //opp Mapping for new value
            Map<id,Opportunity> toldMap = new Map<id,Opportunity>();        //opp Mapping for old value
        
            tnewMap  = (Map<id,Opportunity>)Trigger.newMap;
            toldMap  = (Map<id,Opportunity>)Trigger.oldMap;
                    
            processAfterEGPOpportunityInsertOrUpdate();
            processAccountBasedOnLatestOppStageChange(); //Begin Add 12/18/15 TPB
            
            //Laveen - Added for creating the workplan stages on opp
            AIA_Workplan wp = new AIA_Workplan();
            wp.createWorkplanStages((List<Opportunity>) Trigger.new);
            AIA_Workplan.UpdateWorkplanStages(tnewMap,toldMap);         // added here b'cos -for new opp creation if opp.stage is equal to workplan stage (Sub-process)record, then that record should go In progress  
            
            //End
            //system.debug('@@ in after insert');            
            
    }
    
    protected override void afterUpdate() {
        if(!firstRun)
        createImplementation((List<Opportunity>) Trigger.new);
        processAfterEGPOpportunityInsertOrUpdate();
        processAccountBasedOnLatestOppStageChange(); //Begin Add 12/18/15 TPB
        
        //Chida:B-02108 User can mark the Opportunity as sold (contract was awarded) 
        //if there is a Benefit Request Form marked as sold 
          AIA_Opportunity_Helper mos = new AIA_Opportunity_Helper();
          mos.AIA_Opportunity_Helper((List<Opportunity>) Trigger.new);
        //End
        
        //Laveen - Added to update workplan stage Status to In progress & Start date as today wrt Opportunity Stage
        //New and Old Map values to Update Workplan Stages 
        Map<id,Opportunity> newMap = new Map<id,Opportunity>();
        Map<id,Opportunity> oldMap = new Map<id,Opportunity>(); 
        Map<id,Opportunity> tnewMap = new Map<id,Opportunity>();
        Map<id,Opportunity> toldMap = new Map<id,Opportunity>();
        
        tnewMap  = (Map<id,Opportunity>)Trigger.newMap;
        toldMap  = (Map<id,Opportunity>)Trigger.oldMap;
        
        for(Opportunity opp:tnewMap.values())
        {
            //checking the new value stageName is not equal to old one
            if(opp.StageName != toldMap.get(opp.id).StageName)
            {
                newMap.put(opp.id,opp);
                oldMap.put(opp.id,toldMap.get(opp.id));
            }
            
        }
        
        // Update Workplan Stages
        if(newMap != null && newMap.size()>0){
            AIA_Workplan.UpdateWorkplanStages(newMap,oldMap);    
        }
        // End of Laveen's code
        //system.debug('@@ in after update');
         
        
    }
    
    protected override void afterDelete() {
        processAccountBasedOnOppDelete(); //Begin Add 12/18/15 TPB
    }
    
    protected override void AfterUnDelete() {
        processAccountBasedOnOppUnDelete(); //Begin Add 12/18/15 TPB
    }
    
    

    private void processAfterEGPOpportunityInsertOrUpdate() {
        if(System.isBatch()|| System.isFuture()) {
            System.debug('OpportunityTriggerHandler: Bypassing EGP Opportunity update processing when called from a batch job');
            return;
        }   
        
        // Note on casting below:
        // Outside a trigger, the trigger collections Trigger.new,.old have to be explicitly cast to the SOBject type
        // When working inside a trigger, this casting happens implicitly
        EGPService.processAccountOpportunityUpdateChanges(( List<Opportunity>) Trigger.new, (Map<Id,Opportunity>) Trigger.oldMap);
    }

    // Begin Add 12/18/15 TPB
    private void processAccountBasedOnLatestOppStageChange() {
        UpdateAccountBasedOnLatestOppStageChange.UpdateAccountTypeField((List<Opportunity>) Trigger.new, (Map<Id, Opportunity>) Trigger.oldMap);
    }
    
    private void processAccountBasedOnOppDelete() {
        UpdateAccountBasedOnLatestOppStageChange.UpdateAccountTypeField((List<Opportunity>) Trigger.old, (Map<Id, Opportunity>) Trigger.oldMap);
    }    

    private void processAccountBasedOnOppUnDelete() {
        UpdateAccountBasedOnLatestOppStageChange.UpdateAccountTypeField((List<Opportunity>) Trigger.new, (Map<Id, Opportunity>) Trigger.newMap);      
    }  
    // End Add 12/18/15 TPB
    public static boolean firstRun = false;
    public static Id RecType200Plus = QueryBase.getRecordTypeId('Opportunity', 'AIA_200');
    private static void createImplementation(list<opportunity> opportunityList ){       
        system.debug('@@ in createImplementation');
        list<Benfit_Request_Form__c> brfList = [select id,name,Status__c,Opportunity__c  from Benfit_Request_Form__c  where Opportunity__c in: opportunityList ];
        Map<id,id> oppBRFIdMap = new Map<id,id>();
        for(opportunity opp: opportunityList){
            for(Benfit_Request_Form__c brf:brfList){
                if(brf.Opportunity__c==opp.id){
                oppBRFIdMap.put(opp.id,brf.id);
                break;
                }   
            }
        }
        
        list<AIA_Implementation__c> PSIlist = new list<AIA_Implementation__c>();
        for(opportunity opp: opportunityList){
            if(opp.recordtypeId==RecType200Plus && opp.stageName=='Sold'){
                AIA_Implementation__c psi = new AIA_Implementation__c();
                psi.name__C =opp.name;
                psi.Description__c  =opp.description;
  //              psi.Workplan_Type__c = opp.Workplan_Type__c;
                psi.Status__c='Not Started';
                psi.Account__c = opp.accountId;
                psi.Benefit_Request_Form__c=oppBRFIdMap.get(opp.id);
                psi.Opportunity__c=opp.id;
                PSIlist.add(psi);
            }
        }
        firstRun =true;
        insert PSIlist;
        }
    
}