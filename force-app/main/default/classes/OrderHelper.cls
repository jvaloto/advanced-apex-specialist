public class OrderHelper {

    /**
     * @name AfterUpdate
     * @description 
     * @param List<Order> newList
     * @param List<Order> oldList
     * @return void
    **/
    public static void AfterUpdate(List<Order> newList, List<Order> oldList){
        Set<Id> setIdOrderToFilter = new Set<Id>();

        for(Integer i = 0; i < newList.size(); i ++){
            if(newList[i].Status == Constants.ACTIVATED_ORDER_STATUS && newList[i].Status != oldList[i].Status){
                setIdOrderToFilter.add(newList[i].Id);
            }
            // if(newList[i].ActivatedDate != null && newList[i].ActivatedDate != oldList[i].ActivatedDate){
            //     setIdOrderToFilter.add(newList[i].Id);
            // }
        }

        RollUpOrderItems(setIdOrderToFilter);
    }

    /**
     * @name RollUpOrderItems
     * @description Given a set of Activated Order ids, query the child Order Items and related Products to calculate Inventory levels
     * @param Set<Id> activatedOrderIds
     * @return void
    **/
    public static void RollUpOrderItems(Set<Id> activatedOrderIds){
        //ToDo: Declare a Map named "productMap" of Ids to Product2 records

        //ToDo: Loop through a query of OrderItems related to the activatedOrderIds

            //ToDo: Populate the map with the Id of the related Product2 as the key and Product2 record as the value

        //ToDo: Loop through a query that aggregates the OrderItems related to the Products in the ProductMap keyset

        //ToDo: Perform an update on the records in the productMap



        if(!activatedOrderIds.isEmpty()){
            Set<Id> setIdProductToFilter = new Set<Id>();
            List<Product2> listProductToUpdate = new List<Product2>();

            for(OrderItem forOrderItem : 
                [SELECT Product2Id
                FROM OrderItem
                WHERE OrderId IN: activatedOrderIds]){
                setIdProductToFilter.add(forOrderItem.Product2Id);
            }

            for(AggregateResult forAggregate : 
                [SELECT Product2Id productId
                    , SUM(Quantity) quantity
                FROM OrderItem
                WHERE Product2Id IN: setIdProductToFilter
                GROUP BY Product2Id]){
                Product2 productToAdd = new Product2();
                productToAdd.Id = (Id) forAggregate.get('productId');
                productToAdd.Quantity_Ordered__c = (Decimal) forAggregate.get('quantity');

                listProductToUpdate.add(productToAdd);
            }

            update listProductToUpdate;
        }
    }

}