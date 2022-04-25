/**
 * @name OrderExtension
 * @description This class is provided for you to facilitate the Super Badge
**/
public class OrderExtension {

    public Id orderId;
    public Order orderRecord {get;set;}
    public List<OrderItem> orderItemList {get;set;}
    public String selectedFamily {get;set;}
    public List<chartHelper.chartData> pieData {get;set;}
    public Decimal total {get;set;}

    public Map<Id,OrderItem> orderItemMap;
    ApexPages.StandardSetController standardSetController;

    public OrderExtension(ApexPages.StandardController standardController){
        orderId = standardController.getId();

        updateOrderData();
    }

    private void updateOrderData(){
        orderRecord = queryOrderRecord(orderId, selectedFamily);
        orderItemList = orderRecord.OrderItems;

        OnFieldChange();
    }
    
    /**
     * @name OnFieldChange
     * @description
    **/
    public void OnFieldChange(){
        total = 0;

        Map<String, Decimal> mapTotal = new Map<String, Decimal>();

        for(OrderItem forOrderItem : orderItemList){
            String groupBy = forOrderItem.Product2.Name;
            Decimal totalItem = forOrderItem.Quantity * forOrderItem.UnitPrice;

            total += totalItem;

            if(mapTotal.containsKey(groupBy)){
                mapTotal.put(groupBy, mapTotal.get(groupBy) + totalItem);
            }else{
                mapTotal.put(groupBy, 0);
            }
        }

        pieData = new List<ChartHelper.ChartData>();

        for(String forString : mapTotal.keySet()){
            pieData.add(new ChartHelper.ChartData(forString, mapTotal.get(forString)));
        }
    }

    /**
     * @name SelectFamily
     * @description
    **/
    public void SelectFamily(){
        updateOrderData();
    }

    /**
     * @name Save
     * @description
    **/
    public void Save(){
        Savepoint sp = Database.setSavepoint();

        List<OrderItem> listOrderItemToUpdate = new List<OrderItem>();

        for(OrderItem forOrderItem : orderItemList){
            if(forOrderItem.Quantity > 0){
                listOrderItemToUpdate.add(forOrderItem);
            }
        }

        try{
            update listOrderItemToUpdate;
        }catch(Exception e){
            System.debug(e.getMessage());

            Database.rollback(sp);
        }
    }


    /**
     * @name First
     * @description
    **/
    public void First(){

    }


    /**
     * @name Next
     * @description
    **/
    public void Next(){

    }


    /**
     * @name Previous
     * @description
    **/
    public void Previous(){

    }

    /**
     * @name Last
     * @description
    **/
    public void Last(){

    }

    /**
     * @name GetHasPrevious
     * @description
    **/
    public Boolean GetHasPrevious(){
        return null;
    }

    /**
     * @name GetHasNext
     * @description
    **/
    public Boolean GetHasNext(){
        return null;
    }

    /**
     * @name GetTotalPages
     * @description
    **/
    public Integer GetTotalPages(){
        return null;
    }

    /**
     * @name GetPageNumber
     * @description
    **/
    public Integer GetPageNumber(){
        return null;
    }

    /**
     * @name GetFamilyOptions
     * @description
    **/
    public List<SelectOption> GetFamilyOptions(){
        List<SelectOption> listToReturn = new List<SelectOption>();

        listToReturn.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));

        for(PicklistEntry forPicklist : Constants.PRODUCT_FAMILY){
            listToReturn.add(new SelectOption(forPicklist.getLabel(), forPicklist.getValue()));
        }

        return listToReturn;
    }

    /**
     * @name QueryOrderRecord
     * @description
    **/
    public static Order QueryOrderRecord(Id orderId, String pFamily){
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
                (
                    SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
                         Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                    FROM OrderItems
                    WHERE Product2.Family =: pFamily
                )
            FROM Order
            WHERE Id = :orderId
        ];
    }

}