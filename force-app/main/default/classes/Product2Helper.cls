public class Product2Helper {

    /**
     * @name COLLABORATION_GROUP
     * @description List of CollaborationGroup used in both business and test logic
    **/
    static List<CollaborationGroup> COLLABORATION_GROUP = [
        SELECT Id
        FROM CollaborationGroup
        WHERE Name = 'group name'
        OR Name = :('TEST'+Constants.INVENTORY_ANNOUNCEMENTS)
        LIMIT 1
    ];

    /**
     * @name afterUpdate
     * @description called by product2 Trigger on After Update
     * @param List<Product2> newList
     * @param List<Product2> oldList
    **/
    public static void AfterUpdate(List<Product2> newList, List<Product2> oldList){
        List<Product2> needsAnnouncement = new List<Product2>();

        Map<String, Inventory_Setting__mdt> mapInventory = Inventory_Setting__mdt.getAll();

        for(Integer i = 0; i < newList.size(); i ++){
            if(newList.get(i).Quantity_Remaining__c != oldList.get(i).Quantity_Remaining__c
            && newList.get(i).Quantity_Remaining__c < mapInventory.get(newList.get(i).Family).Low_Quantity_Alert__c){
                needsAnnouncement.add(newList.get(i));
            }
        }

        PostAlerts(needsAnnouncement);
    }

    /**
     * @name postAlerts
     * @description called by product2 Trigger on After Update
     * @param List<Product2> productList
    **/
    public static void PostAlerts(List<Product2> productList){
        List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();
        for ( Product2 p : productList ){
            ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = p.Name + Constants.INVENTORY_LEVEL_LOW;

            ConnectApi.MessageBodyInput bodyInput = new ConnectApi.MessageBodyInput();
            bodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            bodyInput.messageSegments.add(textSegment);

            ConnectApi.AnnouncementInput inputToAdd = new ConnectApi.AnnouncementInput();
            inputToAdd.expirationDate = System.now().addDays(1);
            inputToAdd.sendEmails = false;
            inputToAdd.body = bodyInput;
            toPost.add(inputToAdd);
        }

        AnnouncementQueueable queueableClass = new AnnouncementQueueable();
        queueableClass.toPost = toPost;

        System.enqueueJob(queueableClass);
    }
}