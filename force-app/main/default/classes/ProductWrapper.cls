public class ProductWrapper{
    
    public Product2 productRecord {get; set;}
    public PricebookEntry pricebookEntryRecord {get; set;}

    public ProductWrapper(){
        productRecord = new Product2();
        productRecord.Initial_Inventory__c = 0;

        pricebookEntryRecord = new PricebookEntry();
        pricebookEntryRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
        pricebookEntryRecord.IsActive = true;
        pricebookEntryRecord.UnitPrice = 0;
    }

}