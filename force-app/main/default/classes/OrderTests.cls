@isTest
private class OrderTests {

    @TestSetup
    static void setupTestData(){
        TestDataFactory.InsertTestData(1);
    }

    public static testMethod void OrderUpdate_UnitTest(){
        Order orderData =
            [SELECT Id
            FROM Order
            LIMIT 1];

        orderData.Status = Constants.ACTIVATED_ORDER_STATUS;

        OrderItem orderItemData = 
            [SELECT Id
                , Quantity
                , PricebookEntry.Product2Id
            FROM OrderItem
            WHERE OrderId =: orderData.Id
            LIMIT 1];

        Product2 productDataOld = getProduct(orderItemData.PricebookEntry.Product2Id);
        
        Test.startTest();
        
        update orderData;
        
        Test.stopTest();
        
        Product2 productDataNew = getProduct(orderItemData.PricebookEntry.Product2Id);

        TestDataFactory.VerifyQuantityOrdered(productDataOld, productDataNew, Integer.valueOf(orderItemData.Quantity));
    }

    private static Product2 getProduct(Id pId){
        return
            [SELECT Id
                , Quantity_ordered__c
            FROM Product2
            WHERE Id =: pId];
    }

}