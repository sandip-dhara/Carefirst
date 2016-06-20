@isTest
private class AIA_DE_OpportunityStageClass_Test{
    static testMethod void testOppStage(){
        Test.startTest();
        //Create Opportunity
        Opportunity opp = new Opportunity(name='Testopp',closeDate=system.today()+90,stageName='Prospecting');
        
        ApexPages.StandardController con = new ApexPages.StandardController(opp);
        AIA_DE_OpportunityStageClass dos = new AIA_DE_OpportunityStageClass(con );
        dos.getPickListValues();
        Test.stopTest(); 
       
    }
}