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

        List<Product2> listProductToInsert = new List<Product2>();
        List<PricebookEntry> listPricebookEntryToInsert = new List<PricebookEntry>();

        for(ProductWrapper forProduct : productsToInsert){
            if(String.isNotBlank(forProduct.productRecord.Name)
            && String.isNotBlank(forProduct.productRecord.Family)
            && forProduct.productRecord.Family != Constants.SELECT_ONE
            && forProduct.productRecord.Initial_Inventory__c != null
            && forProduct.productRecord.Initial_Inventory__c > 0
            && forProduct.pricebookEntryRecord.UnitPrice != null
            && forProduct.pricebookEntryRecord.UnitPrice > 0
            && forProduct.productRecord.IsActive){
                listProductToInsert.add(forProduct.productRecord);
                listPricebookEntryToInsert.add(forProduct.pricebookEntryRecord);
            }
        }

        try {
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

}