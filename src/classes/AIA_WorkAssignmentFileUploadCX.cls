/********************************************************************************
********************************************************************************    
 *  Class            : AIADocumentUploadController
 *  Author           : Goutham Rapolu
 *  Version History  : 1.0
 *  Creation         : 05/31/16
 *  Description      : This class will have the logic for upload a document from AIA_Workplan_Assignment__c detail page
 *
 ********************************************************************************
 ********************************************************************************/
public with sharing class AIA_WorkAssignmentFileUploadCX {

//Variable Declaration 
public id recordID{get;set;}
public String description {get;set;}
public String fileName {get;set;}
public Blob fileBody {get;set;}
public Boolean isAttachmentSaved {get;set;}
public AIA_Document__c fNetAttachment{get;set;}
public Attachment attObj;
public AIA_Workplan_Assignment__c work_Assignment_Obj{get;set;}
public AIA_Workplan_Assignment__c work_Assignment;


   //constructor initialization
   public AIA_WorkAssignmentFileUploadCX(ApexPages.StandardController controller) {
       recordID =  ApexPages.CurrentPage().getParameters().get('id');
       fNetAttachment = new AIA_Document__c();
       work_Assignment_Obj = new AIA_Workplan_Assignment__c();
   }

    // creates a new AIA_Document record 
    private Database.SaveResult saveCustomAttachment() {

        work_Assignment = new AIA_Workplan_Assignment__c();
        if(recordID != null){
            work_Assignment = [select id,name,Comments__c,Date_Completed__c,Status__c,Proposal_Request_Form__c,Proposal_Request_Form__r.Opportunity__c,Proposal_Request_Form__r.Opportunity__r.AccountID from AIA_Workplan_Assignment__c where id =: recordID limit 1];

        }
        AIA_Document__c fNetDoc = new AIA_Document__c();
        fNetDoc.Document_Name__c = this.fileName;
        if(work_Assignment != null){
            fNetDoc.Proposal_Request_Form__c = work_Assignment.Proposal_Request_Form__c;
            if(work_Assignment.Proposal_Request_Form__r.Opportunity__c != null || work_Assignment.Proposal_Request_Form__r.Opportunity__c !='')
            fNetDoc.Opportunity__c = work_Assignment.Proposal_Request_Form__r.Opportunity__c;
            if(work_Assignment.Proposal_Request_Form__r.Opportunity__r.AccountID != null || work_Assignment.Proposal_Request_Form__r.Opportunity__r.AccountID !='')
            fNetDoc.Account__c = work_Assignment.Proposal_Request_Form__r.Opportunity__r.AccountID ;
            fNetDoc.Source__c = 'Workplan Assignment';
            fNetDoc.Workplan_Assignment__c = work_Assignment.id;
        }
        
        fNetDoc.Document_Status__c = fNetAttachment.Document_Status__c;
        fNetDoc.Document_Type__c = fNetAttachment.Document_Type__c;
        fNetDoc.Active__c = fNetAttachment.Active__c;
        fNetDoc.Start_Date__c = fNetAttachment.Start_Date__c;
        fNetDoc.End_Date__c = fNetAttachment.End_Date__c;
        
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
    * Upload process is:
    *  1. Insert new AIA_Document__c record
    *  2. Insert new Attachment with the new AIA_Document__c record as parent
    *  3. Update the AIA_Document__c record with the ID of the new Attachment
    **/
    
    public PageReference processUpload() {
        try {
            Database.SaveResult customAttachmentResult = saveCustomAttachment();
        
            if (customAttachmentResult == null || !customAttachmentResult.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                  'Could not save attachment.'));
                return null;
            }
        
            Database.SaveResult attachmentResult = saveStandardAttachment(customAttachmentResult.getId());
        
            if (attachmentResult == null || !attachmentResult.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                  'Could not save attachment.'));            
                return null;
            } else {
                // update the AIA Document Object record with some attachment info
                fNetAttachment = new AIA_Document__c();
                fNetAttachment = [select id,account__r.name,Document_Name__c,Document_Type__c,Active__c,End_Date__c,Start_Date__c,Document_Format__c,
                                  Version__c,Attachment_ID__c,Document_Status__c from AIA_Document__c where id = :customAttachmentResult.getId() limit 1];
                String str = fNetAttachment.Document_Name__c;
                list<string> fileExtension = new list<string>();
                fileExtension = str.split('[.]');
                system.debug(fileExtension[0]+'OOOOOO'+fileExtension[1]);
                fNetAttachment.Document_Name__c = fNetAttachment.Document_Type__c+'_'+fileExtension[0];
                fNetAttachment.Attachment_ID__c = attachmentResult.getId();
                fNetAttachment.Document_Format__c = fileExtension[1];
                update fNetAttachment;
                
                work_Assignment.Status__c ='Completed';
                work_Assignment.Date_Completed__c = system.now();
                work_Assignment.Comments__c = work_Assignment_Obj.Comments__c;
                update work_Assignment;
                system.debug('Update fNetAttachment'+ fNetAttachment);
            }
        
        } catch (Exception e) {
            ApexPages.AddMessages(e);
            return null;
        }
        pageReference pg = new pageReference('/'+recordID);
        pg.setRedirect(true);
        return pg;
    }
    
    public pageReference cancelButton(){
        pageReference pg = new pageReference('/'+recordID);
        pg.setRedirect(true);
        return pg;
    }   

}