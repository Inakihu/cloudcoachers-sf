/**
 * @description       : 
 * @author            : IHU - ihernando@cloudcoachers.com
 * @group             : 
 * @last modified on  : 04-05-2021
 * @last modified by  : IHU - ihernando@cloudcoachers.com
 * Modifications Log 
 * Ver   Date         Author                              Modification
 * 1.0   04-05-2021   IHU - ihernando@cloudcoachers.com   Initial Version
**/
public with sharing class CourseTriggerHelper {
    public static void courseCreateEventWPQueable(List<Course__c> newCourseList){
        List<Course__c> courseListWP = new  List<Course__c>();
        for (Course__c course:newCourseList) {
            if (course.SendWebCalendar__c == true) { 
                courseListWP.add(course);
            }
        }
        if (!courseListWP.isEmpty()) {
            CourseWordpressQueue createEventWP = new  courseWordpressQueue(courseListWP) ;
            System.enqueueJob(createEventWP);  
        }
    }
    public static void courseUpdateEventWPQueable(List<Course__c> newCourseList,List<Course__c> oldCourseList){
        List<Course__c> courseListWP = new List<Course__c>();
        for (Integer i=0; i<newCourseList.size(); i++) {
            
            if(newCourseList[i].SendWebCalendar__c == false && oldCourseList[i].SendWebCalendar__c == true){ // Dejar de mostrar
                newCourseList[i].Status__c = 'false';
                courseListWP.add(newCourseList[i]);
            }

            if (newCourseList[i].SendWebCalendar__c == true){ 
                if( newCourseList[i].Start_Date__c      !=  oldCourseList[i].Start_Date__c      || 
                    newCourseList[i].Ending_Date__c     !=  oldCourseList[i].Ending_Date__c     ||
                    newCourseList[i].Course_Subject__c  !=  oldCourseList[i].Course_Subject__c  ||
                    newCourseList[i].Status__c          !=  oldCourseList[i].Status__c      ||
                    newCourseList[i].Schedule__c        !=  oldCourseList[i].Schedule__c    ||
                    newCourseList[i].Location__c        !=  oldCourseList[i].Location__c
                  ){ //Cambia y hay que actualizar o crear
                    courseListWP.add(newCourseList[i]);
                }
                if(newCourseList[i].Wordpress_Integration_Status__c != oldCourseList[i].Wordpress_Integration_Status__c && 
                    newCourseList[i].Wordpress_Integration_Status__c=='Resend'
                  ){  //reenviar por error
                    courseListWP.add(newCourseList[i]);
                }
            }
        }
        if (!courseListWP.isEmpty()) {
            CourseWordpressQueue updateEventWP = new  courseWordpressQueue(courseListWP) ;
            System.enqueueJob(updateEventWP); 
        }   
    }

    public static void courseDeleteEventWPQueable (List<Course__c> oldCourseList){
        List<Course__c> deleteCourseList = new List<Course__c>();
        for (Course__c courseDelete : oldCourseList) {
            Course__c deleteCourseClone = new Course__C();
            deleteCourseClone=courseDelete.clone(false,true,false,false);
            deleteCourseClone.Status__c='false';
            deleteCourseList.add(deleteCourseClone);
        }
        if (!deleteCourseList.isEmpty()) {
            CourseWordpressQueue deleteEventWP = new courseWordpressQueue(deleteCourseList) ;
            System.enqueueJob(deleteEventWP); 
        }
    }
    public static void courseCheckDate (List<Course__c> newCourseList){
        for (Course__c courseCheck : newCourseList) {
            if (courseCheck.Start_Date__c>courseCheck.Ending_Date__c) {
                courseCheck.addError(label.DatesError);
            }
        }
    }
}