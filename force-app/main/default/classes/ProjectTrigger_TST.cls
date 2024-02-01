/**
 * @File Name          : ProjectTrigger_TST.cls
 * @Description        : 
 * @Author             : IHU - ihernando@cloudcoachers.com
 * @Group              : 
 * @Last Modified By   : IHU - ihernando@cloudcoachers.com
 * @Last Modified On   : 11/15/2019, 3:17:50 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/15/2019   IHU - ihernando@cloudcoachers.com     Initial Version
**/
@IsTest
private class ProjectTrigger_TST {
    @IsTest
    public static void ProjectTrigger_TST() {
        Project__c p = new Project__c();
        p.Name = 'test  project';
        insert p;
    }
}