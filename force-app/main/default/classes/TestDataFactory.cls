/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/
public with sharing class TestDataFactory {

    /**
     * @name ConstructCollaborationGroup
     * @description
    **/
    public static CollaborationGroup ConstructCollaborationGroup(){
        CollaborationGroup groupToReturn = new CollaborationGroup();
        groupToReturn.Name = 'TEST'+ Constants.INVENTORY_ANNOUNCEMENTS;
        groupToReturn.CollaborationType = 'Public';
        return groupToReturn;
    }

    /**
     * @name CreateProducts
     * @description Constructs a list of Product2 records for unit tests
    **/
    public static List<Product2> ConstructProducts(Integer cnt){
        List<Product2> listToReturn = new List<Product2>();

        Integer familyIndex = 0;

        for(Integer i  = 0; i < cnt; i ++){
            Product2 productToAdd = new Product2();
            productToAdd.Name = 'Product Test '+ i;
            productToAdd.IsActive = true;
            productToAdd.Initial_inventory__c = 10;
            productToAdd.Family = Constants.PRODUCT_FAMILY.get(familyIndex).getValue();
            listToReturn.add(productToAdd);

            familyIndex ++;

            if(familyIndex >= Constants.PRODUCT_FAMILY.size()) familyIndex = 0;
        }

        return listToReturn;
    }

    /**
     * @name CreatePricebookEntries
     * @description Constructs a list of PricebookEntry records for unit tests
    **/
    public static List<PricebookEntry> ConstructPricebookEntries(List<Product2> prods){
        List<PricebookEntry> listToReturn = new List<PricebookEntry>();

        for(Product2 forProduct : prods){
            PricebookEntry pricebookEntryToAdd = new PricebookEntry();
            pricebookEntryToAdd.Product2Id = forProduct.Id;
            pricebookEntryToAdd.IsActive = true;
            pricebookEntryToAdd.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            pricebookEntryToAdd.UnitPrice = Math.random() * 30;
            listToReturn.add(pricebookEntryToAdd);
        }

        return listToReturn;
    }

    /**
     * @name CreateAccounts
     * @description Constructs a list of Account records for unit tests
    **/
    public static List<Account> ConstructAccounts(Integer cnt){
        List<Account> listToReturn = new List<Account>();

        for(Integer i = 0; i < cnt; i ++){
            Account accountToAdd = new Account();
            accountToAdd.Name = 'Account Test '+ i;
            listToReturn.add(accountToAdd);
        }

        return listToReturn;
    }

    /**
     * @name CreateContacts
     * @description Constructs a list of Contacxt records for unit tests
    **/
    public static List<Contact> ConstructContacts(Integer cnt, List<Account> accts){
        List<Contact> listToReturn = new List<Contact>();

        Integer contactIndex = 0;

        for(Integer i = 0; i < cnt; i ++){
            Contact contactToAdd = new Contact();
            contactToAdd.FirstName = 'Contact';
            contactToAdd.LastName = 'Test '+ contactIndex;
            contactToAdd.AccountId = accts.get(i).Id;
            listToReturn.add(contactToAdd);

            contactIndex ++;
        }

        return listToReturn;
    }

    /**
     * @name CreateOrders
     * @description Constructs a list of Order records for unit tests
    **/
    public static List<Order> ConstructOrders(Integer cnt, List<Account> accts){
        List<Order> listToReturn = new List<Order>();

        for(Integer i = 0; i < cnt; i ++){
            Order orderToAdd = new Order();
            orderToAdd.AccountId = accts.get(i).Id;
            orderToAdd.Status= Constants.DRAFT_ORDER_STATUS;
            orderToAdd.EffectiveDate = System.today().addDays(10);
            orderToAdd.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            listToReturn.add(orderToAdd);
        }

        return listToReturn;
    }

    /**
     * @name CreateOrderItems
     * @description Constructs a list of OrderItem records for unit tests
    **/
    public static List<OrderItem> ConstructOrderItems(integer cnt, list<pricebookentry> pbes, list<order> ords){
        List<OrderItem> listToReturn = new List<OrderItem>();

        for(Integer i = 0; i < cnt; i ++){
            OrderItem orderItemToAdd = new OrderItem();
            orderItemToAdd.OrderId = ords.get(i).Id;
            orderItemToAdd.PricebookEntryId = pbes.get(i).Id;
            orderItemToAdd.UnitPrice = pbes.get(i).UnitPrice;
            orderItemToAdd.Quantity = Constants.DEFAULT_ROWS;
            listToReturn.add(orderItemToAdd);
        }

        return listToReturn;
    }

    /**
     * @name SetupTestData
     * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
    **/
    public static void InsertTestData(Integer cnt){
        List<Product2> listProduct = ConstructProducts(cnt);
        insert listProduct;

        List<PricebookEntry> listPricebookEntry = ConstructPricebookEntries(listProduct);
        insert listPricebookEntry;

        List<Account> listAccount = ConstructAccounts(cnt);
        insert listAccount;

        List<Contact> listContact = ConstructContacts(cnt, listAccount);
        insert listContact;

        List<Order> listOrder = ConstructOrders(cnt, listAccount);
        insert listOrder;

        List<OrderItem> listOrderItem = ConstructOrderItems(cnt, listPricebookEntry, listOrder);
        insert listOrderItem;
    }

}