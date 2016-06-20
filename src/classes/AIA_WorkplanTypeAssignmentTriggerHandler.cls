/*=========================================================================================
 * Date     : 04/27/2016
 * Developer    : Laveen Kattela(LK)
 * Purpose      : This class is the extension point of the Trigger Framework for adding WorkplanTypeTask trigger handlers.
 *                
 *               
 *
 *=========================================================================================
 *                                 Update History
 *                                 ---------------
 * Date       Developer         Description
 *===========+============+================================================================
 * 04/27/16  |  LK    | Initial Version                                         
 *           |        | 
 *===========+============+================================================================
 */
public with sharing class AIA_WorkplanTypeAssignmentTriggerHandler extends TriggerHandler {

list<AIA_Workplan_Type_Task__c > listOfWorkplanTypeTask = new list<AIA_Workplan_Type_Task__c>();
set<string> queueNames = new set<String>();

public AIA_WorkplanTypeAssignmentTriggerHandler () {}

// This method fires when the user tries to update the existing record of Queue Name to auto-populate the Queue Id
protected override void beforeUpdate() {  
    Map<id,AIA_Workplan_Type_Task__c> oldMap = (map<id,AIA_Workplan_Type_Task__c>)trigger.oldMap; 
    for(AIA_Workplan_Type_Task__c  WTT : (list<AIA_Workplan_Type_Task__c>) Trigger.new){
        if(WTT.Queue_Name__c!=null){
            if( WTT.Queue_Name__c !=oldMap.get(WTT.id).Queue_Name__c){ 
                queueNames.add(WTT.Queue_Name__c);               
                listOfWorkplanTypeTask.add(WTT);
            }
        }else {
            WTT.Queue_Id__c = Null;
        }
     }
     QueueIdupdate(listOfWorkplanTypeTask,queueNames);   
}

//This method fires when the user insert new record to auto-populate Queue id based on Queue name. 
protected override void beforeInsert() {
    for(AIA_Workplan_Type_Task__c  WTT : (list<AIA_Workplan_Type_Task__c>) Trigger.new){
        if(WTT.Queue_Name__c!=null){           
            queueNames.add(WTT.Queue_Name__c);
            listOfWorkplanTypeTask.add(WTT);            
        }
        else {
            WTT.Queue_Id__c = Null;
        }
     }
     QueueIdupdate(listOfWorkplanTypeTask,queueNames);
}

protected override void afterInsert() {
}

protected override void afterUpdate() {
}

//Updating the record with Queue id with respect to queue name.
 public static void QueueIdupdate(list<AIA_Workplan_Type_Task__c > listOfWorkplanTypeTask,set<string> queueNames){    
    if(queueNames!=null && queueNames.size()>0){
        list<Group> groupList = [SELECT Id,Name,Type,DeveloperName  FROM Group where Type ='Queue' and Name IN :queueNames];
        Map<String,id> MapQueueNamesandId =  new Map<String,id>();
        for(Group gp : groupList){
            //Associates the specified value with the specified key in the map
            MapQueueNamesandId.put(gp.Name,gp.id); 
        }
        for(AIA_Workplan_Type_Task__c  WTT : listOfWorkplanTypeTask){
        if(WTT.Queue_Name__c!=Null)
        {
        
            if(MapQueueNamesandId.ContainsKey(WTT.Queue_Name__c)){
                ID QueueId = MapQueueNamesandId.get(WTT.Queue_Name__c);
                WTT.Queue_Id__c = QueueId ;
            }
            else {
                WTT.addError('Selected Queue Name Does not exist');
            }
        }
        
        }
        
    }
    
 
 }


}