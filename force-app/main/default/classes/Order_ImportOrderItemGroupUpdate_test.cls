@istest
public with sharing class Order_ImportOrderItemGroupUpdate_test {
    
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

        List<Product2> lstProductItemGroup = TestDataFactory.insertProducts(3,true);
        List<Product2> lstProductItem = TestDataFactory.insertProducts(1,false);

        Integer ISBN = lstProductItemGroup.size()+1;
        
        i = 0;
        
        for(Product2 prod:lstProductItem){
            prod.ISBN__c = prod.ISBN__c + i;
            i++;
        }

        insert lstProductItem;

        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
      //  List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProductItem,true);

        Pricebook2 PricebookCustom = TestDataFactory.insertPricebookCustom('Plantyn - All 2021');
       // lstPricebookEntry = TestDataFactory.insertPricebookEntry(PricebookCustom.id ,lstProductItem,true);

        List<ProductComponent__c> lstProductComponent = Order_TestDataFactory.InsertGroupComponent(lstProductItem,lstProductItemGroup,true);

        
        Order_TestDataFactory.InsertPricing(lstProductItemGroup,null,true);
        Pricing__c[] lstPricing = Order_TestDataFactory.InsertPricing(lstProductItem,lstProductComponent,true);

        Pricing__c[] lstPricingComponent = Order_TestDataFactory.InsertPricingProductComponent(lstProductComponent,true);
     
        String OrderExternalId = 'Ext123';


        Pricing__c[] lstPricingCheck = [Select ProductComponent__r.Product__c from Pricing__c where ProductComponent__r.Product__c !=: null];

        system.debug('**Price check: lstPricingCheck**'+lstPricingCheck.size());


       PricebookEntry[] lstPricebookEntry = [Select id, Pricebook2.Name,Product2.ISBN__c from PricebookEntry];


       for(PricebookEntry pbe:lstPricebookEntry){
            system.debug('**Before Pricebook2.Name**'+pbe.Pricebook2.Name);
            system.debug('**Before Product2.ISBN**'+pbe.Product2.ISBN__c);
       }



       system.debug('**Before Import Order**');
        lstAccount = [Select NetsuiteInternalId__c from Account];
       List<ImportOrder__c> lstinsertImportOrder = Order_TestDataFactory.insertImportOrderOrder(lstAccount,true,OrderExternalId);

       Order[] OrderImport = [Select id,Pricebook2.Name from Order];
      // system.debug('**Before Import Item:size**'+OrderImport.size());
      // system.debug('**Before Import Item**'+OrderImport[0].Pricebook2.Name);

       List<ImportOrder__c> lstinsertImportOrderItem = Order_TestDataFactory.insertImportOrderItem(lstProductItem,false,OrderExternalId,null);

       List<ImportOrder__c> lstinsertImportOrderItemGroup = Order_TestDataFactory.insertImportOrderItem(lstProductItemGroup,false,OrderExternalId,lstProductItem[0].ISBN__c);


       
       lstinsertImportOrderItem.addAll(lstinsertImportOrderItemGroup);
       insert lstinsertImportOrderItem;

       /*
       system.debug('**After Import**');

        Map<String,ImportOrder__c> Map_ImportOrder = new Map<String,ImportOrder__c>();
        for(ImportOrder__c imp:lstinsertImportOrderItem){
            Map_ImportOrder.put(imp.ProductId__c,imp);    
        }

        OrderItem[] lstOrderItems = [Select id,Product2.ISBN__c,UnitPrice,ProductType__c,Product2Id,ItemGroupId__c,Quantity,NetsuiteQuantity__c from OrderItem ];
        system.debug('**Before Process: OrderItem**'+lstOrderItems.size());

        List<Order_ImportOrderItemGroupUpdate.Request> lst_request = new  List<Order_ImportOrderItemGroupUpdate.Request>();
        for(OrderItem item:lstOrderItems){
            Order_ImportOrderItemGroupUpdate.Request request = new Order_ImportOrderItemGroupUpdate.Request();
            request.SingleOrderItems = item;
            Map_ImportOrder.get(item.Product2.ISBN__c);
            lst_request.add(request);
        }

        Order_ImportOrderItemGroupUpdate.OrderItemGroupUpdate(lst_request);
       */


        /*
        for(Order ord:lstOrder){
            ord.ExternalOrderId__c = OrderExternalId;
        }
        */

       // update ;
    // lstPricing.addall(lstPricingComponent);

        
       // List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
       // List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);
       // List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);

    }


}