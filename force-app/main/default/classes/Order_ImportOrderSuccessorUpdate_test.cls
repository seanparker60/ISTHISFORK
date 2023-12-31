@istest
public with sharing class Order_ImportOrderSuccessorUpdate_test {

    public static testmethod void ImportOrderItemGroupUpdate1(){

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true);

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

       
        
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
       // List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProductItem,true);

        Pricebook2 PricebookCustom = TestDataFactory.insertPricebookCustom('Plantyn - All 2021');


        List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
        List<Product2> lstProductSuccessor = TestDataFactory.insertProducts(1,true);
        Pricing__c[] lstPricing = Order_TestDataFactory.InsertPricing(lstProduct,null,true);
        lstPricing = Order_TestDataFactory.InsertPricing(lstProductSuccessor,null,true);


        Order_TestDataFactory.UpdateSuccessorItem(lstProduct, lstProductSuccessor, true);

        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,PricebookCustom.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,PricebookCustom.id,true);
        
        
        PricebookEntry[] lstPricebookEntryExist = [Select id,Product2Id, Pricebook2Id,Product2.IsSuccessorItemActive__c,Product2.SuccessorItem__c,Product2.SuccessorItem__r.IsActive,Product2.Stocknumber__c,Product2.StockLevel__c, Product2.PlannedPrintDate__c from PricebookEntry where Pricebook2Id !=:standardPricebook.id]; // 
         
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntryExist,true);
        system.debug('**After OrderItem 1**');
        List<OrderShipto__c> lst_OrderShipto = Order_TestDataFactory.insertOrderShipto(1,lstOrder, lstAccount,true);
 


    String OrderExternalId = 'Ext123';
       system.debug('**Before Import Order**');
        lstAccount = [Select NetsuiteInternalId__c from Account];
       List<ImportOrder__c> lstinsertImportOrder = Order_TestDataFactory.insertImportOrderOrder(lstAccount,true,OrderExternalId);
       system.debug('**Before Import Item**');
       List<ImportOrder__c> lstinsertImportOrderItem = Order_TestDataFactory.insertImportOrderItem(lstProduct,false,OrderExternalId,null);

    //   List<ImportOrder__c> lstinsertImportOrderItemGroup = Order_TestDataFactory.insertImportOrderItem(lstProductItemGroup,false,OrderExternalId,lstProductItem[0].ISBN__c);  

       system.debug('**After OrderItem 2**');
       system.debug('**After Import X**');
       insert lstinsertImportOrderItem;

        Map<String,ImportOrder__c> Map_ImportOrder = new Map<String,ImportOrder__c>();
        for(ImportOrder__c imp:lstinsertImportOrderItem){
            Map_ImportOrder.put(imp.ProductId__c,imp);    
        }

        lstOrderItems = [Select id,OrderId,Product2.ISBN__c,Product2Id,UnitPrice,ProductType__c,ItemGroupId__c,Quantity,NetsuiteQuantity__c,PricebookEntryId from OrderItem ];
        system.debug('**Before Process: OrderItem**'+lstOrderItems.size());

        List<Order_ImportOrderSuccessorUpdate.Request> lst_request = new  List<Order_ImportOrderSuccessorUpdate.Request>();
        for(OrderItem item:lstOrderItems){
            Order_ImportOrderSuccessorUpdate.Request request = new Order_ImportOrderSuccessorUpdate.Request();
            request.SingleOrderItems = item;
            Map_ImportOrder.get(item.Product2.ISBN__c);
            lst_request.add(request);
        }

        Order_ImportOrderSuccessorUpdate.OrderSuccessorUpdate(lst_request);
       


        

       // update ;
    // lstPricing.addall(lstPricingComponent);

        
       // List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
       // List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);
       // List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);

    }

}