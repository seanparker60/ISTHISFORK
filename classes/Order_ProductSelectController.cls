public class Order_ProductSelectController {
    

//------------------------------ Aura Methods

    @auraenabled
    Public static  Order  returnOrder(String OrderId){       
        
        Order[] Order; 
            try {
                Order = [Select Type from Order where id=:OrderId];
                return  Order[0];

            }
            catch (Exception e) {
                HandleCustomException.LogException(e,OrderId);
                system.debug('**ProductSelect ReturnOrder: '+ e.getMessage());
                throw new AuraHandledException('Something went wrong: ' + e.getMessage() + 'Please contact system administator'); 
            }
            
       // return  Order[0];
    
    } 


    @auraenabled
    Public static List<ProductListPrice>  loadProductsbyPriceBookContract(List<OrderLineItem> OrderItems, String ContractId,Decimal NoStudents,List<String> ShiptoId,String ExistingContract,String ContractRenewal,String PricingMethod){      
        

        List<ProductListPrice> lstProductListPrice;
        try {

            Contract[] Contract = [Select PriceBook2Id from Contract where id=:ContractId];
            
            lstProductListPrice = loadProductsbyPriceBook(OrderItems,null,Contract[0].Pricebook2Id,NoStudents,ShiptoId,ExistingContract,ContractRenewal,PricingMethod,null);
            return  lstProductListPrice;
        }
        catch (Exception e) {
            HandleCustomException.LogException(e,ContractId);
            system.debug('**ProductSelect loadProductsby Contract: '+ e.getMessage());
            throw new AuraHandledException('Something went wrong: ' + e.getMessage() + ' - Please contact system administator');    
        }
       


        
    }   

    @auraenabled
    Public static List<ProductListPrice>  loadProductsbyPriceBookOrder(List<OrderLineItem> OrderItems,String OrderId,Decimal NoStudents,List<String> ShiptoId,String ExistingContract,String ContractRenewal,String PricingMethod){        
        
        List<ProductListPrice> lstProductListPrice;
        try {
            Order[] Order = [Select PriceBook2Id,PricingMethod__c from Order where id=: OrderId];
            PricingMethod = Order[0].PricingMethod__c;
         
            lstProductListPrice = loadProductsbyPriceBook(OrderItems,null,Order[0].Pricebook2Id,NoStudents,ShiptoId,ExistingContract,ContractRenewal,PricingMethod,null);
            return  lstProductListPrice;   
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            HandleCustomException.LogException(e,OrderId);
            system.debug('**ProductSelect loadProductsby Order: '+ e.getMessage());
            throw new AuraHandledException('Something went wrong: '  + e.getMessage() + ' - Please contact system administator');    
        }
        
        
    
    } 
    @auraenabled
    Public static List<ProductListPrice>  loadProductsbySearch(List<OrderLineItem> OrderItems,List<OrderLineItem> SelectedItems,String OrderId,String searchString){        
        
            

        try {

            List<ProductListPrice> lstProductListPrice;
            Order[] Order = [Select PriceBook2Id from Order where id=:OrderId];
            // system.debug('** Contract**'+ Contract);     
            lstProductListPrice = loadProductsbyPriceBook( OrderItems,SelectedItems,Order[0].Pricebook2Id,null,null,null,null,null,searchString);
            return  lstProductListPrice;

        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            HandleCustomException.LogException(e,OrderId);
            system.debug('**ProductSelect loadProductsby Search: '+ e.getMessage());
            throw new AuraHandledException('Something went wrong: '  + e.getMessage() + ' - Please contact system administator');    
        }
       
        
    
    }
    


    @auraenabled
    Public static List<OrderLineItem>  loadOrderItems(String OrderId, Decimal NoStudents, String PricingMethod){ 
        
        
             try {

                List<OrderLineItem> lstOrderLineItems = new List<OrderLineItem>();
                if(OrderId != null){
                    Order[] Order = [Select PriceBook2Id,PricingMethod__c from Order where id=: OrderId];
                    PricingMethod = Order[0].PricingMethod__c;
    
                }
                                          
                lstOrderLineItems = returnOrderItems(OrderId, NoStudents,PricingMethod);                   
                return lstOrderLineItems;
            }
            catch (Exception e) {
                // "Convert" the exception into an AuraHandledException
                HandleCustomException.LogException(e,OrderId);
                system.debug('**ProductSelect loadOrderItems: '+ e.getMessage());
                throw new AuraHandledException('Something went wrong: ' + e.getMessage() + ' - Please contact system administator');    
        }
       

            
    }
    

    @auraenabled
    Public static String   InsertOrderItems(List<OrderLineItem> OrderItems,String ContractId,String OrderId, Decimal TotalNumberofStudents,List<Account> AccountbyShipto){      
        
        System.enqueueJob(new Order_OrderInsertQueueable(ContractId,OrderId, TotalNumberofStudents,true,AccountbyShipto));
        ProcessInsertOrderItems(OrderItems,ContractId,OrderId,TotalNumberofStudents, AccountbyShipto);       
       
        return OrderId;
    }



    @auraenabled
    Public static List<ListPriceDiscount__c> loadListPriceDiscountType(String OrderId){        
         
        ListPriceDiscount__c[] lst_ListPriceDiscountRegular;
        try { 

            Date CurDate = system.today();
            Order[] Order = [Select Billto__r.OperatingCompany__c,Billto__r.CustomerDiscountGroup__c,Source__c,PricingMethod__c  from Order where id=:OrderId];
             

            //------------ADD OPERATING COMPANY
            if(Order[0].Source__c =='Trade' || Order[0].Source__c =='B2B Shop' || Order[0].Source__c =='B2B Salesforce'){
                String Querystr;

                system.debug('**ProductSelect ListPriceDiscount:Order.Source '+ Order[0].Source__c);
                
                String OperatingCompany,CustomerDiscountGroup;
                OperatingCompany = Order[0].Billto__r.OperatingCompany__c;
                CustomerDiscountGroup = Order[0].Billto__r.CustomerDiscountGroup__c;

                querystr = 'Select Id,ProductDiscountGroup__c,Subsidiary__c,ValueType__c,StartAmount__c,    DiscountType__c,CustomerDiscountGroup__c,OrderLineType__c, MarketSegment__c,Rate__c,StartQuantity__c From ListPriceDiscount__c where  EndDate__c >=:CurDate AND StartDate__c  <=:CurDate AND CustomerDiscountGroup__c =: CustomerDiscountGroup AND Subsidiary__c =: OperatingCompany';
                if(Order[0].PricingMethod__c=='OrderTotalAmount'){
                    querystr += ' AND ValueType__c = \'Amount\' ';
                    querystr += ' ORDER BY StartAmount__c DESC';
                }
                else{
                    querystr += ' AND ValueType__c = \'Quantity\' '; 
                    querystr += ' ORDER BY StartQuantity__c DESC'; 
                }
               // lst_ListPriceDiscountRegular = [Select Id,ProductDiscountGroup__c,Subsidiary__c,ValueType__c,StartAmount__c,    DiscountType__c,CustomerDiscountGroup__c,OrderLineType__c, MarketSegment__c,Rate__c,StartQuantity__c From ListPriceDiscount__c where  EndDate__c >=:CurDate AND StartDate__c  <=:CurDate AND CustomerDiscountGroup__c =: Order[0].Billto__r.CustomerDiscountGroup__c AND Subsidiary__c =: Order[0].Billto__r.OperatingCompany__c   
                 // ORDER BY StartQuantity__c DESC];

                lst_ListPriceDiscountRegular =Database.query(querystr);                                                   
            }                                                              
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            HandleCustomException.LogException(e,OrderId);
            system.debug('**ProductSelect ListPriceDiscount: '+ e.getMessage());
            throw new AuraHandledException('Something went wrong: ' + e.getMessage() + 'Please contact system administator');    
        }
        
        
        system.debug('** lst_ListPriceDiscountRegular**'+ lst_ListPriceDiscountRegular);
        return  lst_ListPriceDiscountRegular;


    }

    @auraenabled
    Public static List<AssetList> loadAssetsforRate (String OrderId, List<String> ShiptoId, String PricingMethod){
       
        List<AssetList> lstAssetList = new List<AssetList>();
        try { 
           
            //----------TEST MODAL ORDER---------------
            Set<String> Set_BillTo = new Set<String>();
                    if(OrderId != null){
                        Order[] Order = [Select PriceBook2Id,PricingMethod__c,Billto__c from Order where id=:OrderId];
                        PricingMethod = Order[0].PricingMethod__c;

                        Set_BillTo.add(Order[0].Billto__c);

                    }
            //-------------------------


            Date CurrrentDay = system.today();

         

                system.debug('**Set_BillTo**'+Set_BillTo);

                asset[] loadAssetsListGroupRate  = [Select id,Name,Product2.Name,PriceBook__c,PriceBook__r.FollowUpPriceBook__c,RenewalDate__c,Account.DigitalActivationEmail__c ,Product2.ProductDiscountGroup__c,Product2.ProductRateGroup__c,RenewalTerm__c,IsUpForRenewal__c,AccountId,PricingMethod__c,BillToAccount__r.ShippingCostMethod__c,BillToAccount__r.PaymentMethod__c,Price,Quantity, BillToAccount__c,Product2Id 
                                            from asset 
                                            where (CancellationDate__c >: CurrrentDay OR CancellationDate__c =:null)
                                            AND RenewalDate__c  >=: CurrrentDay
                                            AND (ActivationDate__c <=: CurrrentDay OR  ActivationDate__c =: null)
                                            AND IsActive__c =: true
                                            AND BillToAccount__c in:Set_BillTo
                                            AND Contract__c =:null];              
                
                for(asset ass:loadAssetsListGroupRate){
                    system.debug('**ass.Name**'+ass.Name);
                    AssetList asset = new AssetList();
                    asset.Id = ass.id;
                    asset.Name = ass.Name ;
                    asset.ProductName = ass.Product2.Name;
                    asset.ProductId = ass.Product2Id;
                    asset.Quantity = ass.Quantity;
                    asset.ProductRateGroup = ass.Product2.ProductRateGroup__c;
                    asset.BillToAccount = ass.BillToAccount__c;
                    lstAssetList.add(asset);
                }  
                return lstAssetList; 
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            HandleCustomException.LogException(e,OrderId);
            system.debug('**ProductSelect AssetsforRate: '+ e.getMessage());
            throw new AuraHandledException('Something went wrong: '+ e.getMessage() + 'Please contact system administator');    
        }
               

                                    

    }
    @auraenabled
    Public static Account  loadAccountbyBillto(String OrderId){    
         
        Account[] AccountbyBillto;
        
            try {
                Order[] Order = [Select Billto__c from Order where id=:OrderId];                                 
                 AccountbyBillto = [Select Id,name,OperatingCompany__c,CustomerDiscountGroup__c  from Account where id =:Order[0].Billto__c  ]; 
                 return AccountbyBillto[0]; 
            } 
            catch (Exception e) {
                // "Convert" the exception into an AuraHandledException
                HandleCustomException.LogException(e,OrderId);
                system.debug('**ProductSelect AccountbyBillto: '+ e.getMessage());
                throw new AuraHandledException('Something went wrong: ' + e.getMessage() + 'Please contact system administator');    
            }
             

            
        }        
    
    @auraenabled
    Public static List<ShiptoAccount>  loadAccountbyShipto(String OrderId, List<String> ShiptoId){    
        List<ShiptoAccount> lstShiptoAccount = new List<ShiptoAccount>();
        
        try {
            
            List<Account> AccountbyShipto = new List <Account>([Select Id,name,NumberofStudents__c, OperatingCompany__c,DefaultBillto__r.CustomerDiscountGroup__c, PurchasingGroup__r.CustomerDiscountGroup__c,CustomerDiscountGroup__c from Account where NumberofStudents__c >=: 0 AND id in:ShiptoId  ]); //      ]); //   Use_in_flow__c =:true 
           
                system.debug('**AccountbyShipto**'+AccountbyShipto);

                for(Account acc:AccountbyShipto){
                    
                    ShiptoAccount ShiptoAccount = new ShiptoAccount();
                    ShiptoAccount.Name = acc.Name;
                    ShiptoAccount.Id =acc.Id;
                    ShiptoAccount.NumberofStudents =acc.NumberofStudents__c;
                    ShiptoAccount.OperatingCompany = acc.OperatingCompany__c;

                    if(acc.DefaultBillto__r.CustomerDiscountGroup__c != null ){
                        ShiptoAccount.CustomerDiscountGroup =   acc.DefaultBillto__r.CustomerDiscountGroup__c;
                    }
                    else if(acc.PurchasingGroup__r.CustomerDiscountGroup__c != null ){
                        ShiptoAccount.CustomerDiscountGroup =   acc.PurchasingGroup__r.CustomerDiscountGroup__c;
                    }
                    else if(acc.CustomerDiscountGroup__c != null ){
                        ShiptoAccount.CustomerDiscountGroup =   acc.CustomerDiscountGroup__c;
                    }
                    lstShiptoAccount.add(ShiptoAccount);
                }
            }
            
            catch (Exception e) {
                // "Convert" the exception into an AuraHandledException
                HandleCustomException.LogException(e,OrderId);
                system.debug('**ProductSelect AccountbyShipto: '+ e.getMessage());
                throw new AuraHandledException('Something went wrong: '    + e.getMessage() + 'Please contact system administator');    
            }
          
        Return lstShiptoAccount;
        
    }
    

    //--------------------------------Handler Methods

    Public static List<OrderLineItem>  returnOrderItems(String curOrderId, Decimal NoStudents, String PricingMethod){     
        
        List<OrderLineItem> lstOrderLineItems = new List<OrderLineItem>();

      
        /*,OrderLineItemType__c*/
        OrderItem[] lstOrderItem = [Select id,NetsuiteQuantity__c,ProductComponent__c,ProductComponent__r.Quantity__c, ComponentListPrice__c, Product2.maxQuantity__c,NetSalesPriceItemGroup__c,DiscountedPriceItemGroup__c,ListPriceItemGroup__c,
        Product2.ProductRateGroup__c,LineItemTotal__c,Product2.Renewable__c,ItemGroup__r.Product2Id,Product2.OrderLineType__c,Product2.MarketSegment__c,Product2.name,Product2.SoldInSegment__c,
        Product2.QuantitySelectionType__c,OrderId,ItemGroup__c,ShipToAccount__r.Name,ShipToAccount__r.CustomerDiscountGroup__c,ListPrice,UnitPrice,Quantity,Product2.ProductDiscountGroup__c,OrderLineType__c,
        ListPriceDiscount__c,ListPriceDiscount__r.OrderLineType__c,ListPriceDiscount__r.Rate__c,Product2Id,PricebookEntryId,ShipToAccount__c,ManualDiscount__c,ManualDiscountPercent__c,ManualDiscountValue__c 
        From OrderItem where OrderId =:curOrderId Order By createddate ASC];

        

        //Return ProductsbyPriceBook;
        Order[] curOrder = [Select Pricebook2Id,Billto__r.CustomerDiscountGroup__c,Billto__r.OperatingCompany__c from Order where Id =:curOrderId]; 
        //PriceBook__c=:curOrder[0].Pricebook2Id  AND
     

       
        //List Price Discount - Need to recaculate for any updates to values since last save / adding ship to's will change the quantity                        
        Date CurDate = system.today();

        
                                                                 

        Map<String,Decimal> Map_OrderProdMap = new Map<String,Decimal>(); 
        Map<String,List<String>> Map_PriceProductType = new Map<String,List<String>>();
        Map<String,List<OrderLineItem>> Map_Component = new Map<String,List<OrderLineItem>>();

        Set<String> Set_ItemGroup = new Set<String>();
        Set<String> Set_ProdItemGroup = new Set<String>();
        String ProdGroup;
   
        List<OrderLineItem> lst_Component;
        
        Map<String,List<ListPriceDiscount>> Map_PriceDiscount = listPriceDiscount(curOrder[0].Pricebook2Id,NoStudents);
        List<OrderItem> lstNonComponentOrderItem = new  List<OrderItem>();




        for(OrderItem Item:lstOrderItem){
            Set_ProdItemGroup.add(Item.Product2Id);
            Set_ItemGroup.add(Item.ItemGroup__c); 
        }    


        Pricing__c[] lstPrice = [Select ListRate__c,Product__c,EndDate__c,IsActive__c,ProductComponent__r.Quantity__c,ProductComponent__r.Type__c,ProductComponent__r.MainProduct__c,ProductComponent__r.Product__c from Pricing__c 
        Where   (ProductComponent__r.MainProduct__c in: Set_ProdItemGroup OR Product__c in: Set_ProdItemGroup OR ProductComponent__r.Product__c in: Set_ProdItemGroup )
        AND StartDate__c <=: system.today()
        AND EndDate__c >=: system.today()
        AND IsActive__c =:true];
        
        Map<String,Decimal> Map_ComponentQuantity  =  new Map<String,Decimal>();
         
       for(Pricing__c item:lstPrice){   
           system.debug('**Item Group Component: Out **'+item.ProductComponent__r.Type__c);
            if(item.ProductComponent__r.Type__c=='Item Group Component' || item.ProductComponent__r.Type__c=='Kit Component' ){ //
                
                Map_ComponentQuantity.put(item.ProductComponent__r.Product__c,item.ProductComponent__r.Quantity__c);
                 
            }                   
        }

       //This is used to make sure that item groups display together on the Product selector
       Integer Count = 1;
        for(OrderItem Item:lstOrderItem){

            //List Price discount information
            ProdGroup = Item.Product2.Name+ Item.Product2.ProductDiscountGroup__c+ Item.ShipToAccount__r.CustomerDiscountGroup__c;

            if(PricingMethod != 'AccountStudents'){
                if(Map_OrderProdMap.get(ProdGroup)== null){      
                    Map_OrderProdMap.put(ProdGroup,Item.Quantity);       
                }
                else{
                    Map_OrderProdMap.put(ProdGroup ,Map_OrderProdMap.get(ProdGroup)+Item.Quantity);         
                }
            } 
            else{
                    Map_OrderProdMap.put(ProdGroup ,Item.Quantity);   
            }

            List<String> PriceProductType = new List<String>();
            PriceProductType.AddAll(Item.Product2.OrderLineType__c.Split(';'));
                            
            Map_PriceProductType.put(Item.id,PriceProductType);

            //Product Component information--------Determine if there are any PackComponents
           

            //---------------------------
            if(Item.ItemGroup__c != null){

                if(Map_Component.get(Item.ItemGroup__c)==null){
                    lst_Component = new List<OrderLineItem>();
                    lst_Component.add(OrderLineItemWrapperCreate(curOrder, Map_PriceDiscount, Set_ItemGroup,Item, PricingMethod, Map_ComponentQuantity,Count)); 
                    Map_Component.put(Item.ItemGroup__c,lst_Component);
                }
                else{
                    Map_Component.get(Item.ItemGroup__c).add(OrderLineItemWrapperCreate(curOrder, Map_PriceDiscount, Set_ItemGroup, Item, PricingMethod, Map_ComponentQuantity,Count));
                }                
                Count++;
            }
            else{
                lstNonComponentOrderItem.add(Item);
            }
        //---------------------------

            
        }
        system.debug('**Load Orders: Set_ItemGroup**'+Set_ItemGroup);
   
       

       List<String> ManualDiscount  = new List<String>();
       ManualDiscount.add('--None--');
        ManualDiscount.add('Percent');
        ManualDiscount.add('Value');

        Boolean listPriceSelected;
        String ItemId;
        
        //This is used to make sure that item groups display together on the Product selector
        for(OrderItem OItem:lstNonComponentOrderItem){
           //---------------------------
          if(OItem.ItemGroup__c == null){
            lstOrderLineItems.Add(OrderLineItemWrapperCreate(curOrder, Map_PriceDiscount, Set_ItemGroup,OItem, PricingMethod, Map_ComponentQuantity,Count));
            Count++;
          }  
          

          if(Map_Component.get(OItem.id)!=null){
                     for(OrderLineItem item:Map_Component.get(OItem.id)){
                        lstOrderLineItems.add(item);
                    }
          }
        }
        

        return lstOrderLineItems;

    }    
    
    //Adds all line items
    public Static OrderLineItem OrderLineItemWrapperCreate(Order[] curOrder, Map<String,List<ListPriceDiscount>> Map_PriceDiscount,Set<String> Set_ItemGroup,OrderItem OItem,String PricingMethod, Map<String,Decimal> Map_ComponentQuantity,Integer Count){

                


        
         Boolean listPriceSelected;
         String ItemId;
         
         List<String> ManualDiscount;
              
             OrderLineItem Item = new OrderLineItem();

             
             ItemId =OItem.id;
             Item.Count = Count;
             Item.ItemId = ItemId; // 
             Item.OrderId = OItem.OrderId; 
             Item.IId = OItem.id;
             Item.Subsidiary = curOrder[0].Billto__r.OperatingCompany__c;
             if(OItem.ItemGroup__c != null){
                 Item.ItemGroupProductId =  OItem.ItemGroup__r.Product2Id;
                 ItemId = OItem.ItemGroup__c;
                 Item.ItemGroup =ItemId;
             }
 
             if(Set_ItemGroup.contains(OItem.id)){
                 Item.ItemGroupComponent = true;
             }
             else{
                 Item.ItemGroupComponent = false; 
             }
             Item.ItemGroupId = OItem.ProductComponent__c;
             Item.Quantity = OItem.Quantity;
             Item.maxQuantity = OItem.Product2.maxQuantity__c; 
             Item.ProductName =  OItem.Product2.name;
             Item.MarketSegment = OItem.Product2.MarketSegment__c;
             Item.ProductId = OItem.Product2Id;
             Item.PricebookEntryId = OItem.PricebookEntryId;
             Item.ShipToAccountId = OItem.ShipToAccount__c; 
             Item.CustomerDiscountGroup =curOrder[0].Billto__r.CustomerDiscountGroup__c;
             Item.DiscountPercent = OItem.ManualDiscountPercent__c;
             Item.DiscountAmount = OItem.ManualDiscountValue__c;  

             if(Map_ComponentQuantity.get(OItem.Product2Id) != null){
              
                if(OItem.NetsuiteQuantity__c != null){
                    //NETSUITE QUANTITY UPDATE 
                   // Item.ComponentQuantity = OItem.NetsuiteQuantity__c/OItem.Quantity;

                    Item.ComponentQuantity = OItem.ProductComponent__r.Quantity__c;
                    Item.Quantity = OItem.NetsuiteQuantity__c;

                }
                else{
                    Item.ComponentQuantity = OItem.Quantity;
                    Item.Quantity = OItem.Quantity;
                }
                 
                  Item.ComponentQuantityFinal = OItem.Quantity; 
                Item.ComponentQuantityTitle = 'Pack quantity: '+Item.ComponentQuantity; 
             }
             else{
                Item.ComponentQuantity =  OItem.Quantity;
                Item.ComponentQuantityTitle = 'Pack quantity: '+OItem.Quantity;
             }         
             
             Item.ShipToAccountId = OItem.ShipToAccount__c;
             Item.ShipToAccountName = OItem.ShipToAccount__r.Name;            
             Item.QuantitySelectionType =  OItem.Product2.QuantitySelectionType__c;
              
             Item.listPriceDiscountType  = OItem.Product2.ProductDiscountGroup__c;
             Item.ProductRateGroup = OItem.Product2.ProductRateGroup__c;
 
             List<String> PriceProductType = new List<String>();
            
             PriceProductType.AddAll(OItem.Product2.OrderLineType__c.Split(';'));
             Item.listPriceProductType = PriceProductType;
 
           
            if(OItem.OrderLineType__c != null){    
                 Item.PriceDiscount = OItem.OrderLineType__c;                 
             }
             else{
               //  Item.PriceDiscount =  '--None--';
             }
             
             
             ManualDiscount  = new List<String>();
              
             ManualDiscount.add('--None--');
             if(OItem.Product2.Renewable__c ==true){
                 ManualDiscount.add('Recurring Percentage');
                 ManualDiscount.add('Recurring Amount');
                 ManualDiscount.add('One-Off Percentage');
                 ManualDiscount.add('One-Off Amount');
                 ManualDiscount.add('One-Off Amount (Subtotal)');
             }
             else{
                 ManualDiscount.add('One-Off Percentage');
                 ManualDiscount.add('One-Off Amount');
                 ManualDiscount.add('One-Off Amount (Subtotal)');
             }
             
             Item.ManualDiscount = ManualDiscount;
 
             Item.DiscountOption = OItem.ManualDiscount__c;
 
             Set<String> Set_SoldInSegment = new Set<String>();
            
             if(OItem.Product2.SoldInSegment__c != null){

                // Set_SoldInSegment.AddAll(OItem.Product2.SoldInSegment__c.Split(';'));  
             
             }
             system.debug('**Map_PriceDiscount**'+Map_PriceDiscount.get(OItem.Product2.ProductDiscountGroup__c)); 
             
             List<ListPriceDiscount> AddlistPriceDiscount;
             //Need to confirm this remove
             if(Map_PriceDiscount.get(OItem.Product2.ProductDiscountGroup__c) != null){
               //  AddlistPriceDiscount = AddlistPriceDiscount(OItem.Product2.MarketSegment__c,Map_PriceDiscount.get(OItem.Product2.ProductDiscountGroup__c));
             }
             //Item.listPriceDiscount = AddlistPriceDiscount;

             if(OItem.ItemGroup__c != null){
                Item.BasePrice = OItem.ComponentListPrice__c;
            }
            else{
                Item.BasePrice = OItem.ListPrice;                
            }

             
               
 
             //Populate totals and discount
                 Item.listPriceRateId = OItem.ListPriceDiscount__c;  
             
                 system.debug('**PricingMethod**'+PricingMethod);
                 if(PricingMethod == 'OrderTotalRate'){
                     Item.STDPrice = OItem.UnitPrice;
                 }
                 else if(OItem.ListPriceDiscount__c != null){
                    if(OItem.ItemGroup__c != null){
                        Item.STDPrice  = OItem.ComponentListPrice__c - (OItem.ComponentListPrice__c* (OItem.ListPriceDiscount__r.Rate__c)/100);
                    }
                    else{
                        Item.STDPrice  = OItem.ListPrice - (OItem.ListPrice* (OItem.ListPriceDiscount__r.Rate__c)/100);                
                    }

                     
                 }
                 else{
                    if(OItem.ItemGroup__c != null){
                        Item.STDPrice  = OItem.ComponentListPrice__c;
                    }
                    else{
                        Item.STDPrice  = OItem.ListPrice;                
                    }

                     
                 }
 
                 if(Set_ItemGroup.contains(OItem.id)){                    
                    // Item.UnitPrice =  OItem.NetSalesPriceItemGroup__c;  
                     Item.STDPrice = OItem.DiscountedPriceItemGroup__c;
                     Item.BasePrice = OItem.ListPriceItemGroup__c;
                 }  
 
                 if(OItem.ManualDiscount__c == 'Recurring Percentage' || OItem.ManualDiscount__c == 'One-Off Percentage' ){
                     Item.DiscountPercentShow = true;
                     Item.DiscountValueShow = false;
                   //  Item.Amount = OItem.Quantity * (Item.STDPrice - (Item.STDPrice * (OItem.ManualDiscountPercent__c/100)  )); 
                     Item.NoDiscAmount =OItem.Quantity * (Item.STDPrice);
                 }
                 else if(OItem.ManualDiscount__c == 'Recurring Amount' || OItem.ManualDiscount__c == 'One-Off Amount' || OItem.ManualDiscount__c == 'One-Off Amount (Subtotal)'){
                     Item.DiscountValueShow = true;
                     Item.DiscountPercentShow = false;
                     system.debug('**Quantity**'+OItem.Quantity+'**List Price**'+Item.STDPrice+'**Manual**'+OItem.ManualDiscountValue__c);
                    // Item.Amount = (OItem.Quantity * Item.STDPrice) - OItem.ManualDiscountValue__c ; 
                     Item.NoDiscAmount =OItem.Quantity * (Item.STDPrice);
                 }
                 
                 else{
                     Item.DiscountValueShow = false;
                     Item.DiscountPercentShow = false;
                    // Item.Amount = OItem.Quantity * (Item.STDPrice); 
                     Item.NoDiscAmount =Item.Amount;
                 }
 
                 if(Set_ItemGroup.contains(OItem.id)){      
                     system.debug('**Load Orders: contains(OItem.id)**');              
                      Item.UnitPrice =  OItem.NetSalesPriceItemGroup__c;  
                      
                 }  
                 else{
                    // Item.UnitPrice = (Item.Amount/OItem.Quantity).setScale(2);
                    Item.UnitPrice = OItem.UnitPrice;
                 }
                 system.debug('***Load: ID**'+OItem.id);
                 system.debug('***Load: Quantity**'+OItem.Quantity);
                 system.debug('***Load: UnitPrice**'+Item.UnitPrice);

                 Item.Amount = (OItem.Quantity * Item.UnitPrice);

        return Item;
    }



    Public static List<ProductListPrice>  loadProductsbyPriceBook(List<OrderLineItem> OrderItem,List<OrderLineItem> SelectedItems, String Pricebook2Id,Decimal NoStudents, List<String> ShiptoId,String ExistingContract,String ContractRenewal,String PricingMethod, String SearchString){ 
        

        Set<String> Set_OrdProd = new Set<String>();
      
        system.debug('***Search: Start ');

        
                

        List<PricebookEntry> ProductsbyPriceBook;
        if(SearchString == null){
            /*Product2.maxQuantity__c,*/
            ProductsbyPriceBook = new List <PricebookEntry>([Select Price__c,Product2.Stocknumber__c,Product2.maxQuantity__c,Product2.DeliveryStatus__c,Product2.Renewable__c,Product2.OrderLineType__c,Product2.ISBNArticleNumber__c,Product2.MarketSegment__c,Product2.name,Product2.SoldInSegment__c, Product2.QuantitySelectionType__c,Product2.ProductDiscountGroup__c,Product2.ProductRateGroup__c,Product2.Type__c,productcode,unitprice,Product2Id from PricebookEntry //,
            where Pricebook2Id =:Pricebook2Id 
            AND IsActive =: true 
            AND Product2.itemGroupManualBlock__c =: false
            AND Product2Id not in: Set_OrdProd
            AND Product2.HasBlock__c=: false Order by Product2.Name ASC limit 70 ]); //AND IsActive =:true

        }
        else{
            /*Product2.maxQuantity__c,*/
            String Search = '%'+SearchString+'%';
            ProductsbyPriceBook = new List <PricebookEntry>([Select Price__c,Product2.Stocknumber__c,Product2.maxQuantity__c,Product2.DeliveryStatus__c,Product2.Renewable__c,Product2.OrderLineType__c,Product2.ISBNArticleNumber__c,Product2.MarketSegment__c,Product2.name,Product2.SoldInSegment__c, Product2.QuantitySelectionType__c,Product2.ProductDiscountGroup__c,Product2.ProductRateGroup__c,Product2.Type__c,productcode,unitprice,Product2Id from PricebookEntry //,
            where Pricebook2Id =:Pricebook2Id 
            AND IsActive =: true
            AND Product2Id not in: Set_OrdProd
            AND Product2.HasBlock__c=: false
            AND Product2.itemGroupManualBlock__c =: false
            AND (Product2.Name  like:Search 
            OR Product2.ISBNArticleNumber__c like:Search
            OR Product2.EAN__c like:Search
            OR Product2.ISBN__c like:Search
            OR Product2.Type__c like: Search
            ) Order by Product2.Name ASC limit 70]);
        }
          
        
    
        Set<String> Set_ItemGroup = new Set<String>();
        Set<String> Set_ItemPrice = new Set<String>();
        for(PricebookEntry pbe:ProductsbyPriceBook){
            
            Set_ItemGroup.add(pbe.Product2Id);

            Set_ItemPrice.add(pbe.Price__c);
        }    
        system.debug('****'+Set_ItemGroup);

        Pricing__c[] lstPrice = [Select ListRate__c,Product__c,Product__r.Type__c,EndDate__c,IsActive__c,ProductComponent__r.Quantity__c,ProductComponent__r.Type__c,ProductComponent__r.MainProduct__c,ProductComponent__r.Product__c from Pricing__c 
        Where (ProductComponent__r.MainProduct__c in: Set_ItemGroup OR id in: Set_ItemPrice)
        //(ProductComponent__r.MainProduct__c in: Set_ItemGroup OR Product__c in: Set_ItemGroup OR ProductComponent__r.Product__c in: Set_ItemGroup )
        //AND id in: Set_ItemPrice
        AND StartDate__c <=: system.today()
        AND EndDate__c >=: system.today()
        AND IsActive__c =: true];

        //AND IsActive__c =: true 

        Map<String,Decimal> Map_ProductPrice  =  new Map<String,Decimal>();
        Map<String,Decimal> Map_ProductQuantity  =  new Map<String,Decimal>();
        

        Map<String,Decimal> Map_ItemGroupBasePrice =  new Map<String,Decimal>();            
        Map<String,String> Map_ItemGroup =  new Map<String,String>();
        Map<String,String> Map_ItemGroupId =  new Map<String,String>();
        Map<String,Decimal> Map_ItemGroupPrice  =  new Map<String,Decimal>();
        Map<String,Decimal> Map_ComponentQuantity  =  new Map<String,Decimal>();
        Map<String,Decimal> Map_ComponentCount  =  new Map<String,Decimal>();
        
        Set<String> Set_ItemKitId =  new Set<String>();
        Set_ItemGroup = new Set<String>();

                    
      //  ProductComponent__c[] lstItemGroupComponent = [Select Product__c,MainProduct__c,Type__c from ProductComponent__c where MainProduct__c in: Set_ItemGroup OR Product__c in:Set_ItemGroup];
        
    //CustomerDiscountGroup__c Set and Product2.ProductDiscountGroup__c 

    for(Pricing__c item:lstPrice){   
        system.debug('**Item Group Component: Out **'+item.ProductComponent__r.Type__c);
            if(item.ProductComponent__r.Type__c=='Item Group Component' || item.ProductComponent__r.Type__c=='Kit Component' ){ //
                Map_ItemGroup.put(item.ProductComponent__r.Product__c,item.ProductComponent__r.MainProduct__c);
                Map_ItemGroupId.put(item.ProductComponent__r.Product__c,item.ProductComponent__c); //item.id
                Map_ItemGroupPrice.put(item.ProductComponent__r.Product__c,item.ListRate__c);
                Map_ComponentQuantity.put(item.ProductComponent__r.Product__c,item.ProductComponent__r.Quantity__c);
                Set_ItemGroup.add(item.ProductComponent__r.MainProduct__c);
                
                
                Decimal ListRateMain;
                if(item.ProductComponent__r.Quantity__c != null && item.ListRate__c != null){
                    ListRateMain = item.ProductComponent__r.Quantity__c*item.ListRate__c;
                }
                else{
                    ListRateMain = 0;     
                }
                system.debug('**Item Group Component: In 1 **'+ListRateMain);
                if(Map_ItemGroupPrice.get(item.ProductComponent__r.MainProduct__c) == null){
                    Map_ItemGroupPrice.put(item.ProductComponent__r.MainProduct__c,ListRateMain);
                   // Map_ProductPrice.put(item.ProductComponent__r.Product__c,item.ListRate__c);
                }
                else{
                    Map_ItemGroupPrice.put(item.ProductComponent__r.MainProduct__c,Map_ItemGroupPrice.get(item.ProductComponent__r.MainProduct__c)+ListRateMain);
                 //   Map_ProductPrice.put(item.ProductComponent__r.Product__c,Map_ItemGroupPrice.get(item.ProductComponent__r.Product__c)+item.ListRate__c);
                }
               

                system.debug('**Item Group Component: In 2**'+Map_ItemGroupPrice);
            }
            
            if(item.ProductComponent__r.Type__c=='Kit Component'){
                Set_ItemKitId.add(item.ProductComponent__r.Product__c); 
            }

            
          // NETSUITE QUANTITY UPDATE// MAIN PRODUCT RATE &&  item.Product__r.Type__c !='Item Group'
           if(item.Product__c != null ){
                Map_ProductPrice.put(item.Product__c,item.ListRate__c);
           } 
           

    }        
 
    system.debug('**Item Group Component: Map_ItemGroupId**'+Map_ItemGroupId);
    system.debug('**Item Group Component: Map_ItemGroup**'+Map_ItemGroup);
    system.debug('**Item Group Component: Map_ProductPrice**'+Map_ProductPrice);

        List<ProductListPrice> lstProductListPrice = new List<ProductListPrice>();
        //Used for Item Group Components
        Map<String,List<ProductListPrice>> Map_ProductListPrice = new Map<String,List<ProductListPrice>>();
        //Full List of LPD for picklist
        Map<String,List<ListPriceDiscount>> Map_PriceDiscount = listPriceDiscount(Pricebook2Id,NoStudents);

        Set<String> Set_ProductId = new Set<String>();

        
       List<String> ManualDiscount  = new List<String>();
       ManualDiscount.add('--None--');
        //ManualDiscount.add('Percent');
       // ManualDiscount.add('Value');

        //Populate Item Group map
        List<PricebookEntry> ProductsbyItemGroup;
        if(Map_ItemGroup.size()>0){
            ProductsbyItemGroup = new List <PricebookEntry>([Select Product2.Renewable__c,Product2.OrderLineType__c,Product2.ISBNArticleNumber__c,Product2.MarketSegment__c,Product2.name,Product2.SoldInSegment__c, Product2.QuantitySelectionType__c,Product2.ProductDiscountGroup__c,Product2.ProductRateGroup__c,Product2.Type__c,productcode,unitprice,Product2Id from PricebookEntry //,
            where Pricebook2Id =:Pricebook2Id AND Product2Id in:Map_ItemGroup.keyset() ]); //AND IsActive =:true
        
                for(PricebookEntry pbe:ProductsbyItemGroup){
                    
                    if(Map_ItemGroup.get(pbe.Product2Id) != null){ 
                            ProductListPrice prodlp = new ProductListPrice();                  
                            prodlp.ProductName =  pbe.Product2.name;
                            prodlp.ItemGroup = Map_ItemGroup.get(pbe.Product2Id);
                            
                            prodlp.ItemGroupId = Map_ItemGroupId.get(pbe.Product2Id);

                            prodlp.listPriceDiscountType = pbe.Product2.ProductDiscountGroup__c;
                            prodlp.ProductRateGroup = pbe.Product2.ProductRateGroup__c;

                            prodlp.ProductId = pbe.Product2Id;
                            prodlp.BasePrice  = Map_ItemGroupPrice.get(pbe.Product2Id);
                            prodlp.ComponentQuantity = Map_ComponentQuantity.get(pbe.Product2Id);
                            prodlp.ComponentQuantityTitle = 'Pack quantity: '+Map_ComponentQuantity.get(pbe.Product2Id);
                            
                            /*
                            if(Map_ItemGroupBasePrice.get(Map_ItemGroup.get(pbe.Product2Id))==null){
                                Map_ItemGroupBasePrice.put(Map_ItemGroup.get(pbe.Product2Id),prodlp.BasePrice);
                            }
                            else{
                                Map_ItemGroupBasePrice.put(Map_ItemGroup.get(pbe.Product2Id),Map_ItemGroupBasePrice.get(Map_ItemGroup.get(pbe.Product2Id))+prodlp.BasePrice);
                            }
                            */

                            prodlp.UnitPrice  = pbe.UnitPrice; // - (pbe.UnitPrice* (Map_Rate.get(pbe.Product2.ProductDiscountGroup__c)/100));
                            prodlp.STDPrice = prodlp.BasePrice;
                            
                            prodlp.ProductTYPE = pbe.Product2.Type__c; // pbe.productcode; replacing SKU
                            prodlp.ProductEAN = pbe.Product2.ISBNArticleNumber__c;
                            
                            system.debug('**pbe.Product2.name **'+pbe.Product2.name);
                            prodlp.QuantitySelectionType =  pbe.Product2.QuantitySelectionType__c;
                    
                            prodlp.PricebookEntryId = pbe.Id;
                            
                            
                            Set<String> Set_SoldInSegment = new Set<String>();
                            
                            prodlp.lstMarketSegment = new List<String>();
                           
                        
                            //Only link LPD for that ProductDiscountGroup

                            List<ListPriceDiscount> AddlistPriceDiscount;
                //Need to confirm this remove            
                            if(Map_PriceDiscount.get(pbe.Product2.ProductDiscountGroup__c) != null){
                             //   AddlistPriceDiscount = AddlistPriceDiscount(pbe.Product2.MarketSegment__c,Map_PriceDiscount.get(pbe.Product2.ProductDiscountGroup__c));
                            }
                           // prodlp.listPriceDiscount = AddlistPriceDiscount;
                            
                           
                           Set_ProductId.add(prodlp.ProductId);
                            
                            List<String> PriceProductType = new List<String>();
                        

                        //Possible OrderLine type from the Product - needs to match with listPriceDiscount for a discount to be applied

                            PriceProductType.AddAll(pbe.Product2.OrderLineType__c.Split(';'));
                            prodlp.listPriceProductType = PriceProductType;
                            
                            ManualDiscount  = new List<String>();
                            ManualDiscount.add('--None--');

                            if(pbe.Product2.Renewable__c ==true){
                                ManualDiscount.add('Recurring Percentage');
                                ManualDiscount.add('Recurring Amount');
                                ManualDiscount.add('One-Off Percentage');                                       
                                ManualDiscount.add('One-Off Amount');
                                ManualDiscount.add('One-Off Amount (Subtotal)');
                            }
                            else{
                                ManualDiscount.add('One-Off Percentage');
                                ManualDiscount.add('One-Off Amount');
                                ManualDiscount.add('One-Off Amount (Subtotal)');
                            }

                            prodlp.ManualDiscount = ManualDiscount;
                            prodlp.MarketSegment =  pbe.Product2.MarketSegment__c;
                            
                        if(Map_ProductListPrice.get(Map_ItemGroup.get(pbe.Product2Id)) == null){
                            lstProductListPrice = new List<ProductListPrice>();
                            lstProductListPrice.add(prodlp);
                            Map_ProductListPrice.put(Map_ItemGroup.get(pbe.Product2Id),lstProductListPrice);
                        }
                        else if(Map_ProductListPrice.get(Map_ItemGroup.get(pbe.Product2Id)) != null){
                            Map_ProductListPrice.get(Map_ItemGroup.get(pbe.Product2Id)).add(prodlp);
                        }

                    }        
            }
    }
    system.debug('**ITEM GROUP SET**'+Set_ItemGroup);
    system.debug('**ITEM GROUP MAP**'+Map_ProductListPrice);

        lstProductListPrice = new List<ProductListPrice>();
    for(PricebookEntry pbe:ProductsbyPriceBook){
        system.debug('**Product2.Name**'+pbe.Product2.name);
        if(Map_ProductPrice.get(pbe.Product2Id) != null  ){    // Exclude Item Group items from main list       
                ProductListPrice prodlp = new ProductListPrice();                  
                prodlp.ProductName =  pbe.Product2.name;
           
             
                prodlp.listPriceDiscountType = pbe.Product2.ProductDiscountGroup__c;
                prodlp.ProductRateGroup = pbe.Product2.ProductRateGroup__c;

                 
                prodlp.ProductId = pbe.Product2Id;
                if(Map_ItemGroupPrice.get(pbe.Product2Id) != null){
                    prodlp.BasePrice  = Map_ItemGroupPrice.get(pbe.Product2Id); 
                    prodlp.UnitPrice  = Map_ItemGroupPrice.get(pbe.Product2Id);
                }
                else{
                    prodlp.BasePrice  = Map_ProductPrice.get(pbe.Product2Id); 
                    prodlp.UnitPrice  = Map_ProductPrice.get(pbe.Product2Id);
                   
                }
                prodlp.STDPrice = prodlp.UnitPrice;
             

                prodlp.STDPrice = prodlp.UnitPrice;

                prodlp.ProductTYPE = pbe.Product2.Type__c; 
                prodlp.ProductEAN = pbe.Product2.ISBNArticleNumber__c;
                prodlp.Stocknumber = pbe.Product2.Stocknumber__c;
                prodlp.maxQuantity = pbe.Product2.maxQuantity__c;
                
                prodlp.DeliveryStatus = pbe.Product2.DeliveryStatus__c;

                system.debug('**Product2.Name**'+prodlp.DeliveryStatus);


                    Set<String> Set_SoldInSegment = new Set<String>();
                    prodlp.lstMarketSegment = new List<String>();
                    
                    system.debug('**pbe.Product2Id**'+pbe.Product2Id); 
                            
                    
                    system.debug('**Map_PriceDiscount**'+ pbe.Product2.name);
                    system.debug('**Map_PriceDiscount**'+Map_PriceDiscount.get(pbe.Product2.ProductDiscountGroup__c));

                    List<ListPriceDiscount> AddlistPriceDiscount = new List<ListPriceDiscount>();
                    

            //Need to confirm this remove        
                    if(Map_PriceDiscount.get(pbe.Product2.ProductDiscountGroup__c) != null){
                         //   AddlistPriceDiscount = AddlistPriceDiscount(pbe.Product2.MarketSegment__c,Map_PriceDiscount.get(pbe.Product2.ProductDiscountGroup__c));
                    }
            //        prodlp.listPriceDiscount = AddlistPriceDiscount;

                    prodlp.MarketSegment =  pbe.Product2.MarketSegment__c;
                    
                   system.debug('**AddlistPriceDiscount**'+AddlistPriceDiscount);

                   
                    List<String> PriceProductType = new List<String>();
                    // PriceProductType.add('--None--');
                    PriceProductType.AddAll(pbe.Product2.OrderLineType__c.Split(';'));
                    prodlp.listPriceProductType = PriceProductType;
                    List<String> AmountDiscountManual  = new List<String>();
                    List<String> PercentDiscountManual = new List<String>();
        
                        ManualDiscount  = new List<String>();
                        ManualDiscount.add('--None--');

                            if(pbe.Product2.Renewable__c ==true){
                                ManualDiscount.add('Recurring Percentage');
                                ManualDiscount.add('Recurring Amount');
                                ManualDiscount.add('One-Off Percentage');                                               
                                ManualDiscount.add('One-Off Amount');
                                ManualDiscount.add('One-Off Amount (Subtotal)');
                            }
                            else{
                                ManualDiscount.add('One-Off Percentage');
                                ManualDiscount.add('One-Off Amount');
                                ManualDiscount.add('One-Off Amount (Subtotal)');
                            }

                            prodlp.ManualDiscount = ManualDiscount;
                        prodlp.QuantitySelectionType =  pbe.Product2.QuantitySelectionType__c;
                        if(prodlp.QuantitySelectionType == 'Defaulted to Quantity'){
                            prodlp.Quantity =1;
                        }    
                        else{
                            prodlp.Quantity=null;
                        }

                        prodlp.PricebookEntryId = pbe.Id;
                
                        
                        
                        

                        if(Map_ProductListPrice.get(pbe.Product2Id) != null){
                            system.debug('**Map_ProductListPrice**'+Map_ProductListPrice.get(pbe.Product2Id) + '****'+ pbe.Product2Id);
                            prodlp.listItemGroupComponent  = Map_ProductListPrice.get(pbe.Product2Id);
                            prodlp.ItemGroupComponent = true;
                        }
                        else{
                            prodlp.ItemGroupComponent = false;   
                        }

                    

                        Set_ProductId.add(prodlp.ProductId);
                        lstProductListPrice.add(prodlp);
            }
            
        }
        
        
        // USED TO LIMIT visibility of Products that are not in Customer Group -- Possible deprecation
        //  lstProductListPrice = AssettoAccountMap( Set_ProductId,ShiptoId, lstProductListPrice,ExistingContract,ContractRenewal,PricingMethod);
        
        system.debug('**lstProductListPrice**'+lstProductListPrice.size());
          
        Return lstProductListPrice;
       
       
        
    }
    
    



    public static Map<String,List<ListPriceDiscount>> listPriceDiscount(String Pricebook2Id, Decimal NoStudents){

        Map<String,List<ListPriceDiscount>> Map_PriceDiscount = new Map<String,List<ListPriceDiscount>>();
         
        Date CurDate = system.today();

        ListPriceDiscount__c[] lst_ListPriceDiscountRegular = [Select ProductDiscountGroup__c,DiscountType__c,OrderLineType__c, MarketSegment__c,Rate__c,StartQuantity__c,CustomerDiscountGroup__c From ListPriceDiscount__c  
        where  StartQuantity__c <=: NoStudents   
        AND  EndDate__c >=:CurDate 
        AND StartDate__c  <=:CurDate ORDER BY StartQuantity__c DESC];
        
        Map<String,Decimal> Map_Rate = new Map<String,Decimal>();
        List<ListPriceDiscount> ListPriceDiscount = new List<ListPriceDiscount>();
        
        for(ListPriceDiscount__c lpr:lst_ListPriceDiscountRegular){
           
            ListPriceDiscount PriceDiscount = new ListPriceDiscount();
            if(Map_Rate.get(lpr.ProductDiscountGroup__c) == null && lpr.OrderLineType__c=='Regular'){
                Map_Rate.put(lpr.ProductDiscountGroup__c,lpr.Rate__c);

                PriceDiscount.MarketSegment = lpr.MarketSegment__c;  
                PriceDiscount.OrderLineType = lpr.OrderLineType__c;
                PriceDiscount.DiscountType = lpr.DiscountType__c;
                PriceDiscount.Discount = lpr.Rate__c;
                PriceDiscount.ProductGroup = lpr.ProductDiscountGroup__c;
                PriceDiscount.CustomerDiscountGroup = lpr.CustomerDiscountGroup__c;
                PriceDiscount.LPDId = lpr.id;
            }
            else if(lpr.OrderLineType__c != 'Regular'){
                        PriceDiscount = new ListPriceDiscount();
                        PriceDiscount.DiscountType = lpr.DiscountType__c;
                        PriceDiscount.MarketSegment = lpr.MarketSegment__c;
                        PriceDiscount.CustomerDiscountGroup = lpr.CustomerDiscountGroup__c;   
                        PriceDiscount.OrderLineType = lpr.OrderLineType__c;
                        PriceDiscount.Discount = lpr.Rate__c;
                        PriceDiscount.ProductGroup = lpr.ProductDiscountGroup__c;
                        PriceDiscount.LPDId = lpr.id;
                         
            }  

            if(Map_PriceDiscount.get(lpr.ProductDiscountGroup__c) == null){
                ListPriceDiscount = new List<ListPriceDiscount>();
                ListPriceDiscount.add(PriceDiscount);
                Map_PriceDiscount.put(lpr.ProductDiscountGroup__c,ListPriceDiscount);
            }
            else{
                Map_PriceDiscount.get(lpr.ProductDiscountGroup__c).add(PriceDiscount); 
            }
        }      
        return Map_PriceDiscount;
    
    



        

    }


    Public static List<ListPriceDiscount> AddlistPriceDiscount(String ProdMarketSegment, List<ListPriceDiscount> ListPriceDiscountType){


        List<ListPriceDiscount> AddlistPriceDiscount = new List<ListPriceDiscount>();
        system.debug('**ProdMarketSegment**'+ProdMarketSegment);

                    for(ListPriceDiscount   lpdiscount:ListPriceDiscountType){
                            
                            ListPriceDiscount PriceDiscount = new ListPriceDiscount();

                            
                            if(lpdiscount.OrderLineType == 'Inspection Copy' && lpdiscount.DiscountType != 'Normal'){
                                
                                if(ProdMarketSegment  == lpdiscount.MarketSegment && ProdMarketSegment != null){

                                    PriceDiscount.MarketSegment = lpdiscount.MarketSegment;
                                    PriceDiscount.CustomerDiscountGroup = lpdiscount.CustomerDiscountGroup;
                                      
                                    PriceDiscount.OrderLineType = lpdiscount.OrderLineType; // + '-' +lpdiscount.MarketSegment;
                                    PriceDiscount.Discount = lpdiscount.Discount;
                                    PriceDiscount.LPDId = lpdiscount.LPDId ;
                                    PriceDiscount.ProductGroup = lpdiscount.ProductGroup;
                                    AddlistPriceDiscount.add(PriceDiscount);
                                }
                                
                            }   
                            else{
                                    PriceDiscount.MarketSegment = lpdiscount.MarketSegment;  
                                    PriceDiscount.CustomerDiscountGroup = lpdiscount.CustomerDiscountGroup; 
                                    PriceDiscount.OrderLineType = lpdiscount.OrderLineType;
                                    PriceDiscount.Discount = lpdiscount.Discount;
                                    PriceDiscount.LPDId = lpdiscount.LPDId ;
                                    PriceDiscount.ProductGroup = lpdiscount.ProductGroup;
                                    AddlistPriceDiscount.add(PriceDiscount);
                            }
                        
                    }

        return AddlistPriceDiscount;

    }
 
    
    Public static string   ProcessInsertOrderItems(List<OrderLineItem> OrderItems,String ContractId,String OrderId, Decimal TotalNumberofStudents,List<Account> AccountbyShipto){       
        
        Contract[] Contract = [Select AccountId,NumberofUsers__c,SoldUsers__c,StartDate,Pricebook2Id,PaymentMethod__c,ShippingCostMethod__c,PricingMethod__c,defaultBilltoAccount__c from Contract where id =: ContractId];
        
        system.debug('**OrderItems 1**');

        //GET Subsidoaries
        if(Contract.size()>0){    
            /*
            if(Contract[0].SoldUsers__c == null){
              //  Contract[0].SoldUsers__c =TotalNumberofStudents;                
            }
            update Contract;
            */

        }

        Id NewOrderId = OrderId;
         

        Set<String> Set_Sub = new Set<String>();
        Map<String,String> Map_Sub = new Map<String,String>(); 
        Map<String,String> Map_Netsuite = new Map<String,String>(); 
        
        Order[] CurOrder = [Select AccountSubsidiary__c,Billto__r.OperatingCompany__c,Type,Account.NetsuiteInternalId__c,OperatingCompany__c,ShippingIndicationRule__c,ShippingCost__c,InsertProductSelector__c,CustomerReference__c,NumberOfStudents__c,Billto__c,ContractId,EffectiveDate,ShipByDate__c from Order where id=: NewOrderId];
        
        List<Map<String,String>> lst_AccSubMaps = new List<Map<String,String>>();
        if(Contract.size()>0){
            Set_Sub.add(Contract[0].defaultBilltoAccount__c);
             //Map_Sub = returnAccountSubsidiary(Set_Sub)[0];

            //lst_AccSubMaps = returnAccountSubsidiary(Set_Sub);
        }
        else if(CurOrder.size()>0){
            Set_Sub.add(CurOrder[0].Billto__c);
            //Map_Sub = returnAccountSubsidiary(Set_Sub)[0];
            //lst_AccSubMaps = returnAccountSubsidiary(Set_Sub);
            if(CurOrder[0].ContractId != null){
                ContractId = CurOrder[0].ContractId;
            }
        }    
        
       
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        List<OrderItem> lstOrderItemToDelete = new List<OrderItem>();
        List<OrderLineItem> lstOrderItemGroup = new List<OrderLineItem>();

      //  system.debug('**OrderItems**'+OrderItems);

        Set<String> Set_ExistingAccIdCon = new Set<String>(); 
        Set<String> Set_ExistingAccIdOrd = new Set<String>(); 

        Set<String> Set_NewAccIdCon = new Set<String>();
        Set<String> Set_NewAccIdOrd = new Set<String>();

       


        if(ContractId != null){

            ContractShipto__c[] lstContractShipto = [Select id,ShiptoAccount__c from ContractShipto__c where Contract__c =: ContractId];

            for(ContractShipto__c con:lstContractShipto){
                Set_ExistingAccIdCon.add(con.ShiptoAccount__c);
            }

        }
        if(NewOrderId != null){

            OrderShipto__c[] lstOrderShipto = [Select id,ShiptoAccount__c from OrderShipto__c where Order__c =: NewOrderId];
            
            for(OrderShipto__c ord:lstOrderShipto){
                Set_ExistingAccIdOrd.add(ord.ShiptoAccount__c);
            }

        }


        for(Account shipto:AccountbyShipto){
            if(!Set_ExistingAccIdOrd.Contains(shipto.Id)){
                Set_NewAccIdOrd.Add(shipto.Id);
            }
            if(!Set_ExistingAccIdCon.Contains(shipto.Id)){
                Set_NewAccIdCon.Add(shipto.Id);
            }
        }

        Set_Sub = new Set<String>();

        Set<String> Set_Products = new Set<String>();
        for(OrderLineItem item:OrderItems){
            Set_Sub.add(item.ShipToAccountId);
            Set_Products.add(item.ProductId);
        }  

        Product2[] lstProduct = [Select id,Type__c,FreeFromDate__c,IsRegularOrderPossible__c,IsInspectionCopyOrderPossible__c,IsUseCopyOrderPossible__c,FixedStartDate__c,StartDate__c,LicenseDuration__c,Renewable__c from Product2 where id in: Set_Products];

        Map<String,Date> Map_FreeFromDate = new Map<String,Date>();
        Map<String,Date> Map_FixedStartDate = new Map<String,Date>();
        Map<String,Date> Map_StartDate = new Map<String,Date>();
        Map<String,Decimal> Map_LicenseDuration = new Map<String,Decimal>();
        Map<String,Boolean> Map_Renewable = new Map<String,Boolean>();
        Map<String,String> Map_ProdType = new Map<String,String>();

        //To be deleted: Moved to trigger
        Map<String,Boolean> Map_InspectionCopyOrder = new Map<String,Boolean>();
        Map<String,Boolean> Map_RegularOrder = new Map<String,Boolean>();
        Map<String,Boolean> Map_UseCopyOrder = new Map<String,Boolean>();       
        //To be deleted: Moved to trigger
       
        Date FixedStartDate;
        for(Product2 prod:lstProduct){
            
            //To be deleted: Moved to trigger
            Map_InspectionCopyOrder.put(prod.id,prod.IsInspectionCopyOrderPossible__c);
            Map_RegularOrder.put(prod.id,prod.IsRegularOrderPossible__c);
            Map_UseCopyOrder.put(prod.id,prod.IsUseCopyOrderPossible__c);
            //To be deleted: Moved to trigger

            if(prod.FixedStartDate__c != null){
                FixedStartDate = date.newinstance(system.today().year(), prod.FixedStartDate__c.month(), prod.FixedStartDate__c.day());
                Map_FixedStartDate.put(prod.id,FixedStartDate);
            }
             
            Map_FreeFromDate.put(prod.id,prod.FreeFromDate__c );
            Map_StartDate.put(prod.id,prod.StartDate__c );
            if(prod.LicenseDuration__c != null){
                Map_LicenseDuration.put(prod.id,decimal.valueof(prod.LicenseDuration__c));
            }

            Map_Renewable.put(prod.id,prod.Renewable__c);
            Map_ProdType.put(prod.id, prod.Type__c);
            
        }

        
        lst_AccSubMaps = returnAccountSubsidiary(Set_Sub);

       // Map_Sub = returnAccountSubsidiary(Set_Sub)[0];

       Map_Sub = lst_AccSubMaps[0];
       Map_Netsuite = lst_AccSubMaps[1];
       

       
    Set<String> Set_DontDelete = new Set<String>();

    for(OrderLineItem item:OrderItems){
          if(item.IsEdited==true){

            OrderItem OItem = new OrderItem();
            
            //ShippingCity,
           // ShippingCountry,
           // ShippingPostalCode,
          //  ShippingState,
          //  ShippingStreet    
          
            OItem.OrderStatus__c = 'Draft';
            OItem.OrderId = NewOrderId; 
            OItem.InsertProductSelector__c = true;
            
            
          system.debug('**item.ItemGroupComponent**'+item.ItemGroupComponent+'**item.ItemGroup**'+item.ItemGroup);
            if(item.ItemGroup == null && item.ItemGroupComponent== true){
                OItem.UnitPrice = 0;
                OItem.NetSalesPriceItemGroup__c = item.UnitPrice.setScale(2);
                OItem.DiscountedPriceItemGroup__c = item.STDPrice;
                OItem.ListPriceItemGroup__c = Item.BasePrice;
                OItem.ComponentListPrice__c = 0;
                
                
            }
            else{
                OItem.UnitPrice = item.UnitPrice.setScale(2);
                OItem.ComponentListPrice__c = Item.BasePrice;

                
            }
            
            if(item.ItemGroup == null){
                OItem.Quantity = item.Quantity;
                OItem.NetsuiteQuantity__c = item.Quantity;
               
            }
            else{
                OItem.Quantity = item.ComponentQuantityFinal;
                OItem.NetsuiteQuantity__c =  item.Quantity;
            }
            

            
           
            
            if(item.ItemGroup == null && item.ItemGroupComponent != true){
                OItem.Renewable__c= Map_Renewable.get(item.ProductId);
            }
            
           


             

            
           // OItem.ItemGroup__c = item.ItemGroupProductId;
            OItem.ListPriceDiscount__c =  item.listPriceRateId;  
            OItem.Product2Id = item.ProductId;
            
            
            OItem.PricebookEntryId = item.PricebookEntryId;
            OItem.ShipToAccount__c  = item.ShipToAccountId; 
            OItem.Account__c = CurOrder[0].Billto__c ;

            OItem.AccountSubsidiary__c = Map_Sub.get(item.ShipToAccountId);            
            
            
            Oitem.NetSuiteIdBilltoAccount__c = CurOrder[0].Account.NetsuiteInternalId__c;
            
            OItem.CustomerReference__c  =  CurOrder[0].CustomerReference__c;
            OItem.OperatingCompany__c  = CurOrder[0].OperatingCompany__c;

            //To be deleted: Moved to trigger
            OItem.NetsuiteInternalId__c = Map_Netsuite.get(item.ShipToAccountId);
            OItem.NetSuiteIdShiptoAccount__c = Map_Netsuite.get(item.ShipToAccountId);
            Oitem.ShippingIndicationRule__c = CurOrder[0].ShippingIndicationRule__c;
            
            Oitem.IsInspectionCopyOrderPossible__c = Map_InspectionCopyOrder.get(item.ProductId);
            Oitem.IsRegularOrderPossible__c = Map_RegularOrder.get(item.ProductId);
            Oitem.IsUseCopyOrderPossible__c = Map_UseCopyOrder.get(item.ProductId);
            //To be deleted: Moved to trigger
            
            Oitem.ProductLicenseDuration__c = Map_LicenseDuration.get(item.ProductId);
            OItem.ProductType__c = Map_ProdType.get(item.ProductId);
            
            system.debug('***ShippingIndicationRule : '+CurOrder[0].ShippingIndicationRule__c);
            

          //  OItem.OrderLineItemType__c = item.PriceDiscount;           
           
           
             OItem.OrderLineType__c = item.PriceDiscount;

             if(!Set_ExistingAccIdCon.Contains(OItem.ShipToAccount__c)){
                Set_NewAccIdCon.Add(OItem.ShipToAccount__c);
            }
            if(!Set_ExistingAccIdOrd.Contains(OItem.ShipToAccount__c)){
                Set_NewAccIdOrd.Add(OItem.ShipToAccount__c);
            }
            
            if(item.DiscountOption !='--None--'){
                OItem.ManualDiscount__c = item.DiscountOption;
            }

            if(OItem.ManualDiscount__c != null){
                if(OItem.ManualDiscount__c.contains('Percent')){
                    OItem.ManualDiscountPercent__c = item.DiscountPercent;
                    OItem.ManualDiscountValue__c = item.STDPrice * item.Quantity*((item.DiscountPercent)/100);
                }
                else if(OItem.ManualDiscount__c.contains('Amount')){
                    OItem.ManualDiscountPercent__c = null;
                    OItem.ManualDiscountValue__c = item.DiscountAmount;
                }
               else{
                    OItem.ManualDiscountPercent__c = null;
                    OItem.ManualDiscountValue__c = null;
               }
            }
          
          //  system.debug('**item.ItemId**'+item.ItemId);

            if(item.ItemId != null && item.IsnewItem !='True'){
                OItem.Id = item.IId;
                
            } 
            
            if(item.ItemGroup == null){
                OItem.FormGroupId__c = item.ItemId;
            }

            lstOrderItem.Add(OItem); 
            if(item.ItemGroup != null){
                lstOrderItemGroup.add(item);
                OItem.Group__c = item.ItemGroup;
            }
          }     
         //    system.debug('**item.PricebookEntryId**'+item.PricebookEntryId);
            system.debug('**Save Order: item.IId**'+item.IId);
         
            if(item.IId != null){
                Set_DontDelete.add(item.IId);
            }   
            
          
            
        }
      
      //  UTIL_TriggerController.OrderItemTriggerSwitch = false;
        try{
            system.debug('**OrderItem Trigger: Before Insert**');
            upsert lstOrderItem id;
            system.debug('**OrderItem Trigger: After Insert**');
        }
        catch(exception e){
            
            HandleCustomException.LogException(e);
            NewOrderId = e.getMessage();
            system.debug('**Error: After Insert**'+NewOrderId);
            return NewOrderId;
        }
        
        
         
     /* FUTURE + REST OPTION */
     try{
        Map<String,String> Map_itemGroup = new Map<String,String>();
          
        String ShiptoProdGroup;
        for(OrderItem  item:lstOrderItem){

            if(item.FormGroupId__c != null){

                Map_itemGroup.put(item.FormGroupId__c ,item.id );
                
            }
        }    


    //This could get moved to UPDATE BELOW

        List<OrderItem> lstOrderItemComponent = new List<OrderItem>();
        system.debug('**lstOrderItemComponent**'+lstOrderItemGroup.size());
        system.debug('**lstOrderItem**'+lstOrderItem.size());

        Set<String> Set_ItemProd = new Set<String>();

            for(OrderLineItem Oitem:lstOrderItemGroup){
                
                for(OrderItem  item:lstOrderItem){
                     
                  
                       system.debug('**item.ItemGroup__c***'+item.FormGroupId__c+'********'+ OItem.ItemGroup);
                
                   ShiptoProdGroup = OItem.ItemGroup;
                     ShiptoProdGroup += item.Product2Id;
                    if(OItem.ProductId == item.Product2Id && OItem.ItemGroup != null && item.ShipToAccount__c  == OItem.ShipToAccountId && !Set_ItemProd.contains(ShiptoProdGroup) && item.Group__c== OItem.ItemGroup){
                        
                        Set_ItemProd.add(item.id);
                        
                        item.ProductComponent__c = OItem.ItemGroupId; //New line
                        
                        if(Map_itemGroup.get(OItem.ItemGroup) != null){
                            item.ItemGroup__c = Map_itemGroup.get(OItem.ItemGroup);
                            item.ItemGroupId__c = Map_itemGroup.get(OItem.ItemGroup);
                        }
                        else{
                            item.ItemGroup__c = OItem.ItemGroup;
                            item.ItemGroupId__c = OItem.ItemGroup;
                        }

                        system.debug('**item.ItemGroup__c1**'+OItem.ItemGroup+'****'+item.id+'***'+item.ItemGroupId__c);

                        lstOrderItemComponent.add(item);
                    }
                
                } 
            }
            system.debug('**lstOrderItemComponent.size()**'+lstOrderItemComponent.size());
            if(lstOrderItemComponent.size()>0){
                
                update  lstOrderItemComponent;
            } 
              
        }
        catch(exception e){
            
            HandleCustomException.LogException(e);
            NewOrderId = e.getMessage();
            system.debug('**Item Group Error:**'+NewOrderId);
            return NewOrderId;
        }
        
        
        system.debug('**After Group 1**');
        if(ContractId != null){
           
         //   system.debug('**Set_NewAccIdCon**'+Set_NewAccIdCon);
            list<ContractShipto__c> lstContractShiptoAdd = new  list<ContractShipto__c>();
            for(String str:Set_NewAccIdCon){
               // if(!Set_existing.contains(str)){
                   if(str != null){ 
                        ContractShipto__c ContractShipto = new  ContractShipto__c();
                        ContractShipto.ShiptoAccount__c = str;
                        ContractShipto.Contract__c = ContractId;
                        lstContractShiptoAdd.add(ContractShipto);
                    } 
               // }    
            }
            try{
                if(lstContractShiptoAdd.size()>0){
                    insert lstContractShiptoAdd;
                }
            }
            catch(exception e){
                HandleCustomException.LogException(e);
                NewOrderId = e.getMessage();
                return NewOrderId;
            }
            
            
        }
        system.debug('**After Group 2**');
        if(NewOrderId != null){

            List<OrderShipto__c>  lstOrderShiptoAdd = new List<OrderShipto__c> ();
            
            for(String str:Set_NewAccIdOrd){
                if(str != null){
                    OrderShipto__c  OrderShipto = new OrderShipto__c();
                    OrderShipto.ShiptoAccount__c = str;
                    OrderShipto.Order__c =NewOrderId ;
                    lstOrderShiptoAdd.add(OrderShipto);
                }
            }
            try{
                if(lstOrderShiptoAdd.size()>0){
                    insert lstOrderShiptoAdd;
                } 
            }
            catch(exception e){
                HandleCustomException.LogException(e);
                NewOrderId = e.getMessage();
                return NewOrderId;
            }
              
            
        }
   
        try{
            for(OrderItem item:lstOrderItem){
                Set_DontDelete.add(item.id);
            }
            system.debug('**Save Order: Set_DontDelete**'+Set_DontDelete);
            //if(Set_DontDelete.size()>0){
                lstOrderItemToDelete = [Select id from OrderItem where id not in:Set_DontDelete  and OrderId =:NewOrderId];    
                delete lstOrderItemToDelete;
           // }
            
         //   SetOrderItemsForFlow(Set_DontDelete);
        }
        catch(exception e){
            HandleCustomException.LogException(e);
            NewOrderId = e.getMessage();
            return NewOrderId;
        }
       

    /* FUTURE + REST OPTION */

    
    
      try{
            
            List<String> Set_NewOrderId = new List<String>();
            Set_NewOrderId.add(NewOrderId);
            system.debug('**Helper: triggerhandler**');


            OrderItem[] lst_OrdItem;
            lst_OrdItem = Order_OrderandOrdeItemHandler.returnQueryOrderItems(Set_DontDelete,null);

            Order_OrderandOrdeItemHandler.OrderItemBusinessLogichandler(lst_OrdItem, CurOrder,null, 'ProductSelectorOrderItems', null,null );

            /*
            lstOrderItem=Order_OrderandOrdeItemHandler.triggerhandler(lst_OrdItem);
            lstOrderItem=Order_ProductCalculationDates.UpdateOrderItemDate(lstOrderItem,CurOrder);
            Update lstOrderItem;
            
            Order_UpdateVatOnItems.UpdateVatOnItems (lstOrderItem);

            if(CurOrder[0].ShippingIndicationRule__c == null){
                Order_UpdateShippingCostsFromItems.UpdateShippingCostsFromItems(lstOrderItem,CurOrder[0]);
            }
            */
            

       }
       catch(exception e){
           HandleCustomException.LogException(e);
           NewOrderId = e.getMessage();
           return NewOrderId;
       }

        return NewOrderId;


    } 

@future
public static void SetOrderItemsForFlow(Set<String> Set_Id){

    OrderItem[] lstOrderItem = [Select id,InsertProductSelector__c from OrderItem where id in:Set_Id];

    for(OrderItem item:lstOrderItem){
        item.InsertProductSelector__c = false;
    }
    
    update lstOrderItem;

}



public static List<Map<String,String>> returnAccountSubsidiary(Set<String> Set_Sub){
         

        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,LegalName__c,NetsuiteInternalId__c,Account__c,Account__r.OperatingCompany__c,Account__r.isVocationalEducation__c,Account__r.isHigherEducation__c from AccountSubsidiary__c where Account__c in:Set_Sub AND (Deleted__c =:false AND 	IsInactive__c =:false) ];

        Map<String,String> Map_Sub = new Map<String,String>();
        Map<String,String> Map_Netsuite = new Map<String,String>();
        
        List<Map<String,String>> lst_Maps = new List<Map<String,String>>();

        for(AccountSubsidiary__c acc:lstAccountSubsidiary){
            
            if(acc.Account__r.OperatingCompany__c == 'Noordhof'){

                if ((acc.Account__r.isVocationalEducation__c == true || acc.Account__r.isHigherEducation__c == true) && acc.LegalName__c=='NoordhoffDigitaalBedrijf' && Map_Sub.get(acc.Account__c) == null){
                    Map_Sub.put(acc.Account__c,acc.id);
                    Map_Netsuite.put(acc.Account__c,acc.NetsuiteInternalId__c);
                    
                }
                else if((acc.Account__r.isVocationalEducation__c == false && acc.Account__r.isHigherEducation__c == false) && acc.LegalName__c !='NoordhoffDigitaalBedrijf' && Map_Sub.get(acc.Account__c) == null){
                    Map_Sub.put(acc.Account__c,acc.id);
                    Map_Netsuite.put(acc.Account__c,acc.NetsuiteInternalId__c);   
                }       
            }
            else{
                    Map_Sub.put(acc.Account__c,acc.id);
                    Map_Netsuite.put(acc.Account__c,acc.NetsuiteInternalId__c);
            }    
        }

        
        lst_Maps.add(Map_Sub);
        lst_Maps.add(Map_Netsuite);
        return lst_Maps;
}





