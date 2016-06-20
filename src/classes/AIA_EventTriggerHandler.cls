/*=========================================================================================
 * Date     : 05/31/2016
 * Developer :    Sree Harsha Akkala
 * Purpose      : This class is the extension point of the Trigger Framework for adding Event trigger handlers.
 *                
 *               
 *
 *=========================================================================================
 *                                 Update History
 *                                 ---------------
 * Date       Developer         Description
 *===========+============+================================================================
 * 05/31/16  |  HA    | Initial Version                                         
 *           |        | 
 *===========+============+================================================================
 */


public with sharing class AIA_EventTriggerHandler extends TriggerHandler {

    public AIA_EventTriggerHandler() {}
    
        /* context override */
    protected override void beforeUpdate() {
        
    }
    
    protected override void beforeInsert() {
        
    }
    
    protected override void afterInsert() {
        BidMeetingUpdate((Map<id,event>) trigger.oldMap,(list<event>) trigger.new);
    }
    
    protected override void afterUpdate() {
        BidMeetingUpdate((Map<id,event>) trigger.oldMap,(list<event>) trigger.new);
    }



private  void  BidMeetingUpdate(Map<id,event> eventOldMap,list<event> eventList){
    list<event> PRFeventList = new list<event>();
    list<event> BRFeventList = new list<event>();
    list<event> updateEventList = new list<event>();
   

    for(event e: eventList){
        //if(schema.PRF__c.sObjectType == id.valueof(e.whatId).getsObjectType() || schema.Benfit_Request_Form__c.sObjectType == id.valueof(e.whatId).getsObjectType()){
        //Puts all the events related to a PRF into a list
        if(schema.PRF__c.sObjectType == id.valueof(e.whatId).getsObjectType()){
            if(trigger.isInsert)
               PRFeventList.add(e);
            if(trigger.isUpdate){
                if(eventOldMap.get(e.id).Bid_Meeting_Decision__c!=null)
                PRFeventList.add(e);
                else
                updateEventList.add(e);
            }
        }
        //Puts all the events related to a BRF into a list
        if(schema.Benfit_Request_Form__c.sObjectType == id.valueof(e.whatId).getsObjectType()){
             BRFeventList.add(e);
        }
        
       
    }
    //Invokes the PrevDuplicateBidDecisions method upon Inserting an event for a PRF
    if(trigger.isInsert && PRFeventList!=null)
        AIA_EventHandler.PrevDuplicateBidDecisions(PRFeventList);

    //Invokes the PrevDuplicateBidDecisions,PrevEditing,updatePRF methods upon updating an event for a PRF
    if(trigger.isUpdate && PRFeventList!=null){
        AIA_EventHandler.PrevDuplicateBidDecisions(updateEventList);
        AIA_EventHandler.PrevEditing(PRFeventList);
        AIA_EventHandler.updatePRF(updateEventList);
    }

    //Invokes the UpdateBRF method to update the related BRF record
    if(BRFeventList!=null){
        AIA_EventHandler.UpdateBRF(BRFeventList);
    }
    
    
}

}