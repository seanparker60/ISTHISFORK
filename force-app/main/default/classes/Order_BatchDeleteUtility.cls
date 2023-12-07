global with sharing class Order_BatchDeleteUtility implements Database.Batchable<sObject>,Schedulable {
    global Order_BatchDeleteUtility() {

    }
    global Database.QueryLocator start(Database.BatchableContext BC){  
        
        return Database.getQueryLocator([SELECT Id,Billto__c,ActivateforBatchProcessing__c  FROM Order where ActivateforBatchProcessing__c =:true AND  Status !=: 'Activated']  ); // WHERE ACCOUNT HAS ACTIVE ASSET
    }
    
    global void execute(Database.BatchableContext BC, List<Order> scope){
       
               for(Order ord:scope){
                    ord.ActivateforBatchProcessing__c = false;
               }
               update scope;
       
    }
    global void finish(Database.BatchableContext BC){

    }
    
    global void execute(SchedulableContext sc)
    {
        Order_BatchDeleteUtility  DeleteUtility = new Order_BatchDeleteUtility();
        database.executebatch(DeleteUtility ,20);
    }

}