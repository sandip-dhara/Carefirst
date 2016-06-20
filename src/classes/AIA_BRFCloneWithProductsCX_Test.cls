//===================================================================================
//Date: 06/18/2016
//Developer: Goutham Rapolu
//Purpose: Test class for AIA_BRFCloneWithProductsCX
//==================================================================================
// Update History
// Date         Developer               Description
// 
//==================================================================================
//06/18/2016    Goutham Rapolu     Initial Development
//==================================================================================

@isTest
public with sharing class AIA_BRFCloneWithProductsCX_Test {

    static testMethod void testBRFCloneWithProductsCX() {
	
		User u = AIA_TestUtil.createTestUser();
	      System.runAs(u) {    
	      	
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
	         
	         // setup a reference to the page the controller is expecting with the parameters
        	PageReference pref = Page.AIA_BRFCloneWithProducts;
        	Test.setCurrentPage(pref);
        	
        	// Construct the standard controller
	        ApexPages.StandardController con = new ApexPages.StandardController(brf);
	
	        // create the controller
	        AIA_BRFCloneWithProductsCX ext = new AIA_BRFCloneWithProductsCX(con);
	
	        // Switch to test context
	        Test.startTest();
	
	        // call the cloneWithProducts method
	        PageReference ref = ext.cloneWithProducts();
	        // create the matching page reference
	        PageReference redir = new PageReference('/'+ext.newBRF.id+'/e?retURL=%2F'+ext.newBRF.id);
	
	        // make sure the user is sent to the correct url
	        System.assertEquals(ref.getUrl(),redir.getUrl());
	
	        // check that the new Benfit_Request_Form__c was created successfully
	        Benfit_Request_Form__c newBRF = [select id from Benfit_Request_Form__c where id = :ext.newBRF.id];
	        System.assertNotEquals(newBRF, null);
	        // check that the line item was created
	        List<Proposed_Products__c> newItems = [Select p.Id From Proposed_Products__c p where Benefit_Request_Form__c = :newBRF.id];
	        System.assertEquals(newItems.size(),1);
	
	        // Switch back to runtime context
	        Test.stopTest();
	         
	      }

    }

}