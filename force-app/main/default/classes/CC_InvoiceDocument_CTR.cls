/**
 * @File Name          : CC_InvoiceDocument_CTR.cls
 * @Description        : 
 * @Author             : IHU - ihernando@cloudcoachers.com
 * @Group              : 
 * @Last Modified By   : IHU - ihernando@cloudcoachers.com
 * @Last Modified On   : 07-03-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/27/2020   TXU - jmurdiain@cloudcoachers.com     Initial Version
**/
public with sharing class CC_InvoiceDocument_CTR {
    public Id idInvoice;
    public Invoice__c invoice{get;set;}
    public Organization cloudCoachers{get; private set;}
    public CC_CifAndWeb__c ccData {get;private set;}
    public Boolean showDiscount {get; private set;}
    public List<InvoiceLine__c> ivaLst{get; private set;}
    public List<TotalTaxes> lstTaxes{get; private set;}
    

    public void setIdInvoice(Id idsf){
        Map<String,TotalTaxes> mapTaxes = new Map<String,TotalTaxes>();
        this.idInvoice = idsf;
        this.invoice = [SELECT Withholding__c,(SELECT id, UnitPrice__c, TaxAmount__c, DiscountType__c,DiscountAmount__c, Name,ProductId__r.Name, Quantity__c,Discount__c,Tax__c,NetAmount__c, TotalAmount__c,TotalPrice__c, Description__c, Description_Rich__c FROM Invoice_Lines__r), BankAccountId__r.Bank_Name__c, BankAccountId__r.IBAN__c, BankAccountId__r.Owner__c, BankAccountId__r.Swift__c, id,Total_Price__c,Name,Notes__c, Invoice_Number__c,InvoiceDate__c,DiscountAmount__c,NetAmount__c, TaxAmount__c,TotalAmount__c , AccountId__c,Status__c,DueDate__c, VATNumber__c, BillingStreet__c, BillingState__c, BillingPostalCode__c, BillingCountry__c, AccountId__r.Business_Name__c, NetAmountWithoutWithholding__c, WithholdingAmount__c FROM Invoice__c WHERE id = :idInvoice];
        
        cloudCoachers =[SELECT id, Name, Street, state, PostalCode, Country FROM Organization];
        
        ccData = CC_CifAndWeb__c.getInstance();

        if(this.invoice.DiscountAmount__c > 0){
            this.showDiscount = true;
        }else{
            this.showDiscount = false;
        }
        for (InvoiceLine__c invo : this.invoice.Invoice_Lines__r) {
            if(invo.Tax__c != '0' && invo.Tax__c != null){
                if (mapTaxes.containsKey(invo.Tax__c)){
                    mapTaxes.put(invo.Tax__c, new TotalTaxes(mapTaxes.get(invo.Tax__c).tax,mapTaxes.get(invo.Tax__c).amount+invo.TaxAmount__c));
                }else{
                    TotalTaxes totTaxes = new TotalTaxes(invo.Tax__c,invo.TaxAmount__c);
                    mapTaxes.put(invo.Tax__c,totTaxes);
                }
            }
        }

        this.lstTaxes = mapTaxes.values();
        System.debug(lstTaxes);
    }
    public Id getIdInvoice(){
        return this.idInvoice;
    }

    private class TotalTaxes {
        public String tax;
        public Decimal amount = 0 ;
        public TotalTaxes (String tax, Decimal amount){
            this.tax = tax;
            this.amount = amount;
        }
        public String getTax(){
            return this.tax;
        }
        public Decimal getAmount(){
            return this.amount;
        }
    }
}