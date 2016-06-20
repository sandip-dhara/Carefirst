//===================================================================================
//Date: 06/18/2016
//Developer: Goutham Rapolu
//Purpose: Test class for AIADocumentUploadController
//==================================================================================
// Update History
// Date         Developer               Description
// 
//==================================================================================
//06/18/2016    Goutham Rapolu     Initial Development
//==================================================================================

@isTest
private class AIADocumentUploadController_Test {
   
    Public static testmethod void TestAccount() {
    	 List<AIA_Document__c> aiaDocList = new List<AIA_Document__c>();
	     User u = AIA_TestUtil.createTestUser();
	      System.runAs(u) {    
	      	 // creating AIA Document
	      	 AIA_Document__c aiaDoc = AIA_TestUtil.createAIADocument();
	      	 system.assertNotEquals(null,aiaDoc.id);
	         
	      	 aiaDocList.add(aiaDoc);
	      	 
			 // Create Account
	         Account a = AIA_TestUtil.CreateAccount('TestAccount'); 
	         system.assertNotEquals(null,a.id);
	         string cv = 'document';
		     Blob cvBlob = Blob.toPdf('document');
		     
	         Apexpages.Currentpage().getParameters().put('id',a.id);
	         ApexPages.StandardSetController testController = new ApexPages.StandardSetController(aiaDocList);
	         AIADocumentUploadController controllerObj = new AIADocumentUploadController(testController);
	         controllerObj.fileBody = cvBlob;
	         controllerObj.fileName = 'TestDoc.pdf';
	         controllerObj.description = 'test Document';
	         controllerObj.processUpload();
	         controllerObj.cancelButton();  
	      }      
    }
    
    Public static testmethod void TestOpportunity() {
    	 List<AIA_Document__c> aiaDocList = new List<AIA_Document__c>();
    	 User u = AIA_TestUtil.createTestUser();
    	 System.runAs(u) { 
    	 	 // creating AIA Document
	      	 AIA_Document__c aiaDoc = AIA_TestUtil.createAIADocument();
	      	 system.assertNotEquals(null,aiaDoc.id);
	      	 aiaDocList.add(aiaDoc); 
	      	 
			 // Create Account
	         Account a = AIA_TestUtil.CreateAccount('TestAccount');
	         system.assertNotEquals(null,a.id);
	         // Create Opportunity
	         Opportunity o = AIA_TestUtil.AIA_createopportunity(a.Id);
	         system.assertNotEquals(null,o.id);
	         Apexpages.Currentpage().getParameters().put('id',o.id);
	         ApexPages.StandardSetController testController = new ApexPages.StandardSetController(aiaDocList);
	         AIADocumentUploadController controllerObj = new AIADocumentUploadController(testController);
	         controllerObj.processUpload();
	         controllerObj.cancelButton();
    	 }
    }
    
    Public static testmethod void TestBenfitRequestForm() {
    	 List<AIA_Document__c> aiaDocList = new List<AIA_Document__c>();
	     User u = AIA_TestUtil.createTestUser();
	     System.runAs(u) {  
	     	// creating AIA Document
	      	 AIA_Document__c aiaDoc = AIA_TestUtil.createAIADocument();
	      	 system.assertNotEquals(null,aiaDoc.id);
	      	 aiaDocList.add(aiaDoc);
	      	 
			 // Create Account
	         Account a = AIA_TestUtil.CreateAccount('TestAccount');
	         system.assertNotEquals(null,a.id);
	         
	         // Create Opportunity
	         Opportunity o = AIA_TestUtil.AIA_createopportunity(a.Id);
	         system.assertNotEquals(null,o.id);
	         
	         // Create PRF
	         PRF__c p = AIA_TestUtil.CreatePRF(o.Id);
	         system.assertNotEquals(null,p.id);
	         Benfit_Request_Form__c brf = AIA_TestUtil.CreateBRF(p.id,a.id);
	         system.assertNotEquals(null,brf.id);
	         Apexpages.Currentpage().getParameters().put('id',brf.id);
	         ApexPages.StandardSetController testController = new ApexPages.StandardSetController(aiaDocList);
	         AIADocumentUploadController controllerObj = new AIADocumentUploadController(testController);
	         controllerObj.processUpload();
	         controllerObj.cancelButton();
	     }
    }
    
