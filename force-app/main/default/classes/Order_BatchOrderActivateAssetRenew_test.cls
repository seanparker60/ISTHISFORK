@istest
public with sharing class Order_BatchOrderActivateAssetRenew_test {
    
    
    static testmethod void BatchOrderActivateAssetRenew  (){
        
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
        
       
        lstOrder[0].ActivateforBatchProcessing__c =true;
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

        Order_BatchOrderActivateAssetRenewal AssetRenewal = new Order_BatchOrderActivateAssetRenewal();
        database.executebatch(AssetRenewal ,1);   
       String chron = '0 0 23 * * ?';        
       system.schedule('Test Sched', chron, AssetRenewal);  

        /*
        Order[] SOQLOrder = [Select ValidationErrorsOrder__c,ValidationErrorsOrderProducts__c from Order ];
        
        system.debug('***BatchOrderActivate: ValidationErrorsOrder'+SOQLOrder[0].ValidationErrorsOrder__c);
        system.debug('***BatchOrderActivate: ValidationErrorsOrderProducts'+ SOQLOrder[0].ValidationErrorsOrderProducts__c);
        system.debug('***BatchOrderActivate: AccountSubsidiaryRequir'+ SOQLOrderItems[0].ValidateActivateAccountSubsidiaryRequir__c);
        system.debug('***BatchOrderActivate: ActivationEmail'+ SOQLOrderItems[0].ValidateActivateDigitalActivationEmail__c);
        system.debug('***BatchOrderActivate: NetSuiteId'+ SOQLOrderItems[0].ValidateActivateNetSuiteId__c);
        system.debug('***BatchOrderActivate: ShippingAddressRequired'+ SOQLOrderItems[0].ValidateActivateShippingAddressRequired__c);
        system.debug('***BatchOrderActivate: LicenseMoreThan12Mont'+ SOQLOrderItems[0].ValidateCannotSellLicenseMoreThan12Mont__c);
        system.debug('***BatchOrderActivate: TypeCheck'+ SOQLOrderItems[0].ValidateOrderLineTypeCheck__c);
        system.debug('***BatchOrderActivate: ComponentNonRenewable'+ SOQLOrderItems[0].ValidateProductComponentNonRenewable__c);
       
        
        OrderItem[] SOQLOrderItems = [Select 
        ValidateActivateAccountSubsidiaryRequir__c,
        ValidateActivateDigitalActivationEmail__c,
        ValidateActivateNetSuiteId__c,
        ValidateActivateShippingAddressRequired__c,
        ValidateCannotSellLicenseMoreThan12Mont__c,
        ValidateOrderLineTypeCheck__c,
        ValidateProductComponentNonRenewable__c
        From OrderItem 
        ];
        */

        Test.stopTest();
        
    }


}