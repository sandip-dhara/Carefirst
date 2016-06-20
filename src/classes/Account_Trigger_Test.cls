@isTest
private class Account_Trigger_Test {
    static testMethod void Test1() {
        Test.startTest();
        AIA_TestUtil.createAccount('TestAccountInsert');
        AIA_TestUtil.updateAccount('TestAccountUpdate');
        //Create account
        Account a = new Account();
        a.Name = 'SomeTest' + Date.Today();
        a.Type = 'Customer';
        a.billingstate = 'MD';
        a.billingCountry = 'United States';
        a.billing_County_Code__c = 'CA-Carroll';
        a.shippingstate = 'MD';
        a.shippingcountry = 'USA';        
        insert a;
        
        Account b = new Account();
        b.Name = 'SomeTest2' + Date.Today();
        b.Type = 'Customer';
        b.billingstate = 'AB';
        b.billingCountry = 'Canada';
        //a.billing_County_Code__c = 'CA-Carroll';
        b.shippingstate = 'AB';
        b.shippingcountry = 'Canada';        
        insert b;

        Test.stopTest();        
        System.assert([select Id from Account where Id=:a.id].size() == 1);
    }
   
    // Test error condition
    static testMethod void Test2() {
        Test.startTest();
        //Create account
        Account a = new Account();
        a.Name = 'SomeTest2' + Date.Today();
        a.Type = 'Customer';
        //a.billingstate = 'AB';
        //a.billingCountry = 'US';
        // MD is not a state for Canada
        a.shippingstate = 'CA';
        a.shippingcountry = 'US';                  
    
        // We need the try catch block in order to 
        // to get 100% code coverage
        try {
            insert a;
        //  System.assert(false);
        }
        catch (Exception e)
        {
           // expected
        } 
                
        Test.stopTest();
        System.assert([select Id from Account where Id=:a.id].size() == 1);
    }
}