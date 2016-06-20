@isTest
private class AIADocumentUploadController_Test {
    
    static testMethod void Test1() {
        AIA_Document__c aiaDoc = new AIA_Document__c();
            aiaDoc.Document_Status__c = 'Complete';
            aiaDoc.Document_Type__c = 'Additional Documentation';
            aiaDoc.Active__c = True;
            aiaDoc.Start_Date__c = System.today();
            aiaDoc.End_Date__c = System.today()+10;
            aiaDoc.Approval_Status__c = 'Pending';
        insert aiaDoc;
        
        //Create account
        Account acc = new Account();
            acc.Name = 'SomeTest' + Date.Today();
            acc.Type = 'Customer';
        insert acc;
        
        //Create Opportunity
        Opportunity opp = new Opportunity();
            opp.Name = 'OppTest' + Date.Today();  
            opp.AccountId = acc.id;
            opp.StageName = 'Proposal';
            opp.CloseDate = Date.Today();
            opp.GeneralProducer__c = 'Direct';
            
            Date effectiveDate = opp.CloseDate.addDays(30);        
            opp.Effective_Date__c = Date.newInstance(effectiveDate.Year(), effectiveDate.Month(),1);
            Date contractEndDate = opp.Effective_Date__c+365;
            contractEndDate = Date.newInstance(contractEndDate.Year(), contractEndDate.Month(), 1);
            contractEndDate = contractEndDate.addDays(-1);
            opp.Contract_End_Date__c = contractEndDate;     
            
        insert opp;
        
        List<AIA_Document__c> aiaDocList = new List<AIA_Document__c>();
        aiaDocList.add(aiaDoc);
        
        AIA_Implementation__c impObj = new AIA_Implementation__c();
        impObj.Name__c = 'Test';
        impObj.Opportunity__c = opp.id;
        insert impObj;
        
        Benfit_Request_Form__c brf = new Benfit_Request_Form__c();
        brf.Opportunity__c = opp.id;
        brf.Account__c = acc.id;
        insert brf;
        
        Proposed_Products__c ppr = new Proposed_Products__c();
        //ppr.Opportunity__c = opp.id;
        ppr.Benefit_Request_Form__c = brf.id;
        //ppr.Account__c = acc.id;
        insert ppr;
        
        Apexpages.Currentpage().getParameters().put('id', opp.id);
        ApexPages.StandardSetController testController = new ApexPages.StandardSetController(aiaDocList);
        AIADocumentUploadController controllerObj = new AIADocumentUploadController(testController);
        controllerObj.processUpload();
        controllerObj.cancelButton();
    }
    
    static testMethod void Test2() {
    
    }
}