/********************************************************************************
********************************************************************************    
 *  Class            : AIA_BRFTriggerHelper 
 *  Author           : Goutham Rapolu
 *  Version History  : 1.0
 *  Creation         : 05/31/16
 *  Description      : Notify PRF Team to Verify Zip Code-User Story --B02076
 *                     Send to Underwriting
 *
 ********************************************************************************
 ********************************************************************************/
public with sharing class AIA_BRFTriggerHelper {
    
//Variable Declaration 
public static List<Benfit_Request_Form__c> BRFList = new list<Benfit_Request_Form__c>();
public static Set<Id> oppID = new Set<ID>();
public static Set<Id> prfID = new Set<ID>(); 
public static Map<String,String> mapOppId = new map<String,String>(); 
public static Map<String,String> mapprfId = new map<String,String>();
public static Map<String,integer> mapCountForBRF = new map<String,integer>();
public static set<String> oppIdSet = new set<String>();
public static set<string> BRFIdSet = new set<string>();
public static set<string> BRFIdSetErrors = new set<string>();
public static final string STR_NEW = 'New';
public static list<Benfit_Request_Form__c> BRFListForEmail = new list<Benfit_Request_Form__c>();
public static set<Id> accIDs = new set<Id>();
public static final string CENSUS_INFORMATION = 'Census Information';
public static final string ERROR_MSG = 'Cannot send to Underwriting since the Account is new, No related  PRF and No Census Information Document attached to the BRF';

/**
* @Author: Goutham Rapolu
* @This Method is called from BRFTrigger during insertion or updation of BRF
* @This method - preparaing data and showing error if condition does not meet
*                querying and storing data for sending email for 1st BRF on Opportunity and PRF 
* @param -  list<Benfit_Request_Form__c> ,Map<id,Benfit_Request_Form__c>
* @Output -
*/

public static void accountNameUpdate(list<Benfit_Request_Form__c> newBRFList,Map<id,Benfit_Request_Form__c> oldBRFMap){
  for (Benfit_Request_Form__c  BRF: newBRFList) 
  {  
    if (BRF.State__c == 'VA' && BRF.State__c != null)
    {
      BRFList.add(BRF); 
    }
    system.debug('BRFList>>>>>>'+BRFList);
    
    if(BRF.Opportunity__c != null){
      oppID.add(BRF.Opportunity__c);
    }
    system.debug('oppID>>>>>>'+oppID);
    
    if(BRF.Proposal_Request_Form__c != null){
      prfID.add(BRF.Proposal_Request_Form__c);
    }
    system.debug('prfID>>>>>>'+prfID);
    
    if(BRF.Submit_to_Underwriting__c){
          BRFIdSet.add(BRF.Id);   
    }
    system.debug('BRFIdSet>>>>>>'+BRFIdSet);

    if(oppID != null && oppID.size()>0){
     for(Opportunity opp: [select id,account.id,Business_Type__c,(SELECT id FROM Benfit_Request_Forms__r),(select Id from Proposal_Request_Forms__r) from opportunity where id=: oppID limit 10000]){
        mapOppId.put(opp.id,opp.account.id);
        if(opp.Benfit_Request_Forms__r.size() == 0)
          mapCountForBRF.put(opp.id,opp.Benfit_Request_Forms__r.size());
        if(opp.Business_Type__c == STR_NEW && opp.Proposal_Request_Forms__r.size() == 0){
          oppIdSet.add(opp.Id);
        } 
     }
    }
    system.debug('mapOppId>>>>>>'+mapOppId);
    system.debug('mapCountForBRF>>>>>>'+mapCountForBRF);
    system.debug('oppIdSet>>>>>>'+oppIdSet);

    if(prfID != null && prfID.size()>0){
     for(PRF__c prf: [select id,Opportunity__r.id,Opportunity__c,(SELECT id FROM Benefit_Request_Forms__r) from PRF__c where id=: prfID limit 10000]){
        mapprfId.put(prf.id,prf.Opportunity__r.id);
        if(prf.Benefit_Request_Forms__r.size() == 1)
          mapCountForBRF.put(prf.id,prf.Benefit_Request_Forms__r.size());
     }
    }
    system.debug('mapprfId>>>>>>'+mapprfId);
    system.debug('mapCountForBRF>>>>>>mapprfId'+mapCountForBRF);

    if(mapprfId != null && mapprfId.containsKey(BRF.Proposal_Request_Form__c)){
      BRF.Opportunity__c = mapprfId.get(BRF.Proposal_Request_Form__c);
      system.debug(BRF.Proposal_Request_Form__c +'>>>>>>>>'+ mapOppId.get(BRF.Proposal_Request_Form__c));
    }
    
    system.debug('!!!!!!!!'+BRFIdSet);
    system.debug('********'+oppIdSet);
    if(BRFIdSet != NULL && BRFIdSet.size() >0 && oppIdSet != NULL && oppIdSet.size()>0){
      for(Benfit_Request_Form__c brfObj: [Select Id, Opportunity__c,Submit_to_Underwriting__c, (Select Id, Document_Type__c from File_Net_Documents__r where Document_Type__c =: CENSUS_INFORMATION) from Benfit_Request_Form__c where Id IN:BRFIdSet AND Opportunity__c IN:oppIdSet]){   
        system.debug('BRFIdSetErrors>>>>>>BRFIdSetErrors'+BRFIdSetErrors+'**********'+brfObj.File_Net_Documents__r.size());
        if(brfObj.File_Net_Documents__r.size() == 0){
            BRFIdSetErrors.add(brfObj.Id);
        }
          
      } 
    }
    system.debug('BRFIdSet>>>>>>'+BRFIdSet);
  if(BRFIdSetErrors != NULL && BRFIdSetErrors.size() >0){
    if(BRFIdSetErrors.contains(BRF.Id)){
            BRF.addError(ERROR_MSG);
    }
  }
  }
  
  if(mapCountForBRF != null && !mapCountForBRF.isEmpty()){
    
    for(Benfit_Request_Form__c BRF: BRFList){
        if(mapCountForBRF.containsKey(BRF.Opportunity__c)){
          BRFListForEmail.add(BRF);
          accIDs.add(BRF.Account__c);
        }else if(mapCountForBRF.containsKey(BRF.Proposal_Request_Form__c)){
          BRFListForEmail.add(BRF);
          accIDs.add(BRF.Account__c);
        }
    }
  }
  }

/**
* @Author: Goutham Rapolu
* @This Method is called from BRFTrigger
* @This method - This method is used to send the email 
* @param -  list<Benfit_Request_Form__c> ,Set<ID> 
* @Output -
*/

  public static void processEmail(list<Benfit_Request_Form__c> newBRFList,Set<ID> accountIDs){
   
  List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
  list<string> toAddresses = new list<string>();
  
  //Retrieving User name from custo label
  String uName = system.label.AIA_User_Detail_For_Sending_Email;
  //querying the account data based on accountIds
  Map<Id,Account> accmap = new Map<Id,Account>([select id,name,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry from account where id =: accountIDs]);
  // query the data from user object
  if(uName != null){
    User usr = [select id,lastname,Firstname,email,Username from user where Username =: uName and IsActive = true];
    if(usr != null){
       toAddresses.add(usr.email);
    }
  }
  
  // storing data for email
  for (Benfit_Request_Form__c  BRF: newBRFList){
    string addr = '';  
    account acc = accmap != null && accmap.containskey(BRF.Account__c)? accmap.get(BRF.Account__c):null;
    string accName = '';
    
    if(acc != null){
        if(acc.BillingStreet != null)
            addr = acc.BillingStreet+ '<br/>';
        if(acc.BillingCity != null)
            addr += acc.BillingCity+ '<br/>';
        if(acc.BillingState != null) 
            addr += acc.BillingState+ '<br/>';
        if(acc.BillingPostalCode != null)
            addr += acc.BillingPostalCode+ '<br/>';
        If(acc.BillingCountry != null)
            addr += acc.BillingCountry+ '<br/>';
        accName = acc.name;
    }

   list<string> emailbodytemplate = new list<string>{accName,addr,BRF.Account_Website__c,BRF.id};
   string msgBody =string.format(system.label.AiA_Email_Body_For_BRF,emailbodytemplate);

      // Create a new Email
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
    mail.setToAddresses(toAddresses);
    mail.setSenderDisplayName('Zip Code Verfication');
    mail.setHTMLbody(msgBody);
    mail.setSaveAsActivity(false);
      
      // Add your email to the master list
    mails.add(mail);  
  }
   // Send all emails in the master list
   Messaging.sendEmail(mails);
  
}

}