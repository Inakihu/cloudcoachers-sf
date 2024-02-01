/**
 * @description       : 
 * @author            : IHU - ihernando@cloudcoachers.com
 * @group             : 
 * @last modified on  : 02-18-2021
 * @last modified by  : IHU - ihernando@cloudcoachers.com
 * Modifications Log 
 * Ver   Date         Author                              Modification
 * 1.0   02-09-2021   IHU - ihernando@cloudcoachers.com   Initial Version
**/
public with sharing class CC_SendDiplomaEmail_Invocable {
    
    @InvocableMethod
    public static void send(List<Id> lstCourseAttendanceIds) {
        List<Course_Attendance__c> lstCourseAttendanceToUpdate = [SELECT Id, Attendant__c FROM Course_Attendance__c WHERE Id = :lstCourseAttendanceIds];
        List<Messaging.SingleEmailMessage> lstSingleEmailMessage = new List<Messaging.SingleEmailMessage>();

        Config_Course_Attendance_Notifications__c configCourseAttendanceNotification;
        configCourseAttendanceNotification = Config_Course_Attendance_Notifications__c.getInstance();
        
        for (Course_Attendance__c ca : lstCourseAttendanceToUpdate){
            // Define the email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            // Sets the paramaters of the email
            email.setTemplateId(Label.CC_Diploma_EmailTemplateId);
            email.setTargetObjectId(ca.Attendant__c);
            email.setWhatId(ca.Id);
            if(!String.isBlank(configCourseAttendanceNotification.OrgWideEmailAddress_Id__c)){
                email.setOrgWideEmailAddressId(configCourseAttendanceNotification.OrgWideEmailAddress_Id__c);
            }

            // Sends the email
            List<Messaging.Emailfileattachment> fileAttachments;
            fileAttachments = new List<Messaging.Emailfileattachment>();
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            if(!String.isBlank(configCourseAttendanceNotification.Diploma_File_Name__c)){
                efa.setFileName(configCourseAttendanceNotification.Diploma_File_Name__c + '.pdf');
            }else{
                efa.setFileName('Diploma.pdf');
            }
            
            PageReference pdf = Page.CC_Diploma_PDF_v2;
            pdf.getParameters().put('id',ca.Id);
            pdf.setRedirect(true);
            // Take the PDF content
            Blob b;
            if(Test.isRunningTest()) { 
                b = blob.valueOf('Unit.Test');
            } else {
                b = pdf.getContent();
            }
            
            // Create the email attachment
            efa.setBody(b);
            fileAttachments.add(efa);
            email.setFileAttachments(fileAttachments);
            System.debug('email:' + email);
            lstSingleEmailMessage.add(email);
        }

        Messaging.SendEmailResult[] r;
        System.debug('Emails:' + lstSingleEmailMessage);
        r = Messaging.sendEmail(lstSingleEmailMessage);
        for(Integer i = 0 ; i < r.size(); i++){
            if(r[i].isSuccess()){
                lstCourseAttendanceToUpdate[i].Diploma_Email_Sent__c = true;
                lstCourseAttendanceToUpdate[i].SendEmailError__c = '';
            }else{
                lstCourseAttendanceToUpdate[i].SendEmailError__c = r[i].getErrors()[0].getMessage();
            }
        }
        
        update lstCourseAttendanceToUpdate;
    }
}