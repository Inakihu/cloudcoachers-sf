/**
 * @File Name          : SendEmailWithAttachmentsTest.cls
 * @Description        : 
 * @Author             : Oriol Farras - ofarras@cloudcoachers.com
 * @Group              : 
 * @Last Modified By   : IHU - ihernando@cloudcoachers.com
 * @Last Modified On   : 04-10-2021
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    22/1/2020   Oriol Farras - ofarras@cloudcoachers.com     Initial Version
**/
@istest
public with sharing class SendEmailWithAttachmentsTest {

   @istest
    public static void testSendEmail(){
        CC_TestDF_CustomSetting.createConfig_Wordpress_Integration();
        Test.setMock(HttpCalloutMock.class, new CourseTriggerHandlerTest.CourseTriggerHandlerTestMock()); 
        
        
        Account acc = new Account(Name='testAccount');
        insert acc; 

        Contact cont = new Contact();
		cont.FirstName='Test';
		cont.LastName ='Test';
		cont.accountId = acc.id;
        cont.Email = 'test@gmail.com';
		insert cont;

        Contact cont2 = new Contact();
		cont2.FirstName='Test 2';
		cont2.LastName ='Test 2';
		cont2.accountId = acc.id;
        cont2.Email = 'tes2t@gmail.com';
		insert cont2;
        
        Product2 prod = new Product2(Name = 'Curso X',Family='Training',IsActive=true);
        insert prod;

        ContentVersion contentVersion = new ContentVersion(
        Title = 'EX-Examen 1',
        PathOnClient = 'Examen1.pdf',
        VersionData = Blob.valueOf('Test Content Examen'),
        IsMajorVersion = true
        );
        insert contentVersion;    

        ContentVersion contentVersion2 = new ContentVersion(
        Title = 'DC-Documentacion',
        PathOnClient = 'Documentacion.zip',
        VersionData = Blob.valueOf('Test Content Examen'),
        IsMajorVersion = true
        );
        insert contentVersion2; 

        ContentDocumentLink contendoclink = New ContentDocumentLink();
        contendoclink.contentdocumentid=[select contentdocumentid from contentversion where id =: contentVersion.id].contentdocumentid;
        contendoclink.LinkedEntityId =prod.id;
        contendoclink.shareType = 'V';
        insert contendoclink;

         ContentDocumentLink contendoclink2 = New ContentDocumentLink();
        contendoclink2.contentdocumentid=[select contentdocumentid from contentversion where id =: contentVersion2.id].contentdocumentid;
        contendoclink2.LinkedEntityId =prod.id;
        contendoclink2.shareType = 'V';
        insert contendoclink2;
        
        Course__c course  = new Course__C(Name = 'Curso X enero', Course_Product__c=prod.id);
        insert course;

        Course_Attendance__c asistente = new Course_Attendance__c(Course__c = course.id,Attendant__c=cont.id);
        insert asistente;

        Course_Attendance__c asistente2 = new Course_Attendance__c(Course__c = course.id,Attendant__c=cont2.id);
        insert asistente2;
        
        List<SendEmailWithAttachments.Request> requests= new List<SendEmailWithAttachments.Request>();
        
        for (Integer n=0; n<=200; n++ ){
            SendEmailWithAttachments.Request request = new SendEmailWithAttachments.Request();
            if (Math.Mod(n,2)==0){
                request.tipoAdjuntos ='EX';
                request.idAsistente = asistente.id;
                request.idContacto = cont.id;
            }else{
                request.tipoAdjuntos ='DC';
                request.idAsistente = asistente2.id;
                request.idContacto = cont2.id;
            }
            request.idProducto = prod.id ;
            requests.add(request);
        }

        Test.startTest();
            SendEmailWithAttachments.executeSendEmailWithAttachments(requests);
            Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();   

        List<Course_Attendance__c> asistentescheck = [select id,Exam_Sent__c,Documentation_Sent__c  from  Course_Attendance__c];
        for (Course_Attendance__c asistentecheck:asistentescheck){
            //System.assertEquals(asistentecheck.Exam_Sent__c || asistentecheck.Documentation_Sent__c, true, 'No ha se han enviado nada');
        }
    }

    @IsTest
    static void testFail(){
        CC_TestDF_CustomSetting.createConfig_Wordpress_Integration();
        Test.setMock(HttpCalloutMock.class, new CourseTriggerHandlerTest.CourseTriggerHandlerTestMock()); 
        
        Account acc = new Account(Name='testAccount');
        insert acc; 

        Contact cont = new Contact();
		cont.FirstName='Test';
		cont.LastName ='Test';
		cont.accountId = acc.id;
		insert cont;
        
        Product2 prod = new Product2(Name = 'Curso X',Family='Training',IsActive=true);
        insert prod;

        Course__c course  = new Course__C(Name = 'Curso X enero', Course_Product__c=prod.id);
        insert course;

        Course_Attendance__c asistente = new Course_Attendance__c(Course__c = course.id,Attendant__c=cont.id);
        insert asistente;
        
        List<SendEmailWithAttachments.Request> requests= new List<SendEmailWithAttachments.Request>();
        
        SendEmailWithAttachments.Request request = new SendEmailWithAttachments.Request();
        request.tipoAdjuntos ='EX';
        request.idAsistente = asistente.id;
        request.idContacto = cont.id;
        request.idProducto = prod.id ;
        requests.add(request);
        
        Test.startTest();
            SendEmailWithAttachments.executeSendEmailWithAttachments(requests);
            Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();   

        Course_Attendance__c asistentecheck = [select id, SendEmailError__c from  Course_Attendance__c where id=:asistente.id];
        System.assertNotEquals(asistentecheck.SendEmailError__c.length(), 0, 'No ha registrado el error');

    }
}