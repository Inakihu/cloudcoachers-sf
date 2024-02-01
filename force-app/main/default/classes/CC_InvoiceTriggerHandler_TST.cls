/**
 * @File Name          : CC_InvoiceTriggerHandler_TST.cls
 * @Description        : 
 * @Author             : TXU - jmurdiain@cloudcoachers.com
 * @Group              : 
 * @Last Modified By   : TXU - jmurdiain@cloudcoachers.com
 * @Last Modified On   : 3/18/2020, 2:54:14 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/25/2020   TXU - jmurdiain@cloudcoachers.com     Initial Version
**/
@isTest
public with sharing class CC_InvoiceTriggerHandler_TST {
    
    @TestSetup
    static void makeData(){
        List<Account> accLst = CC_TestDF_Account.createAccounts(1);
        Invoice__c invoice = new Invoice__c();
        invoice.AccountId__c = accLst[0].Id;
        invoice.Type__c = 'TSS';
        invoice.Status__c = 'Draft';
        invoice.InvoiceDate__c = date.newinstance(1960, 2, 17);
        insert invoice;
        CC_Invoice_Number__c invoiceNumber = new CC_Invoice_Number__c();
        invoiceNumber.Name = 'testInvoiceNumberTSS';
        invoiceNumber.Next_Invoice_Number__c = 3;
        invoiceNumber.Type__c = 'TSS';
        invoiceNumber.Year__c = '1960';
        insert invoiceNumber;

        InvoiceTrigger__c config = new InvoiceTrigger__c();
        config.SetInvoiceNumber__c = true;
        insert config;
    }

    @isTest static void test_insertInvoice() {
        List<Account> accLst = [SELECT id FROM Account];
        List<Invoice__c> invoiceLst = new List<Invoice__c>();
        Invoice__c invoice = new Invoice__c();
        invoice.AccountId__c = accLst[0].Id;
        invoice.Type__c = 'TSS';
        invoice.Status__c = 'Completed';
        invoice.InvoiceDate__c = date.newinstance(1960, 4, 17);
        invoiceLst.add(invoice);
        Invoice__c invoice2 = new Invoice__c();
        invoice2.AccountId__c = accLst[0].Id;
        invoice2.Type__c = 'TSS';
        invoice2.Status__c = 'Completed';
        invoice2.InvoiceDate__c = date.newinstance(1960, 6, 27);
        invoiceLst.add(invoice2);
        Invoice__c invoice3 = new Invoice__c();
        invoice3.AccountId__c = accLst[0].Id;
        invoice3.Type__c = 'TSS';
        invoice3.Status__c = 'Completed';
        invoice3.InvoiceDate__c = date.newinstance(2000, 2, 17);
        invoiceLst.add(invoice3);
        insert invoiceLst;
    }

    @isTest static void test_updateInvoice() {
        List<Invoice__c> invoiceLst = [SELECT id, Status__c, AccountId__c, Type__c, InvoiceDate__c, Invoice_Number__c FROM Invoice__c];
        Invoice__c invoice = invoiceLst[0].clone(false,true,false,false);
        insert invoice;
        invoiceLst.add(invoice);
        for (Invoice__c invoiceAux : invoiceLst) {
            invoiceAux.Status__c = 'Completed';
            invoiceAux.InvoiceDate__c = date.newinstance(1960, 2, 17);
        }
        update invoiceLst;
        
        invoiceLst = [SELECT id, Status__c, AccountId__c, Type__c, InvoiceDate__c, Invoice_Number__c FROM Invoice__c];
        String yearString = String.valueOf(invoiceLst[0].InvoiceDate__c.Year());
        List<CC_Invoice_Number__c> invoiceNumberLst = [SELECT Next_Invoice_Number__c FROM CC_Invoice_Number__c WHERE Type__c = :invoiceLst[0].Type__c AND Year__c = :yearString];
        Decimal numAux = invoiceNumberLst[0].Next_Invoice_Number__c - invoiceLst.size();
        System.debug(invoiceLst);
        for (Invoice__c invoiceAux : invoiceLst) {
            System.assertEquals(invoiceAux.Type__c+' - '+invoiceAux.InvoiceDate__c.year()+' - '+invoiceAux.InvoiceDate__c.month()+' - '+String.valueOf(numAux).leftPad(4, '0'), invoiceAux.Invoice_Number__c);
            numAux++;
        }
    }
    @isTest static void test_updateInvoiceWithInvoiceNumber() {
        List<Invoice__c> invoiceLst = [SELECT id, Status__c, AccountId__c, Type__c, InvoiceDate__c, Invoice_Number__c FROM Invoice__c];
        List<CC_Invoice_Number__c> invoiceNumberLst = [SELECT Next_Invoice_Number__c FROM CC_Invoice_Number__c];
        for (Invoice__c invoice : invoiceLst) {
            invoice.Status__c = 'Completed';
        }
        update invoiceLst;
        Decimal numAux = invoiceNumberLst[0].Next_Invoice_Number__c;
        invoiceLst = [SELECT id, Status__c, AccountId__c, Type__c, InvoiceDate__c, Invoice_Number__c FROM Invoice__c];
        for (Invoice__c invoiceAux : invoiceLst) {
            System.assertEquals(invoiceAux.Type__c+' - '+invoiceAux.InvoiceDate__c.year()+' - '+invoiceAux.InvoiceDate__c.month()+' - '+String.valueOf(numAux).leftPad(4, '0'), invoiceAux.Invoice_Number__c);
            numAux++;
        }
    }
}