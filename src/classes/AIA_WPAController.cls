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
            wpa.Proposal_Request_Form__c= apexpages.currentpage().getparameters().get('PRFid');
            
            insert wpa;
        }
        catch(exception e){
            system.debug(e.getMessage());
        }        
        return new pagereference('https://carefirst--devAIA.cs44.my.salesforce.com/'+wpa.id);        
    }    
            
}