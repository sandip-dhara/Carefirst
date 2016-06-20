/****************************************************************************************************
 * 04/08/2015 - Tom Barrett (TPB
 * Created a new QueryBase because new functionality was needed that did not exist in the 
 * API 20.0 version that the QueryBase was orginally credit from.
 * This was safer than changing the API in QueryBase and having to test every piece of logic in 
 * the QueryBase class
 *---------------------------------------------------------------------------------------------------
 *                      ----===[ HISTORY ]===---
 * Date        Developer        Description
 * 05/31/16    Goutham Rapolu   getCreatableFieldsSOQL Method  Returns a dynamic SOQL statement 
 *                               for the whole object, includes only creatable fields since we will 
 *                              be inserting a cloned result of this query
 *---------------------------------------------------------------------------------------------------
 *  
 ****************************************************************************************************
*/

public without sharing class QueryBase2 {
    
/* SOQL queries */


/*
* @purpose : The static method used to post to a Chatter Group.
*            The 'FeedTitleInBody' parameter is used to precede the message with the title.
*            The idea is to allow for a user to see what the message is specifically about 
*            in a quick view-able way.
* @param   : Chatter Group, Title for Post, Post Message and Feed Title In Post Message
* @return  : none
*/     
    public static void PostToChatterGroup(String GroupName, String FeedTitle, String FeedBody, Boolean FeedTitleInBody) { 
        try { 
            if ( FeedTitleInBody ) {
                FeedBody =+ FeedTitle.toUpperCase() + ': ' + FeedBody;
            } 
        
            // Get the id of the group to post to and then
            // save the message to that group
            Id ParentId = [ SELECT Id 
                            FROM CollaborationGroup
                            WHERE Name = :GroupName LIMIT 1 ].Id;                                        

            FeedItem fi = new FeedItem();        
            fi.ParentId = ParentId;
            fi.Title = FeedTitle;            
            fi.Body = FeedBody;
            insert fi;          
        } catch ( System.Exception e ) {
            System.debug(LoggingLevel.ERROR, 'Exception in QueryBase2.PostToChatterGroup: Error at line ' + e.getLineNumber() + ' - ' + e.getMessage());    
        }         
    }  
    
/*
* @purpose : The static method used to retrieve the email address stored on the
             object 'DynamicCodeDataStore' from a specific record. 
             This is better than hard-coding email addresses because the email address 
             can be changed without touching code.
* @param   : Name of the process which you want to retrieve the email for
* @return  : String which holds the email address stored on the Custom Setting record
*/        
    public static String getDynamicCodeDataStore(String ProcessName) {
        System.debug('ProcessName: ' + ProcessName);
        String EmailAddress = ''; 
        DynamicCodeDataStore__c cs = DynamicCodeDataStore__c.getInstance(ProcessName);
        if ( cs != null ) {
            EmailAddress = cs.Email__c;
        }    
        return emailAddress;    
    }

/*
* @purpose : The static method used to retrieve the creatable fields stored on the
*            object.          
* @param   : Object name and where clause coniditons
* @return  : Returns all creatable field as per params
*/   

public static string getCreatableFieldsSOQL(String objectName, String whereClause){
     
    String selects = '';
    if (whereClause == null || whereClause == ''){ return null; }
     
    // Get a map of field name and field token
    Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
    list<string> selectFields = new list<string>();
    if (fMap != null){
        for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
            Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
            if (fd.isCreateable()){ // field is creatable
                selectFields.add(fd.getName());
            }
        }
    }
     
    if (!selectFields.isEmpty()){
        for (string s:selectFields){
            selects += s + ',';
        }
        if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
         
    }
     
    return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;    
} 
}