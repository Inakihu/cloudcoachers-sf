/**
 * @File Name          : InvoiceTrigger.trigger
 * @Description        : 
 * @Author             : TXU - jmurdiain@cloudcoachers.com
 * @Group              : 
 * @Last Modified By   : TXU - jmurdiain@cloudcoachers.com
 * @Last Modified On   : 2/25/2020, 11:23:10 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/24/2020   TXU - jmurdiain@cloudcoachers.com     Initial Version
**/
trigger InvoiceTrigger on Invoice__c (before insert,
                                    before update,
                                    before delete,
                                    after insert,
                                    after update,
                                    after delete,
                                    after undelete) {
    (new CC_InvoiceTriggerHandler()).execute();
}