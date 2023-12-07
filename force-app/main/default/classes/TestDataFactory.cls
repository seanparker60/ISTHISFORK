@Istest
Public Class TestDataFactory{

//DIFFERENT OPTIONS FOR INSERT ACCOUNTS 
    public static Account insertAccount(Boolean doInsert) {
        
        Account Acc = new Account();
        Acc.Name = 'School';
        Acc.Area__c = 'Dutch';

        if(doInsert) {
            insert acc;
        }

        return acc;

    }

    Public static List<Account> insertAccounts(Integer Count){

    
        List<Account> lst_Account = new List<Account>();
        for(Integer i=0;i<Count;i++){
            
            Account Acc = new Account();
            Acc.Name = 'School'+i;
            Acc.Area__c = 'Dutch';
            lst_Account.Add(Acc);
        }
        
        Insert lst_Account;
        
        return lst_Account;
        
    }
   
    Public static List<Account> insertAccounts(Integer Count, String Opco,Boolean doInsert){

        Id educationalRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType='Account' AND Name = 'B2B Educational' LIMIT 1].Id;
        List<Account> lst_Account = new List<Account>();
        for(Integer i=0;i<Count;i++){
            
            Account Acc = new Account();
            acc.RecordTypeId = educationalRecordTypeId;
            Acc.Name = 'School'+i;
            Acc.TypeOfAccount__c = 'Sales';
            Acc.OperatingCompany__c = Opco;
            Acc.CustomerCategory__c = 'Educational Institution';
            Acc.CustomerDiscountGroup__c = 'Educational Institution';
            Acc.NetsuiteInternalId__c = '1234'+i;
            Acc.ShippingCity = 'Amsterdam';
            Acc.ShippingCountry = 'Netherlands';
            Acc.ShippingPostalCode = '1224AM';
            Acc.ShippingStreet = 'DePijp22';  
            Acc.Area__c = 'Dutch';
            lst_Account.Add(Acc);
        }
        if(doInsert) {
            insert lst_Account;
        }
        return lst_Account;

    }
    
    Public static List<Account> insertAccountsSubsidiary(Integer Count, String Opco,Boolean HigherEducation,Boolean doInsert){

    
        List<Account> lst_Account = new List<Account>();
        for(Integer i=0;i<Count;i++){
            
            Account Acc = new Account();
            Acc.Name = 'School'+i;
            Acc.LegalName__c = Acc.Name;
            Acc.LegalName2__c = Acc.Name;
            Acc.OperatingCompany__c =  Opco;
            Acc.CustomerCategory__c = 'Educational Institution';
            Acc.CustomerDiscountGroup__c ='Educational Institution';
            Acc.NetsuiteInternalId__c = '12345'+i;
            Acc.TypeOfAccount__c = 'Sales';
            Acc.NumberofStudents__c = 222;
            Acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2BEducational').getRecordTypeId();
            Acc.isHigherEducation__c = HigherEducation;
            Acc.ShippingCity = 'Amsterdam';
            Acc.ShippingCountry = 'Netherlands';
            Acc.ShippingPostalCode = '1224AM';
            Acc.ShippingStreet = 'DePijp22'; 
            Acc.BillingReminderEmail__c ='test@test.com';
            Acc.BillingReminderEmail2__c ='test@test.com';
            Acc.DigitalActivationEmail__c ='test@test.com';
            Acc.InvoicingEmail__c ='test@test.com';
            Acc.InvoiceEmail2__c ='test@test.com';
            Acc.OrderNotificationEmail__c ='test@test.com';
            Acc.OrderNotificationEmail2__c ='test@test.com';
            Acc.Area__c = 'Dutch';
            lst_Account.Add(Acc);
        }

        if(doInsert) {
            insert lst_Account;
        }
        
        
        return lst_Account;
    
}