   Public static testmethod void TestPRF(){
   	     List<AIA_Document__c> aiaDocList = new List<AIA_Document__c>();
	     User u = AIA_TestUtil.createTestUser();
	     System.runAs(u) { 
	     	// creating AIA Document
	      	 AIA_Document__c aiaDoc = AIA_TestUtil.createAIADocument();
	      	 system.assertNotEquals(null,aiaDoc.id);
	      	 aiaDocList.add(aiaDoc);
	      	  
			 // Create Account
	         Account a = AIA_TestUtil.CreateAccount('TestAccount');
	         system.assertNotEquals(null,a.id);
	         // Create Opportunity
	         Opportunity o = AIA_TestUtil.AIA_createopportunity(a.Id);
	         system.assertNotEquals(null,o.id);
	         // Create PRF
	         PRF__c p = AIA_TestUtil.CreatePRF(o.Id);
	         system.assertNotEquals(null,p.id);
	         Apexpages.Currentpage().getParameters().put('id',p.id);
	         ApexPages.StandardSetController testController = new ApexPages.StandardSetController(aiaDocList);
	         AIADocumentUploadController controllerObj = new AIADocumentUploadController(testController);
	         controllerObj.processUpload();
	         controllerObj.cancelButton();
	     }
    }
    
    Public static testmethod void TestAIAImplementation() {
    	 List<AIA_Document__c> aiaDocList = new List<AIA_Document__c>();
	     User u = AIA_TestUtil.createTestUser();
	      System.runAs(u) {    
	      	 // creating AIA Document
	      	 AIA_Document__c aiaDoc = AIA_TestUtil.createAIADocument();
	      	 system.assertNotEquals(null,aiaDoc.id);
	      	 aiaDocList.add(aiaDoc);
	      	 
			 // Create Account
	         Account a = AIA_TestUtil.CreateAccount('TestAccount'); 
	         system.assertNotEquals(null,a.id);
	         Opportunity o = AIA_TestUtil.AIA_createopportunity(a.Id);
	         system.assertNotEquals(null,o.id);
	         AIA_Implementation__c aiaImp = AIA_TestUtil.CreateImp(o.id);
	         system.assertNotEquals(null,aiaImp.id);
	         Apexpages.Currentpage().getParameters().put('id',aiaImp.id);
	         ApexPages.StandardSetController testController = new ApexPages.StandardSetController(aiaDocList);
	         AIADocumentUploadController controllerObj = new AIADocumentUploadController(testController);
	         controllerObj.processUpload();
	         controllerObj.cancelButton();  
	      }      
    }
    
    Public static testmethod void TestProposedProducts() {
    	 List<AIA_Document__c> aiaDocList = new List<AIA_Document__c>();
	     User u = AIA_TestUtil.createTestUser();
	      System.runAs(u) {    
	      	 // creating AIA Document
	      	 AIA_Document__c aiaDoc = AIA_TestUtil.createAIADocument();
	      	 system.assertNotEquals(null,aiaDoc.id);
	      	 aiaDocList.add(aiaDoc);
	      	 
			 // Create Account
	         Account a = AIA_TestUtil.CreateAccount('TestAccount');
	         system.assertNotEquals(null,a.id);
	         // Create Opportunity
	         Opportunity o = AIA_TestUtil.AIA_createopportunity(a.Id);
	         system.assertNotEquals(null,o.id);
	         // Create PRF
	         PRF__c p = AIA_TestUtil.CreatePRF(o.Id);
	         system.assertNotEquals(null,p.id);
	         Benfit_Request_Form__c brf = AIA_TestUtil.CreateBRF(p.id,a.id);
	         system.assertNotEquals(null,brf.id);
	         Proposed_Products__c aiaImp = AIA_TestUtil.createProposedProducts(brf.id);
	         system.assertNotEquals(null,aiaImp.id);
	         Apexpages.Currentpage().getParameters().put('id',aiaImp.id);
	         ApexPages.StandardSetController testController = new ApexPages.StandardSetController(aiaDocList);
	         AIADocumentUploadController controllerObj = new AIADocumentUploadController(testController);
	         controllerObj.processUpload();
	         controllerObj.cancelButton();  
	      }      
    }
    
    Public static testmethod void TestAIABenefitDesign() {
    	 List<AIA_Document__c> aiaDocList = new List<AIA_Document__c>();
	     User u = AIA_TestUtil.createTestUser();
	      System.runAs(u) {    
	      	 // creating AIA Document
	      	 AIA_Document__c aiaDoc = AIA_TestUtil.createAIADocument();
	      	 system.assertNotEquals(null,aiaDoc.id);
	      	 aiaDocList.add(aiaDoc);
	      	 
			 // Create Account
	         Account a = AIA_TestUtil.CreateAccount('TestAccount');
	         system.assertNotEquals(null,a.id);
	         // Create Opportunity
	         Opportunity o = AIA_TestUtil.AIA_createopportunity(a.Id);
	         system.assertNotEquals(null,o.id);
	         // Create PRF
	         
	         AIA_Benefit_Design__c aiaBD = AIA_TestUtil.createBenefitDesign(o.id);
	         system.assertNotEquals(null,aiaBD.id);
	         Apexpages.Currentpage().getParameters().put('id',aiaBD.id);
	         ApexPages.StandardSetController testController = new ApexPages.StandardSetController(aiaDocList);
	         AIADocumentUploadController controllerObj = new AIADocumentUploadController(testController);
	         controllerObj.processUpload();
	         controllerObj.cancelButton();  
	      }      
    }
}