//===================================================================================
//Date: 05/04/2016
//Developer: Sree Harsha Akkala
//Purpose: Proposed Product Class
//=========================================================================================
// Update History
// Date         Developer               Description
//==================================================================================
//05/04/2016    Sree Harsha Akkala      Initial Development
//==================================================================================
// Date:       05/23/2016
// Developer:  Goutham Rapolu
// Desciption: : updateBRFMHPTestResult Method(): If the Proposal Request form form is created from BRF then the BRF MPH Test Result field will be 
//               updated Based on Proposal request Form. 
//               validationForCustomCheck Mthod() : To check whether there is an AIA Document (Document Type = "Marked Up Benefit Summary") attached 
//               to the Proposed Product, when the custom flag on the Proposed Product is true
//=================================================================================================================================================

// Change name to AIA_ProposedProductsHandler
// TODO: Add comments - there are no comments
public class AIA_PPHandler extends TriggerHandler {
    
    public AIA_PPHandler(){}
    public static boolean firstRun=false;
    
    public static Final String errorMsg = label.AIA_PP_Error_Msg;
    
    
    protected override void afterInsert() {     
        if(!firstRun)
        updateMHPTest((list<Proposed_Products__c>) trigger.new,(Map<id,Proposed_Products__c>) trigger.oldMap);
            // Please add comments
        
        updateBRFMHPTestResult((list<Proposed_Products__c>) trigger.new,(Map<id,Proposed_Products__c>) trigger.oldMap);
        validationForCustomCheck((list<Proposed_Products__c>) trigger.new,(Map<id,Proposed_Products__c>) trigger.oldMap);
    }
    protected override void afterUpdate() {
        if(!firstRun)
            updateMHPTest((list<Proposed_Products__c>) trigger.new,(Map<id,Proposed_Products__c>) trigger.oldMap);
        updateBRFMHPTestResult((list<Proposed_Products__c>) trigger.new,(Map<id,Proposed_Products__c>) trigger.oldMap);
        validationForCustomCheck((list<Proposed_Products__c>) trigger.new,(Map<id,Proposed_Products__c>) trigger.oldMap);
    }
    
    // Updates the completed by and completed date on the proposed products when the MHP Test Result is updated
    public static void updateMHPTest(list<Proposed_Products__c> newPPList,Map<id,Proposed_Products__c> oldPPMap){
        
        // Get list of products if the BRF is MHP required
        list<Proposed_Products__c> ppList = [select id,name,MHP_Test_Result__c,Benefit_Request_Form__r.MHP_Required__c from Proposed_Products__c where id in:newPPList ];
        system.debug('@@ppList'+ppList);
        if(ppList.size()>0){
                    
            for(Proposed_Products__c pp: ppList){
                if(oldPPMap!=null){
                    //if(oldPPMap.get(pp.id).MHP_Test_Result__c!=null && pp.MHP_Test_Result__c!=null){
                        if(oldPPMap.get(pp.id).MHP_Test_Result__c!=pp.MHP_Test_Result__c){
                            pp.MHP_Test_Completed_Date__c = system.now();
                            pp.MHP_Test_Completed_By__c=userInfo.getUserId();               
                        }
                    //}
                }
                else{
                    if(pp.MHP_Test_Result__c!=null){
                        pp.MHP_Test_Completed_Date__c = system.now();
                        pp.MHP_Test_Completed_By__c=userInfo.getUserId();
                    }
                }
            }
            
            firstRun=true;
            try{
            update ppList;
            }
            catch(exception e){}
        }
    }
    
    /**
    * @Author: Goutham Rapolu
    * @This Method is called from Proposed Products trigger
    * @This method - If the Proposal Request form form is created from BRF then the BRF MPH Test Result field will be 
    *                updated Based on Proposal request Form
    * @param -  list<Proposed_Products__c> ,list<Proposed_Products__c>
    * @Output - Update the BRF based on PP's Records
    */
    
