@Istest

Public class bg_AllObjectTriggerHandler_test{




Public static testmethod void bg_AllObjectTriggerHandler1(){


    test.starttest();
       
    TestDataFactory.insertAccounts(1,'Plantyn',true);
    test.stoptest();

}

Public static testmethod void bg_AllObjectTriggerHandler2(){


    test.starttest();
       
    List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);

    List<Id> Set_AccId = new List<Id>();
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
        }

        Order_AccountSubsidiary.AccountSubsidiary(Set_AccId);

        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '88776'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
        }

        update lstAccountSubsidiary;

        List<Product2> lstProduct = TestDataFactory.insertProducts(3,false);
        for(Product2 prod:lstProduct){
            prod.FixedStartDate__c = null;
        }
        insert lstProduct;

        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,false);


        List<Id> RecordIds = new List<Id>();
        Set<Id> Set_RecordIds = new Set<Id>();
        for(Order ord:lstOrder){
            system.debug('**Map_AccSub**'+Map_AccSub.get(ord.AccountId));
            ord.AccountSubsidiary__c = Map_AccSub.get(ord.AccountId); 
            ord.NetSuiteIdAccountSubsidiary__c = '12345';
            RecordIds.add(ord.id);
            Set_RecordIds.add(ord.id);
        }
        
        for(OrderItem item:lstOrderItems){
            system.debug('**Map_AccSub**'+Map_AccSub.get(item.ShipToAccount__c));
            item.AccountSubsidiary__c = Map_AccSub.get(item.ShipToAccount__c); 
        }

        insert lstOrderItems;
        
        system.debug('**AccountSubsidiary**'+lstOrder[0].AccountSubsidiary__c);
        system.debug('**NetSuiteIdAccountSubsidiary**'+lstOrder[0].NetSuiteIdAccountSubsidiary__c);
        
        system.debug('**ValidationErrorsOrderProducts**'+lstOrder[0].ValidationErrorsOrderProducts__c);
        system.debug('**ValidationErrorsOrder**'+lstOrder[0].ValidationErrorsOrder__c);
        

        lstOrder[0].Status ='Activated';
        //update lstOrder;

        bg_AllObjectInvocableHandler.AllObjectInvocableHandler(RecordIds);

        bg_CustomApiParameter apiParam = new bg_CustomApiParameter();
            
           

                apiParam = new bg_CustomApiParameter();
                apiParam.ids = Set_RecordIds;
                apiParam.DMLOperation =  'Update'; 

                system.debug('***ORDERREST Before ***');
                //bg_RESTCalloutUtil bg = new bg_RESTCalloutUtil(apiParam);
                System.enqueueJob(new bg_RESTCalloutUtil(apiParam));
                system.debug('***ORDERREST After ***');           

    test.stoptest();

}




}