@Istest
public with sharing class Order_ProductCalculationDates_test {
    

    Public static testmethod void ProductCalculationDates1(){
        Test.startTest();
           List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
   
           Set<String> Set_AccId = new Set<String>();
           for(Account acc:lstAccount){
               Set_AccId.add(acc.id);
           }
   
           AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];
   
           Map<String,String> Map_AccSub = new Map<String,String>();
           Integer i=0;
           for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
               sub.NetsuiteInternalId__c = '88776'+i;
               Map_AccSub.put(sub.Account__c,sub.id);
               i++;
           }
   
           update lstAccountSubsidiary;
   
           List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);

           for(Product2 prod:lstProduct){

                prod.FreeFromDate__c = system.today() - 50;
                prod.FixedStartDate__c = system.today() - 55;
            }
            update lstProduct;

           Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
           List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
           List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
           List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);
           List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
   
           List<Id> OrderId = new List<Id>();

           for(Order item:lstOrder){
                OrderId.add(item.id);
           }
           
           lstOrderItems = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);  
           Order_ProductCalculationDates.ProductCalculationDates(lstOrderItems);
   
         
           Test.stopTest();
           
       }


       Public static testmethod void ProductCalculationDates2(){
        Test.startTest();
           List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
   
           Set<String> Set_AccId = new Set<String>();
           for(Account acc:lstAccount){
               Set_AccId.add(acc.id);
           }
   
           AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];
   
           Map<String,String> Map_AccSub = new Map<String,String>();
           Integer i=0;
           for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
               sub.NetsuiteInternalId__c = '88776'+i;
               Map_AccSub.put(sub.Account__c,sub.id);
               i++;
           }
   
           update lstAccountSubsidiary;
   
           List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);

           for(Product2 prod:lstProduct){
                prod.FreeFromDate__c = prod.FixedStartDate__c-5;
           }
           update lstProduct;

           Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
           List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
           List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
           List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);
           List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
   
           List<Id> OrderId = new List<Id>();

           for(Order item:lstOrder){
                OrderId.add(item.id);
           }
           
           lstOrderItems = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);  
   
           Order_ProductCalculationDates.ProductCalculationDates(lstOrderItems);
   
         
           Test.stopTest();
           
       }

       Public static testmethod void ProductCalculationDates3(){
        Test.startTest();
           List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
   
           Set<String> Set_AccId = new Set<String>();
           for(Account acc:lstAccount){
               Set_AccId.add(acc.id);
           }
   
           AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];
   
           Map<String,String> Map_AccSub = new Map<String,String>();
           Integer i=0;
           for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
               sub.NetsuiteInternalId__c = '88776'+i;
               Map_AccSub.put(sub.Account__c,sub.id);
               i++;
           }
   
           update lstAccountSubsidiary;
   
           List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);

           

           for(Product2 prod:lstProduct){
                prod.FixedStartDate__c = null;
           }
           update lstProduct;

           Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
           List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
           List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
           List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);
           List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
   
           List<Id> OrderId = new List<Id>();

           for(Order item:lstOrder){
                OrderId.add(item.id);
           }
           
           lstOrderItems = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);  
   
           Order_ProductCalculationDates.ProductCalculationDates(lstOrderItems);
   
         
           Test.stopTest();
           
       }



}