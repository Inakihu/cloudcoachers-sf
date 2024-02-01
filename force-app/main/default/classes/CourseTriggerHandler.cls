public with sharing class CourseTriggerHandler {
    public static void execute(List<Course__c> newCourseList, List<Course__c> oldCourseList, System.TriggerOperation operationType) {
        switch on operationType {
            when  AFTER_INSERT{
                CourseTriggerHelper.courseCreateEventWPQueable(newCourseList);
            }
             when AFTER_UPDATE {
                CourseTriggerHelper.courseUpdateEventWPQueable(newCourseList,oldCourseList);
             }
             when BEFORE_DELETE{
                CourseTriggerHelper.courseDeleteEventWPQueable(oldCourseList);
             }
             when BEFORE_INSERT{
                CourseTriggerHelper.courseCheckDate(newCourseList);
             }
             when BEFORE_UPDATE{
                CourseTriggerHelper.courseCheckDate(newCourseList);
             }
        }
    }
}