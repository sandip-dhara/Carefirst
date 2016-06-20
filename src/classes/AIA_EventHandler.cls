//===================================================================================
//Date: 04/21/2016
//Developer: Sree Harsha Akkala
//Purpose: Eventhandler.
//=========================================================================================
// Update History
// Date         Developer               Description
//==================================================================================
//04/21/2016    Sree Harsha Akkala      Initial Development
//==================================================================================
public class AIA_EventHandler{
public static final string BID_MEETING ='Bid Meeting';
public static final string BID ='Bid';
public static final string NO_BID ='No Bid';
public static final string NO_DECISION='No Decision';
public static Id rt_acc_51= QueryBase.getRecordtypeId('Event', 'AIA_Meeting');

/*******************************************************************
Purpose:  The method prevents creation of events with BID or NO BID if the meeting decision is taken
Parameters: List<event>
Returns: None                                                        
********************************************************************/
// TODO: This is not using the proper trigger handler code, it should extend the triggerHandler
// TODO: PreventEditing of Event after decision - can't this be done in a validation rule
// TODO: Please add eror handling - there is no try catch block in most of the code

public static void PrevDuplicateBidDecisions(list<event> NewPRFEvents){
    set<id> PRFIdSet = new set<id>();
    set<id> eventIdSet = new set<id>();
    for(event e:NewPRFEvents){
        PRFIdSet.add(e.whatId);
        eventIdSet.add(e.id);
    }
    
    list<event> ExistingPRFEvents = [select id,Bid_Meeting_Decision__c,Meeting_Type__c,whatId,RecordTypeId from event where whatId in:PRFIdSet AND isdeleted = false and  id NOT IN :eventIdSet];
    //Id rt_acc_51= QueryBase.getRecordtypeId('Event', 'AIA_Meeting');
    if(rt_acc_51 != null){
        for(event existingEvent:ExistingPRFEvents){
            for(event newEvent: NewPRFEvents){
                if(existingEvent.whatId==newEvent.whatId && rt_acc_51 == newEvent.RecordTypeId){
                    if(newEvent.Meeting_Type__c == BID_MEETING && existingEvent.Meeting_Type__c != null){
                        if(newEvent.Bid_Meeting_Decision__c != null){
                            if((existingEvent.Bid_Meeting_Decision__c == BID|| existingEvent.Bid_Meeting_Decision__c == NO_BID) && (newEvent.Bid_Meeting_Decision__c == BID || newEvent.Bid_Meeting_Decision__c == NO_BID)){
                               newEvent.addError('You cannot create another event when it is already '+existingEvent.Bid_Meeting_Decision__c); 
                            }
                        }else if(existingEvent.Bid_Meeting_Decision__c == null){
                            if(newEvent.Bid_Meeting_Decision__c == BID || newEvent.Bid_Meeting_Decision__c == NO_BID){
                                newEvent.addError('You cannot create another event when it is already '+existingEvent.Bid_Meeting_Decision__c); 
                            }
                        }
                    }
                }
            }           
        }
        updatePRF(NewPRFEvents);
    }
}

/*******************************************************************
Purpose:  The method updates the PRF record fields finalmeetingdecision,OriginalBidDate,FinalDecisionDate & NoBidCommments
Parameters: List<event>
Returns: None                                                        
********************************************************************/    
public static void updatePRF(list<event> NewPRFEvents){
    set<id> PRFIdSet = new set<id>();
    for(event e:NewPRFEvents){
        PRFIdSet.add(e.whatId);
    }

    list<event> ExistingPRFEvents = [select id,createdDate,Bid_Meeting_Decision__c,Meeting_Type__c,No_Bid_Comments__c,whatId from event  where whatId in:PRFIdSet and isdeleted = false order by createdDate ASC];
    list<PRF__c> PRFList = new list<PRF__c>();
    PRFList=[select id,Final_Bid_Decision__c from PRF__c where id in:PRFIdSet];
    Map<id,list<event>> PRFEventsMap = new Map<id,list<event>>();

    if(ExistingPRFEvents.size()>0){
        for(event e: ExistingPRFEvents){
            list<event> tempEventList = new list<event>();
            if(PRFEventsMap.get(e.whatId)==null){
                tempEventList.add(e);
                PRFEventsMap.put(e.whatId,tempEventList);
            }
            else{
                tempEventList.addAll(PRFEventsMap.get(e.whatId));
                tempEventList.add(e);
                PRFEventsMap.put(e.whatId,tempEventList);
            }
        }
    }

    if(PRFList.size()>0 || PRFList != null){
    for(PRF__c prf: PRFList){
        for(event e:PRFEventsMap.get(prf.id)){
            if(e.Meeting_Type__c == BID_MEETING){
            prf.Original_Bid_Date__c = e.createdDate.date();
            break;
            }
        }
    }
    for(PRF__c prf: PRFList){
        for(event e:PRFEventsMap.get(prf.id)){
            
            if(e.Bid_Meeting_Decision__c==BID){
                prf.Final_Bid_Decision__c=BID;
                prf.Final_Decision_Date__c=e.createdDate.date();
                break;
            }
            if(e.Bid_Meeting_Decision__c==NO_BID){
                prf.Final_Bid_Decision__c=NO_BID;
                prf.Final_Decision_Date__c=e.createdDate.date();
                if(e.No_Bid_Comments__c!=null)
                prf.No_Bid_Comments__c= e.No_Bid_Comments__c;
                break;
            }
            if(e.Bid_Meeting_Decision__c==NO_DECISION){
                prf.Final_Bid_Decision__c=NO_DECISION;                    
            }               
        }
    }
    update PRFList;             
}
}

/*******************************************************************
Purpose:  The method prevents editing the event record once the bid meeting decision is taken
Parameters: List<event>
Returns: None                                                        
********************************************************************/ 
// TODO: Please see if you can do this in a validation rule
public static void PrevEditing(list<event> NewPRFEvents){
    for(event e:NewPRFEvents){
        if(e.Bid_Meeting_Decision__c!=null)
        e.addError('You cannot edit this record');          
    }
    
}


/*******************************************************************
Purpose:  The method updates the BRF record with ARCApprovalStatus & ARCcomments
Parameters: List<event>
Returns: None                                                        
********************************************************************/ 
// TODO: UpdateBRFWithARCApprovalStatus
// TODO: Please add comments
public static void updateBRF(list<event> NewBRFEvents){
    set<id> BRFIdSet = new set<id>();
    for(event e:NewBRFEvents){
        BRFIdSet.add(e.whatId);
    }
    
    list<event> ExistingBRFEvents = [select id,createdDate,Approval_Meeting_Decision__c,ARC_Meeting_Comments__c,Meeting_Type__c,No_Bid_Comments__c,whatId,RecordTypeId from event  where whatId in:BRFIdSet and isdeleted = false order by createdDate ASC];
    list<Benfit_Request_Form__c> BRFList = new list<Benfit_Request_Form__c>();
    BRFList=[select id,ARC_Approval_Status__c,ARC_Comments__c from Benfit_Request_Form__c where id in:BRFIdSet];
    Map<id,list<event>> BRFEventsMap = new Map<id,list<event>>();
    if(ExistingBRFEvents.size()>0){
        for(event e: ExistingBRFEvents){
            list<event> tempEventList = new list<event>();
            if(BRFEventsMap.get(e.whatId)==null){
                tempEventList.add(e);
                BRFEventsMap.put(e.whatId,tempEventList);
            }
            else{
                tempEventList.addAll(BRFEventsMap.get(e.whatId));
                tempEventList.add(e);
                BRFEventsMap.put(e.whatId,tempEventList);
            }
        }
    }

    if(BRFList.size()>0 || BRFList != null){
        for(Benfit_Request_Form__c brf: BRFList){
            for(event e:BRFEventsMap.get(brf.id)){
                if(rt_acc_51 != null){
                    if(e.Meeting_Type__c == 'ARC Approval Meeting' && rt_acc_51 == e.RecordTypeId ){
                        brf.ARC_Approval_Status__c = e.Approval_Meeting_Decision__c;
                        brf.ARC_Comments__c = e.ARC_Meeting_Comments__c;
                        break;
                    }
                }
            }
        }
        update BRFList;
    }   
    
}
    
}