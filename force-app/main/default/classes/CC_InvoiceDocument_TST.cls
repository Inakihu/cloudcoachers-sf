/**
 * @File Name          : CC_InvoiceDocument_TST .cls
 * @Description        : 
 * @Author             : TXU - jmurdiain@cloudcoachers.com
 * @Group              : 
 * @Last Modified By   : TXU - jmurdiain@cloudcoachers.com
 * @Last Modified On   : 3/16/2020, 11:42:36 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/25/2020   TXU - jmurdiain@cloudcoachers.com     Initial Version
**/
@isTest
public with sharing class CC_InvoiceDocument_TST {
    @isTest static void test_Controller() {
        List<Account> accLst = CC_TestDF_Account.createAccounts(1);
        Invoice__c invoice = new Invoice__c();
        invoice.AccountId__c = accLst[0].Id;
        invoice.Type__c = 'TSS';
        invoice.Status__c = 'Draft';
        invoice.InvoiceDate__c = date.newinstance(1960, 2, 17);
        insert invoice;

        InvoiceLine__c invLine = new InvoiceLine__c();
        invLine.AmountDiscount__c = 100;
        invLine.Description__c = 'Hola';
        invLine.Discount__c = 0.1;
        invLine.InvoiceId__c = invoice.Id;
        invLine.AmountDiscount__c = 100;
        //invLine.ProductId__c
        invLine.Quantity__c = 2;
        invLine.Tax__c = '21';
        invLine.UnitPrice__c = 2000;
        insert invLine;

        CC_CifAndWeb__c cifAndWeb = new CC_CifAndWeb__c();
        cifAndWeb.CC_CIF__c = 'B83644853';
        cifAndWeb.CC_Web__c = 'www.cloudcoachers.com';
        cifAndWeb.SetupOwnerId = UserInfo.getOrganizationId();
        insert cifAndWeb;
    
        CC_InvoiceDocument_CTR controller = new CC_InvoiceDocument_CTR();
        controller.setIdInvoice(invoice.Id);

        controller.getIdInvoice();
    }
}