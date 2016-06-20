//===================================================================================
//Date: 04/19/2016
//Developer: Sree Harsha Akkala
//Purpose: Test class for AIA_WPAController.
//=========================================================================================
// Update History
// Date         Developer               Description
//==================================================================================
//04/19/2016    Sree Harsha Akkala      Initial Development
//==================================================================================
@isTest
private class AIA_WPAController_Test{
    static testMethod void testSave(){
        Test.startTest();
        //Create PRF
        PRF__c prf = new PRF__c(name='TestPRF');
        insert prf;
        Test.setCurrentPageReference(new PageReference('Page.WorkPlanAssignmentPage')); 
        System.currentPageReference().getParameters().put('PRFid', prf.id);
        AIA_Workplan_Assignment__c wp = new AIA_Workplan_Assignment__c();
        ApexPages.StandardController con = new ApexPages.StandardController(wp);
        AIA_WPAController wpaCtrl = new AIA_WPAController(con);
        //wpaCtrl.wpa.Process_Request_Form__c = prf.id;
        wpaCtrl.save();
        Test.stopTest();
    }
}