//===================================================================================
//Date: 04/19/2016
//Developer: Sree Harsha Akkala
//Purpose: Saves the Workplan Assignment and links it with Proposal Request Form.
//=========================================================================================
// Update History
// Date         Developer               Description
//==================================================================================
//04/19/2016    Sree Harsha Akkala      Initial Development
//==================================================================================
public class AIA_WPAController {
    
    public AIA_Workplan_Assignment__c wpa{get;set;}
    /**
     * Sets the owner to current user.  
     * @Constructor AIA_WPAController    
    */
    public AIA_WPAController(ApexPages.StandardController controller) {
        wpa = new AIA_Workplan_Assignment__c();
        wpa.ownerId=userinfo.getuserId();
    }
     /**
     * Saves the Workplan Assignment and links it with Proposal Request Form.   
     * @method save  
    */  
    public pagereference save(){
        try{
            id prfId = apexpages.currentpage().getparameters().get('PRFid');
            wpa.Proposal_Request_Form__c= prfId;
            PRF__c prf=[select opportunity__c,Opportunity__r.AccountId from PRF__c where id =: prfId];
            wpa.Account__c = prf.Opportunity__r.AccountId;
            insert wpa;
        }
        catch(exception e){
            system.debug(e.getMessage());
        }        
        return new pagereference('https://carefirst--devAIA.cs44.my.salesforce.com/'+wpa.id);        
    }    
            
}