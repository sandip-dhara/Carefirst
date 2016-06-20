/*------------------------------------------------------------------------------------
 *                      ----===[ HISTORY ]===---
 * Date        Developer        Description
 *------------------------------------------------------------------------------------
 * 05/19/2016 Chida--B-02108 
 B-02108 
 1.User can mark the Opportunity as sold (contract was awarded) if there is a Benefit Request Form marked as sold
                                 
 * 
  *************************************************************************************
 */
 
 //---------------------------------------------------------------------------------------------------------

/**
* @Author: Chida
* @Purpose: User can mark the Opportunity as sold (contract was awarded) if there is a Benefit Request Form marked as sold
    
* Input List of Opportunities
*/


public class AIA_Opportunity_Helper
{
    //List of Opportunities
    public void AIA_Opportunity_Helper(List<Opportunity> listOppty)
    {
      //  User can mark the Opportunity as sold (contract was awarded) if there is a Benefit Request Form marked as sold
    
        for(Opportunity opt: listOppty)
        {
         if(opt.StageName  == 'Sold')
        {
            List<Benfit_Request_Form__c> BRF=[select ID from Benfit_Request_Form__c where Status__c = 'Sold' AND Opportunity__c =: opt.id];
            if(BRF.size() < 1)
            {
                opt.adderror('There are no "Sold" Benefit Request Forms under it');
            }
        }
        }
    }
}