/********************************************************************************
********************************************************************************    
 *  Class            : AIADocumentUploadController
 *  Author           : Goutham Rapolu
 *  Version History  : 1.0
 *  Creation         : 05/31/16
 *  Description      : This class will have the logic for upload a document from Account, Opportunity 
 *                     PRF, BRF, Implementation, Workplan Assignment.
 *
 ********************************************************************************
 ********************************************************************************/


public with sharing class AIADocumentUploadController {

//Variable Declaration 
public id recordID{get;set;} // Record Id of object where document upload was initiated
String myIdPrefix; // for Getting prefix from record ID
public String description {get;set;} // Using In VF page for adding description for file
public String fileName {get;set;}
public Blob fileBody {get;set;}
public Boolean isAttachmentSaved {get;set;}
public AIA_Document__c fNetAttachment{get;set;}
public Attachment attObj;


   //constructor initialization
   public AIADocumentUploadController(ApexPages.StandardSetController controller) {
       
       recordID =  ApexPages.CurrentPage().getParameters().get('id');
       //Get prefix from record ID
       myIdPrefix = String.valueOf(recordID).substring(0,3);
       // Set Attachment Flag to not saved
       isAttachmentSaved = false;
       // Initialize new AIA Document
       fNetAttachment = new AIA_Document__c();
   }

    /**
    * @Author: Goutham Rapolu
    * @This method - getting the object details using Schema based on recordID
    * @param - String recordID
    * @Output - Returns object name
    */
   public String findObjectNameFromRecordIdPrefix(String recordID){
        String objectName = '';
        try{    
            //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
             
            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                System.debug('Prefix is ' + prefix);
                 
                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                    System.debug('Object Name! ' + objectName);
                    break;
                }
             }
        }catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }   
    
    /**
    * @Author: Goutham Rapolu
    * @This method - creates a new FileNetDocument record
    * @param - String recordID
    * @Output - Returns object name
    */ 
    private Database.SaveResult saveCustomAttachment() {
        
        //SObject sObj;
        Proposed_Products__c objPP;
        PRF__c objPRF;
        Opportunity objOpp;
        Account objAcc;
        Benfit_Request_Form__c objBRF;
        AIA_Benefit_Design__c objBD;
        AIA_Implementation__c objImp;
        
        String getObjName ='';
        list<AIA_Document__c> FNDlist = new list<AIA_Document__c>();
        getObjName= findObjectNameFromRecordIdPrefix(myIdPrefix);

        // Based on the object name, query the data from object and checking if how many AIA_Document__c are there.
        if(getObjName != null && getObjName == 'PRF__c'){
            if(recordID != null)
            objPRF = [select Id,Opportunity__c,Opportunity__r.accountID FROM PRF__c where id =: recordID  and Opportunity__c != null limit 1];
            FNDlist = [select id from AIA_Document__c where Proposal_Request_Form__c =: recordID];
        }else if(getObjName != null && getObjName == 'Opportunity'){
            if(recordID != null)
            objOpp = [select AccountId,Id FROM Opportunity where id =: recordID limit 1];
            FNDlist = [select id from AIA_Document__c where Opportunity__c =: recordID];
        }else if(getObjName != null && getObjName == 'Account'){
            if(recordID != null)
            objAcc = [select Id FROM Account where id =: recordID limit 1];
            FNDlist = [select id from AIA_Document__c where Account__c =: recordID];
        }else if(getObjName != null && getObjName == 'Benfit_Request_Form__c'){
            if(recordID != null)
            objBRF = [select Id,Opportunity__c,Account__c FROM Benfit_Request_Form__c where id =: recordID limit 1];
            system.debug('objBRF'+objBRF);
            FNDlist = [select id from AIA_Document__c where Benefit_Request_Form__c =: recordID];
        
        }else if(getObjName != null && getObjName == 'Proposed_Products__c'){
            if(recordID != null)
            objPP = [select Id, Opportunity__c,Benefit_Request_Form__c, Account__c  FROM Proposed_Products__c where id =: recordID  ];
            system.debug('objPP'+objPP);
            FNDlist = [select id from AIA_Document__c where Proposed_Products__c =: recordID];  
        }else if(getObjName != null && getObjName == 'AIA_Benefit_Design__c'){
            if(recordID != null)
            objBD = [select Id, Account_Name__c FROM AIA_Benefit_Design__c where id =: recordID  ];
            system.debug('objBD'+ objBD);
            FNDlist = [select id from AIA_Document__c where Benefit_Design__c =: recordID];
        }else if(getObjName != null && getObjName == 'AIA_Implementation__c'){
            if(recordID != null)
            objImp = [select Id, Account__c, Opportunity__c FROM AIA_Implementation__c where id =: recordID];
            system.debug('objImp'+ objImp);
            FNDlist = [select id from AIA_Document__c where Implementation__c =: recordID];
        }
        
        // Associate with the parent objects
        //Cannot use getObjName name in source as it will return API name.
        AIA_Document__c fNetDoc = new AIA_Document__c();
        fNetDoc.Document_Name__c = this.fileName;
        if(getObjName != null && getObjName == 'PRF__c'){
            fNetDoc.Proposal_Request_Form__c = objPRF.id;
            fNetDoc.Opportunity__c = objPRF.Opportunity__c;
            fNetDoc.Account__c = objPRF.Opportunity__r.accountID;
            fNetDoc.Source__c = 'PRF';
        }else if(getObjName != null && getObjName =='Opportunity'){
            fNetDoc.Opportunity__c = objOpp.id;
            fNetDoc.Account__c = objOpp.AccountId;
            fNetDoc.Source__c = 'Opportunity';
        }else if(getObjName != null && getObjName =='Account'){
            fNetDoc.Account__c = objAcc.Id;
            fNetDoc.Source__c = 'Account';
        }else if(getObjName != null && getObjName =='Benfit_Request_Form__c'){
            fNetDoc.Benefit_Request_Form__c = objBRF.id;
            system.debug('fNetDoc.Benefit_Request_Form__c'+fNetDoc.Benefit_Request_Form__c+'>>>>>>>>>>>>'+objBRF.id);
            system.debug('getObjName'+getObjName);
            fNetDoc.Opportunity__c = objBRF.Opportunity__c;
            fNetDoc.Account__c = objBRF.Account__c;
            fNetDoc.Source__c = 'Benefit Request Form';  
        }else if(getObjName != null && getObjName =='Proposed_Products__c'){
            fNetDoc.Proposed_Products__c = objPP.id;
            system.debug('fNetDoc.Proposed_Products__c'+fNetDoc.Proposed_Products__c+'>>>>>>>>>>>>'+objPP.id);
            system.debug('getObjName'+getObjName);
            fNetDoc.Benefit_Request_Form__c = objPP.Benefit_Request_Form__c;
            fNetDoc.Opportunity__c = objPP.Opportunity__c;
            fNetDoc.Account__c = objPP.Account__c;
            fNetDoc.Source__c = 'Proposed Products';
        }else if(getObjName != null && getObjName =='AIA_Benefit_Design__c'){
            fNetDoc.Benefit_Design__c = objBD.id; 
            system.debug('fNetDoc.Benefit_Design__c'+fNetDoc.Benefit_Design__c +'>>>>>>>>>>>>'+ objBD.id);
            system.debug('getObjName'+getObjName);
            fNetDoc.Account__c = objBD.Account_Name__c;
            fNetDoc.Source__c = 'Benefit Design';
        }else if(getObjName != null && getObjName =='AIA_Implementation__c'){
            fNetDoc.Implementation__c = objImp.id; 
            system.debug('fNetDoc.Implementation__c'+fNetDoc.Implementation__c +'>>>>>>>>>>>>'+ objImp.id);
            system.debug('getObjName'+getObjName);
            fNetDoc.Account__c = objImp.Account__c;
            fNetDoc.Opportunity__c = objImp.Opportunity__c;
            fNetDoc.Source__c = 'Implementation';
        }
        
        if(FNDlist!= null && FNDlist.size()>0){
            fNetDoc.Version__c = FNDlist.size()+1;
        }else{
            fNetDoc.Version__c =1;
        }
        
        fNetDoc.Document_Status__c = fNetAttachment.Document_Status__c;
        fNetDoc.Document_Type__c = fNetAttachment.Document_Type__c;
        fNetDoc.Active__c = fNetAttachment.Active__c;
        fNetDoc.Start_Date__c = fNetAttachment.Start_Date__c;
        fNetDoc.End_Date__c = fNetAttachment.End_Date__c;
        fNetDoc.Approval_Status__c =fNetAttachment.Approval_Status__c;
        
        system.debug('fNetDoc'+ fNetDoc);
        // fill out cust obj fields
        return Database.insert(fNetDoc,true);
    }
    
    // create an actual Attachment record
    private Database.SaveResult saveStandardAttachment(Id parentId) {
        Database.SaveResult result;
     
        Attachment attachment = new Attachment();
        attachment.body = this.fileBody;
        attachment.name = this.fileName;
        attachment.description = description;
        attachment.parentId = parentId;
        
        // insert the attahcment
        result = Database.insert(attachment,true);
        // reset the file for the view state
        fileBody = Blob.valueOf(' ');
        isAttachmentSaved = true;
        return result;
    }
    
    /**
    * Called when the user clicks the attach button on the visualforce.    
    * Clicking the attach button does the following:
    *  1. Insert new AIA_Document__c record
    *  2. Insert new Attachment with the new AIA_Document__c record as parent
    *  3. Update the AIA_Document__c record with the ID of the new Attachment
    **/
    
    // Attach Button
    public PageReference processUpload() {
        Database.SaveResult attachmentResult; // insert the attahcment
        Database.SaveResult customAttachmentResult; // insert AIA_Document__c record
        
        try {
             customAttachmentResult = saveCustomAttachment();
        
            if (customAttachmentResult == null || !customAttachmentResult.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                  'Could not save attachment.'));
                system.debug('Test 1');
                return null;
            }
        
            attachmentResult = saveStandardAttachment(customAttachmentResult.getId());
            
            if (attachmentResult == null || !attachmentResult.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                  'Could not save attachment.'));
                system.debug('Test 2');           
                return null;
            } else {
                system.debug('Test 3');
                // update the FilenetDocument Object record with some attachment info
                fNetAttachment = new AIA_Document__c();
                fNetAttachment = [select id,account__r.Account_Legal_Name__c,Document_Name__c,Document_Type__c,Active__c,End_Date__c,Start_Date__c,Document_Format__c,
                                  Version__c,Attachment_ID__c,Approval_Status__c,Document_Status__c,Benefit_Request_Form__c,Opportunity__c,Account__c,Source__c from AIA_Document__c where id = :customAttachmentResult.getId() limit 1];
                system.debug(fNetAttachment+'fNetAttachment');
                String str = fNetAttachment.Document_Name__c;
                list<string> fileExtension = new list<string>();
                fileExtension = str.split('[.]');
                system.debug(fileExtension[0]+'OOOOOO'+fileExtension[1]);
                fNetAttachment.Document_Name__c = fNetAttachment.account__r.Account_Legal_Name__c+'_'+fNetAttachment.Document_Type__c+'_'+fileExtension[0]+'_'+fNetAttachment.Version__c;
                fNetAttachment.Attachment_ID__c = attachmentResult.getId();
                fNetAttachment.Document_Format__c = fileExtension[1];
                update fNetAttachment;
                system.debug('Update fNetAttachment'+ fNetAttachment);
            }
        
        } catch (Exception e) {
            ApexPages.AddMessages(e);
            system.debug('Test 4');
            fNetAttachment = new AIA_Document__c();
            if(customAttachmentResult.getId() != null){
                fNetAttachment = [select id,account__r.Account_Legal_Name__c,Document_Name__c,Document_Type__c,Active__c,End_Date__c,Start_Date__c,Document_Format__c,
                                      Version__c,Attachment_ID__c,Approval_Status__c,Document_Status__c,Benefit_Request_Form__c,Opportunity__c,Account__c,Source__c from AIA_Document__c where id = :customAttachmentResult.getId() limit 1];
                system.debug(fNetAttachment+'fNetAttachment');
            }
            if(fNetAttachment != null)
            delete fNetAttachment;
            return null;
        }
        pageReference pg = new pageReference('/'+recordID);
        pg.setRedirect(true);
        return pg;
    }
    
    // Cancel Button
    public pageReference cancelButton(){
        pageReference pg = new pageReference('/'+recordID);
        pg.setRedirect(true);
        return pg;
    }
        
}