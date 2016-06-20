/*=========================================================================================
 * Date     : 10/21/2014
 * Developer    : Ken Gill
 * Purpose      : This class is the extension point of the Trigger Framework for adding Account trigger handlers.
 *                
 *               
 *
 *=========================================================================================
 *                                 Update History
 *                                 ---------------
 * Date       Developer         Description
 *===========+============+================================================================
 * 11/17/14  |  KG    | Initial Version                                         
 *           |        | 
 *===========+============+================================================================
 */


public with sharing class AccountTriggerHandler extends TriggerHandler {

    public AccountTriggerHandler() {}
    
        /* context override */
    protected override void beforeUpdate() {
        RenewalDateUpdate((List<Account>) Trigger.new);
    }
    
    protected override void beforeInsert() {
        RenewalDateUpdate((List<Account>) Trigger.new);
    }
    
    protected override void afterInsert() {
    
    }
    
    protected override void afterUpdate() {
        processAfterEGPAccountUpdate();
    }

private void processAfterEGPAccountUpdate() {
        if(System.isBatch() || System.isFuture()) {
        System.debug('AccountTriggerHandler: Bypassing EGP Account update processing when called from a batch job');
        return;
    }   
    
      // Note on casting below:
      // Outside a trigger, the trigger collections Trigger.new,.old have to be explicitly cast to the SOBject type
      // When working inside a trigger, this casting happens implicitly
      EGPService.processAccountUpdateChanges(( List<Account>) Trigger.new, (Map<Id,Account>) Trigger.oldMap);
}

private  void  RenewalDateUpdate(list<account> accountList){
    for(account acc:accountList){   
        // If renewal date is less then the first day of the current month
        if(acc.Renewal_Date__c < system.today().toStartOfMonth()){            
            // Set the final renewal date to the current renewal date + 1 year
            acc.Final_Renewal_Date__c =acc.Renewal_Date__c.addYears(1);
        }
        else{
            // Set the final renewal date to the current date
            acc.Final_Renewal_Date__c =acc.Renewal_Date__c;
        }

    }
}

}