    public static void updateBRFMHPTestResult(list<Proposed_Products__c> newPPList,Map<id,Proposed_Products__c> oldPPMap){
        
        Map<Id,boolean> failMapPP = new Map<Id,boolean>(); // To store Fail value from MHP_Test_Result__c fields
        Map<Id,boolean> passMapPP = new Map<Id,boolean>(); // To store pass value from MHP_Test_Result__c fields
        Map<Id,boolean> blankMapPP = new Map<Id,boolean>(); // To store blank value from MHP_Test_Result__c fields
        Map<Id,boolean> deferredMapPP = new Map<Id,boolean>(); // To store deferred value from MHP_Test_Result__c fields
        integer totalPP = 0; // to store all Proposed Products count
        integer totalPassPP = 0; // to store total pass Proposed Products count
        list<Proposed_Products__c> ppList = new list<Proposed_Products__c>();// to store Proposed Products records
        list<Benfit_Request_Form__c> brfList = new list<Benfit_Request_Form__c>(); // to store BRF records
        Set<String> BRFIds = new Set<String>();
        
        // Get record type for Medical
        Id rt_PP_Medical= QueryBase.getRecordtypeId('Proposed_Products__c', 'Medical');
        
        // Get all Medical Proposed Products
        if(rt_PP_Medical != null)
            ppList = [select id,name,MHP_Test_Result__c,Benefit_Request_Form__r.Funding_Arrangements__c,Benefit_Request_Form__r.MHP_Test_Result__c,Benefit_Request_Form__c from Proposed_Products__c where id in:newPPList and recordtypeId =: rt_PP_Medical];
        
        if(ppList.size()>0){      
            for(Proposed_Products__c pp: ppList){
                boolean isUpdate = false;
                boolean isInsert = false;
                BRFIds.add(pp.Benefit_Request_Form__c);
                system.debug('pp.Benefit_Request_Form__c'+ pp.Benefit_Request_Form__c);
                if(oldPPMap == null){//insert
                    isInsert = true;
                }
                else{//update
                    if(oldPPMap.get(pp.id).MHP_Test_Result__c != pp.MHP_Test_Result__c){
                        isUpdate = true;
                    }
                }
                
                if((isUpdate || isInsert) && pp.Benefit_Request_Form__r.Funding_Arrangements__c == 'ASO'){
                    if(pp.MHP_Test_Result__c == 'Fail')
                        failMapPP.put(pp.Benefit_Request_Form__c,true); 
                    if(String.isBlank(pp.MHP_Test_Result__c))
                        blankMapPP.put(pp.Benefit_Request_Form__c,true);
                    if(pp.MHP_Test_Result__c == 'Deferred')
                        deferredMapPP.put(pp.Benefit_Request_Form__c,true); 
                    if(pp.MHP_Test_Result__c == 'Pass'){
                        passMapPP.put(pp.Benefit_Request_Form__c,true);
                        totalPassPP ++;
                    }
                    
                }else if((isUpdate || isInsert) && (pp.Benefit_Request_Form__r.Funding_Arrangements__c == 'Risk' || pp.Benefit_Request_Form__r.Funding_Arrangements__c == 'Both' || pp.Benefit_Request_Form__r.Funding_Arrangements__c == 'Other')){
                    if(pp.MHP_Test_Result__c == 'Fail')
                        failMapPP.put(pp.Benefit_Request_Form__c,true); 
                    if(String.isBlank(pp.MHP_Test_Result__c))
                        blankMapPP.put(pp.Benefit_Request_Form__c,true);
                    if(pp.MHP_Test_Result__c == 'Pass'){
                        passMapPP.put(pp.Benefit_Request_Form__c,true);
                        totalPassPP ++;
                    }
                    
                }
                totalPP ++;
            }
            
            if(BRFIds != null && BRFIds.size() > 0){
            for(Benfit_Request_Form__c BRF: [select id,Funding_Arrangements__c,MHP_Test_Result__c from Benfit_Request_Form__c where id =: BRFIds]){
                if(failMapPP != null && failMapPP.size()>0){
                    BRF.MHP_Test_Result__c = 'Fail';
                }else if(blankMapPP != null && blankMapPP.size()>0){
                    BRF.MHP_Test_Result__c = 'Pending';
                }else if(deferredMapPP != null && deferredMapPP.size()>0){
                    BRF.MHP_Test_Result__c = 'Deferred';
                }else if(passMapPP != null && passMapPP.size()>0){
                    if(totalPassPP == totalPP)
                    BRF.MHP_Test_Result__c = 'Pass';
                }
                brfList.add(BRF);
            }
            }
        }
        
        if(brfList != null && brfList.size()>0){
            firstRun=true;
            update brfList;
        }
    }
    
    /**
    * @Author: Goutham Rapolu
    * @This Method is called from Proposed Products trigger
    * @This method - To check whether there is an AIA Document (Document Type = "Marked Up Benefit Summary") attached 
    *             to the Proposed Product, when the custom flag on the Proposed Product is true
    * @param -  list<Proposed_Products__c> ,Map<id,Proposed_Products__c>
    * @Output - Through an error if condition is not meet 
    */
     
     public static void validationForCustomCheck(list<Proposed_Products__c> newPPList,Map<id,Proposed_Products__c> oldPPMap){

        map<id,Proposed_Products__c> ppMap = new map<id,Proposed_Products__c>([SELECT Custom__c,Id,(select id, Document_Type__c from File_Net_Documents__r) FROM Proposed_Products__c where id in:newPPList]);
        system.debug('errorMsg'+errorMsg);
         system.debug('ppMap'+ ppMap);
        if(ppMap != null && ppMap.size()>0){
            for(Proposed_Products__c pp: newPPList){
                    if(pp.Custom__c == True)
                {
                    if(ppMap.containsKey(pp.Id) && ppMap.get(pp.Id).File_Net_Documents__r.size()>0){
                    for(AIA_Document__c FND: ppMap.get(pp.Id).File_Net_Documents__r){
                        if(FND.Document_Type__c != 'Marked Up Benefit Summary'){
                            firstRun=true;
                            pp.adderror(errorMsg);
                        }
                    }
                    }else{
                        firstRun=true;
                        pp.adderror(errorMsg);
                    }
                }
            }
        }
     }
     

}