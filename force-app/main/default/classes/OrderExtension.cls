/**
 * @name OrderExtension
 * @description This class is provided for you to facilitate the Super Badge
**/
public class OrderExtension {

    public Order orderRecord {get;set;}
    public List<OrderItem> orderItemList {get;set;}
    public String selectedFamily {get;set;}
    public List<chartHelper.chartData> pieData {get;set;}
    public Decimal total {get;set;}

    public Map<Id,OrderItem> orderItemMap;
    ApexPages.StandardSetController standardSetController;

    public OrderExtension(ApexPages.StandardController standardController){
        orderRecord = (Order) standardController.getRecord();

        selectedFamily = Constants.SELECT_ONE;

        orderItemMap = new Map<Id, OrderItem>();
        
        updateOrderData();
    }
    
    public void updateOrderData(){
        if(orderRecord.Id == null){
            orderRecord = new Order();
            orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
        }else{
            orderRecord = queryOrderRecord(orderRecord.Id);

            orderItemList = orderRecord.OrderItems;
            
            for(OrderItem forOrderItem : orderItemList){
                orderItemMap.put(forOrderItem.Product2Id, forOrderItem);
            }
        }

        getQueryOrderItems();
    }

    public void getQueryOrderItems(){
        String query =
            'SELECT Id '+
                ' , Name '+
                ' , Product2.Family '+
                ' , Product2.Name '+
                ' , Product2.Quantity_Remaining__c  '+
                ' , Product2Id '+
                ' , UnitPrice '+
            ' FROM PricebookEntry '+
            ' WHERE IsActive = true ';
            
        if(String.isNotEmpty(selectedFamily) && selectedFamily != Constants.SELECT_ONE){
            query += ' AND Product2.Family =: selectedFamily ';
        }

        standardSetController = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        
        standardSetController.setPageSize(Constants.DEFAULT_ROWS);

        createOrderItems();
    }

    public void createOrderItems(){
        orderItemList = new List<OrderItem>();

        for(sObject forSObject : standardSetController.getRecords()){
            PricebookEntry pricebookEntryData = (PricebookEntry) forSObject;

            OrderItem orderItemToAdd;

            if(orderItemMap.containsKey(pricebookEntryData.Product2Id)){
                orderItemToAdd = orderItemMap.get(pricebookEntryData.Product2Id);
            }else{
                orderItemToAdd = new OrderItem();
                orderItemToAdd.PricebookEntryId = pricebookEntryData.Id;
                orderItemToAdd.Product2 = pricebookEntryData.Product2;
                orderItemToAdd.Product2Id = pricebookEntryData.Product2Id;
                orderItemToAdd.Quantity = 0;
                orderItemToAdd.UnitPrice = pricebookEntryData.UnitPrice;
            }
            
            orderItemList.add(orderItemToAdd);
            orderItemMap.put(pricebookEntryData.Product2Id, orderItemToAdd);
        }

        OnFieldChange();
    }
    
    /**
     * @name OnFieldChange
     * @description
    **/
    public void OnFieldChange(){
        total = 0;
        pieData = new List<ChartHelper.ChartData>();

        for(OrderItem forOrderItem : orderItemMap.values()){
            pieData.add(new ChartHelper.ChartData(forOrderItem.Product2.Name, forOrderItem.Quantity * forOrderItem.UnitPrice));
            total += forOrderItem.Quantity * forOrderItem.UnitPrice;
        }
    }

    /**
     * @name SelectFamily
     * @description
    **/
    public void SelectFamily(){
        getQueryOrderItems();
    }

    /**
     * @name Save
     * @description
    **/
    public void Save(){
        Savepoint sp = Database.setSavepoint();

        try{
            upsert orderRecord;
        }catch(Exception e){
            System.debug(e.getMessage());

            Database.rollback(sp);
        }

        List<OrderItem> listOrderItemToUpdate = new List<OrderItem>();
        List<OrderItem> listOrderItemToDelete = new List<OrderItem>();

        for(OrderItem forOrderItem : orderItemList){
            if(forOrderItem.Quantity > 0){
                if(forOrderItem.OrderId == null) forOrderItem.OrderId = orderRecord.Id;

                listOrderItemToUpdate.add(forOrderItem);
            }else if(forOrderItem.Id != null){
                listOrderItemToDelete.add(forOrderItem);
            }
        }

        try{
            upsert listOrderItemToUpdate;
            delete listOrderItemToDelete;
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
        standardSetController.first();
        
        createOrderItems();
    }


    /**
     * @name Next
     * @description
    **/
    public void Next(){
        standardSetController.next();
        
        createOrderItems();
    }


    /**
     * @name Previous
     * @description
    **/
    public void Previous(){
        standardSetController.previous();
        
        createOrderItems();
    }

    /**
     * @name Last
     * @description
    **/
    public void Last(){
        standardSetController.last();
        
        createOrderItems();
    }

    /**
     * @name GetHasPrevious
     * @description
    **/
    public Boolean GetHasPrevious(){
        return standardSetController.getHasPrevious();
    }

    /**
     * @name GetHasNext
     * @description
    **/
    public Boolean GetHasNext(){
        return standardSetController.getHasNext();
    }

    /**
     * @name GetTotalPages
     * @description
    **/
    public Integer GetTotalPages(){
        return (Integer) Math.ceil((Decimal) standardSetController.getResultSize() / (Decimal) Constants.DEFAULT_ROWS);
    }

    /**
     * @name GetPageNumber
     * @description
    **/
    public Integer GetPageNumber(){
        return standardSetController.getPageNumber();
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
    public static Order QueryOrderRecord(Id orderId){
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
                (
                    SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
                         Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                    FROM OrderItems
                )
            FROM Order
            WHERE Id = :orderId
        ];
    }

}