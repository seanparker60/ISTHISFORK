@isTest
public with sharing class LI_updateOrderLineItems_TEST {
    
    @TestSetup
    static void makeData(){
        
        Account acc = LI_DataFactory.createAccount(true);
        AccountSubsidiary__c accSub = LI_DataFactory.createSubsidiary(acc, true);
        Product2 product = LI_DataFactory.createProduct2(true);
        Pricebook2 standardPricebook = LI_DataFactory.createStandardPricebook(true);
        PricebookEntry bpe = LI_DataFactory.createPriceBookEnrtyForStandardPriceBook(product, standardPricebook, accSub, true);
        Order order = LI_DataFactory.createOrder(acc, standardPricebook, true);
        
    }

    @IsTest
    static void testInsert(){
        
        Order order = [SELECT Id, ShippingIndicationRule__c FROM Order LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        AccountSubsidiary__c accSub = [SELECT Id FROM AccountSubsidiary__c LIMIT 1];

        Test.startTest();
            LI_DataFactory.createOrderItem(order, accSub, pbe, true);
        Test.stopTest();
        
        OrderItem oi = [SELECT Id, ShippingIndicationRule__c FROM OrderItem];
        System.assertEquals('Based on weight non Domestic', oi.ShippingIndicationRule__c);
    }

    @IsTest
    static void testUpdate(){
        
        Order order = [SELECT Id, ShippingIndicationRule__c FROM Order LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        AccountSubsidiary__c accSub = [SELECT Id FROM AccountSubsidiary__c LIMIT 1];
        
        LI_DataFactory.createOrderItem(order, accSub, pbe, true);

        OrderItem oiBefore = [SELECT Id, ShippingIndicationRule__c FROM OrderItem];

        Test.startTest();
            order.ShippingIndicationRule__c = 'Shipping Cost Exempt';
            update order;
            OrderItem oiAfter = [SELECT Id, ShippingIndicationRule__c FROM OrderItem];
        Test.stopTest();

        System.assertEquals('Shipping Cost Exempt', oiAfter.ShippingIndicationRule__c);
    }

}