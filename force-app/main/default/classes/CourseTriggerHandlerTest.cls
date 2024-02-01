/**
 * @File Name          : CourseTriggerHandlerTest.cls
 * @Description        : 
 * @Author             : Juanan jrubio@cloudcoachers.com
 * @Group              : 
 * @Last Modified By   : IHU - ihernando@cloudcoachers.com
 * @Last Modified On   : 04-11-2021
 * @Modification Log   : 
 * Ver       Date            Author      		            Modification
 * 1.0    11/03/2020   Juanan jrubio@cloudcoachers.com     Initial Version
**/
@isTest
public with sharing class CourseTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        CC_TestDF_CustomSetting.createConfig_Wordpress_Integration();
        Test.setMock(HttpCalloutMock.class, new CourseTriggerHandlerTestMock('1111')); 
        List<Course__c> testList= new List<Course__c>();
            Course__c testCourse = new Course__c();
            testCourse.RecordTypeId='0121p000000oVSiAAM';
            testCourse.Course_Type__c='ISDI Trailhead';
            testCourse.Name='testName';
            testCourse.Course_Subject__c='Pardot Consultant';
            testCourse.Ending_Date__c=Date.today().addDays(5);
            testCourse.Location__c='Cloud Coachers Madrid';
            testCourse.Schedule__c='9:00h - 12:00h';
            testCourse.Start_Date__c=Date.today();
            testCourse.Status__c='Open';
            testList.add(testCourse);
        insert testList;
    }
    @isTest static void testCreateEvent() {
        List<Course__c> testList= new List<Course__c>();
            Course__c testCourse = new Course__c();
            testCourse.RecordTypeId='0121p000000oVSiAAM';
            testCourse.Course_Type__c='Calendar Course';
            testCourse.Name='testName';
            testCourse.Course_Subject__c='Pardot Consultant';
            testCourse.Ending_Date__c=Date.today().addDays(5);
            testCourse.Location__c='Cloud Coachers Madrid';
            testCourse.Schedule__c='9:00h - 12:00h';
            testCourse.Start_Date__c=Date.today();
            testCourse.Status__c='Open';
            testList.add(testCourse);
        insert testList;
        CourseTriggerHandlerTestMock mockClass= new CourseTriggerHandlerTestMock();
        mockClass.saleforceId=testList[0].id;
        mockClass.status=true;
        Test.setMock(HttpCalloutMock.class, mockClass);
    }    
    @isTest static void testUpdateEvent() {
        List<Course__c> testListNew= [SELECT id,Ending_Date__c,Course_Type__c FROM Course__c];
        for (Course__c updatecourse : testListNew) {
            updatecourse.Ending_Date__c=Date.today().addDays(10);
            updatecourse.Course_Type__c='Calendar Course';
        }
        update testListNew;
        CourseTriggerHandlerTestMock mockClass= new CourseTriggerHandlerTestMock();
        mockClass.saleforceId=testListNew[0].id;
        mockClass.status=true;
        Test.setMock(HttpCalloutMock.class, mockClass);
    } 
    @isTest static void testUpdateEventErrorDates() {
        List<Course__c> testListNew= [SELECT id,Ending_Date__c,Course_Type__c FROM Course__c];
        for (Course__c updatecourse : testListNew) {
            updatecourse.Ending_Date__c=Date.newInstance(1995, 04, 25);
            updatecourse.Course_Type__c='Calendar Course';
        }
        try {
            update testListNew;
        } catch (Exception e) {
            Boolean Error =  e.getMessage().contains(label.DatesError) ? true : false;
            System.AssertEquals(true, Error);
        }
    } 
    @isTest static void testUpdateEventErrorJson() {
        List<Course__c> testListNew= [SELECT id,Ending_Date__c,Course_Type__c FROM Course__c];
        for (Course__c updatecourse : testListNew) {
            updatecourse.Course_Type__c='Calendar Course';
            updatecourse.Ending_Date__c=Date.today().addDays(10);
        }        
        update testListNew;
        CourseTriggerHandlerTestMockErrorJson mockClass= new CourseTriggerHandlerTestMockErrorJson();
        mockClass.saleforceId=testListNew[0].id;
        mockClass.status=true;
        Test.setMock(HttpCalloutMock.class, mockClass);
    } 
    @isTest static void testUpdateEventErrorConection() {
        List<Course__c> testListNew= [SELECT id,Ending_Date__c,Course_Type__c FROM Course__c];
        for (Course__c updatecourse : testListNew) {
            updatecourse.Course_Type__c='Calendar Course';
            updatecourse.Ending_Date__c=Date.today().addDays(10);
        }        
        update testListNew;
        CourseTriggerHandlerTestMockErrorConection mockClass= new CourseTriggerHandlerTestMockErrorConection();
        mockClass.saleforceId=testListNew[0].id;
        mockClass.status=true;
        Test.setMock(HttpCalloutMock.class, mockClass);
    } 
    @isTest static void testDeleteEvent() {
        List<Course__c> testListNew= [SELECT id FROM Course__c];
        // Set mock callout class 
        CourseTriggerHandlerTestMock mockClass= new CourseTriggerHandlerTestMock();
        mockClass.saleforceId=testListNew[0].id;
        mockClass.status=false;
        Test.setMock(HttpCalloutMock.class, mockClass);
        test.startTest();
        delete testListNew;
        test.stopTest();
    } 
    public class CourseTriggerHandlerTestMock implements HttpCalloutMock{
        public String saleforceId; 
        public Boolean status;
        public String EventIdWordpress;

        public CourseTriggerHandlerTestMock(){
            this.EventIdWordpress = '483';
        }

        public CourseTriggerHandlerTestMock(String EventIdWordpress){
            this.EventIdWordpress = EventIdWordpress;
        }
        
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('[{"Wordpress_Integration_Error_Message":"OK","Event_Id_Wordpress":' + EventIdWordpress + ',"IdSF":"'+saleforceId+'","Wordpress_Integration_Status":"Confirmed","Wordpress_Last_Synchronization":"2020-11-03 16:47:05","Status":'+status+'}]');
            return res;
        }
    }
    public class CourseTriggerHandlerTestMockErrorJson implements HttpCalloutMock{
        public String saleforceId; 
        public Boolean status;
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('error en el json');
            return res;
        }
    }
    public class CourseTriggerHandlerTestMockErrorConection implements HttpCalloutMock{
        public String saleforceId; 
        public Boolean status;
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('Error');
            res.setStatusCode(401);
            res.setBody('fail connexion');
            return res;
        }
    }
}