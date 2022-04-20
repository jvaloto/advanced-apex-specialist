public class ProductWrapper{
    
    public Product2 productRecord {get; set;}
    public PricebookEntry pricebookEntryRecord {get; set;}

    public ProductWrapper(){
        productRecord = new Product2();
        pricebookEntryRecord = new PricebookEntry();
    }

}