public with sharing class Order_AssetsCreateOnOrderActivation implements Queueable{
    



    // turn into queueable
    // On complete call
    // bg_AllObjectInvocableHandler.AllObjectInvocableHandler(Set_ItemId);
    
   

    Private List<Id> ItemIdFullList;
    Private Set<Id> ItemId;

    Public Order_AssetsCreateOnOrderActivation(List<Id> ItemIdFullList, Set<Id> ItemId){
        this.ItemIdFullList = ItemIdFullList;
        this.ItemId = ItemId;
   }
    
  public void execute(System.QueueableContext qc) {
    processAssetsFromOrder(ItemIdFullList,ItemId);
  }   


  // @invocablemethod
    //@future
    public static void processAssetsFromOrder(List<Id> ItemIdFullList, Set<Id> ItemId){
        

        if(ItemId.size()>0){

        

                    OrderItem[] lstOrderItem = [Select id,Asset__c,Quantity,Order.Type,TrialStartDate__c,TrialEndDate__c,StartDate__c, Order.Pricebook2Id,UnitPrice,Order.Billto__c,Order.Source__c, EndDate,ManualDiscount__c,ManualDiscountPercent__c,
                                                        ListPrice,DiscountedPrice__c,ServiceDate,LicenseDuration__c,CreatedDate,ShipToAccount__c,Renewable__c,AssetIdValidate__c,ShipToAttentionOf__c,
                                                        Product2.Method__c,OrderLineType__c,Product2.Name,OperatingCompany__c,Order.EndDate,ManualDiscountValue__c,NetsuiteQuantity__c,Order.shipToAttentionOf__c,
                                                        Order.PricingMethod__c,Product2Id,ShipToAccount__r.DigitalActivationEmail__c, Product2.Type__c,DigitalActivationEMail__c                                    
                                                        From OrderItem where Id in:ItemId limit 200];
                    
                    
                
                    Set<String> Set_Asset = new Set<String>();
                    Set<String> Set_BillTo = new Set<String>();
                    Set<String> Set_ShipTo = new Set<String>();
                    Set<String> Set_PricingMethod = new Set<String>();
                    List<Asset> lstNewAsset = new List<Asset>();
                    Set<string> Set_AssetCreate = new Set<string>();
                    
                    String ProdShipto;
                    Integer varIterator = 0;
                    String OrderType = 'Standard';

                    if(lstOrderItem[0].Order.Type == 'RenewalOrder'){

                                OrderType = 'RenewalOrder';

                                for(OrderItem  item:lstOrderItem){
                                    Set_Asset.add(item.Product2Id);
                                    Set_BillTo.add(item.Order.Billto__c);
                                    Set_ShipTo.add(item.ShipToAccount__c);
                                    Set_PricingMethod.add(item.Order.PricingMethod__c);
                                }        

                                system.debug('**AssetCreation: Set Assets**'+Set_Asset);

                                system.debug('**AssetCreation: Set Assets**'+Set_Asset);

                                Asset[] ListOfAssets= [Select AccountCustomerNumber__c,EndDate__c,AccountId,AccountName__c,ActivationDate__c,AssetLevel,AutomatedRenewProcess__c,OrderLineType__c,
                                                            BillToAccount__c,BillToName__c,CancellationDate__c,CancellationReason__c,CancellationTrigger__c,Channel__c,
                                                            ContactId,Contract__c,CreatedById,CreatedDate,Crebocode__c,CurrencyIsoCode,CurrentEdition__c,CurrentMethod__c,
                                                            CurrentPublisher__c,Description,DigitalFactor__c,DiscountedPrice__c,Id,InstallDate,IsActive__c,ISBN__c,
                                                            IsBooklistPresent__c,IsCompetitorProduct,IsDeleted,IsInternal,IsUpForRenewal__c,LastRenewalUpdate__c,
                                                            LastViewedDate,Level__c,LicenseDuration__c,ListPrice__c,LocationTotalNumberofStudents__c,
                                                            ManualDiscountPercent__c,ManualDiscountValue__c,ManualDiscount__c,MethodCode__c,MethodName__c,
                                                            Method__c,Name,NumberofActiveUsers__c,OperatingCompany__c,OrderProduct__c,OwnerId,ParentId,Price,Product2.Type__c,DigitalActivationEmail__c,
                                                            PriceBook__c,PriceValidTillDate__c,PricingMethod__c,Product2Id,ProductClass__c,ProductCode,ProductFamilyType__c,
                                                            ProductFamily__c,PurchaseDate,Quantity,RecordTypeId,RecordTypeName__c,RenewalDate__c,RenewalTerm__c,
                                                            Unit__c,UsageEndDate 
                                                            from Asset where Product2Id in:Set_Asset AND BillToAccount__c in:Set_BillTo AND AccountId in:Set_ShipTo AND PricingMethod__c in: Set_PricingMethod];

                                system.debug('**AssetCreation: ListOfAssets**'+ListOfAssets);
                                
                                
                            
                                Boolean addNewAsset;

                    
                    
                                for(OrderItem  item:lstOrderItem){                           
                                    addNewAsset = true;
                                    
                                        for(Asset ass:ListOfAssets){
                                                if(item.Product2Id == ass.Product2Id && item.ShipToAccount__c == ass.AccountId && item.Order.PricingMethod__c ==  ass.PricingMethod__c ){
                                                    system.debug('**AssetCreation: Product2Id**'+'*Item**'+item.Product2Id+'**ass**'+ass.Product2Id);
                                                    system.debug('**AssetCreation: Product2Id**'+'*Item**'+item.Product2Id+'**ass**'+ass.Product2Id);
                                                                        
                                                    ass.OrderLineType__c = item.OrderLineType__c;
                                                   
                                                    ass.PriceBook__c = item.Order.Pricebook2Id;
                                                   
                                                    ass.Description = 'Description';
                                                    
                                                    if(item.Product2.Type__c =='Non-inventory Item'){
                                                        if(ass.DigitalActivationEmail__c == null){
                                                            item.DigitalActivationEMail__c =  item.ShipToAccount__r.DigitalActivationEmail__c;
                                                        }
                                                        else{
                                                            item.DigitalActivationEMail__c =  ass.DigitalActivationEmail__c;
                                                        }                                                        
                                                    }

                                                    if(item.Order.Type == 'RegularOrder'){
                                                        ass.Quantity = ass.Quantity+item.Quantity; 
                                                        item.AssetIdValidate__c  = ass.Id;
                                                        item.Asset__c = ass.Id;
                                                        system.debug('**AssetCreation: Regular Order**');
                                                    }
                                                    else if(item.Order.Type == 'RenewalOrder'){
                                                        //ass.Quantity = item.Quantity;

                                                        //To manage Item Group components
                                                        
                                                        //NESTUITE QUANTITY
                                                     //   ass.Quantity = item.Quantity;
                                                    //   ass.Quantity = item.NetsuiteQuantity__c;
                                                        ass.Price = item.UnitPrice;
                                                        ass.Description = 'Description';
                                                        
                                                        ass.ManualDiscount__c = item.ManualDiscount__c;
                                                        ass.ManualDiscountPercent__c = item.ManualDiscountPercent__c;
                                                        ass.ManualDiscountValue__c = item.ManualDiscountValue__c;
                                                        ass.ListPrice__c = item.ListPrice; 
                                                        ass.DiscountedPrice__c = item.DiscountedPrice__c;
                                                    
                                                        ass.LicenseDuration__c = item.LicenseDuration__c;
                                                        ass.PriceBook__c = item.Order.Pricebook2Id ;
                                                    
                                                        system.debug('**AssetCreation: Renewal Order**');


                                                        ass.RenewalDate__c = item.EndDate;

                                                    }
                                                    if(item.Order.shipToAttentionOf__c != null){
                                                        ass.ShipToAttentionOf__c = item.Order.shipToAttentionOf__c;
                                                    }
                                                    else{
                                                        ass.ShipToAttentionOf__c = item.ShipToAttentionOf__c;
                                                    }
                                                        
                                                    addNewAsset=false;
                                                }                        
                                        }
                                        if(addNewAsset){
                                            ProdShipto = item.Product2Id;
                                            ProdShipto += item.ShipToAccount__c;
                                            Set_AssetCreate.add(ProdShipto);
                                        }
                                        
                            }  
                        
                    }

                    for(OrderItem  item:lstOrderItem){
                                        ProdShipto = item.Product2Id;
                                        ProdShipto += item.ShipToAccount__c;
                                    
                                if(OrderType == 'Standard' || (Set_AssetCreate.contains(ProdShipto) && OrderType == 'RenewalOrder')){
                                    
                                            system.debug('**AssetCreation: Name**'+item.Product2.Name);
                                            Asset NewAsset = new Asset();
                                            NewAsset.AccountId = item.ShipToAccount__c; 
                                            NewAsset.OrderItemIdOnCreate__c = item.id;
                                            
                                            NewAsset.BillToAccount__c = item.Order.Billto__c;
                                            NewAsset.DiscountedPrice__c = item.DiscountedPrice__c;
                                            
                                            NewAsset.IsActive__c = true;
                                            NewAsset.OrderLineType__c = item.OrderLineType__c;
                                            
                                            NewAsset.ListPrice__c = item.ListPrice;
                                            NewAsset.ManualDiscountPercent__c = item.ManualDiscountPercent__c;
                                            NewAsset.ManualDiscountValue__c = item.ManualDiscountValue__c;
                                            NewAsset.ManualDiscount__c = item.ManualDiscount__c;
                                            NewAsset.Method__c = item.Product2.Method__c;
                                            NewAsset.Name = item.Product2.Name;
                                            NewAsset.OperatingCompany__c= item.OperatingCompany__c;
                                            NewAsset.Price = item.UnitPrice;
                                            NewAsset.PriceBook__c	= item.Order.Pricebook2Id;
                                            NewAsset.PriceValidTillDate__c = item.Order.EndDate;
                                            NewAsset.PricingMethod__c = item.Order.PricingMethod__c;
                                            NewAsset.Product2Id= item.Product2Id;
                                            
                                            NewAsset.Quantity = item.Quantity;
                                            //NewAsset.tmpOrderItemId__c = item.Id;
                                            NewAsset.Description = string.valueof(varIterator);


                                            NewAsset.AutomatedRenewProcess__c = item.Renewable__c;
                                            NewAsset.LicenseDuration__c = item.LicenseDuration__c;
                                            NewAsset.InstallDate = item.ServiceDate;

                                            if(item.Renewable__c == false && item.LicenseDuration__c>0){
                                                NewAsset.EndDate__c = item.StartDate__c.addMonths(integer.valueof(item.LicenseDuration__c))-1;                                                
                                            }
                                            else if(item.Renewable__c == true){
                                                NewAsset.EndDate__c = item.StartDate__c.addMonths(integer.valueof(item.LicenseDuration__c))-1;
                                                NewAsset.RenewalDate__c = item.EndDate+1;
                                            }

                                            if(item.TrialStartDate__c != null){
                                                NewAsset.ActivationDate__c = item.TrialStartDate__c;   
                                            }
                                            else{
                                                NewAsset.ActivationDate__c = item.ServiceDate;
                                            }
                                            

                                            if(item.Order.Source__c == 'B2B Salesforce'){
                                                NewAsset.PurchaseDate = NewAsset.ActivationDate__c;
                                            }
                                            else{
                                                NewAsset.PurchaseDate = date.valueof(item.CreatedDate);
                                            }
                                            
                                            
                                            if(item.Product2.Type__c =='Non-inventory Item' && item.DigitalActivationEmail__c !=null){
                                                    NewAsset.DigitalActivationEmail__c =  item.DigitalActivationEmail__c;
                                                    item.DigitalActivationEmail__c = item.DigitalActivationEmail__c;
                                            }
                                            else if(item.Product2.Type__c =='Non-inventory Item' && item.ShipToAccount__r.DigitalActivationEmail__c !=null){
                                                    NewAsset.DigitalActivationEmail__c =  item.ShipToAccount__r.DigitalActivationEmail__c;
                                                    item.DigitalActivationEmail__c = item.ShipToAccount__r.DigitalActivationEmail__c;
                                            }

                                            
                                            
                                            if(item.Order.shipToAttentionOf__c != null){
                                                NewAsset.ShipToAttentionOf__c = item.Order.shipToAttentionOf__c;
                                            }
                                            else{
                                                NewAsset.ShipToAttentionOf__c = item.ShipToAttentionOf__c;
                                            }

                                            lstNewAsset.add(NewAsset);
                                            varIterator++;
                                    //  }         
                                    }                  
                    }    
                    system.debug('**AssetCreation: lstNewAsset**'+lstNewAsset);

                    try{
                    //FOR UPSELL: Commented out until needed
                    //update ListOfAssets;
                    
                    insert lstNewAsset;
                    
                    
                    Set<Id> ItemIdRemove = new Set<Id>();

                    for(OrderItem  item:lstOrderItem){
                            
                            for(Asset ass:lstNewAsset){
                                if(item.Product2Id == ass.Product2Id && item.ShipToAccount__c == ass.AccountId && ass.OrderItemIdOnCreate__c = item.id ){
                                    item.Asset__c = ass.Id;
                                    item.AssetIdValidate__c  = ass.Id;
                                }    
                            }

                            ItemIdRemove.add(item.id);
                    } 
                    update lstOrderItem;
                    system.debug('**AssetCreation: Updated**');

                    
                        ItemId.RemoveAll(ItemIdRemove);
                        System.enqueueJob(new Order_AssetsCreateOnOrderActivation(ItemIdFullList,ItemId));
                                            
                        if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True){
                            CalloutException e = new CalloutException();
                            e.setMessage('Error');
                            throw e;        
                        }
                    }
                    catch(exception e){

                        HandleCustomException.LogException(e,lstOrderItem[0].id);
                        system.debug('**AssetCreation: Error**'+e.getmessage());
                    }

        }
        else{
            bg_AllObjectInvocableHandler.AllObjectInvocableHandler(ItemIdFullList);
        }          
                
    }    


}