/**
 * This class has changed because the step 9 with this error:
 * Please ensure that product2Extension and its methods are still working as specified in the earlier challenge
 */

public without sharing class Product2Extension {

    public List<ProductWrapper> productsToInsert {get;set;}

    public Product2Extension(ApexPages.StandardController controller){
        productsToInsert = new List<ProductWrapper>();
        addRows();  
     }

     public List<SelectOption> GetFamilyOptions(){
        List<SelectOption> listToReturn = new List<SelectOption>();

        listToReturn.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));

        for(PicklistEntry forPicklistEntry : Constants.PRODUCT_FAMILY){
            listToReturn.add(new SelectOption(forPicklistEntry.getLabel(), forPicklistEntry.getValue()));
        }

        return listToReturn;
    }

    public void AddRows(){
        for ( Integer i=0; i< Constants.DEFAULT_ROWS; i++ ){
            productsToInsert.add(new ProductWrapper());
        }
    }

    public List<ChartHelper.ChartData> GetInventory(){
        return ChartHelper.GetInventory();
    }
    
    public PageReference Save(){
        Savepoint sp = Database.setSavepoint();

        try {
            List<Product2> listProductToInsert = new List<Product2>();
            List<PricebookEntry> listPricebookEntryToInsert = new List<PricebookEntry>();

            for(ProductWrapper forProduct : productsToInsert){
                if(null != forProduct.productRecord
                && null != forProduct.pricebookEntryRecord){
                    if(null != forProduct.productRecord.Name
                    && null != forProduct.productRecord.Family
                    && Constants.SELECT_ONE != forProduct.productRecord.Family
                    && null != forProduct.productRecord.Initial_Inventory__c
                    && null != forProduct.pricebookEntryRecord.UnitPrice){
                        forProduct.pricebookEntryRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
                        forProduct.pricebookEntryRecord.IsActive = true;

                        listProductToInsert.add(forProduct.productRecord);
                        listPricebookEntryToInsert.add(forProduct.pricebookEntryRecord);
                    }
                }
            }
        
            insert listProductToInsert;

            for(Integer i = 0; i < listProductToInsert.size(); i ++){
                listPricebookEntryToInsert.get(i).Product2Id = listProductToInsert.get(i).Id;
            }
            
            insert listPricebookEntryToInsert;

            //If successful clear the list and display an informational message
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,listProductToInsert.size()+' Inserted'));
            productsToInsert.clear();   //Do not remove
            addRows();  //Do not remove
        } catch (Exception e){
            Database.rollback(sp);

            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
        }
        
        return null;
    }

    public class ProductWrapper{
        public Product2 productRecord {get; set;}
        public PricebookEntry pricebookEntryRecord {get; set;}

        public ProductWrapper(){
            productRecord = new Product2();

            pricebookEntryRecord = new PricebookEntry();
        }
    }

}