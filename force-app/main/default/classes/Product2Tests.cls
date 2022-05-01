@isTest
private class Product2Tests {

    @TestSetup
    static void setupTestData(){
        TestDataFactory.InsertTestData(1);
    }

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    static TestMethod void Product2Extension_UnitTest(){
        Test.setCurrentPage(Page.Product2New);

        Test.startTest();
            Product2Extension ext = new Product2Extension(new ApexPages.standardController(new Product2()));

            System.assertEquals(Constants.DEFAULT_ROWS, ext.productsToInsert.size());
            
            ext.addRows();

            System.assertEquals(Constants.DEFAULT_ROWS * 2, ext.productsToInsert.size());

            ext.productsToInsert.get(0).productRecord.Name = 'Method test';
            ext.productsToInsert.get(0).productRecord.Family = Constants.PRODUCT_FAMILY.get(0).getValue();
            ext.productsToInsert.get(0).productRecord.Initial_Inventory__c = 10;
            ext.productsToInsert.get(0).productRecord.IsActive = true;
            ext.productsToInsert.get(0).pricebookEntryRecord.UnitPrice = 5;

            ext.save();

            System.assertEquals(Constants.PRODUCT_FAMILY.size() + 1, ext.GetFamilyOptions().size());

            System.assertNotEquals(0, ext.GetInventory().size());
        Test.stopTest();

        try{

            Product2 productData = 
                [SELECT Id
                , Name
                FROM Product2
                WHERE Name = 'Method test'
                    AND IsActive = true
                    AND Initial_Inventory__c = 10];

            PricebookEntry pricebookEntryData = 
                [SELECT Id
                FROM PricebookEntry
                WHERE Product2Id =: productData.Id
                    AND UnitPrice = 5];

            System.assert(true);
        }catch(Exception e){
            System.assert(false, e.getMessage());
        }
    }

    public static testMethod void Product2Trigger_UnitTest(){
        Product2 productData = 
            [SELECT Id
                , Quantity_Remaining__c
                , Quantity_Ordered__c
            FROM Product2
            WHERE Name = 'Product Test 0'];

        productData.Quantity_Ordered__c = 100;

        Test.startTest();

        update productData;

        Test.stopTest();
    }

}