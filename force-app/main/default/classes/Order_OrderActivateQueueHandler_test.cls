@Istest
public with sharing class Order_OrderActivateQueueHandler_test {
    

static testmethod void BatchOrderActivateAssetRenew1(){    
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
    List<Order> lstOrder = TestDataFactory.insertOrderHeader(2,lstAccount,lstContract,standardPricebook.id,false);
    
    for(Order ord:lstOrder){
        ord.ActivateforBatchProcessing__c =true;
    }
    
    Insert lstOrder;

    List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,false); 

    
    List<Asset>lst_Asset = TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,false);
    
    Date CurrrentDay = system.today();
    
    Map<String,String> Map_Asset = new Map<String,String>();

    for(Asset ass:lst_Asset){
        ass.LastRenewalUpdate__c =CurrrentDay;
    }
    Insert lst_Asset;

    for(Asset ass:lst_Asset){
        Map_Asset.put(ass.Product2Id,ass.id);
    }


    system.debug('***BatchOrderActivate: Map_Asset'+Map_Asset);

    for(OrderItem item:lstOrderItems){
        item.Asset__c = Map_Asset.get(item.Product2Id);

        system.debug('***BatchOrderActivate: Map_Asset: Ind'+Map_Asset.get(item.Product2Id));

    }
    insert lstOrderItems;

    lstOrder[0].TriggerBusinessRules__c =true;
    update lstOrder;
    
    String checked = '';
    Set<String> Set_Checked = new Set<String>();
    Order_OrderActivateQueueHandler.checknextOrder(checked,Set_Checked);

    Test.stopTest();
        
}



}