//DIFFERENT OPTIONS FOR INSERT ORDERS   
Public static List<Contract> insertContract(Integer Count,List<Account> lst_Acc, Id PriceBook,Boolean doInsert){

    
    List<Contract> lst_Contract = new List<Contract>();
    for(Account acc:lst_Acc){
        for(Integer i=0;i<Count;i++){
            
            Contract con = new Contract();
            con.AccountId = acc.id;
            con.SoldUsers__c = 222; 
            con.StartDate = system.today()-30;
            con.Pricebook2Id = PriceBook;
            lst_Contract.add(con);
        }
    }
    if(doInsert) {
        insert lst_Contract;
    }  
   
    return lst_Contract;    

}

//DIFFERENT OPTIONS FOR INSERT ORDERS   
Public static List<Order> insertOrderHeader(Integer Count,List<Account> lst_Acc,List<Contract> lst_con, Id PriceBook,Boolean doInsert){

    

    List<Order> lst_Order = new List<Order>();
    if(lst_con.size()>0){
        system.debug('**Contract for Order **');
        for(Account acc:lst_Acc){

            for(Contract con:lst_con){ 
                system.debug('**Contract for Order 2**');
                if(acc.id == con.AccountId){ 
                    system.debug('**Contract for Order 3**');    
                    for(Integer i=0;i<Count;i++){ 
                        system.debug('**Contract for Order 4**');                  
                        Order ord = new Order();
                        ord.AccountId = acc.id;
                      //  ord.ContractId = con.id;
                        ord.Billto__c = acc.id;
                        ord.OperatingCompany__c = 'Plantyn';
                        ord.InsertProductSelector__c = true;
                        ord.EffectiveDate = system.today() - 30;
                        ord.ShipByDate__c = ord.EffectiveDate;
                        ord.Pricebook2Id = PriceBook;
                        ord.Status = 'Draft';
                        ord.BillingReminderEmail__c = 	acc.BillingReminderEmail__c;
                        ord.BillingReminderEmail2__c = acc.BillingReminderEmail2__c ;
                        ord.DigitalActivationEmail__c = acc.DigitalActivationEmail__c ;
                        ord.InvoiceEmail__c =  acc.InvoicingEmail__c ;
                        ord.InvoiceEmail2__c =  acc.InvoiceEmail2__c ;
                        ord.OrderNotificationEmail__c = acc.OrderNotificationEmail__c ;
                        ord.OrderNotificationEmail2__c = acc.OrderNotificationEmail2__c ;

                        lst_Order.add(ord);
                    }
                }    
            }    
        }
    }    
    else{
        for(Account acc:lst_Acc){
            for(Integer i=0;i<Count;i++){
                
                Order ord = new Order();
                ord.Pricebook2Id = PriceBook;
                lst_Order.add(ord);
            }
        }
    } 
    if(doInsert) {
        insert lst_Order;
    } 
    
    return lst_Order;    

}

//DIFFERENT OPTIONS FOR INSERT ORDERS
Public static List<OrderItem> insertOrderItems(Integer Count,List<Account> lstAccount,Map<String,String> Map_AccSub,List<Order> lst_Ord, List<PricebookEntry> lst_PBE,Boolean doInsert){

    List<OrderItem> lst_OrdItem = new List<OrderItem>();
    for(Order ord:lst_Ord){

        for(Integer i=0;i<Count;i++){
            
            for(PricebookEntry pbe:lst_PBE){
              
              for(Account acc:lstAccount){
                    OrderItem ordItem = new OrderItem();

                    ordItem.ShipToAccount__c = acc.id;
                    ordItem.Product2Id = pbe.Product2Id; 
                   
                    ordItem.AccountSubsidiary__c = Map_AccSub.get(acc.id);
                    ordItem.OrderId = ord.id;
                    ordItem.InsertProductSelector__c = true;
                    ordItem.Quantity = 5;
                    ordItem.UnitPrice = 100;
                    ordItem.StartDate__c = ord.ShipByDate__c+2;
                    ordItem.ServiceDate = ord.ShipByDate__c+2;
                    ordItem.NetSuiteIdBilltoAccount__c = '8979'+i;
                    ordItem.NetSuiteIdShiptoAccount__c = '3456'+i;
                    ordItem.PricebookEntryId  = pbe.id ; 
                    ordItem.ShippingCity__c =acc.ShippingCity;
                    ordItem.ShippingCountry__c =acc.ShippingCountry;
                    ordItem.ShippingPostalCode__c=acc.ShippingPostalCode ;
                    ordItem.ShippingState__c=acc.ShippingState;
                    ordItem.ShippingStreet__c  =acc.ShippingStreet; 
                   // ordItem.discount__c = 2;   
                    lst_OrdItem.add(ordItem);
              }
                
            }    

        }
    }
    if(doInsert) {
        insert lst_OrdItem;
    }  
    
    return lst_OrdItem;    

}
/*
Public static List<OrderShipto__c> insertOrderShipto(Integer Count,List<Order> lst_Ord, List<Account> lst_Acc){

     
    List<OrderShipto__c> lst_OrderShipto = new List<OrderShipto__c>();
    for(Order ord:lst_Ord){

        for(Integer i=0;i<Count;i++){
            
            for(Account acc:lst_Acc){
                OrderShipto__c Shipto = new OrderShipto__c();  
                Shipto.Order__c  = ord.id; 
                Shipto.ShiptoAccount__c = acc.id;         
                lst_OrderShipto.add(Shipto);
            }    

        }
    }
     
    insert lst_OrderShipto;
    return lst_OrderShipto;    

}
*/


