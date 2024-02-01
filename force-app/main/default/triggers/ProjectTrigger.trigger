/**
 * @File Name          : ProjectTrigger.trigger
 * @Description        : 
 * @Author             : IHU - ihernando@cloudcoachers.com
 * @Group              : 
 * @Last Modified By   : IHU - ihernando@cloudcoachers.com
 * @Last Modified On   : 11/27/2019, 4:18:03 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/15/2019   IHU - ihernando@cloudcoachers.com     Initial Version
**/
trigger ProjectTrigger on Project__c (before insert,
                                      before update, 
                                      before delete,
                                      after insert,
                                      after update, 
                                      after delete, 
                                      after undelete) {
    if(Trigger.isBefore){
           
    }else{
        ccSabbatic.GlobalUtilsLabels gul = new ccSabbatic.GlobalUtilsLabels('1634002','Name',true,true);
        if(!Test.isRunningTest()){
            gul.syncLabels(Trigger.New,Trigger.Old,Trigger.OperationType);
        }
    }
}