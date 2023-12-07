@Istest
public with sharing class Order_AssetsCreateOnOrderActivation_test {
    
    public static testmethod void AssetsCreateOnOrderActivation1 (){

        
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
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);

        /*
        List<Id> OrderId = new List<Id>();
        for(Order ord:lstOrder){
            OrderId.add(ord.id);
        }
         Order_AssetsCreateOnOrderActivation.processAssetsFromOrder(OrderId);
        */

        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=true;

        List<Id> lst_ItemId = new List<Id>();
        List<Id> Set_OrdId = new List<Id>();
        for(OrderItem item:lstOrderItems){
                lst_ItemId.add(item.id);
                Set_OrdId.add(item.Orderid);           
        }
                   
        //MAKE A QUEUEUABLE CALL
        Set<Id> Set_ItemId = new Set<Id>();
        Set_ItemId.addAll(lst_ItemId);
        Order_AssetsCreateOnOrderActivation.processAssetsFromOrder(lst_ItemId,Set_ItemId);
  
        test.stoptest();
  
  
     }

     public static testmethod void AssetsCreateOnOrderActivation2 (){

        
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
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);

        for(Order ord:lstOrder){
                ord.PricingMethod__c = 'OrderProductQuantity';
        }
        insert lstOrder;

        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
         
       
        
        List<Asset>lst_Asset = TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,false);

        for(Asset ass:lst_Asset){
            ass.PricingMethod__c = 'OrderProductQuantity';
        }

        Insert lst_Asset;

        /*
        List<Id> OrderId = new List<Id>();
        for(Order ord:lstOrder){
            OrderId.add(ord.id);
        }
         Order_AssetsCreateOnOrderActivation.processAssetsFromOrder(OrderId);
        */

        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=true;

        List<Id> lst_ItemId = new List<Id>();
        List<Id> Set_OrdId = new List<Id>();
        for(OrderItem item:lstOrderItems){
                lst_ItemId.add(item.id);
                Set_OrdId.add(item.Orderid);           
        }
                   
        //MAKE A QUEUEUABLE CALL
        Set<Id> Set_ItemId = new Set<Id>();
        Set_ItemId.addAll(lst_ItemId);
        Order_AssetsCreateOnOrderActivation.processAssetsFromOrder(lst_ItemId,Set_ItemId);
  
        test.stoptest();
  
  
     }

     public static testmethod void AssetsCreateOnOrderActivation3 (){

        
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
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);
        
        for(Order ord:lstOrder){
            ord.Type = 'RenewalOrder';
            ord.PricingMethod__c = 'OrderProductQuantity';
        }
        insert lstOrder;


        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
         
       
        
        List<Asset>lst_Asset = TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,false);
        for(Asset ass:lst_Asset){
            ass.PricingMethod__c = 'OrderProductQuantity';
        }
        Insert lst_Asset;
        
        

        /*
        List<Id> OrderId = new List<Id>();
        for(Order ord:lstOrder){
            OrderId.add(ord.id);
        }
         Order_AssetsCreateOnOrderActivation.processAssetsFromOrder(OrderId);
        */

        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=true;

        List<Id> lst_ItemId = new List<Id>();
        List<Id> Set_OrdId = new List<Id>();
        for(OrderItem item:lstOrderItems){
                lst_ItemId.add(item.id);
                Set_OrdId.add(item.Orderid);           
        }
                   
        //MAKE A QUEUEUABLE CALL
        Set<Id> Set_ItemId = new Set<Id>();
        Set_ItemId.addAll(lst_ItemId);
        Order_AssetsCreateOnOrderActivation.processAssetsFromOrder(lst_ItemId,Set_ItemId);
                    

       
  
        test.stoptest();
  
  
     }
      

}