//INSERT PRODUCTS
Public static List<Product2> insertProducts(Integer Count,Boolean doInsert){

    List<Product2> lst_prod = new List<Product2>();
     
    for(Integer i=0;i<=Count;i++){
            
            Product2 prod = new Product2();
            prod.name = 'Prod'+i;
            prod.ProductDiscountGroup__c = 'Workbooks';
            prod.IsRegularOrderPossible__c = true;
            prod.IsInspectionCopyOrderPossible__c = true;
            prod.IsUseCopyOrderPossible__c = true;
            prod.HasBlock__c= false;
            prod.VAT__c = 'Low';
            prod.ISBN__c = '99-9999-999'+i;
            prod.Weight__c = 1;
            prod.CoreLicense__c =true;
            prod.LicenseDuration__c = '6';
            prod.FixedStartDate__c = system.today()-5;
            prod.MarketSegment__c = 'SecondaryEducation';
            prod.SoldInSegment__c = 'SecondaryEducation';
            lst_prod.add(prod);
    }     
    if(doInsert) {
        insert lst_prod;
    } 
    
    return lst_prod;    

}

//INSERT PRICEBOOKS
Public static Pricebook2 insertPricebook(){
 
    Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),StartDate__c= system.today()-16,EndDate__c = system.today()+116,PricebookType__c='PrimaryEducation', IsActive = true,Subsidiary__c = 'Plantyn');

    update standardPricebook;

    return standardPricebook;
}

Public static Pricebook2 insertPricebookCustom(String PBName){
    
    OrderRequestPricebook__mdt[] OrderRequestPricebook = [Select Pricebook__c,OperatingCompany__c from OrderRequestPricebook__mdt where OperatingCompany__c ='Plantyn'   ];


    Pricebook2 CustomPricebook = new Pricebook2(Name= OrderRequestPricebook[0].Pricebook__c /*PBName*/,StartDate__c= system.today()-16,EndDate__c = system.today()+116,PricebookType__c='PrimaryEducation', IsActive = true,Subsidiary__c = 'Plantyn');

    Insert CustomPricebook;

    return CustomPricebook;
}


//INSERT PRICEBOOK ENTRY
Public static List<PricebookEntry> insertPricebookEntry(Id Pricebook ,List<Product2> lst_prod,Boolean doInsert){

    List<PricebookEntry> lst_PricebookEntry = new List<PricebookEntry>();
    
    integer i=0;
    for(Product2 prod:lst_prod){
        
            PricebookEntry pbe = new PricebookEntry();
            pbe.Pricebook2Id = Pricebook;
            pbe.Product2Id = prod.id;
            pbe.unitprice = 110;
            pbe.IsActive =true;
            pbe.Subsidiary__c = 'Plantyn';
            lst_PricebookEntry.add(pbe); 
        
    }      
    if(doInsert) {
        insert lst_PricebookEntry;
    } 
    
    return lst_PricebookEntry;    

}

