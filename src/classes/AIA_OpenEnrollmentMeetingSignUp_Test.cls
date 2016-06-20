@isTest
private class AIA_OpenEnrollmentMeetingSignUp_Test{
static testMethod void testSignUp(){
    AIA_TestUtil.AIA_Implemenation_Test();
    event e =[select id from event ];
    user u = AIA_TestUtil.AIA_createUser('Signup');

      System.runAs(u) {
    AIA_OpenEnrollmentMeetingSignUp.signUp(e.id);
    }
}
}