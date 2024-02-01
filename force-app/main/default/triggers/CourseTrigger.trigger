trigger CourseTrigger on Course__c (before delete, 
                                    before insert, 
                                    before update, 
                                    after delete, 
                                    after insert, 
                                    after undelete, 
                                    after update) {

                                    CourseTriggerHandler.execute(Trigger.new,Trigger.old,Trigger.operationType);
}