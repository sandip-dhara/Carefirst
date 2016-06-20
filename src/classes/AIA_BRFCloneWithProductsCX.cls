/*=========================================================================================
// Date: 04/21/2016
// Developer: Goutham Rapolu
// Purpose: Select Previous Plan Year's Form Story --B02086
// Limitations:
//
//=========================================================================================
//                                 Update History
// Date       Developer      Description
// 5/25/2016  PR             Removed the field utilization (Blue_Rewards_wellness__C,FSA_Blue_Fund,Carve_out_integration__C,Formulary_ASO__c,
//                           Exclusive_Speciality_Network__c,Formulary_Risk__c,Tiers__c) 
//=========================================================================================
//
//========================================================================================= */


public with sharing class AIA_BRFCloneWithProductsCX {
    //added an instance varaible for the standard controller
    private ApexPages.StandardController controller {get; set;}
     // add the instance for the variables being passed by id on the url
    public Benfit_Request_Form__c BRF{get;set;}
    
    public Benfit_Request_Form__c newBRF{get;set;}
    // initialize the controller
    public AIA_BRFCloneWithProductsCX(ApexPages.StandardController controller) {

        //initialize the stanrdard controller
        this.controller = controller;
        // load the current record
        BRF = (Benfit_Request_Form__c)controller.getRecord();

    }
    
    /**
    * @Author: Goutham Rapolu
    * @This method - method called from the VF's action attribute to clone the BRF
    * @param - 
    * @Output -
    */
    public PageReference cloneWithProducts() {

         // setup the save point for rollback
         Savepoint sp = Database.setSavepoint();
        
        
         try {
              //copy the Benfit_Request_Form__c
             String soql = QueryBase2.getCreatableFieldsSOQL('Benfit_Request_Form__c','id  =\''+BRF.id+'\'');
             system.debug('soql'+soql);
             BRF = (Benfit_Request_Form__c)Database.query(soql);
             newBRF = BRF.clone(false);
             insert newBRF;
             
             // copy over the Proposed_Products__c
             List<Proposed_Products__c> items = new List<Proposed_Products__c>();
             if(newBRF != null){
                  String soqlForPP = QueryBase2.getCreatableFieldsSOQL('Proposed_Products__c','Benefit_Request_Form__c =\''+BRF.id+'\'');
                  List<Proposed_Products__c> ppList = new List<Proposed_Products__c>();
                  ppList = Database.query(soqlForPP);
                  if(ppList != null && ppList.size()>0){
                  for(Proposed_Products__c pp: ppList){
                      Proposed_Products__c newPP = pp.clone(false);
                      newPP.Benefit_Request_Form__c = newBRF.id;
                      items.add(newPP);
                 }
                 }
             }
             system.debug('items'+items);
             if(items != null && items.size()>0){
                insert items;
             }

         } catch (Exception e){
             // roll everything back in case of error
            Database.rollback(sp); ApexPages.addMessages(e); return null;
         }
         

        return new PageReference('/'+newBRF.id+'/e?retURL=%2F'+newBRF.id);
    }
       
}