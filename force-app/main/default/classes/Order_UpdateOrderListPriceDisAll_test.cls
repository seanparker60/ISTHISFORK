@istest
public with sharing class Order_UpdateOrderListPriceDisAll_test {

    //Order_UpdateOrderListPriceDiscountAll_test full name shortened in the class

    public static testmethod void UpdateOrderListPriceDiscountAll1_test() {
          
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
        
            List<OrderShipto__c> lst_OrderShipto = Order_TestDataFactory.insertOrderShipto(1,lstOrder, lstAccount,true);
            List<ListPriceDiscount__c> ListPriceDiscount = Order_TestDataFactory.insertListPriceDiscount(5,'Regular','Workbooks',true);


            TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,true);

            List<String> lstOrderId = new List<String>();

            for(Order ord:lstOrder ){
                lstOrderId.add(ord.id);
            }

            Order_UpdateOrderListPriceDiscountAll.UpdateOrdeItemswithListPriceDiscount(null,lstOrderId ,null);
        
    }
    
    public static testmethod void UpdateOrderListPriceDiscountAll2_test() {
          

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
        for(Order ord:lstOrder ){
            ord.PricingMethod__c ='ProductDiscountGroupUsageBased';
        }
        insert lstOrder;

        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,false);
    
        for(OrderItem item:lstOrderItems){
            item.ManualDiscount__c='One-Off Amount';
            item.ManualDiscountValue__c = 1;
        }
        insert lstOrderItems;

        List<OrderShipto__c> lst_OrderShipto = Order_TestDataFactory.insertOrderShipto(1,lstOrder, lstAccount,true);
        List<ListPriceDiscount__c> ListPriceDiscount = Order_TestDataFactory.insertListPriceDiscount(5,'Regular','Workbooks',true);

        TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,true);

        List<String> lstOrderId = new List<String>();

        for(Order ord:lstOrder ){
            lstOrderId.add(ord.id);
        }
//1
        Order_UpdateOrderListPriceDiscountAll.UpdateOrdeItemswithListPriceDiscount(null,lstOrderId ,null);

        for(Order ord:lstOrder ){
            ord.PricingMethod__c ='ProductUsageBased';
        }
        update lstOrder;
//2
        Order_UpdateOrderListPriceDiscountAll.UpdateOrdeItemswithListPriceDiscount(null,lstOrderId ,null);
        
        for(OrderItem item:lstOrderItems){
            item.ManualDiscount__c='One-Off Percentage';
            item.ManualDiscountPercent__c = 10;
        }
        update lstOrderItems;
        
         
        for(Order ord:lstOrder ){
            ord.PricingMethod__c ='OrderProductQuantity';
        }
//3
        update lstOrder;
        Order_UpdateOrderListPriceDiscountAll.UpdateOrdeItemswithListPriceDiscount(null,lstOrderId ,null);

        for(Order ord:lstOrder ){
            ord.PricingMethod__c ='AccountStudents';
        }
//4
        update lstOrder;
        Order_UpdateOrderListPriceDiscountAll.UpdateOrdeItemswithListPriceDiscount(null,lstOrderId ,null);

    //5
    UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;       
    Order_UpdateOrderListPriceDiscountAll.UpdateOrdeItemswithListPriceDiscount(null,lstOrderId ,null);   
}
}