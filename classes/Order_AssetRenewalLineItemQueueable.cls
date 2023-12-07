public with sharing class Order_AssetRenewalLineItemQueueable implements Queueable {
    
    Private List<Order> CurOrder;
    Private Map<Decimal,List<OrderItem>> Map_OrderItems;
    Private Map<String,Decimal> Map_OrderProdMap;
    Private List<Asset> lstAssets;
    Private Map<String,List<String>> Map_PriceProductType;
    Private Decimal index;
    
    
    public Order_AssetRenewalLineItemQueueable(List<Order> CurOrder,Map<Decimal,List<OrderItem>> Map_OrderItems,List<Asset> lstAssets,Map<String,Decimal> Map_OrderProdMap,Map<String,List<String>> Map_PriceProductType, Decimal index) {
       this.CurOrder = CurOrder;
       this.Map_OrderItems = Map_OrderItems;
       this.lstAssets = lstAssets;
       this.index = index;
       this.Map_OrderProdMap = Map_OrderProdMap;
       this.Map_PriceProductType = Map_PriceProductType;
       system.debug('**OrderItem Trigger: Queueable Constructor: Index INSIDE**'+index);
    }

    public void execute(System.QueueableContext qc) {
             
            system.debug('**OrderItem Trigger: Queueable Constructor: Load**'+'**index**'+index+'****'+Map_OrderItems.get(index));
        List<OrderItem> lst_AssetItems;

        if(Map_OrderItems.get(index) != null){

                    UTIL_TriggerController.OrderItemTriggerSwitch = false;
                    boolean errormessge=false;    
                    
                    try{
                        insert Map_OrderItems.get(index);

                        // ERROR HANDLING FOR ZERO ORDER ITEMS

                    }
                    catch(exception e){
                        errormessge=true;
                        system.debug('**OrderItem Trigger: Catch error**'+e.getmessage());
                        HandleCustomException.LogException(e,Map_OrderItems.get(index)[0].OrderId);
                    }
                    if(errormessge==false){

                            try{    
                        
                                    lst_AssetItems = new List<OrderItem>();

                                    Set<String> Set_ItemId = new Set<String>();
                                    Set<String> Set_GroupId = new Set<String>();
                                    List<String> Lst_OrdId = new List<String>();

                                    for(OrderItem item:Map_OrderItems.get(index)){
                                        Set_ItemId.add(item.id);
                                        
                                        //Item Groups
                                    }

                                    lst_AssetItems = Order_OrderandOrdeItemHandler.returnQueryOrderItems(Set_ItemId,null);
                                    
                                    
                                    Set<String> Set_CusDiscountGroup = new Set<String>();
                                    Set<String> Set_OperatingCo = new Set<String>();
                                    Set<String> Set_ProdDiscountGroup = new Set<String>();
                                    Set<String> Set_OrderLineItemType = new Set<String>();
                                    Set<String> Set_MarketSegment = new Set<String>();
                                
                                    for(Orderitem item: lst_AssetItems){ 
                                        Set_CusDiscountGroup.add(item.Order.Billto__r.CustomerDiscountGroup__c);
                                        Set_OperatingCo.add(item.Order.Billto__r.OperatingCompany__c);
                                        Set_ProdDiscountGroup.add(item.Product2.ProductDiscountGroup__c);                                    
                                        Set_OrderLineItemType.add(item.OrderLineType__c);                                        
                                        Set_MarketSegment.add(item.Product2.MarketSegment__c);
                                        Lst_OrdId.add(item.OrderId);                               
                                                            
                                    }

                                    Date CurDate = system.today();

                                    ListPriceDiscount__c[] lst_ListPriceDiscountRegular = [Select Id,DiscountType__c,ProductDiscountGroup__c,Subsidiary__c,CustomerDiscountGroup__c,OrderLineType__c, MarketSegment__c,Rate__c,StartQuantity__c From ListPriceDiscount__c  
                                                                                                                    where  EndDate__c >=:CurDate 
                                                                                                                    AND StartDate__c  <=:CurDate
                                                                                                                    AND CustomerDiscountGroup__c in: Set_CusDiscountGroup
                                                                                                                    AND Subsidiary__c in: Set_OperatingCo 
                                                                                                                    AND ProductDiscountGroup__c in: Set_ProdDiscountGroup 
                                                                                                                    AND OrderLineType__c in: Set_OrderLineItemType  
                                                                                                                    AND MarketSegment__c in: Set_MarketSegment    
                                                                                                                    ORDER BY StartQuantity__c DESC];
                                  
                                //Item Groups NOT IN USE                                
                                    /*
                                                                             
                                                        Map<String,String> Map_ItemGroupId = new Map<String,String>();
                                                        Map<String,String> Map_ItemGroupProdMapId = new Map<String,String>();
                                                        Map<String,Decimal> Map_Quantity = new Map<String,Decimal>();

                                                        Pricing__c[] lstPrice = [Select ListRate__c,ProductComponent__r.Product__r.Name,Product__c,EndDate__c,IsActive__c,ProductComponent__r.Quantity__c,ProductComponent__r.Type__c,ProductComponent__r.MainProduct__c,ProductComponent__r.Product__c from Pricing__c 
                                                        Where   (ProductComponent__r.MainProduct__c in: Set_GroupId)
                                                        AND StartDate__c <=: system.today()
                                                        AND EndDate__c >=: system.today()];
                                                        
                                                        if(lstPrice.size()>0){
                                                            
                                                                for(Orderitem item: lst_AssetItems){
                                                                    if(Set_GroupId.contains(item.Product2Id)){
                                                                        system.debug('**Asset renewal: Item Group**'+item.Product2Id);
                                                                        Map_ItemGroupId.put(item.Product2Id,item.Id);
                                                                    }
                                                                }
                                                            
                                                            
                                                            Set_GroupId = new Set<String>();
                                                            for(Pricing__c price:lstPrice){ 
                                                                if(price.ProductComponent__r.MainProduct__c != null){
                                                                    Map_Quantity.put(price.ProductComponent__r.Product__c,price.ProductComponent__r.Quantity__c);
                                                                    Map_ItemGroupProdMapId.put(price.ProductComponent__r.Product__c,price.ProductComponent__r.MainProduct__c);
                                                                    Set_GroupId.add(price.ProductComponent__r.MainProduct__c);
                                                                }
                                                                                                                           } 
                                                            lst_AssetItems = Order_ItemGroupsHandler.ProcessItemGroups(lst_AssetItems,Map_Quantity,Map_ItemGroupId,Map_ItemGroupProdMapId);
                                                        }
                                    */


                                    lst_AssetItems = Order_OrderandOrdeItemHandler.triggerhandler(lst_AssetItems); // Map_OrderItems.get(index)
                                                        
                                    // MOVE ALL LIST PRICE DISCOUNTS TO SAME PROCESS FOR CALCULATION
                                    //  lst_AssetItems = Order_UpdateOrderListPriceDiscountAll.returnItemswithListpriceId('Renewal',lst_AssetItems, lst_ListPriceDiscountRegular, Map_OrderProdMap, Map_PriceProductType);
                                   
                                    lst_AssetItems = Order_UpdateOrderListPriceDiscountAll.ProcessUpdate(null,Lst_OrdId,Null,lst_AssetItems,lst_ListPriceDiscountRegular);
                                    lst_AssetItems =Order_ProductCalculationDates.UpdateOrderItemDate(lst_AssetItems,CurOrder);
                                    
                                    
                                    
                                    
                                    Update lst_AssetItems;
                                    
                                    //VAT & SHIPPING COST Calculated in Order_OrderItemTriggerQueueable below with full list of Items
                                    system.debug('**OrderItem Trigger: Queueable Constructor: Index before**'+index);
                                    index++;
                                    system.debug('**OrderItem Trigger: Queueable Constructor: Index After**'+index);


                                    if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True){
                                        CalloutException e = new CalloutException();
                                        e.setMessage('Error');
                                        throw e;        
                                    }
                                }
                                catch(exception e){
                                    system.debug('**OrderItem Trigger: Catch error**'+e.getmessage() + '. StackTrace: ' + e.getStackTraceString());

                                    HandleCustomException.LogException(e,lst_AssetItems[0].id);
                                    index++;
                                    //errormessge=true;
                                }

                                system.debug('**OrderItem Trigger: Before Job**');
                                    if(!Test.isRunningTest() && errormessge != true){
                                        system.debug('**OrderItem Trigger: In new Job**');
                                        System.enqueueJob(new Order_AssetRenewalLineItemQueueable(CurOrder,Map_OrderItems,lstAssets,Map_OrderProdMap, Map_PriceProductType,index));
                                    }  
                        
                    }    


        }
        else{
            
            
            try{
                if(lstAssets.size()>0){
                    system.debug('**OrderItem Trigger: Queueable Constructor: Load'+ lstAssets[0].LastRenewalUpdate__c );
                    update lstAssets;
                }


                if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True){
                    CalloutException e = new CalloutException();
                    e.setMessage('Error');
                    throw e;        
                  }

            }
            catch(exception e){
                HandleCustomException.LogException(e,lstAssets[0].id);
            }   

            if(!Test.isRunningTest() && CurOrder != null){
                System.enqueueJob(new Order_OrderItemTriggerQueueable(CurOrder,'Start'));
            }
            
                
        }
        
        

    }    
}