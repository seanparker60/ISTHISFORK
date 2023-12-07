public with sharing class Order_AssetRenewal {
    
    

    @auraenabled
    Public static void RenewAssets(){
        
        Date CurrrentDay = system.today();
        Date RenewalDay = system.today();

        asset[] lstAssets = [Select id,PriceBook__c,LastRenewalUpdate__c,DiscountedPrice__c,ManualDiscountPercent__c,ManualDiscountValue__c,
                                    PriceBook__r.FollowUpPriceBook__c,Product2.LicenseDuration__c,Product2.OrderLineType__c,RenewalDate__c,
                                    Account.DigitalActivationEmail__c ,Product2.ProductDiscountGroup__c,Product2.ProductRateGroup__c,OrderLineType__c,
                                    RenewalTerm__c,IsUpForRenewal__c,AccountId,PricingMethod__c,BillToAccount__r.ShippingCostMethod__c,ManualDiscount__c,
                                    BillToAccount__r.PaymentMethod__c,BillToAccount__r.CustomerDiscountGroup__c,Account.CustomerDiscountGroup__c,
                                    Price,Quantity, BillToAccount__c,BillToAccount__r.OperatingCompany__c,Account.OperatingCompany__c,
                                    Product2Id,BillToAccount__r.NetsuiteInternalId__c,Account.NetsuiteInternalId__c, Account.NumberofStudents__c,ShipToAttentionOf__c,
                                    BillToAccount__r.ShippingStreet,BillToAccount__r.ShippingPostalCode,BillToAccount__r.ShippingCountry,BillToAccount__r.ShippingCity,
                                    BillToAccount__r.BillingStreet,BillToAccount__r.BillingPostalCode,BillToAccount__r.BillingCountry,BillToAccount__r.BillingCity,
                                    Product2.IsSuccessorItemActive__c,Product2.SuccessorItem__c,Product2.SuccessorItem__r.IsActive,Product2.Type__c
                                    from asset 
                                    where 
                                    (Product2Id !=: null AND BillToAccount__c !=: null AND PricingMethod__c !=: null )
                                    AND((
                                        (CancellationDate__c >: CurrrentDay OR CancellationDate__c =:null)
                                        //AND IsUpForRenewal__c =:true 
                                        AND RenewalDate__c  =: RenewalDay
                                        AND LastRenewalUpdate__c !=: CurrrentDay 
                                        AND AutomatedRenewProcess__c =: true 
                                        AND Contract__c =:null
                                        AND Product2.Type__c != 'Item Group'
                                    )
                                    OR(
                                        AssetRenewalTrigger__c =: true
                                        AND Product2.Type__c != 'Item Group'
                                    )

                                    )
                                    ];

                                    system.debug('***lstAssets***'+lstAssets.size());
       if(lstAssets.size()==1){
            Initiate_Order_AssetRenewal(lstAssets,CurrrentDay,RenewalDay);
       }                             
       else if(lstAssets.size()>1){
        Order_Batch_AccountswithRenwalAssets  AssetRenewal = new Order_Batch_AccountswithRenwalAssets();
        database.executebatch(AssetRenewal ,500);
       }     
       

      
       
    }

    @invocablemethod
    Public static void RenewAssets(List<Id> AssetId){
        Date CurrrentDay = system.today();
        Date RenewalDay = system.today();

        asset[] lstAssets = [Select id,PriceBook__c,LastRenewalUpdate__c,ManualDiscountPercent__c,ManualDiscountValue__c,PriceBook__r.FollowUpPriceBook__c,PriceBook__r.Name,Product2.LicenseDuration__c,Product2.OrderLineType__c,RenewalDate__c,Account.DigitalActivationEmail__c ,
                                Product2.ProductDiscountGroup__c,Product2.ProductRateGroup__c,RenewalTerm__c,IsUpForRenewal__c,DiscountedPrice__c,OrderLineType__c,
                                AccountId,PricingMethod__c,BillToAccount__r.ShippingCostMethod__c,BillToAccount__r.PaymentMethod__c,ManualDiscount__c,ShipToAttentionOf__c,
                                BillToAccount__r.CustomerDiscountGroup__c,Account.CustomerDiscountGroup__c,Price,Quantity,Account.OperatingCompany__c,BillToAccount__r.OperatingCompany__c,
                                BillToAccount__c,Product2Id,BillToAccount__r.NetsuiteInternalId__c,Account.NetsuiteInternalId__c, Account.NumberofStudents__c,
                                BillToAccount__r.ShippingStreet,BillToAccount__r.ShippingPostalCode,BillToAccount__r.ShippingCountry,BillToAccount__r.ShippingCity,
                                BillToAccount__r.BillingStreet,BillToAccount__r.BillingPostalCode,BillToAccount__r.BillingCountry,BillToAccount__r.BillingCity,
                                Product2.IsSuccessorItemActive__c,Product2.SuccessorItem__c,Product2.SuccessorItem__r.IsActive, Product2.Type__c
                                    from asset 
                                    where (CancellationDate__c >: CurrrentDay OR CancellationDate__c =:null)
                                    //AND IsUpForRenewal__c =:true 
                                    AND RenewalDate__c  =: RenewalDay
                                    AND PricingMethod__c !=: null
                                    AND BillToAccount__c !=: null 
                                    AND Product2.Type__c != 'Item Group'
                                    AND LastRenewalUpdate__c !=: CurrrentDay 
                                    AND AutomatedRenewProcess__c =: true 
                                    AND Contract__c =:null
                                    AND Id in: AssetId];

          Initiate_Order_AssetRenewal(lstAssets,CurrrentDay,RenewalDay);
       
       
    }

    //@invocablemethod
    Public static void Initiate_Order_AssetRenewal(asset[] lstAssets,Date CurrrentDay,Date RenewalDay){

                  
        Set<String> Set_PriceBook = new Set<String>();
        Set<String> Set_ProductId = new Set<String>();
        Set<String> Set_SuccProductId = new Set<String>();
        Map<String,String> Map_SwapSuccProductId = new Map<String,String>();        
        Map<String,String> Map_SwapSuccPBEId = new Map<String,String>();

        Set<String> Set_Sub = new Set<String>();
        Map<String,String> Map_PriceBook = new Map<String,String>();
        Map<String,String> Map_BillTOPB = new Map<String,String>();
        Map<String,String> Map_PBBIllTo = new Map<String,String>();
         

        Map<String,String> Map_PBShipTo = new Map<String,String>();
        Map<String,String> Map_ShipToCount = new Map<String,String>();
        Map<String,Decimal> Map_MultiShipTo = new Map<String,Decimal>();

        Map<String,String> Map_ShipToNetsuiteId = new Map<String,String>();
        Map<String,String> Map_OperatingCompany = new Map<String,String>();

        Map<String,String> Map_PricingMethod = new Map<String,String>();
        Map<String,String> Map_ShippingCostMethod = new Map<String,String>();
        Map<String,String> Map_PaymentMethod = new Map<String,String>();
        Map<String,List<Asset>> Map_AssetPricingMethod = new Map<String,List<Asset>>();
         
        Map<String,String> Map_ShippingStreet = new Map<String,String>();
        Map<String,String> Map_ShippingPostalCode = new Map<String,String>();
        Map<String,String> Map_ShippingCountry = new Map<String,String>();
        Map<String,String> Map_ShippingCity = new Map<String,String>();
        Map<String,String> Map_ShipToAttentionOf = new Map<String,String>();

        Map<String,String> Map_BillingStreet = new Map<String,String>();
        Map<String,String> Map_BillingPostalCode = new Map<String,String>();
        Map<String,String> Map_BillingCountry = new Map<String,String>();
        Map<String,String> Map_BillingCity = new Map<String,String>();
        Map<String,Boolean> Map_ShipComplete = new Map<String,Boolean>();
        
        

        for(asset ass:lstAssets){
            Set_PriceBook.add(ass.PriceBook__c);
            Set_ProductId.add(ass.Product2Id);

            if(ass.Product2.IsSuccessorItemActive__c == true && ass.Product2.SuccessorItem__c != null && ass.Product2.SuccessorItem__r.IsActive == true){
                Set_SuccProductId.add(ass.Product2.SuccessorItem__c);                
                Map_SwapSuccProductId.put(ass.Product2Id,ass.Product2.SuccessorItem__c);
                Map_SwapSuccPBEId.put(ass.Product2.SuccessorItem__c,ass.Product2Id);
            }
             
        }    
        
        Pricebook2[] lstPriceBook =   [Select id,IsActive,FollowUpPriceBook__c,ShippingComplete__c from Pricebook2 where id in:Set_PriceBook];
        



        Set_PriceBook = new Set<String>();
        for(Pricebook2 pbe:lstPriceBook){
            
            
            if(pbe.IsActive == false){
                Map_PriceBook.put(pbe.id,pbe.FollowUpPriceBook__c);
                Set_PriceBook.add(pbe.FollowUpPriceBook__c);
            }
            else{
                Map_PriceBook.put(pbe.id,pbe.id);
                Set_PriceBook.add(pbe.id);
            }

            Map_ShipComplete.put(pbe.id,pbe.ShippingComplete__c);
   
        }
 //       system.debug('**Map_PriceBook**'+Map_PriceBook);
 //       system.debug('**Set_ProductId**'+Set_ProductId);
       
       
        List<PricebookEntry> ProductsbyPriceBook = new List <PricebookEntry>([Select id,Pricebook2Id,	Price__r.ListRate__c, Product2.name,Product2.SoldInSegment__c, Product2.IsSuccessorItemActive__c,Product2.SuccessorItem__c,Product2.SuccessorItem__r.IsActive, Product2.QuantitySelectionType__c,Product2.ProductRateGroup__c,productcode,Product2Id,unitprice from PricebookEntry where Pricebook2Id in:Set_Pricebook AND (Product2Id in: Set_ProductId OR Product2Id in: Set_SuccProductId) AND IsActive =:true]); 
        
        List<PricebookEntry> ProductsbyPriceBookSuccessor = new List <PricebookEntry>([Select id,Pricebook2Id,	Price__r.ListRate__c, Product2.name,Product2.SoldInSegment__c, Product2.IsSuccessorItemActive__c,Product2.SuccessorItem__c,Product2.SuccessorItem__r.IsActive, Product2.QuantitySelectionType__c,Product2.ProductRateGroup__c,productcode,Product2Id,unitprice from PricebookEntry where Pricebook2Id in:Set_Pricebook AND Product2Id in: Set_SuccProductId AND IsActive =:true]); 
        
        Set_SuccProductId = new Set<String>();
        for(PricebookEntry pbe:ProductsbyPriceBookSuccessor){
            Set_SuccProductId.add(pbe.Product2Id);
        }

        Map<String,String> Map_PBE = new Map<String,String>();
        Map<String,Decimal> Map_PBEUnitPrice = new Map<String,Decimal>();
        
        

        String PBId;
        Set<String> Set_Product = new set<String>();

//ERROR IF ASSET PRODUCT NOT IN FOLLOW UP PRICEBOOK

        Set<String> Set_ProductActive = new Set<String>();
        system.debug('**ProductsbyPriceBook**'+ProductsbyPriceBook.size());
        for(PricebookEntry pbe:ProductsbyPriceBook){

          //  system.debug('**pbe.Product2Id**'+pbe.Product2Id);
            PBId = pbe.Pricebook2Id;

            //Product has active successor item (required for use) - use the product to populate the successor item, don't do anything with successor item
            if(Set_SuccProductId.contains(Map_SwapSuccProductId.get(pbe.Product2Id))){                
                
            }
            else if(Map_SwapSuccProductId.get(pbe.Product2Id) != null){ //Successor Item
               
                PBId += Map_SwapSuccPBEId.get(pbe.Product2Id);
                
              
                Map_PBE.put(PBId,pbe.id);

                if(pbe.Price__r.ListRate__c != null){               
                    Map_PBEUnitPrice.put(PBId,pbe.Price__r.ListRate__c); 
                }
                else{
                    Map_PBEUnitPrice.put(PBId,pbe.unitprice);  
                }

                Set_ProductActive.add(pbe.Product2Id);
            }
            else{ // No successor Item
                PBId += pbe.Product2Id;
                Map_PBE.put(PBId,pbe.id);

                if(pbe.Price__r.ListRate__c != null){               
                    Map_PBEUnitPrice.put(PBId,pbe.Price__r.ListRate__c);  
                }
                else{
                    Map_PBEUnitPrice.put(PBId,pbe.unitprice);  
                }

                Set_ProductActive.add(pbe.Product2Id);
            }
            
            
            
            
            Set_Product.add(pbe.Pricebook2Id);
        }

        system.debug('**Map_PBE**'+Map_PBE);

        List<OrderItem> lstOrderItem = new List<OrderItem>();
        
        Set<String> Set_BillTo = new Set<String>(); 
        Set<String> Set_ShipTo = new Set<String>();
        Set<String> Set_Prod  = new Set<String>();

        Map<String,Decimal> Map_StudentNoShipTotal = new Map<String,Decimal>();
        Map<String,Decimal> Map_OrderLineCount = new Map<String,Decimal>();
         
        String PricebookPricingMethod;

        system.debug('**Order_Batch Before Loop: Size**'+lstAssets.size());

        Integer i=0;

        Set<String> Set_OrderLineType = new Set<String>();
        Set<String> Set_ProductDiscountGroup = new Set<String>();
        Set<String> Set_CustomerDiscountGroup = new Set<String>();
        Set<String> Set_OperatingCompany = new Set<String>();
         
        List<ErrorLog__c> lstErrorLog = new List<ErrorLog__c>();
        List<Asset> lst_AssetErrorLog = new List<Asset>();

        Map<String,Date> Map_OrderDate = new Map<String,Date>();

        for(asset ass:lstAssets){
           
            string AccPB;
            
            AccPB = ass.BillToAccount__c;
            AccPB += Map_PriceBook.get(ass.PriceBook__c);
            AccPB += ass.PricingMethod__c;
            system.debug('**Before IF**');

            if(Map_OrderLineCount.get(AccPB) == null){
                Map_OrderLineCount.put(AccPB,1);
            }
            else{
                Map_OrderLineCount.put(AccPB,Map_OrderLineCount.get(AccPB)+1);
            }

            if(ass.BillToAccount__c != null && Map_PriceBook.get(ass.PriceBook__c) != null && ass.PricingMethod__c != null && Set_ProductActive.contains(ass.Product2Id) ){
                system.debug('**IN IF**');

                Set_OrderLineType.add(ass.Product2.OrderLineType__c);
                Set_ProductDiscountGroup.add(ass.Product2.ProductDiscountGroup__c);
                Set_CustomerDiscountGroup.add(ass.BillToAccount__r.CustomerDiscountGroup__c);
                Set_OperatingCompany.add(ass.BillToAccount__r.OperatingCompany__c);

                Set_BillTo.add(ass.BillToAccount__c);
                Set_Prod.add(ass.Product2Id);

                Set_Sub.add(ass.BillToAccount__c);
                Set_Sub.add(ass.AccountId);

                Map_OperatingCompany.put(AccPB, ass.BillToAccount__r.OperatingCompany__c);
                   
                Map_ShippingStreet.put(AccPB, ass.BillToAccount__r.ShippingStreet);
                Map_ShippingPostalCode.put(AccPB, ass.BillToAccount__r.ShippingPostalCode);
                Map_ShippingCountry.put(AccPB, ass.BillToAccount__r.ShippingCountry);
                Map_ShippingCity.put(AccPB, ass.BillToAccount__r.ShippingCity);

                Map_BillingStreet.put(AccPB, ass.BillToAccount__r.BillingStreet);
                Map_BillingPostalCode.put(AccPB, ass.BillToAccount__r.BillingPostalCode);
                Map_BillingCountry.put(AccPB, ass.BillToAccount__r.BillingCountry);
                Map_BillingCity.put(AccPB, ass.BillToAccount__r.BillingCity);

                Map_ShipToAttentionOf.put(AccPB, ass.ShipToAttentionOf__c);

                Map_BillTOPB.put(AccPB, Map_PriceBook.get(ass.PriceBook__c));
                Map_PBBIllTo.put(AccPB,ass.BillToAccount__c);
                
                

                if(Map_OrderDate.get(AccPB)==null || Map_OrderDate.get(AccPB)>ass.RenewalDate__c){
                    Map_OrderDate.put(AccPB,ass.RenewalDate__c);
                }
                

                String multi;
                multi = AccPB+ ass.AccountId;

                
                if(!Set_ShipTo.contains(multi)){
                    Set_ShipTo.add(multi);
                    if(Map_MultiShipTo.get(AccPB)==null){
                        Map_MultiShipTo.put(AccPB,1);
                    }
                    else{
                        Map_MultiShipTo.put(AccPB,Map_MultiShipTo.get(AccPB)+1);
                    }                    
                }
                

                if(Map_MultiShipTo.get(AccPB) == 1 && Map_ShipToCount.get(AccPB) == null){
                    Map_ShipToCount.put(AccPB,ass.AccountId);
                    Map_ShipToNetsuiteId.put(AccPB,ass.Account.NetsuiteInternalId__c);
                }
                else if(Map_MultiShipTo.get(AccPB)>1){
                    Map_ShipToCount.put(AccPB,'MULTIPLE');
                }
                

                Map_PricingMethod.put(ass.BillToAccount__c,ass.PricingMethod__c);  //ass.BillToAccount__r.PricingMethod__c

                
                Map_ShippingCostMethod.put(ass.BillToAccount__c,ass.BillToAccount__r.ShippingCostMethod__c); 
                Map_PaymentMethod.put(ass.BillToAccount__c,ass.BillToAccount__r.PaymentMethod__c);

               
               
               PricebookPricingMethod = Map_PriceBook.get(ass.PriceBook__c);
               PricebookPricingMethod += ass.PricingMethod__c;
                

               if(Map_AssetPricingMethod.get(AccPB)==null){
                
                    List<Asset> lst_PriceAsset = new List<Asset>();
                    lst_PriceAsset.add(ass);

                    Map_AssetPricingMethod.put(AccPB,lst_PriceAsset);
               }
               else{
                    Map_AssetPricingMethod.get(AccPB).add(ass);
               }
               i++;
               if(ass.PricingMethod__c == 'AccountStudents'){

                    if(Map_StudentNoShipTotal.get(AccPB)==null){                      
                        Map_StudentNoShipTotal.put(AccPB,ass.Account.NumberofStudents__c);
                    }
                    else{
                        Map_StudentNoShipTotal.put(AccPB,Map_StudentNoShipTotal.get(AccPB) + ass.Account.NumberofStudents__c);
                    }

               }

               AccPB +=ass.AccountId;
                Map_PBShipTo.put(AccPB,  ass.AccountId);
            }
            else{
                //ERROR HANDLING FOR NO PRICEBOOK

                ErrorLog__c errorLog = new ErrorLog__c();
                errorLog.Errororigin__c = 'Apex';
                errorLog.RelatedToId__c = ass.id;
                errorLog.ExceptionMessage__c = 'Inactive Pricebook Entry on renewal';
                errorLog.ExceptionType__c = 'Inactive Pricebook Entry on renewal';
                lstErrorLog.add(errorLog);
                ass.RenewalMessage__c = 'Inactive Pricebook Entry on renewal';
                ass.AssetRenewalTrigger__c = false;
                lst_AssetErrorLog.add(ass);
            }
            
        }   




        system.debug('**Map_BillTOPB**'+Map_BillTOPB);
        system.debug('**Map_PBBIllTo**'+Map_PBBIllTo);

        system.debug('**Order_Batch After Loop: Size i*'+i);
        

        for(String BT:Map_PBBIllTo.keyset()){

            system.debug('**PBPricingMethod : Before loop'+BT);
   
        }  

        //Get all active assets per Bill to for List price discount.

        

        List<OrderShipto__c> lstOrderShipto = new List<OrderShipto__c>();

        
        List<Map<String,String>> lst_AccSubMaps = new List<Map<String,String>>();


        Map<String,String> Map_Sub = new Map<String,String>();
        Map<String,String> Map_Netsuite = new Map<String,String>();
        lst_AccSubMaps = Order_ProductSelectController.returnAccountSubsidiary(Set_Sub);

        Map_Sub = lst_AccSubMaps[0];
        Map_Netsuite = lst_AccSubMaps[1];

        Date CurDate = system.today();

//ADD CRITERIA TO QUEABLE




//Get All future PricingMethod renewal Assets per pricing method 

Set<String> Set_PricingMethod = new Set<String>();
String ListAllPricingMethod = 'OrderProductQuantity;ProductUsageBased;ProductDiscountGroupUsageBased';
Set_PricingMethod.addAll(ListAllPricingMethod.Split(';'));

/*
         asset[] lstAssetsDiscount  = [Select id,Product2.Name,PriceBook__c,PriceBook__r.FollowUpPriceBook__c,RenewalDate__c,Account.DigitalActivationEmail__c ,Product2.ProductDiscountGroup__c,Product2.ProductRateGroup__c,RenewalTerm__c,IsUpForRenewal__c,AccountId,PricingMethod__c,BillToAccount__r.ShippingCostMethod__c,BillToAccount__r.PaymentMethod__c,Price,Quantity, BillToAccount__c,Product2Id 
                                    from asset 
                                    where (CancellationDate__c >: CurrrentDay OR CancellationDate__c =:null)
                                    //AND IsUpForRenewal__c =:true 
                                    AND RenewalDate__c  >=: CurrrentDay
                                    AND PricingMethod__c in:   Set_PricingMethod
                                    AND BillToAccount__c in:Set_BillTo
                                    AND Contract__c =:null]; 
*/

//Get Quantity Per pricing method except 'AccountStudents'
  
  //  system.debug('**Assets for discount: **'+lstAssetsDiscount);

    // REMOVING ASSET USAGE QUANTITY FROM THIS CLASS => List price discount Class    
    //    Map_BillToPRod =  returnUsageBasedAssets(lstAssetsDiscount);
                                       
    Map<String,Decimal> Map_BillToPRod = new Map<String,Decimal>();      
   
List<Order> lst_Order = new List<Order>();


Decimal index=0;
Map<Decimal,List<OrderItem>> Map_OrderItems = new Map<Decimal,List<OrderItem>>();

Map<String,List<String>> Map_PriceProductType = new Map<String,List<String>>();

            for(String BT:Map_PBBIllTo.keyset()){


                    String AssetPricingMethod;
                    if(BT.contains('AccountStudents')){
                        AssetPricingMethod = 'AccountStudents';
                    }
                    else if(BT.contains('OrderProductQuantity')){
                        AssetPricingMethod = 'OrderProductQuantity';
                    }
                    else if(BT.contains('ProductUsageBased')){
                        AssetPricingMethod ='ProductUsageBased';
                    }
                    else if(BT.contains('ProductDiscountGroupUsageBased') ){ 
                        AssetPricingMethod = 'ProductDiscountGroupUsageBased';
                    }
                        String ShippingCostMethod = Map_ShippingCostMethod.get(Map_PBBIllTo.get(BT)); 
                        String PaymentMethod = Map_PaymentMethod.get(Map_PBBIllTo.get(BT));


            Order NewOrder;
            if(Map_BillTOPB.get(BT) != null){

                       
                        NewOrder = new Order();
                      //  NewOrder.ContractId = ContractId;
                        NewOrder.AccountId = Map_PBBIllTo.get(BT); 

                        if(Map_OrderDate.get(BT) != null){
                            NewOrder.EffectiveDate = Map_OrderDate.get(BT);
                            NewOrder.ShipByDate__c = Map_OrderDate.get(BT);
                        }
                        else{
                            NewOrder.EffectiveDate = system.today();
                            NewOrder.ShipByDate__c = system.today();
                        }

                        
                        
                   
                        NewOrder.Pricebook2Id = Map_BillTOPB.get(BT);
                        NewOrder.ShipComplete__c = Map_ShipComplete.get(NewOrder.Pricebook2Id);
                        NewOrder.Billto__c = Map_PBBIllTo.get(BT); 
                        NewOrder.Status = 'Draft';
                        NewOrder.PricingMethod__c = AssetPricingMethod;
                        NewOrder.ShippingCostMethod__c = ShippingCostMethod;
                        NewOrder.ShippingIndicationRule__c = null;
                        NewOrder.PaymentMethod__c = PaymentMethod;
                        NewOrder.Type = 'RenewalOrder';
                        NewOrder.Source__c = 'B2B Salesforce';
                        NewOrder.PaymentStatus__c = 'payment_pending'; 
                        NewOrder.PaymentMethodType__c = 'Invoice';   

                      //  NewOrder.ActivateforBatchProcessing__c = true;
                        NewOrder.AccountSubsidiary__c =  Map_Sub.get(Map_PBBIllTo.get(BT));
                        NewOrder.NetSuiteIdAccountSubsidiary__c = Map_Netsuite.get(Map_PBBIllTo.get(BT));
                        
                       
                        NewOrder.OperatingCompany__c = Map_OperatingCompany.get(BT);
                        NewOrder.BillingStreet   = Map_BillingStreet.get(BT);
                        NewOrder.BillingPostalCode   = Map_BillingPostalCode.get(BT);
                        NewOrder.BillingCountry   = Map_Billingcountry.get(BT);
                        NewOrder.BillingCity   = Map_BillingCity.get(BT); 
                        
                        NewOrder.OrderImportLineCountSent__c = Map_OrderLineCount.get(BT);                      

                        if(Map_ShipToCount.get(BT)=='MULTIPLE'){
                            NewOrder.MultipleShippingLocations__c= true;
                        }
                        else{
                            NewOrder.Shipto__c = Map_ShipToCount.get(BT);
                            NewOrder.ShipToAttentionOf__c = Map_ShipToAttentionOf.get(BT);
                            NewOrder.NetSuiteIdShiptoAccount__c = Map_ShipToNetsuiteId.get(BT); 
                            
                            NewOrder.ShippingStreet   = Map_ShippingStreet.get(BT);
                            NewOrder.ShippingPostalCode   = Map_ShippingPostalCode.get(BT);
                            NewOrder.ShippingCountry   = Map_ShippingCountry.get(BT);
                            NewOrder.ShippingCity   = Map_ShippingCity.get(BT);
                        }
                        

                     
                        Insert NewOrder;
                        index++;
                        system.debug('**NewOrder 1**index**'+index);
                        
                        lst_Order.add(NewOrder);

                //TO REMOVING ASSET USAGE QUANTITY FROM THIS CLASS => List price discount Class    
               
                if(AssetPricingMethod=='AccountStudents'){
                            Map_BillToPRod.put(NewOrder.id,Map_StudentNoShipTotal.get(BT));
                            system.debug('**Assets for MAP: ACCOUNT**'+Map_BillToPRod);
                        }
                       
              
                        Map<String,String> Map_RateId;
                        
                        String type;
 
                        Decimal NumberofStudents;
                        String shiptoAcc;
          
                        Set<String> Set_AddUniqueShip = new Set<String>();
               
                List<OrderItem> lst_OrderItemAsset = new  List<OrderItem>();       
                for(Asset ass:Map_AssetPricingMethod.get(BT)){
                        
                            shiptoAcc = BT + ass.AccountId;
                          //  system.debug('**Add Order: Map_PBShipTo**'+Map_PBShipTo.get(shiptoAcc));
                          //  system.debug('**Add Order: Map_ShipAsset**'+ass.AccountId);
                         //   system.debug('**Add Order: Map_BillTOPB.get(PB)**'+Map_BillTOPB.get(BT));
                         //   system.debug('**Add Order: PriceBook**'+ass.PriceBook__c);
                         //   system.debug('**Add Order: FollowUpPriceBook**'+ass.PriceBook__r.FollowUpPriceBook__c);

                            

                                if(Map_PBShipTo.get(shiptoAcc) == ass.AccountId && (ass.PriceBook__c == Map_BillTOPB.get(BT) || ass.PriceBook__r.FollowUpPriceBook__c == Map_BillTOPB.get(BT))){
                                  
                                    String BilltoProd;
                                   
                                    system.debug('**Add Order: IN 1**');

                                   
                                    PBId = NewOrder.Pricebook2Id;
                                    PBId += ass.Product2Id;

                                    system.debug('**Map_PBE**'+PBId);

                                    if(Map_PBE.get(PBId) != null){
                                     
                                      system.debug('**Add Order: IN 2 **');
                                    OrderItem item = new OrderItem();
                                    item.ShipToAccount__c = ass.AccountId;

                                    //Add Ship tos    
                                    if(!Set_AddUniqueShip.Contains(ass.AccountId)){
                                        OrderShipto__c OrderShipto = new OrderShipto__c();
                                        OrderShipto.Order__c = NewOrder.id;
                                        OrderShipto.ShiptoAccount__c =ass.AccountId;
                                        lstOrderShipto.add(OrderShipto);
                                        Set_AddUniqueShip.add(ass.AccountId);
                                        system.debug('**Add Order: ass.AccountId**'+ass.AccountId);
                                    }
                                    
                                        

                                    item.Account__c = Map_PBBIllTo.get(BT);
                                    item.AccountSubsidiary__c = Map_Sub.get(ass.AccountId);

                                    item.NetsuiteInternalId__c = ass.Account.NetsuiteInternalId__c;
                                    item.NetSuiteIdShiptoAccount__c = ass.Account.NetsuiteInternalId__c;
                                    item.NetSuiteIdBilltoAccount__c = ass.BillToAccount__r.NetsuiteInternalId__c;
                                    
                                   
                                    
                                    item.ShipToAttentionOf__c = ass.ShipToAttentionOf__c;
                                    
                                    item.Quantity = ass.Quantity;
                                    //NETSUITE QUANTITY
                                    item.NetsuiteQuantity__c = ass.Quantity;

                                     //TO  REMOVE :> ASSET USAGE QUANTITY FROM THIS CLASS => List price discount Class    
                                     
                                    if(Map_PriceProductType.get(ass.Product2Id) == null){
                                        List<String> PriceProductType = new List<String>();
                                        PriceProductType.AddAll(ass.Product2.OrderLineType__c.Split(';'));
                                        Map_PriceProductType.put(ass.Product2Id,PriceProductType);
                                    }

                                    if(ass.Quantity!= null && AssetPricingMethod !='AccountStudents'){
                                        
                                        BilltoProd = ass.BillToAccount__c;
                                        
                                        if(Map_BillToPRod.get(BilltoProd)==null){
                                            Map_BillToPRod.put(BilltoProd,ass.Quantity);
                                        }
                                        else{                
                                                Map_BillToPRod.put(BilltoProd,Map_BillToPRod.get(BilltoProd)+ass.Quantity);      
                                        }
                        
                                        BilltoProd += ass.Product2.ProductRateGroup__c; //  ProductDiscountGroup__c
                        
                                        if(Map_BillToPRod.get(BilltoProd)==null){
                                            Map_BillToPRod.put(BilltoProd,ass.Quantity);
                                        }
                                        else{
                                            Map_BillToPRod.put(BilltoProd,Map_BillToPRod.get(BilltoProd)+ass.Quantity);      
                                        }
                                    }
                                

                                    if(Map_PBEUnitPrice.get(PBId) != null){
                                        item.unitprice =Map_PBEUnitPrice.get(PBId);
                                    }
                                    else{
                                        item.unitprice =ass.Price;
                                    }
                                     
                                    
                                   if(ass.ManualDiscount__c != null && ass.ManualDiscount__c.contains('Recurring')){ 
                                        if(ass.ManualDiscount__c != null && (ass.ManualDiscount__c.contains('Amount'))){
                                            item.ManualDiscount__c = ass.ManualDiscount__c;
                                            item.ManualDiscountValue__c = ass.ManualDiscountValue__c;
                                            item.UnitPrice = item.UnitPrice-item.ManualDiscountValue__c;  
                                            
                                        }
                                        else if(ass.ManualDiscount__c != null && (ass.ManualDiscount__c.contains('Percentage'))){
                                            item.ManualDiscount__c = ass.ManualDiscount__c;
                                            item.ManualDiscountPercent__c = ass.ManualDiscountPercent__c;
                                            item.UnitPrice = item.UnitPrice-(item.UnitPrice*(Item.ManualDiscountPercent__c/100));
                                            
                                        } 
                                    }                                
                                 

                                    item.PricebookEntryId = Map_PBE.get(PBId);
                                    item.OrderStatus__c = 'Draft';
                                    item.OrderId = NewOrder.id;
                                    item.OrderLineType__c = ass.OrderLineType__c; 

                                    item.Renewable__c= true;
                                    item.Asset__c = ass.id;
                                    item.ProductType__c = ass.Product2.Type__c;
                                    item.DigitalActivationEMail__c = ass.Account.DigitalActivationEmail__c;
                                    item.orderImportNumber__c = 'Asset Renewal';
                                    

                                    item.StartDate__c = ass.RenewalDate__c; 
                                    item.ServiceDate = ass.RenewalDate__c;
                                    //NB ADd licence duration (ie number of months) instead of renewal term
                                    if(ass.Product2.LicenseDuration__c != null){
                                        item.EndDate  = ass.RenewalDate__c.addMonths(integer.valueof(ass.Product2.LicenseDuration__c)) ; //system.today()
                                        ass.RenewalDate__c = ass.RenewalDate__c.addMonths(integer.valueof(ass.Product2.LicenseDuration__c)) ; //system.today()
                                    }

                                   lst_OrderItemAsset.add(item);
                                   system.debug('**NewOrder MAP **index**'+index);
                                    Map_OrderItems.put(index,lst_OrderItemAsset);
                                    ass.LastRenewalUpdate__c = system.today();
                                     ass.AssetRenewalTrigger__c = false;
                                    
                                    }
                                }
                        }

          
                        
                    }
                     

            }    
        system.debug('**NewOrder OUT **index**'+index);
        system.debug('**Assets for MAP: MAP**'+Map_BillToPRod);
        try {
            
            Insert lstOrderShipto;
            
            /*
            
            
            Insert lstOrderItem;
            lstOrderItem =  Order_OrderandOrdeItemHandler.triggerhandler(lstOrderItem);
            Update lstOrderItem;
            
            System.enqueueJob(new Order_OrderItemTriggerQueueable(lst_Order,'Start'));
            
            system.debug('**OrderItem Trigger: Update Assets**');
            update lstAssets;
            */

            if(lst_Order.size()>0){
                System.enqueueJob(new Order_AssetRenewalLineItemQueueable(lst_Order,Map_OrderItems,lstAssets,Map_BillToPRod,Map_PriceProductType,1));
            }
            

            if(lstErrorLog.size()>0){
               insert lstErrorLog;
               update lst_AssetErrorLog;
            }

             if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True){
                CalloutException e = new CalloutException();
                e.setMessage('Error');
                throw e;        
              }
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            system.debug('**Add Order: Error**'+e.getMessage());
            HandleCustomException.LogException(e,lstOrderShipto[0].id);
                
        }
        
        

        
}
/*
public static Map<String,Decimal> returnUsageBasedAssets(asset[] lstAssets){

   
        Map<String,Decimal> Map_BillToPRod = new Map<String,Decimal>();                            
        for(asset ass:lstAssets){

            if(ass.Quantity!= null){
                String BilltoProd;
                BilltoProd = ass.BillToAccount__c;
                
                if(Map_BillToPRod.get(BilltoProd)==null){
                    Map_BillToPRod.put(BilltoProd,ass.Quantity);
                }
                else{                
                        Map_BillToPRod.put(BilltoProd,Map_BillToPRod.get(BilltoProd)+ass.Quantity);      
                }

                BilltoProd += ass.Product2.ProductRateGroup__c; //  ProductDiscountGroup__c

                if(Map_BillToPRod.get(BilltoProd)==null){
                    Map_BillToPRod.put(BilltoProd,ass.Quantity);
                }
                else{
                    Map_BillToPRod.put(BilltoProd,Map_BillToPRod.get(BilltoProd)+ass.Quantity);      
                }
            }
           

            
           
        }
        system.debug('**BilltoProd Call**'+Map_BillToPRod);
        return Map_BillToPRod;
}
*/


}