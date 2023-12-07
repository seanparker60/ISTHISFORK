global with sharing class Order_BatchUpdateB2BOrders implements Database.Batchable<sObject>,Schedulable,Database.AllowsCallouts {
   

    global Database.QueryLocator start(Database.BatchableContext BC){  
        
        //Simpler to start with Orders than Assets renewed today to ensure that there is no split due to batch size
        Date CurrrentDay = system.today()-1;

        system.debug('**Order Created: 1');
      // return Database.getQueryLocator([SELECT Id,Billto__c,B2BJobRun__c,ActivateforBatchProcessing__c,Source__c  FROM Order where 	LineCount__c >:0 AND (((Source__c =:'B2B Invoice' OR Source__c =:'B2B Trade' OR Source__c =:'B2B Shop' OR Source__c =:'B2B DirectPayment') AND createddate >: CurrrentDay and Status !=: 'Activated') OR (Source__c =:'B2B Shop'  AND Status !=: 'Activated' AND (ValidationErrorsOrder__c >:0 OR ValidationErrorsOrderProducts__c >:0))) ]  );
    
      return Database.getQueryLocator([SELECT Id,Billto__c,TriggerBusinessRules__c,ActivateforBatchProcessing__c,Source__c  FROM Order where 	LineCount__c >:0 AND Type != 'RenewalOrder' AND createddate >: CurrrentDay and Status !=: 'Activated' AND (TriggerBusinessRules__c =:true OR (ValidationErrorsOrder__c >:0 OR ValidationErrorsOrderProducts__c >:0)) ]  );
    
    }
    
    global void execute(Database.BatchableContext BC, List<Order> scope){  
        
        List<Id> OrderId = new List<Id>();
        for(Order ord:Scope){
          //  ord.B2BJobRun__c = true;
         //   if(ord.Source__c !='B2B Shop'){
          //      ord.ActivateforBatchProcessing__c=true;
                
          //  }
            OrderId.add(ord.Id);
        }

        system.debug('**Order Created: 2'+OrderId.size());
        if(OrderId.size()>0){
            Order_B2BOrderInvocable.UpdateOrderItemsfuture (OrderId);
        }
        //update scope;
        

    }  

    global void finish(Database.BatchableContext BC){

      //OrderActivationRules__mdt OrderActivationRules

        Datetime NextStart =  Datetime.now().addMinutes(5);
        String hour = String.valueOf(NextStart.hour());
        String min = String.valueOf(NextStart.minute()); 
        String ss = String.valueOf(00);
   
        
   
        String dayT = String.valueOf(NextStart.day());
        String monthT = String.valueOf(NextStart.Month()); 
   
        
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + dayT +' '+  monthT+ ' ?';
   
           system.debug('***nextFireTime***'+nextFireTime);
       if(!Test.isRunningTest()){     
          Order_BatchOrderActivateAssetRenewal  orderActivate = new Order_BatchOrderActivateAssetRenewal();
          System.schedule('B2BActivateOrders: Started At ' + String.valueOf(Datetime.now()), nextFireTime, orderActivate);
        }
        
      //  Order_BatchOrderActivateAssetRenewal  orderActivate = new Order_BatchOrderActivateAssetRenewal();
      //  database.executebatch(orderActivate ,1);
    }
    global void execute(SchedulableContext sc)
    {
        Order_BatchUpdateB2BOrders  B2BOrders = new Order_BatchUpdateB2BOrders();
        database.executebatch(B2BOrders ,1);
    }




}