Public static List<Asset> insertAsset(Id Pricebook ,List<Product2> lst_prod,List<Account> lst_Billto, List<Account> lst_Account,Boolean doInsert){

    List<Asset> lst_Asset = new List<Asset>();
    
    
        
        
        for(Account acc:lst_Billto){   
            
            
            for(Product2 prod:lst_prod){
                Asset asset = new Asset();
                asset.name = 'Product1';
                asset.PriceBook__c = Pricebook;
                asset.Product2Id = prod.id;
                asset.Price = 110;
                
                 
                asset.AutomatedRenewProcess__c = true;
                asset.ActivationDate__c = system.today()-1;
                asset.BooklistDate__c = system.today();
                
                asset.CancellationDate__c = null;
                asset.CancellationReason__c = null;
                asset.IsActive__c = true;
                asset.RenewalDate__c =system.today();
                asset.PricingMethod__c ='OrderProductQuantity';
    
                asset.UsageEndDate = system.today()+22;
                asset.PurchaseDate = system.today()-2;
    
                asset.Quantity = 100;
                asset.SoldUsers__c = 100;
                asset.NumberofActiveUsers__c = 100;
                asset.BillToAccount__c = acc.id;
                asset.AccountId = acc.id;
                lst_Asset.add(asset);        
            }  
            /*
            for(Asset ass:lst_Asset){
                ass.BillToAccount__c = acc.id;
            }    
            */
        }
        /*
        for(Account acc:lst_Account){
            for(Asset ass:lst_Asset){
                ass.AccountId = acc.id;
            } 
        }   
        */
    if(doInsert) {
            insert lst_Asset;
    }
    
    return lst_Asset;    

}

@future
Public static void testInsert(){
    List<OrderItem>  OrderItems = new List<OrderItem>();

    Order[] CurOrder = [Select AccountSubsidiary__c,Account.NetsuiteInternalId__c,OperatingCompany__c,InsertProductSelector__c,CustomerReference__c,NumberOfStudents__c,Billto__c,ContractId,EffectiveDate,ShipByDate__c from Order where id=: '8013N000001lvsnQAA'];
        
     List<PricebookEntry> ProductsbyPriceBook;
             
                ProductsbyPriceBook = new List <PricebookEntry>([Select Product2.Renewable__c,Product2.OrderLineType__c,Product2.ISBNArticleNumber__c,Product2.MarketSegment__c,Product2.name,Product2.SoldInSegment__c, Product2.QuantitySelectionType__c,Product2.ProductDiscountGroup__c,Product2.ProductRateGroup__c,Product2.Type__c,productcode,unitprice,Product2Id 
        from PricebookEntry where Pricebook2Id =:'01s3N0000027HpIQAU' limit 2000 ]);    
    
        List<String> ShiptoId = new List<String>();
        String ShiptoList = '0013N00000aMyHBQA0;0013N00000aMyHCQA0;0013N00000aMyPhQAK;0013N00000aMyPjQAK;';
        ShiptoId.addAll(ShiptoList.Split(';'));		
    integer i=0;
    
    for(PricebookEntry pbe:ProductsbyPriceBook){
    
        for(String accid:ShiptoId){
             OrderItem item = new OrderItem();
            item.UnitPrice = pbe.unitprice;
               // item.STDPrice= pbe.unitprice;
             //   Item.BasePrice= pbe.unitprice;
            
            item.InsertProductSelector__c = true;
                item.Quantity = 2;
                item.Product2Id = pbe.Product2Id;
                item.PricebookEntryId= pbe.id;
                item.ShipToAccount__c=accid; 
            item.AccountSubsidiary__c = 'a0g3N0000026uHAQAY';
                item.Account__c = CurOrder[0].Billto__c ;
                item.OrderId = CurOrder[0].id;
                //item.PriceDiscount='';
           // item.DiscountOption='';
            //item.DiscountPercent=null;
                item.NetSuiteIdBilltoAccount__c = '8979'+i;
                item.NetSuiteIdShiptoAccount__c = '3456'+i;
            OrderItems.add(item);
            i++;
        }	
    }
    
    insert OrderItems;
    
           

}


}