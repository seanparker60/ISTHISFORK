@istest
public with sharing class Order_TestDataFactory {
    

    Public Static List<Pricing__c> InsertPricing(List<Product2> lst_prod,List<ProductComponent__c> lstProductComponent,Boolean doInsert){

        List<Pricing__c> lstPricing = new List<Pricing__c>();

        integer exid=0;

        Map<String,String> Map_Component = new Map<String,String>();

        if(lstProductComponent != null){
            for(ProductComponent__c ItemGrp:lstProductComponent){
                Map_Component.put(ItemGrp.Product__c,ItemGrp.Id);


            }        
        }
 
        String randomNumber = string.valueof(Integer.valueof((Math.random() * 10000)));
        for(Product2 prod:lst_prod){
    
                    Pricing__c Pricing = new Pricing__c();
                    Pricing.StartDate__c= system.today()-15;
                    Pricing.EndDate__c = system.today()+115;           
                    Pricing.ExternalId__c=randomNumber +exid;
                    Pricing.IsActive__c = true;
                    Pricing.ProductComponent__c=Map_Component.get(prod.Id);
                    Pricing.ListRate__c= 123;
                    Pricing.Product__c= prod.Id;           
                    Pricing.Subsidiary__c= 'Plantyn';
                  //  Pricing.SubsidiaryRAW__c= 'Plantyn'; 
                    lstPricing.add(Pricing);
                    exid++;

                    system.debug('**Insert Pricing: 1**');
                             
        }

        

        if(doInsert) {
            Insert lstPricing;
            system.debug('**Insert Pricing: 2**');
        } 

        return lstPricing;

    }
    Public Static List<Pricing__c> InsertPricingProductComponent(List<ProductComponent__c> lstProductComponent,Boolean doInsert){

        List<Pricing__c> lstPricing = new List<Pricing__c>();

        integer exid=0;

        Map<String,String> Map_Component = new Map<String,String>();
        String randomNumber = string.valueof(Integer.valueof((Math.random() * 10000)));
        for(ProductComponent__c ItemGrp:lstProductComponent){
            Map_Component.put(ItemGrp.Product__c,ItemGrp.Id);
            Pricing__c Pricing = new Pricing__c();
            Pricing.StartDate__c= system.today()-15;
            Pricing.EndDate__c = system.today()+115;           
            Pricing.ExternalId__c= randomNumber+exid;
            Pricing.IsActive__c = true;
            Pricing.ProductComponent__c=ItemGrp.Id;
            Pricing.ListRate__c= 123;
                    
            Pricing.Subsidiary__c= 'Plantyn';
          //  Pricing.SubsidiaryRAW__c= 'Plantyn'; 
            lstPricing.add(Pricing);
            exid++;

            system.debug('**Insert Pricing Component: 1**');
        }    


        

        if(doInsert) {
            Insert lstPricing;
            system.debug('**Insert Pricing: 2**');
        } 

        return lstPricing;

    }


    Public static void UpdateSuccessorItem(List<Product2> lstProduct, List<Product2> lstSuccessor, Boolean doUpdate){


        Set<String> Set_Succ = new Set<String>(); 

        for(Product2 prd:lstProduct){
    
            for(Product2 succ:lstSuccessor){

                if(prd.SuccessorItem__c == null && !Set_Succ.contains(succ.id)){
                    prd.SuccessorItem__c = succ.id;
                    Set_Succ.add(succ.id);
                    prd.IsSuccessorItemActive__c = true;
                }

            }

        }

        if(doUpdate){
            update lstProduct;
        }


    }


    Public Static void InsertVAT(Set<String> Set_Shipping, List<Product2> lst_Product, Boolean doInsert){

        List<VAT__c> lstVAT = new List<VAT__c>();
      //  NexusCountry__c,Product__c from VAT__c where toLabel(NexusCountry__c) in:Set_ShippingCountry AND Product__c in:Set_VAT];
        
        for(Product2 prod:lst_Product){
            
            for(String ship:Set_Shipping){
                VAT__c VAT = new VAT__c();
                VAT.NexusCountry__c = ship; 
                VAT.Product__c = prod.VAT__c;
                lstVAT.add(VAT);
            }
    
        }

        if(doInsert) {
            Insert lstVAT;
            system.debug('**Insert VAT: 2**');
        } 

    }    

    Public Static void InsertShippingCost(Set<String> Set_Operating, Boolean doInsert){

        List<ShippingCost__c> lstShippingCost = new List<ShippingCost__c>();
      //  NexusCountry__c,Product__c from VAT__c where toLabel(NexusCountry__c) in:Set_ShippingCountry AND Product__c in:Set_VAT];
             
            for(String opco:Set_Operating){
                ShippingCost__c ShippingCost = new ShippingCost__c();
                ShippingCost.Subsidiary__c = opco; 
                ShippingCost.ShippingRule__c = 'PU - Based on weight Domestic';
                ShippingCost.IsActive__c = true;
                ShippingCost.RangeValue__c = 1;
                lstShippingCost.add(ShippingCost);
            }
            for(String opco:Set_Operating){
                ShippingCost__c ShippingCost = new ShippingCost__c();
                ShippingCost.Subsidiary__c = opco; 
                ShippingCost.ShippingRule__c = 'PU - Based on weight non Domestic';
                ShippingCost.IsActive__c = true; 
                ShippingCost.RangeValue__c = 1;
                lstShippingCost.add(ShippingCost);
            }
            system.debug('**Insert ShippingCost: Subsidiary**'+lstShippingCost[0].Subsidiary__c);

        if(doInsert) {
            Insert lstShippingCost;
            system.debug('**Insert ShippingCost:**');

            system.debug('**Insert ShippingCost: RangeValue**'+lstShippingCost[0].RangeValue__c);
        } 

    }    


    
    /*
    Public Static List<ProductComponentPricing__c> InsertProductComponentPricing(List<Product2> lst_prod,List<ProductComponent__c> lstProductComponent, Id PriceBookId,Boolean doInsert){

        List<ProductComponentPricing__c> lstPricing = new List<ProductComponentPricing__c>();

        integer exid=0;
        for(Product2 prod:lst_prod){
    
            for(ProductComponent__c ItemGrp:lstProductComponent){  
        
                    ProductComponentPricing__c Pricing = new ProductComponentPricing__c();
                    Pricing.StartDate__c= system.today()-15;
                    Pricing.EndDate__c = system.today()+115;           
                    Pricing.ProductComponent__c=ItemGrp.Id;
                    Pricing.ComponentPrice__c= 123;
                    Pricing.IsActive__c = true;
                    Pricing.PriceBook__c = PriceBookId;   
                    Pricing.Subsidiary__c= 'Plantyn';
                  //  Pricing.SubsidiaryRAW__c= 'Plantyn'; 
                    lstPricing.add(Pricing);
                    exid++;

                    system.debug('**Insert Pricing: 1**');
            }                  
        }
        if(doInsert) {
            Insert lstPricing;
            system.debug('**Insert Pricing: 2**');
        } 

        return lstPricing;

    }
    */


    Public Static List<ProductComponent__c> InsertGroupComponent(List<Product2> lst_prod,List<Product2> lst_ItemGroup,Boolean doInsert){
        
      
        List<ProductComponent__c> lstProductComponent = new List<ProductComponent__c>();

        for(Product2 prod:lst_prod){
            for(Product2 prdcmp:lst_ItemGroup){
                ProductComponent__c ProductComponent = new ProductComponent__c();
                ProductComponent.MainProduct__c = prod.id;
                ProductComponent.Type__c='Item Group Component';
                ProductComponent.Product__c= prdcmp.id;   
                ProductComponent.Quantity__c = 4;                        
                lstProductComponent.add(ProductComponent);
            }                  
        }
        if(doInsert) {
            Insert lstProductComponent;
        } 
        
        return lstProductComponent;
    
    }


    Public static List<OrderShipto__c> insertOrderShipto(Integer Count,List<Order> lst_Ord, List<Account> lst_Acc,Boolean doInsert){

     
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
        if(doInsert) {
            insert lst_OrderShipto;
        }
       
        return lst_OrderShipto;    
    
    }
    Public static List<ListPriceDiscount__c> insertListPriceDiscount(Integer Count,String OrderLineType,String ProductDiscountGroup,Boolean doInsert){ 
       
        List<ListPriceDiscount__c> lst_ListPriceDiscount = new List<ListPriceDiscount__c>();
            
        for(Integer i=0;i<Count;i++){                           
            ListPriceDiscount__c ListPrice = new ListPriceDiscount__c();  
            ListPrice.ProductDiscountGroup__c  = ProductDiscountGroup; 
            ListPrice.Rate__c = i+5;
            ListPrice.StartQuantity__c = i*65;
            ListPrice.DiscountType__c ='Normal'; 
            ListPrice.MarketSegment__c ='SecondaryEducation';
            ListPrice.CustomerDiscountGroup__c='Educational Institution';
            ListPrice.ProductDiscountGroup__c = ProductDiscountGroup;
            ListPrice.OrderLineType__c   = OrderLineType; 
            ListPrice.EndDate__c = system.today()+30;
            ListPrice.StartDate__c = system.today()-30;     
            lst_ListPriceDiscount.add(ListPrice);       
        }
        if(doInsert) {
            insert lst_ListPriceDiscount;
        }
        
        return lst_ListPriceDiscount;    
    
    }
    Public static List<ImportOrder__c> insertImportOrderOrder(List<Account> lstAccount,Boolean doInsert,String ExternalOrderId){ 
     
        List<ImportOrder__c> lstImportOrder = new List<ImportOrder__c>();

        Integer i=0;
        
        String DayO = String.Valueof(system.today().day());
        String MonthO = String.Valueof(system.today().Month());

        if(system.today().day() <10){
            DayO = '0'+ String.Valueof(system.today().day());
        }
        if(system.today().Month() <10){
            MonthO  = '0'+ String.Valueof(system.today().Month());
        }

        String OrderDate = DayO+'-'+MonthO+'-'+system.today().year();

        for(Account acc:lstAccount){
            ImportOrder__c ImportOrder = new ImportOrder__c();
            ImportOrder.quantity__c =5;
            ImportOrder.ExternalOrderId__c = ExternalOrderId;
            ImportOrder.orderDate__c = OrderDate;
            ImportOrder.OperatingCompany__c = 'Plantyn';
            ImportOrder.customerNo__c = acc.NetsuiteInternalId__c;
            lstImportOrder.add(ImportOrder);    
            i++;
        }

        if(doInsert) {
            insert lstImportOrder;
        }
        system.debug('**InImport Order: orderDate**'+lstImportOrder[0].orderDate__c);
        system.debug('**InImport Order: effectivedate**'+lstImportOrder[0].effectivedate__c);

        return lstImportOrder;
    }    
    Public static List<ImportOrder__c> insertImportOrderItem(List<Product2> lstProduct,Boolean doInsert,String ExternalOrderId, String GoupItemId){ 
     
        List<ImportOrder__c> lstImportOrder = new List<ImportOrder__c>();

        for(Product2 prod:lstProduct){
            ImportOrder__c ImportOrder = new ImportOrder__c();
            ImportOrder.quantity__c =5;
            ImportOrder.ExternalOrderId__c = ExternalOrderId;
            system.debug('**Import Item: ISBN*'+prod.ISBN__c);
            ImportOrder.ProductId__c = prod.ISBN__c;
            ImportOrder.itemGroupId__c = GoupItemId;
            lstImportOrder.add(ImportOrder);    
        }


        if(doInsert) {
            insert lstImportOrder;
        }

        return lstImportOrder;
    }    
       

}