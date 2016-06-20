/*------------------------------------------------------------------------------------
 *                      ----===[ HISTORY ]===---
 * Date        Developer        Description
 *------------------------------------------------------------------------------------
 * 06/06/2016 Sree Harsha Akkala    This class is the controller for AIA_OpenEnrollmentMeetings Page
 *                                  It is used to get and display a list of open enrollment meetings
 * 
  *************************************************************************************
 */

/**
* @Author: Sree Harsha Akkala 
* @Purpose: This controller fetches Open Enrollment Meetings records based on the meeting status filters(Open/Full/Completed)
*/
public class AIA_OpenEnrollmentMeetingController {
public boolean isOpen{get;set;} // Checkbox to get enrollments with a status of open
public boolean isFull{get;set;} // Checkbox to get enrollments that have reached maxed
public boolean isCompleted{get;set;}
public list<event> eventList{get;set;} // List of open enrollment environments
// TODO: Check if we can use the developer name, there is a method in the queryBase class (the method is queryBase.getRecordTypeId(ObjectName, DeveloperName))
public Id oemRtypeId= Schema.SObjectType.event.RecordTypeInfosByName.get('AIA Open Enrollment Meeting').RecordTypeId; // Record Id for the Open Meeting Enrollment event

/**
* @This constructor is used to initialize the filter variables and to invoke the fetchOpenEnrollmentMettings method upon page load
*/
public AIA_OpenEnrollmentMeetingController (){
    isOpen=true;
    isFull=false;
    isCompleted=false;
    eventList = new list<event>();    
    fetchOpenEnrollmentMettings();
}

/**
* @This Method is called from constructor(page load) & from the actionfunction(on applying the filters) of AIA_OpenEnrollmentMeetings page
* @This method - Queries the Open Enrollment Meetings records based on the meeting status filters(Open/Full/Completed)  
* @param - None  
* @Output - Assigning  Open Enrollment Meetings records to eventList 
*/
  
public void fetchOpenEnrollmentMettings(){
    string meetingStatusfilter;
    string Open= 'Open'; // use static variables
    string Full= 'Full'; // use static variable or constant
    string Completed= 'Completed';
    
    //START-- Constructing the filter condition based on the fiters(Open/Full/Completed) selected on VF page.
    // TODO: Please let me know why we aren't using the existing meeting status field and created another field
    // TODO: This is a different record type, so we should the same meeting status field
    // This logic should be replace with the one below
    if(isOpen && isFull && isCompleted)
        meetingStatusfilter = ' ( Meeting_Status1__c=:Open OR Meeting_Status1__c=:Full OR Meeting_Status1__c=:Completed)';
    else if(isOpen && isFull){
        system.debug('@@1'+meetingStatusfilter );
        meetingStatusfilter = '( Meeting_Status1__c=:Open OR Meeting_Status1__c=:Full)';
        system.debug('@@2'+meetingStatusfilter );
    }
    else if(isFull && isCompleted)
        meetingStatusfilter = '( Meeting_Status1__c=:Full OR Meeting_Status1__c=:Completed)'; 
    else if(isFull)
        meetingStatusfilter = ' Meeting_Status1__c=:Full';
    else if(isCompleted)
        meetingStatusfilter = ' Meeting_Status1__c=:Completed';
    else
        meetingStatusfilter = ' Meeting_Status1__c=:Open';
    //END-- Constructing the filter condition based on the fiters(Open/Full/Completed) selected on VF page.
    
    // Construct filter - New logic
    /*
    Boolean firstInstance = false;
    if (isOpen)
        meetingStatusFilter = '  ( Meeting_Status1__c=:Open)';
        firstInstance = true;
    if (isFull)
        if (firstInstance)
            meetingStatusFilter =' ( Meeting_Status1__c=:Full)';
        else
            meetingStatusFilter =' OR ( Meeting_Status1__c=:Full)';
    */
    
    //Dynamic query to fetch the Open Enrollment Meeting records
    string query = 'select id,subject,ActivityDate ,Name_Of_Account__c,Capacity__c,Signed_Up__c,Meeting_Status1__c,recordtype.id from event where  recordtype.id=:oemRtypeId and '+meetingStatusfilter;
    //Assigning the queried event records(Open Enrollment Meeting records) to eventList
    // TODO: Add error handling - No try catch block
    eventList= database.query(query);
}
}