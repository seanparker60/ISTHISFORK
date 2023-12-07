@istest
public with sharing class Order_B2BOrderInvoice_test {
    
    public static testmethod void Order_B2BOrderInvoice1(){

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
        
        List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);
        Order_TestDataFactory.insertOrderShipto(1,lstOrder, lstAccount,true);
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
       
        List<Id> Lst_OrdId = new List<Id>();
         
        Lst_OrdId.add(lstOrder[0].Id);
       /*
        List<Order_B2BOrderInvocable.Request> request = new List<Order_B2BOrderInvocable.Request>();

        Order_B2BOrderInvocable.Request req = new Order_B2BOrderInvocable.Request();
        req.OrderId = Lst_OrdId;
        request.add(req);
        Order_B2BOrderInvocable.B2BOrderInvocable(request);
        */

        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=true; //For activating exceptions in classes
        Order_B2BOrderInvocable.UpdateOrderItems(Lst_OrdId);
    }

    public static testmethod void Order_B2BOrderInvoice2(){

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
        
        List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);
       
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
       
        List<Id> Lst_OrdId = new List<Id>();
         
        Lst_OrdId.add(lstOrder[0].Id);
       /*
        List<Order_B2BOrderInvocable.Request> request = new List<Order_B2BOrderInvocable.Request>();

        Order_B2BOrderInvocable.Request req = new Order_B2BOrderInvocable.Request();
        req.OrderId = Lst_OrdId;
        request.add(req);
        Order_B2BOrderInvocable.B2BOrderInvocable(request);
        */

        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=true; //For activating exceptions in classes
        Order_B2BOrderInvocable.UpdateOrderItems(Lst_OrdId);
    }
}