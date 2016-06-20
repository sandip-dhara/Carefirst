//===================================================================================
//Date: 05/23/2016
//Developer: Sree Harsha Akkala
//=========================================================================================
// Update History
// Date         Developer               Description
//==================================================================================
// 05/23/2016    Sree Harsha Akkala      Initial Development
//==================================================================================

//public class AIA_Opportunity_ImplementationHandler
public class AIA_ImplementationHandler{
    
    public static boolean firstRun = false;

    public static Id RecType200Plus = QueryBase.getRecordTypeId('Opportunity', 'AIA_200');
    
    // TODO: What does this method do, add input and output parameters
    // TODO: Add comments
    // TODO: Only search for sold BRF
    // TODO: Only search for opportunity with a status of sold
    // TODO: Add error handling
    public static void createImplementation(list<opportunity> opportunityList){
        system.debug('@@ in createImplementation');
        list<Benfit_Request_Form__c> brfList = [select id,name,Status__c,Opportunity__c  from Benfit_Request_Form__c  where Opportunity__c in: opportunityList ];
        Map<id,id> oppBRFIdMap = new Map<id,id>();
        for(opportunity opp: opportunityList){
            for(Benfit_Request_Form__c brf:brfList){
                if(brf.Opportunity__c==opp.id){
                oppBRFIdMap.put(opp.id,brf.id);
                break;
                }   
            }
        }
        
        list<AIA_Implementation__c> PSIlist = new list<AIA_Implementation__c>();
        for(opportunity opp: opportunityList){
            if(opp.recordtypeId==RecType200Plus && opp.stageName=='Sold'){
                AIA_Implementation__c psi = new AIA_Implementation__c();
                psi.name__C =opp.name;
                psi.Description__c  =opp.description;
                psi.Workplan_Type__c = opp.Workplan_Type__c;
                psi.Status__c='Not Started';
                psi.Account__c = opp.accountId;
                psi.Benefit_Request_Form__c=oppBRFIdMap.get(opp.id);
                psi.Opportunity__c=opp.id;
                PSIlist.add(psi);
            }
        }
        firstRun =true;
        insert PSIlist;
        }
       
}