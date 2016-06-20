//===================================================================================
//Date: 04/21/2016
//Developer: Sree Harsha Akkala
//Purpose: Test class for Eventhandler.
//=========================================================================================
// Update History
// Date         Developer               Description
//==================================================================================
//04/21/2016    Sree Harsha Akkala      Initial Development
//==================================================================================
@isTest
private class AIA_EventHandler_Test{
    /*******************************************************************
    Purpose:  This  testmethod tests the logic of eventhandler
    Parameters: None
    Returns: None                                                        
    ********************************************************************/
    static testmethod void testPrevDuplicateBidDecisions(){
        try{
        test.startTest();
        PRF__c prf = new PRF__c(name='TestPRF');
        insert prf;
        event noDecisionEvent = new event(DurationInMinutes=60,ActivityDateTime=system.now(),whatId=prf.id,Bid_Meeting_Decision__c='No Decision');
        insert noDecisionEvent ;
        event NoBidDecisionEvent= new event(DurationInMinutes=60,ActivityDateTime=system.now(),whatId=prf.id,Bid_Meeting_Decision__c='No Bid',No_Bid_Comments__c='Did not like the deal');
        insert NoBidDecisionEvent;
        event BidDecisionEvent = new event(DurationInMinutes=60,ActivityDateTime=system.now(),whatId=prf.id,Bid_Meeting_Decision__c='No Bid',No_Bid_Comments__c='Did not like the deal');
        insert BidDecisionEvent ;
        NoBidDecisionEvent.subject = 'Call';
        update NoBidDecisionEvent;
        test.stopTest();
        }
        catch(exception e){
            system.debug('exception'+e.getMessage());
            /****************************************************
            Boolean expectedExceptionThrown =  e.getMessage().contains('You cannot create another event when it is already') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
            *****************************************************/
        }      
        
    }
    static testmethod void testBidDecisions(){
        try{
        test.startTest();
        PRF__c prf = new PRF__c(name='TestPRF',Original_Bid_Date__c=null,Final_Decision_Date__c=null);
        insert prf;  
        event noDecisionEvent = new event(DurationInMinutes=60,ActivityDateTime=system.now(),whatId=prf.id,Bid_Meeting_Decision__c='No Decision');
        insert noDecisionEvent ;           
        event BidDecisionEvent = new event(DurationInMinutes=60,ActivityDateTime=system.now(),whatId=prf.id,Bid_Meeting_Decision__c='Bid');
        insert BidDecisionEvent ;
        }
         catch(exception e){
            system.debug('exception'+e.getMessage());
         }
    }
    static testmethod void PrevEditing(){
        try{
        test.startTest();
        PRF__c prf = new PRF__c(name='TestPRF');
        insert prf;
        event BidDecisionEvent = new event(DurationInMinutes=60,ActivityDateTime=system.now(),whatId=prf.id,Bid_Meeting_Decision__c='No Bid',No_Bid_Comments__c='Did not like the deal');
        insert BidDecisionEvent ;
        BidDecisionEvent.subject = 'Call';
        update BidDecisionEvent ;
        test.stopTest();
        }
        catch(exception e){
            system.debug('exception'+e.getMessage());
           /***************************************
            Boolean expectedExceptionThrown =  e.getMessage().contains('You cannot edit this record') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
            ***************************************/
        }      
    }
    static testmethod void testUpdateBRF(){
        try{
        test.startTest();
        Benfit_Request_Form__c brf = new Benfit_Request_Form__c();
        insert brf;
        event ArcDecisionEvent = new event(DurationInMinutes=60,ActivityDateTime=system.now(),whatId=brf.id,Approval_Meeting_Decision__c='Approved',ARC_Meeting_Comments__c='Did not like the deal');
        insert ArcDecisionEvent ;
        test.stopTest();
        }
        catch(exception e){
            system.debug('exception'+e.getMessage());            
        } 
    }
}