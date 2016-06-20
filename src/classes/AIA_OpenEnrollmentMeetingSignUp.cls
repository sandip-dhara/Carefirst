/*------------------------------------------------------------------------------------
 *                      ----===[ HISTORY ]===---
 * Date        Developer        Description
 *------------------------------------------------------------------------------------
 * 06/06/2016 Sree Harsha Akkala    This class is used with the signup button
                                 
 * 
  *************************************************************************************
 */

/**
* @Author: Sree Harsha Akkala 
* @Purpose: This class allows the users to signup for the OpenEnrollmentMeeting
*/
global class AIA_OpenEnrollmentMeetingSignUp {
    
/**
* @This webservice static Method is called from signUp button on event record 
* @This method - Creates a relation between event & the current user who is signing up (if event not full/completed)
* @param - EventId  
* @Output - Inserts eventRelation record 
*/
    // TODO: Why do I need to call a webservice to update the event, instead of directly updating the event relationship
    // Sree to check if we can directly update the event relation object directly instead of calling a webservice
    webservice static void signUp(String eventId) {
        EventRelation er = new EventRelation(EventId = eventId, RelationId = userinfo.getUserId(), Status='Accepted');
        insert er;
        event e = [select current__c,capacity__c,Meeting_Status1__c from event where id=:eventId];
        if(e.current__c!=null)      
        e.current__c=e.current__c+1;
        else
        e.current__c=1;
    system.debug('@@ current__c'+e.current__c);
    system.debug('@@ capacity__c'+e.capacity__c);
        if(e.capacity__c!=null){
        if(e.current__c==e.capacity__c){
            system.debug('@@ in full');
            e.Meeting_Status1__c='Full';
        }
        }
        update e;
        
    }
    
}