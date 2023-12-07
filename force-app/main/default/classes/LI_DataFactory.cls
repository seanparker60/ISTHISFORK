@isTest
public with sharing class LI_DataFactory {
    
    public static Account createAccount(Boolean doInsert) {

        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.NumberofStudents__c = 1;
		acc.OperatingCompany__c = 'Plantyn';
        acc.Area__c = 'Dutch';

        if (doInsert) {
            insert acc;
        }
        return acc;
    }

    public static Order createOrder(Account account, Pricebook2 pb, Boolean doInsert) {
        
        Order order = new Order();
        order.AccountId = account.Id;
        order.Status = 'Under Review';
        order.EffectiveDate = Date.today();
        order.ShippingIndicationRule__c = 'Based on weight non Domestic';
        order.Pricebook2Id = pb.Id;
        order.OperatingCompany__c = 'Plantyn';

        System.debug(LoggingLevel.DEBUG, 'Order to create: ' + order);
        if (doInsert) {
            insert order;
        }
        return order;
    }

    public static OrderItem createOrderItem(Order order, AccountSubsidiary__c accSub, PricebookEntry pbe, Boolean doInsert) {

        OrderItem oi = new OrderItem();
        oi.OrderId = order.Id;
        oi.Quantity = 1;
        oi.PricebookEntryId = pbe.Id;
        oi.AccountSubsidiary__c = accSub.Id;
        oi.UnitPrice = 25.0;

        if (doInsert) {
            insert oi;
        }
        return oi;
    }

    public static Product2 createProduct2(Boolean doInsert) {
        
        Product2 product = new Product2();
        product.Name = 'Test Product';

        if (doInsert) {
            insert product;
        }
        return product;
    }

    public static Pricebook2 createStandardPricebook(Boolean doInsert) {

        Pricebook2 pb = new Pricebook2();
        pb.Id = Test.getStandardPricebookId();
        pb.IsActive = true;

        if (doInsert) {
            update pb;
        }
        return pb;
    }

    public static PricebookEntry createPriceBookEnrtyForStandardPriceBook(Product2 product, Pricebook2 standardPricebook, AccountSubsidiary__c accSub, Boolean doInsert) {

        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = standardPricebook.Id;
        pbe.Product2Id = product.Id;
        pbe.UnitPrice = 1.0;
        pbe.IsActive = true;
        pbe.Subsidiary__c = 'Plantyn';

        if (doInsert) {
            insert pbe;
        }
        return pbe;
    }

    public static AccountSubsidiary__c createSubsidiary(Account acc, Boolean doInsert) {

        AccountSubsidiary__c accSub = new AccountSubsidiary__c();
        accSub.Account__c = acc.Id;
        accSub.LegalName__c = 'Plantyn';

        if (doInsert) {
            insert accSub;
        }
        return accSub;
    }

}