Public Class ProductListPrice{
        
    @auraenabled Public String ProductId {get;set;} 
    @auraenabled Public String ItemGroup {get;set;} 
    @auraenabled Public String ItemGroupId {get;set;}
    @auraenabled Public String ItemGroupType {get;set;}    
    @auraenabled Public String ProductName {get;set;} 
    @auraenabled Public String ProductSKU {get;set;} 
    @auraenabled Public String ProductTYPE {get;set;} 
    @auraenabled Public String ProductEAN {get;set;} 
    @auraenabled Public String PricebookEntryId {get;set;}
    @auraenabled Public String RateId {get;set;}
    @auraenabled Public Decimal Rate {get;set;}
    @auraenabled Public Decimal Stocknumber {get;set;}
    @auraenabled Public Decimal maxQuantity {get;set;}
    @auraenabled Public String DeliveryStatus {get;set;}
    

    @auraenabled Public Decimal UnitPrice {get;set;}  
    @auraenabled Public Decimal Quantity {get;set;}
    @auraenabled Public Decimal BasePrice {get;set;}  
    @auraenabled Public Decimal STDPrice {get;set;} 

    @auraenabled Public Decimal ComponentQuantity {get;set;}
    @auraenabled Public Decimal ComponentQuantityFinal {get;set;}
    @auraenabled Public String ComponentQuantityTitle {get;set;}
    

    @auraenabled Public String listPriceRateId {get;set;}
    @auraenabled Public List<ListPriceDiscount> listPriceDiscount {get;set;}
    @auraenabled Public List<String> listPriceProductType {get;set;}
    @auraenabled Public String listPriceDiscountType {get;set;}
    @auraenabled Public String ProductRateGroup {get;set;}   
    @auraenabled Public List<String> ManualDiscount {get;set;}
    @auraenabled Public List<String> PercentDiscountManual {get;set;}
    @auraenabled Public List<String> AmountDiscountManual {get;set;}
    
    @auraenabled Public String QuantitySelectionType {get;set;}
    @auraenabled Public String MarketSegment {get;set;}
    @auraenabled Public List<String> lstMarketSegment {get;set;}
    @auraenabled Public List<Asset2Product> listAsset2Product {get;set;}
    @auraenabled Public List<ProductListPrice> listItemGroupComponent {get;set;}
    @auraenabled Public Boolean ItemGroupComponent {get;set;}
    
}

   Public class OrderLineItem{
        
        @auraenabled Public String ItemId {get;set;} 
        @auraenabled Public String IId {get;set;}
        @auraenabled Public Boolean IsEdited {get;set;}
        @auraenabled Public String ItemGroup {get;set;} 
        @auraenabled Public String ItemGroupId {get;set;}
        @auraenabled Public String ItemGroupProductId {get;set;}
        @auraenabled Public Boolean ItemGroupComponent {get;set;}
        @auraenabled Public Decimal maxQuantity {get;set;}
        @auraenabled Public String IsnewItem {get;set;}
        
        @auraenabled Public String OrderId {get;set;}
        @auraenabled Public Decimal Quantity {get;set;} 
        @auraenabled Public String ComponentQuantityTitle {get;set;}
        @auraenabled Public Decimal ComponentQuantityFinal {get;set;}
        @auraenabled Public Decimal ComponentQuantity {get;set;}
        @auraenabled Public Decimal Rate {get;set;}
       @auraenabled Public String DiscountOption {get;set;}
       @auraenabled Public Decimal DiscountPercent {get;set;}
       @auraenabled Public Decimal DiscountAmount {get;set;}
       
      //  @auraenabled Public String RateId {get;set;}
        @auraenabled Public Decimal Amount {get;set;}
        @auraenabled Public Decimal NoDiscAmount {get;set;}   

        @auraenabled Public Decimal BasePrice {get;set;}
        @auraenabled Public Decimal STDPrice {get;set;}
        @auraenabled Public Decimal UnitPrice {get;set;} 
        @auraenabled Public Decimal Count {get;set;}


        @auraenabled Public String ProductId {get;set;}
        @auraenabled Public String ShipToAccountId {get;set;}
        @auraenabled Public String CustomerDiscountGroup {get;set;}
        @auraenabled Public String Subsidiary {get;set;}
        @auraenabled Public String MarketSegment {get;set;}

        @auraenabled Public String ShipToAccountName {get;set;}
        @auraenabled Public String ProductName {get;set;} 
        @auraenabled Public String listPriceRateId {get;set;}
        @auraenabled Public String PricebookEntryId {get;set;}
        @auraenabled Public String PriceDiscount {get;set;}
        @auraenabled Public List<ListPriceDiscount> listPriceDiscount {get;set;}
        @auraenabled Public String listPriceDiscountType {get;set;}
        @auraenabled Public String ProductRateGroup {get;set;}
        @auraenabled Public List<String> listPriceProductType {get;set;}
        @auraenabled Public List<ProductListPrice> listItemGroupComponent {get;set;}

        @auraenabled Public List<String> ManualDiscount {get;set;}
        @auraenabled Public List<String> PercentDiscountManual {get;set;}
        @auraenabled Public List<String> AmountDiscountManual {get;set;}
        @auraenabled Public String QuantitySelectionType {get;set;}
        @auraenabled Public Boolean DiscountValueShow {get;set;}
        @auraenabled Public Boolean DiscountPercentShow {get;set;}
        
    }
    
    
    
    Public Class ListPriceDiscount{
        
        @auraenabled Public String LPDId {get;set;} 
        @auraenabled Public String MarketSegment {get;set;} 
        @auraenabled Public String DiscountType {get;set;}       
        @auraenabled Public String OrderLineType {get;set;} 
        @auraenabled Public Decimal Discount {get;set;}
        @auraenabled Public String ProductGroup {get;set;}  
        @auraenabled Public String CustomerDiscountGroup {get;set;}

        
        
    }
    
    Public Class Asset2Product{
        
        @auraenabled Public String ProductId {get;set;} 
        @auraenabled Public String MarketSegment {get;set;}   
        @auraenabled Public String AccountId {get;set;}  
        @auraenabled Public Decimal Quantity {get;set;}
        @auraenabled Public Decimal ActivatedUsers {get;set;} 
        @auraenabled Public Decimal ShipToQuantity {get;set;} 
        @auraenabled Public Boolean IsMarketSegment {get;set;}      
        
    }
   
    Public Class ShiptoAccount{ 
        
        @auraenabled Public String Name {get;set;} 
        @auraenabled Public String Id {get;set;}   
        @auraenabled Public String CustomerDiscountGroup {get;set;} 
        @auraenabled Public String OperatingCompany {get;set;}  
        @auraenabled Public Decimal NumberofStudents {get;set;}
           
        
    }
    
    Public Class AssetList{ 
        @auraenabled Public String Id {get;set;}
        @auraenabled Public String Name {get;set;} 
        @auraenabled Public String ProductId {get;set;}   
        @auraenabled Public String ProductRateGroup {get;set;}
        @auraenabled Public String ProductName {get;set;}        
        @auraenabled Public Decimal Quantity {get;set;}
        @auraenabled Public String BillToAccount {get;set;}
   
    }
}