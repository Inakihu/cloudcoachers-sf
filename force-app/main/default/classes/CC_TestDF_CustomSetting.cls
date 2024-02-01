/**
 * @description       : 
 * @author            : IHU - ihernando@cloudcoachers.com
 * @group             : 
 * @last modified on  : 04-10-2021
 * @last modified by  : IHU - ihernando@cloudcoachers.com
 * Modifications Log 
 * Ver   Date         Author                              Modification
 * 1.0   02-17-2021   IHU - ihernando@cloudcoachers.com   Initial Version
**/
@Istest
public class CC_TestDF_CustomSetting {

    public static void createConfig_Course_Attendance_Notifications() {
        Config_Course_Attendance_Notifications__c configCourseAttendanceNotification;
        configCourseAttendanceNotification = new Config_Course_Attendance_Notifications__c();
        configCourseAttendanceNotification.Diploma_File_Name__c ='Diploma';
        /*List<OrgWideEmailAddress> lstOrgWideEmailAddress = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        if(lstOrgWideEmailAddress.size()>0){
            configCourseAttendanceNotification.OrgWideEmailAddress_Id__c = lstOrgWideEmailAddress[0].Id;
        }*/
        configCourseAttendanceNotification.SetupOwnerId = UserInfo.getOrganizationId();
        insert configCourseAttendanceNotification; 
    }
    
    public static void createConfig_Wordpress_Integration() {
        WPConfig__c wPConfig = WPConfig__c.getInstance();
        wPConfig.Secret__c = 'Secreto';
        wPConfig.endPoint__c = 'https://www.cloudcoachers.com/wp-json/salesforce/events/'; 
        insert wPConfig; 
    }
}