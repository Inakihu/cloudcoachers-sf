/**
 * @File Name          : CC_InvoiceTriggerHandler.cls
 * @Description        : 
 * @Author             : TXU - jmurdiain@cloudcoachers.com
 * @Group              : 
 * @Last Modified By   : TXU - jmurdiain@cloudcoachers.com
 * @Last Modified On   : 3/18/2020, 2:40:32 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/24/2020   TXU - jmurdiain@cloudcoachers.com     Initial Version
 * 1.1    3/06/2020   IHU - ihernando@cloudcoachers.com     Permitir que se desactive por la asignación de Custom Setting.
**/
public with sharing class CC_InvoiceTriggerHandler {
    public void execute(){
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                setInvoiceNumberBeforeInsert(Trigger.New);
            }else if(Trigger.isUpdate){
                setInvoiceNumberBeforeUpdate(Trigger.new, Trigger.old);
            }
        }
    }
    
    private void setInvoiceNumberBeforeInsert(List<Invoice__c> invoiceLstNew){
        Boolean isActive = true;
        InvoiceTrigger__c config = InvoiceTrigger__c.getInstance();
        if(config != null){
            isActive = config.SetInvoiceNumber__c;
        }

        if (isActive){
            List<Invoice__c> invoiceLstCompleted = new List<Invoice__c>();
            Map<string,List<Invoice__c>> invoiceMapLst = new Map<string,List<Invoice__c>>();
            
            for (Integer i = 0; i < invoiceLstNew.size(); i++) {
                if (invoiceLstNew[i].Status__c	== 'Completed') {
                    invoiceLstCompleted.add(invoiceLstNew[i]);
                }
            }
            if(!invoiceLstCompleted.isEmpty()){
                Set<String> yearList = new Set<String>();
                Set<String> tipoLst = new Set<String>();
                for (Invoice__c invoice : invoiceLstCompleted) {
                    yearList.add(String.valueOf(invoice.InvoiceDate__c.year()));
                    tipoLst.add(invoice.Type__c);
                }
                List<CC_Invoice_Number__c> invoiceNumberLst = [SELECT id, Next_Invoice_Number__c, Type__c, Year__c FROM CC_Invoice_Number__c WHERE Year__c IN :yearList AND Type__c IN :tipoLst];
                Map<String,CC_Invoice_Number__c> invoiceNumberMap = new Map<String,CC_Invoice_Number__c>();
                for (CC_Invoice_Number__c invoiceNumber : invoiceNumberLst) {
                    invoiceNumberMap.put(invoiceNumber.Type__c+'__'+invoiceNumber.Year__c, invoiceNumber);
                }

                for (Invoice__c invoice : invoiceLstCompleted) {
                    String auxKey = invoice.Type__c+'__'+invoice.InvoiceDate__c.year();
                    if(invoiceMapLst.containsKey(auxKey)){
                        List<Invoice__c> invoiceLstAux = invoiceMapLst.get(auxKey);
                        invoiceLstAux.add(invoice);
                        invoiceMapLst.put(auxKey,invoiceLstAux);
                    }else{
                        List<Invoice__c> invoiceLstAux = new List<Invoice__c>();
                        invoiceLstAux.add(invoice);
                        invoiceMapLst.put(auxKey,invoiceLstAux);
                    } 
                }
                //Se comprueba que existan los invoiceNumber de los tipos y fechas que entran, si no existen se crean.
                List<CC_Invoice_Number__c> invoiceNumberInsert = new List<CC_Invoice_Number__c>();
                for (String auxKey : invoiceMapLst.keySet()) {
                    CC_Invoice_Number__c invoiceNumber = invoiceNumberMap.get(auxKey);
                    if(invoiceNumber == null){
                        Invoice__c inv = invoiceMapLst.get(auxKey)[0];
                        CC_Invoice_Number__c newInvoiceNumber = new CC_Invoice_Number__c();
                        newInvoiceNumber.Name = 'Invoice_Number_'+inv.Type__c;
                        newInvoiceNumber.Type__c = inv.Type__c;
                        newInvoiceNumber.Year__c =String.valueOf(inv.InvoiceDate__c.year());
                        newInvoiceNumber.Next_Invoice_Number__c = 1;
                        invoiceNumberInsert.add(newInvoiceNumber);
                        invoiceNumberMap.put(inv.Type__c+'__'+inv.InvoiceDate__c.year(), newInvoiceNumber);
                    }
                }
                insert invoiceNumberInsert;

                List<CC_Invoice_Number__c> invoiceNumberLstToUpdate = new List<CC_Invoice_Number__c>();
                for (String auxKey : invoiceMapLst.keySet()) {
                    CC_Invoice_Number__c invoiceNumb = invoiceNumberMap.get(auxKey);
                    if(invoiceNumb != null){
                        Decimal nextNumber = invoiceNumb.Next_Invoice_Number__c;
                        for (Invoice__c inv : invoiceMapLst.get(auxKey)) {
                            inv.Invoice_Number__c = inv.Type__c+' - '+inv.InvoiceDate__c.year()+inv.InvoiceDate__c.month()+' - '+String.valueOf(nextNumber).leftPad(4, '0');
                            nextNumber++;
                        }
                        invoiceNumb.Next_Invoice_Number__c = nextNumber;
                        invoiceNumberLstToUpdate.add(invoiceNumb);
                        invoiceMapLst.remove(auxkey);
                    }
                }
                update invoiceNumberLstToUpdate;
            }
        } 
    }


    private void setInvoiceNumberBeforeUpdate(List<Invoice__c> invoiceLstNew, List<Invoice__c> invoiceLstOld){
        Boolean isActive = true;
        InvoiceTrigger__c config = InvoiceTrigger__c.getInstance();
        if(config != null){
            isActive = config.SetInvoiceNumber__c;
        }

        if (isActive){
            List<Invoice__c> invoiceLstCompleted = new List<Invoice__c>();
            Map<string,List<Invoice__c>> invoiceMapLst = new Map<string,List<Invoice__c>>();
            
            for (Integer i = 0; i < invoiceLstNew.size(); i++) {
                if (invoiceLstNew[i].Status__c != invoiceLstOld[i].Status__c && invoiceLstNew[i].Status__c	== 'Completed') {
                    invoiceLstCompleted.add(invoiceLstNew[i]);
                }
            }
            if(!invoiceLstCompleted.isEmpty()){
                Set<String> yearList = new Set<String>();
                Set<String> tipoLst = new Set<String>();
                for (Invoice__c invoice : invoiceLstCompleted) {
                    yearList.add(String.valueOf(invoice.InvoiceDate__c.year()));
                    tipoLst.add(invoice.Type__c);
                }
                List<CC_Invoice_Number__c> invoiceNumberLst = [SELECT id, Next_Invoice_Number__c, Type__c, Year__c FROM CC_Invoice_Number__c WHERE Year__c IN :yearList AND Type__c IN :tipoLst];
                Map<String,CC_Invoice_Number__c> invoiceNumberMap = new Map<String,CC_Invoice_Number__c>();
                for (CC_Invoice_Number__c invoiceNumber : invoiceNumberLst) {
                    invoiceNumberMap.put(invoiceNumber.Type__c+'__'+invoiceNumber.Year__c, invoiceNumber);
                }

                for (Invoice__c invoice : invoiceLstCompleted) {
                    String auxKey = invoice.Type__c+'__'+invoice.InvoiceDate__c.year();
                    if(invoiceMapLst.containsKey(auxKey)){
                        List<Invoice__c> invoiceLstAux = invoiceMapLst.get(auxKey);
                        invoiceLstAux.add(invoice);
                        invoiceMapLst.put(auxKey,invoiceLstAux);
                    }else{
                        List<Invoice__c> invoiceLstAux = new List<Invoice__c>();
                        invoiceLstAux.add(invoice);
                        invoiceMapLst.put(auxKey,invoiceLstAux);
                    } 
                }
                //Se comprueba que existan los invoiceNumber de los tipos y fechas que entran, si no existen se crean.
                List<CC_Invoice_Number__c> invoiceNumberInsert = new List<CC_Invoice_Number__c>();
                for (String auxKey : invoiceMapLst.keySet()) {
                    CC_Invoice_Number__c invoiceNumber = invoiceNumberMap.get(auxKey);
                    if(invoiceNumber == null){
                        Invoice__c inv = invoiceMapLst.get(auxKey)[0];
                        CC_Invoice_Number__c newInvoiceNumber = new CC_Invoice_Number__c();
                        newInvoiceNumber.Name = 'Invoice_Number_'+inv.Type__c;
                        newInvoiceNumber.Type__c = inv.Type__c;
                        newInvoiceNumber.Year__c =String.valueOf(inv.InvoiceDate__c.year());
                        newInvoiceNumber.Next_Invoice_Number__c = 1;
                        invoiceNumberInsert.add(newInvoiceNumber);
                        invoiceNumberMap.put(inv.Type__c+'__'+inv.InvoiceDate__c.year(), newInvoiceNumber);
                    }
                }
                insert invoiceNumberInsert;

                List<CC_Invoice_Number__c> invoiceNumberLstToUpdate = new List<CC_Invoice_Number__c>();
                for (String auxKey : invoiceMapLst.keySet()) {
                    CC_Invoice_Number__c invoiceNumb = invoiceNumberMap.get(auxKey);
                    if(invoiceNumb != null){
                        Decimal nextNumber = invoiceNumb.Next_Invoice_Number__c;
                        for (Invoice__c inv : invoiceMapLst.get(auxKey)) {
                            inv.Invoice_Number__c = inv.Type__c+' - '+inv.InvoiceDate__c.year()+' - '+inv.InvoiceDate__c.month()+' - '+String.valueOf(nextNumber).leftPad(4, '0');
                            nextNumber++;
                        }
                        invoiceNumb.Next_Invoice_Number__c = nextNumber;
                        invoiceNumberLstToUpdate.add(invoiceNumb);
                        invoiceMapLst.remove(auxkey);
                    }
                }
                update invoiceNumberLstToUpdate;
            }
        }
    }

    /*private void setBillingAddress(List<Invoice__c> invoiceLstNew){
        Boolean isActive = true;
        InvoiceTrigger__c config = InvoiceTrigger__c.getInstance();
        if(config != null){
            isActive = config.SetBillingAddress__c;
        }

        if (isActive){
            for (Invoice__c inv : invoiceLstNew) {
                
            }
        }
    }*/
}