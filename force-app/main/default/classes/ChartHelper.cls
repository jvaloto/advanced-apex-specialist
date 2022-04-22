public without sharing class ChartHelper {

    @AuraEnabled
    public static List<chartData> GetInventory(){
        List<chartData> cht = new List<chartData>();

        for(AggregateResult forAggregate : 
        [SELECT SUM(Quantity_remaining__c) quantity
            , Family name
        FROM Product2
        WHERE IsActive = true
        GROUP BY Family
        HAVING SUM(Quantity_remaining__c) > 0]){
            cht.add(new ChartData((String) forAggregate.get('name'), (Decimal) forAggregate.get('quantity')));
        }

        return cht;
    }

    public class ChartData {
        public String name {get;set;}
        public Decimal val {get;set;}

        public ChartData(String name, Decimal val){
            this.name = name;
            this.val = val;
        }
    }

}