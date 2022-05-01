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

    public static testMethod void OrderExtension_UnitTest(){
        Test.setCurrentPage(Page.OrderEdit);

        Test.startTest();

        OrderExtension orderExtension = new OrderExtension(new ApexPages.standardController(new Order()));

        System.assertEquals(1, orderExtension.orderItemList.size());

        orderExtension.SelectFamily();
        orderExtension.First();
        orderExtension.Next();
        orderExtension.Previous();
        orderExtension.Last();
        orderExtension.GetHasPrevious();
        orderExtension.GetHasNext();
        orderExtension.GetTotalPages();
        orderExtension.GetPageNumber();
        orderExtension.GetFamilyOptions();

        orderExtension.orderItemList.get(0).Quantity = 2;
        orderExtension.orderItemList.get(0).UnitPrice = 5;

        orderExtension.save();

        Test.stopTest();
    }

    private static Product2 getProduct(Id pId){
        return
            [SELECT Id
                , Quantity_ordered__c
            FROM Product2
            WHERE Id =: pId];
    }

}