public with sharing class Order_OrderandOrdeItemHandler {
    
    //After
    //VAT
    //Shipping cost

    //Product date
    //Order Activatio

//FROM ORDER ITEM


@invocablemethod
    public static void UpdateShippingDates(List<Id> recordIdStrings){

        OrderItem[] lstOrderItem;
        try {
            List<string> ObjectName = UTIL_getObjectName.returnObjectName(recordIdStrings);

            if(ObjectName[0]=='Order'){
                
              //  UTIL_TriggerController.OrderItemTriggerSwitch = false;


                Order[] CurOrder = [Select AccountSubsidiary__c,NumberOfStudents__c,Billto__c,ContractId,EffectiveDate,ShipByDate__c from Order where id in: recordIdStrings];

                for(Order  ord:CurOrder){
                    ord.EffectiveDate = ord.ShipByDate__c;
                }
                

                lstOrderItem = [Select id,Order.EffectiveDate, Order.ShipByDate__c,LineItemTotal__c,ItemGroup__r.Product2Id,Product2.OrderLineType__c,Product2.MarketSegment__c,Product2.name,Product2.SoldInSegment__c,Product2.QuantitySelectionType__c,OrderId,ItemGroup__c,ShipToAccount__r.Name,ShipToAccount__r.CustomerDiscountGroup__c,ListPrice,UnitPrice,Quantity,Product2.ProductDiscountGroup__c,ListPriceDiscount__c,ListPriceDiscount__r.OrderLineType__c,ListPriceDiscount__r.Rate__c,Product2Id,PricebookEntryId,ShipToAccount__c,ManualDiscount__c,ManualDiscountPercent__c,ManualDiscountValue__c 
                From OrderItem where OrderId in:recordIdStrings];

                lstOrderItem = Order_ProductCalculationDates.UpdateOrderItemDate(lstOrderItem,CurOrder);  //recordIdStrings,
                update lstOrderItem;
                update CurOrder;
               

               if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True){
                    CalloutException e = new CalloutException();
                    e.setMessage('Error');
                    throw e;        
               }
            }
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            HandleCustomException.LogException(e,lstOrderItem[0].id);
        }
        finally {
            // Something executed whether there was an error or not
        }
       
    }


    /* TO BE IMPLEMENTED
    Public static List<OrderItem> OrderItemBusinessLogichandler(List<OrderItem> lstOrderItem, CurOrder){

        //Product Selector 1
        lstOrderItem=Order_OrderandOrdeItemHandler.triggerhandler(lst_OrdItem);
        lstOrderItem=Order_ProductCalculationDates.UpdateOrderItemDate(lstOrderItem,CurOrder);

        //Product Selector 2         System.enqueueJob(new Order_OrderItemTriggerQueueable(lst_Order,'Start'));
        Order_UpdateVatOnItems.UpdateVatOnItems (lstOrderItem);
        Order_UpdateShippingCostsFromItems.UpdateShippingCostsFromItems(lstOrderItem,CurOrder[0]);


        //B2B
        lst_OrdItem = Order_OrderandOrdeItemHandler.triggerhandler(lst_OrdItem);
        lst_OrdItem =Order_ProductCalculationDates.UpdateOrderItemDate(lst_OrdItem,lst_Order);        
        if(lst_Order[0].Source__c =='Trade' || lst_Order[0].Source__c =='B2B Shop' || lst_Order[0].Source__c =='B2B Salesforce'){
            lst_OrdItem = Order_UpdateOrderListPriceDiscountAll.ProcessUpdate(Null,Lst_OrdId,Null,lst_OrdItem,lst_ListPriceDiscountRegular);
        }

        System.enqueueJob(new Order_OrderItemTriggerQueueable(lst_Order,'Start'));


        //AssetRenewal
        lst_AssetItems = Order_OrderandOrdeItemHandler.triggerhandler(lst_AssetItems); // Map_OrderItems.get(index)
        lst_AssetItems = Order_UpdateOrderListPriceDiscountAll.returnItemswithListpriceId(lst_AssetItems, lst_ListPriceDiscountRegular, Map_OrderProdMap, Map_PriceProductType);
        //lst_AssetItems =Order_OrderandOrdeItemHandler.UpdateOrderItemDate(lst_AssetItems,CurOrder);
        lst_AssetItems =Order_ProductCalculationDates.UpdateOrderItemDate(lst_AssetItems,CurOrder);
        System.enqueueJob(new Order_OrderItemTriggerQueueable(CurOrder,'Start'));


    }    

    


*/


    Public static List<OrderItem> triggerhandler(List<OrderItem> lstOrderItem){
        
        String orgId = [SELECT Id FROM Organization].Id;

        system.debug('**OrderItem Trigger: Handler: lstOrderItem**'+lstOrderItem);

        Set<String> Set_ShipTo = new Set<String> ();
        
        Set<String> Set_OrdId = new Set<String> ();
        Set<String> Set_ProdId = new Set<String> ();
        Set<String> Set_InvMulti = new Set<String>();
        Map<String,Set<String>> Map_InvMulti = new Map<String,Set<String>>();
        

        for(OrderItem item:lstOrderItem){
            Set_ShipTo.add(item.ShipToAccount__c);
            Set_OrdId.add(item.OrderId);
            Set_ProdId.add(item.Product2Id);
        }    
        system.debug('**OrderItem Trigger: Set_ProdId**'+Set_ProdId);

        Order[] CurOrder = [Select id,ShipComplete__c,Billto__r.NetsuiteInternalId__c From Order where id in: Set_OrdId];

        Map<String,Boolean> Map_OrdShipComplete = new Map<String,Boolean>();
        Map<String,String> Map_BillToAccNS = new Map<String,String>();

        for(Order ord:CurOrder){
            Map_OrdShipComplete.put(ord.id,ord.ShipComplete__c);
            Map_BillToAccNS.put(ord.id,ord.Billto__r.NetsuiteInternalId__c);
        }

        Product2[] lstProduct = [Select id,DeliverComplete__c,IsInspectionCopyOrderPossible__c,IsRegularOrderPossible__c,IsUseCopyOrderPossible__c from Product2 where id in: Set_ProdId];

        Map<String,Boolean> Map_ProdDelCompl = new Map<String,Boolean>();
        Map<String,Boolean> Map_InspectionCopyOrder = new Map<String,Boolean>();
        Map<String,Boolean> Map_RegularOrder = new Map<String,Boolean>();
        Map<String,Boolean> Map_UseCopyOrder = new Map<String,Boolean>();  

        
        for(Product2 prod:lstProduct){

         //   system.debug('**OrderItem Trigger: ProductLoop**');

            Map_ProdDelCompl.put(prod.id, prod.DeliverComplete__c);
            Map_InspectionCopyOrder.put(prod.id,prod.IsInspectionCopyOrderPossible__c);
            Map_RegularOrder.put(prod.id,prod.IsRegularOrderPossible__c);
            Map_UseCopyOrder.put(prod.id,prod.IsUseCopyOrderPossible__c);
        }


        Account[] lstShipto = [Select ShippingCity,ShippingCountry,ExternalCustomerId__c,OperatingCompany__c,ShippingCostMethod__c,NetsuiteInternalId__c,ShippingPostalCode,ShippingState,ShippingStreet,DigitalActivationEmail__c From Account where id in: Set_ShipTo];

        Map<String,String> Map_ShippingCity = new Map<String,String>();
        Map<String,String> Map_ShippingCountry = new Map<String,String>();
        Map<String,String> Map_ShippingPostalCode = new Map<String,String>();
        Map<String,String> Map_ShippingState = new Map<String,String>();
        Map<String,String> Map_ShippingStreet = new Map<String,String>();
        Map<String,String> Map_DigitalActivationEmail = new Map<String,String>();
        Map<String,String> Map_NetsuiteId = new Map<String,String>();
        Map<String,String> Map_ShippingIndicationRule = new Map<String,String>();
        Map<String,String> Map_OperatingComapny = new Map<String,String>();
        
        
        for(Account acc:lstShipto){
            Map_ShippingCity.put(acc.id,acc.ShippingCity);
            Map_ShippingCountry.put(acc.id,acc.ShippingCountry);
            Map_ShippingPostalCode.put(acc.id,acc.ShippingPostalCode);
            Map_ShippingState.put(acc.id,acc.ShippingState);
            Map_ShippingStreet.put(acc.id,acc.ShippingStreet);
            Map_DigitalActivationEmail.put(acc.id,acc.DigitalActivationEmail__c);
            Map_NetsuiteId.put(acc.id,acc.NetsuiteInternalId__c);
            Map_ShippingIndicationRule.put(acc.id,acc.ShippingCostMethod__c);
            Map_OperatingComapny.put(acc.id,acc.OperatingCompany__c);
           
        }
       

        for(OrderItem item:lstOrderItem){
            
            //Digital Activation Mail

            //system.debug('**OrderItem Trigger: DigitalActivationEmail **'+item.ShipToAccount__r.DigitalActivationEmail__c);
            //system.debug('**OrderItem Trigger: ProductLicenseDuration**'+item.ProductLicenseDuration__c);
           // system.debug('**OrderItem Trigger: item.Product2.LicenseDuration**'+item.Product2.LicenseDuration__c);

           if(item.DigitalActivationEMail__c == null){

            /*
            if(item.Order.Source__c.Contains('eCommerce')){
                item.DigitalActivationEMail__c =  item.Order.DigitalActivationEMail__c;
            }
            */
            
            if( Map_DigitalActivationEmail.get(item.ShipToAccount__c) !=null && (item.ProductLicenseDuration__c != null || item.Product2.LicenseDuration__c !=null)){ //&& {!Assign_Digital_Activation} Was visited == false){  
                item.DigitalActivationEMail__c = Map_DigitalActivationEmail.get(item.ShipToAccount__c);
            }

           } 

            //List Price Discount Amount
            if(item.List_Price_Rate__c !=null){ // && {!Assign_List_Price_Discount_Amount} Was visited == false){

                item.ListPriceDiscountAmount__c = (item.Quantity * item.ListPrice *   item.List_Price_Rate__c).setScale(2);
                //{!form_ListPriceDiscountAmount}
            }

            //Ship To Account
            if(item.ShipToAccount__c !=null && item.ShippingCity__c == null){  //&& {!Assign_Shipping_information} Was visited == false){            
               // system.debug('**Ship To Account:item.ShipToAccount__r.ShippingCity **');
                item.ShippingCity__c= Map_ShippingCity.get(item.ShipToAccount__c);
                item.ShippingCountry__c= Map_ShippingCountry.get(item.ShipToAccount__c);
                item.ShippingPostalCode__c= Map_ShippingPostalCode.get(item.ShipToAccount__c);
                item.ShippingState__c= Map_ShippingState.get(item.ShipToAccount__c);
                item.ShippingStreet__c= Map_ShippingStreet.get(item.ShipToAccount__c);
            }

            //Shiping cost exempt: true
            if( item.Order.ShippingCostExempt__c == true){ // && {!Assign_Shipping_Cost_Exempt_True} Was visited == false){
               // system.debug('**Shipping Cost Exempt**');
                item.ShippingIndicationRule__c = 'Shipping Cost Exempt';
            }

            //Shipping cost exempt: false
            else if( item.Order.ShippingCostExempt__c != true && item.Order.ShippingCostMethodNS__c != null){  //  item.Order.ShippingIndicationRule__c != null){ //&& {!Assign_Shipping_Cost_Exempt_false} Was visited == false
                //    system.debug('**No Cost Exempt**');    
                    item.ShippingIndicationRule__c = item.Order.ShippingCostMethodNS__c;
            }
            else if( item.Order.ShippingCostExempt__c != true && Map_ShippingIndicationRule.get(item.ShipToAccount__c) != null){  //  item.Order.ShippingIndicationRule__c != null){ //&& {!Assign_Shipping_Cost_Exempt_false} Was visited == false
                //    system.debug('**No Cost Exempt**');    
                    item.ShippingIndicationRule__c = Map_ShippingIndicationRule.get(item.ShipToAccount__c);
            }
           // system.debug('**ShippingIndicationRule: In loop**'+item.ShippingIndicationRule__c); 
            
                //Org is a Sandbox or tests is running (Test.isRunningTest() included to add code coverage independant of the Org type)
                if(orgId == '00D3N0000008kLoUAI' || Test.isRunningTest()){
                    if(Map_OperatingComapny.get(item.ShipToAccount__c) =='Plantyn' && item.ShippingIndicationRule__c != null){
                            if(item.ShippingIndicationRule__c == 'Based on order total'){
                                    item.ShippingMethodNetsuiteId__c ='320';
                                }
                                else if(item.ShippingIndicationRule__c == 'Based on weight Domestic'){
                                    item.ShippingMethodNetsuiteId__c ='319';
                                }
                                else if(item.ShippingIndicationRule__c == 'Based on weight non Domestic'){
                                    item.ShippingMethodNetsuiteId__c ='318';
                                }
                                else if(item.ShippingIndicationRule__c == 'Shipping Cost Exempt'){
                                    item.ShippingMethodNetsuiteId__c ='196';
                                } 
                        }
                        else if(Map_OperatingComapny.get(item.ShipToAccount__c) =='Liber' && item.ShippingIndicationRule__c != null){
                            if(item.ShippingIndicationRule__c == 'Based on order total'){
                                item.ShippingMethodNetsuiteId__c ='7528';
                            }
                            else if(item.ShippingIndicationRule__c == 'Based on weight Domestic'){
                                item.ShippingMethodNetsuiteId__c ='7526';
                            }
                            else if(item.ShippingIndicationRule__c == 'Based on weight non Domestic'){
                                item.ShippingMethodNetsuiteId__c ='7527';
                            }
                            else if(item.ShippingIndicationRule__c == 'Shipping Cost Exempt'){
                                item.ShippingMethodNetsuiteId__c ='7525';
                            }
                        }
                        else if(Map_OperatingComapny.get(item.ShipToAccount__c) =='Noordhoff' && item.ShippingIndicationRule__c != null){
                            item.ShippingMethodNetsuiteId__c ='0';
                        }
                }
                //Org is a UAT/Production or tests is running (Test.isRunningTest() included to add code coverage independant of the Org type)
                if(orgId != '00D3N0000008kLoUAI' || Test.isRunningTest()){
                    if(Map_OperatingComapny.get(item.ShipToAccount__c) =='Plantyn' && item.ShippingIndicationRule__c != null){
                        if(item.ShippingIndicationRule__c == 'Based on order total'){
                            item.ShippingMethodNetsuiteId__c ='193';
                        }
                        else if(item.ShippingIndicationRule__c == 'Based on weight Domestic'){
                            item.ShippingMethodNetsuiteId__c ='194';
                        }
                        else if(item.ShippingIndicationRule__c == 'Based on weight non Domestic'){
                            item.ShippingMethodNetsuiteId__c ='195';
                        }
                        else if(item.ShippingIndicationRule__c == 'Shipping Cost Exempt'){
                            item.ShippingMethodNetsuiteId__c ='196';
                        } 
                    }
                    else if(Map_OperatingComapny.get(item.ShipToAccount__c) =='Liber' && item.ShippingIndicationRule__c != null){
                        if(item.ShippingIndicationRule__c == 'Based on order total'){
                            item.ShippingMethodNetsuiteId__c ='7528';
                        }
                        else if(item.ShippingIndicationRule__c == 'Based on weight Domestic'){
                            item.ShippingMethodNetsuiteId__c ='7526';
                        }
                        else if(item.ShippingIndicationRule__c == 'Based on weight non Domestic'){
                            item.ShippingMethodNetsuiteId__c ='7527';
                        }
                        else if(item.ShippingIndicationRule__c == 'Shipping Cost Exempt'){
                            item.ShippingMethodNetsuiteId__c ='7525';
                        } 
                    }
                    else if(Map_OperatingComapny.get(item.ShipToAccount__c) =='Noordhoff' && item.ShippingIndicationRule__c != null){
                        item.ShippingMethodNetsuiteId__c ='0';
                    }
                }              
            
            if(Map_OrdShipComplete.get(item.OrderId) == true){
                item.DeliveryType__c='Wait for full delivery';
            }

            if(item.ItemGroup__c != null){
                item.DeliveryType__c='Wait for full delivery';
            }

            if(item.ItemGroup__c == null && Map_ProdDelCompl.get(item.Product2Id)==true){
                item.DeliveryType__c='Wait for full delivery';
            }

            system.debug('**OrderItem Trigger: RegularOrder**'+Map_RegularOrder.get(item.Product2Id));

            item.IsInspectionCopyOrderPossible__c = Map_InspectionCopyOrder.get(item.Product2Id);
            item.IsRegularOrderPossible__c = Map_RegularOrder.get(item.Product2Id);
            item.IsUseCopyOrderPossible__c = Map_UseCopyOrder.get(item.Product2Id);

            item.NetSuiteIdBilltoAccount__c = Map_BillToAccNS.get(item.OrderId);
            item.NetSuiteIdShiptoAccount__c = Map_NetsuiteId.get(item.ShipToAccount__c);
            item.NetsuiteInternalId__c = Map_NetsuiteId.get(item.ShipToAccount__c);

            item.OrderMultipleShippingLocations__c = item.Order.MultipleShippingLocations__c;

            if(item.ProductType__c == 'Inventory Item'){
                
                if(Map_InvMulti.get(item.OrderId) == null ){
                    Set_InvMulti = new Set<String>();
                    Set_InvMulti.add(item.ShipToAccount__c);
                    Map_InvMulti.put(item.OrderId, Set_InvMulti);
                }
                else{
                    Set_InvMulti = new Set<String>();
                    Set_InvMulti.addall(Map_InvMulti.get(item.OrderId));
                    Set_InvMulti.add(item.ShipToAccount__c);
                    Map_InvMulti.put(item.OrderId,Set_InvMulti);
                }
                item.MultiShiptoInventoryRollingCount__c = Map_InvMulti.get(item.OrderId).size(); 
            }

           // item.NetSuiteIdShiptoAccount__c = Map_Netsuite.get(item.ShipToAccount__c);

           //Discount
           if(item.ProductType__c != 'Item Group'){

            system.debug('**OrderItem Trigger: NetsuiteListPrice**'+item.NetsuiteListPrice__c);
            system.debug('**OrderItem Trigger: UnitPrice**'+item.UnitPrice);
            system.debug('**OrderItem Trigger: Quantity**'+item.Quantity);


            item.TotalDiscountAmount__c = (item.NetsuiteListPrice__c - item.UnitPrice) * item.Quantity;
            }

            if(item.List_Price_Rate__c != null){
                item.ListPriceDiscountRate__c = item.List_Price_Rate__c;
            }
           /*
           if(item.discount__c != null){
                item.TotalDiscountAmount__c = item.discount__c * item.Quantity; 
          }
          */

        }
        
        return lstOrderItem;
    }
 

    Public static List<OrderItem> returnQueryOrderItems(Set<String> Set_ItemId,List<Id> OrderId){

        String Querystr;
        
            Querystr= 'Select id,'
         +'  ShipToAccount__c,'
         +'  ProductLicenseDuration__c, '                
         +'  Quantity,'
         +'  ListPrice,'
         +'  List_Price_Rate__c,'       
         +'  Product2Id,'
         +'  ItemGroup__c,'
         +' ShippingCity__c,'
         +' ShippingCountry__c,'
         +'  ShippingPostalCode__c,'
         +' ShippingState__c,'
         +' ShippingStreet__c,'
         +' ShippingIndicationRule__c,'         
         +'  DeliveryType__c,'
         +' discount__c,'
         +' ListPriceDiscountRate__c,'
         +' TotalDiscountAmount__c,'
         +' DiscountedPrice__c,' 
         +' DiscountedPriceItemGroup__c,'
         +' NetSalesPriceItemGroup__c,'
         +' NetsuiteListPrice__c,'
         +' ProductType__c,'
         +' OrderMultipleShippingLocations__c,'
         +' IsInspectionCopyOrderPossible__c,'
         +' IsRegularOrderPossible__c,'
         +' IsUseCopyOrderPossible__c,'
         +' NetsuiteInternalId__c,'          
         +' ManualDiscountValue__c,'
         +' ManualDiscount__c,'
         +' ManualDiscountPercent__c,'
         +' DigitalActivationEMail__c,'
         +' UnitPrice,'
         +' ListPriceItemGroup__c,'
         +' ComponentListPrice__c,'
         +' MultiShiptoInventoryRollingCount__c,'
         +' StartDate__c,'
         +' ServiceDate,'      
         +' OrderId,'
         +' Order.ShippingCostExempt__c,'
         +' Order.Billto__r.CustomerDiscountGroup__c,'
         +' Order.Billto__r.OperatingCompany__c,'
         +' Order.ShippingIndicationRule__c,'
         +' Order.ShippingCostMethodNS__c,'        
         +' Order.MultipleShippingLocations__c,' 
         +' Order.DigitalActivationEMail__c,'
         +' Order.PricingMethod__c,'
         +' Order.Source__c,'
         +' ShipToAccount__r.NumberOfStudents__c,'
         +' Product2.ProductRateGroup__c,'          
         +' Product2.MarketSegment__c,'
         +' Product2.LicenseDuration__c,'
         +' Product2.Name,'
         +' Product2.OrderLineType__c,'
         +' Product2.ProductDiscountGroup__c,'
         +' OrderLineType__c,'
         +' Product2.IsSuccessorItemActive__c,'
         +' Product2.SuccessorItem__c,'
         +' Product2.Stocknumber__c,'
         +' Product2.StockLevel__c,' 
         +'  Product2.PlannedPrintDate__c'
         +'  from OrderItem where ';
         
         if(OrderId != null){
             querystr += 'OrderId in: OrderId';
         }
         else{
            querystr += 'Id in: Set_ItemId';
         }
         

         system.debug('***querystr**'+querystr);

         OrderItem[] lst_OrdItem =  Database.query(querystr);

         system.debug('***lst_OrdItem**'+lst_OrdItem);

         return lst_OrdItem;
   }    


}