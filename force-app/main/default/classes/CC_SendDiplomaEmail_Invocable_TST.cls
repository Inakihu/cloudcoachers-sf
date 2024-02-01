/**
 * @description       : 
 * @author            : IHU - ihernando@cloudcoachers.com
 * @group             : 
 * @last modified on  : 04-10-2021
 * @last modified by  : IHU - ihernando@cloudcoachers.com
 * Modifications Log 
 * Ver   Date         Author                              Modification
 * 1.0   02-11-2021   IHU - ihernando@cloudcoachers.com   Initial Version
**/
@Istest
private class CC_SendDiplomaEmail_Invocable_TST {

    @TestSetup
    static void makeData(){
        System.debug('CC_SendDiplomaEmail_Invocable_TST.makeData');
        System.debug('CC_SendDiplomaEmail_Invocable_TST.CC_TestDF_CustomSetting.createConfig_Course_Attendance_Notifications');
        CC_TestDF_CustomSetting.createConfig_Course_Attendance_Notifications();
        CC_TestDF_CustomSetting.createConfig_Wordpress_Integration();
        Test.setMock(HttpCalloutMock.class, new CourseTriggerHandlerTest.CourseTriggerHandlerTestMock()); 
        System.debug('CC_SendDiplomaEmail_Invocable_TST.CC_TestDF_Account.createAccountsWithTypeName');
        List<Account> lstAlumnos = CC_TestDF_Account.createAccountsWithTypeName(5, 'PersonAccount');
        System.debug('CC_SendDiplomaEmail_Invocable_TST.CC_TestDF_Course.createRecords');
        List<Course__c> lstCourse = CC_TestDF_Course.createRecords(1);
        System.debug('CC_SendDiplomaEmail_Invocable_TST.CC_TestDF_Course_Attendance.createRecords');
        List<Account> lstAlumnos2 = [SELECT Id,PersonContactId FROM Account WHERE Id IN :lstAlumnos];
        List<Course_Attendance__c> lstAsistentes = CC_TestDF_Course_Attendance.createRecords(lstAlumnos2,lstCourse[0].Id);
    }

    @IsTest
    private static void testSendEmailDiploma(){
        System.debug('CC_SendDiplomaEmail_Invocable_TST.testSendEmailDiploma');
        //GIVEN
        Map<Id, Course_Attendance__c> mapAsistentes = new Map<Id, Course_Attendance__c>([SELECT Id,Name FROM Course_Attendance__c]);
        List<Id> lstIds = new List<Id>(mapAsistentes.keySet());
        //WHEN
        Test.startTest();
        CC_SendDiplomaEmail_Invocable.send(lstIds);
        Test.stopTest();
        //THEN

    }
}