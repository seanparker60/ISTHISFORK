public with sharing class Order_B2BOrderInvocable {
  

    @invocablemethod
    public static void UpdateOrderItems (List<Id> OrderId){
        UpdateOrderItemsfuture (OrderId);
    }//  @future
    public static void UpdateOrderItemsfuture (List<Id> OrderId){    
        Set<String> ShiptoId = new Set<String>();
      
        
            OrderItem[]   lst_OrdItem = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);    

            /* OrderLineItemType__c, */
            
        Map<String,String> Map_ShipToOrd = new Map<String,String>();

        String OrdShip;
        List<String> lstOrderId = new List<String>();

        
        Order[] lst_Order = [SELECT EffectiveDate,ShipByDate__c,Pricebook2Id,Billto__r.PaymentMethod__c,Type,NetSuiteIdAccountSubsidiary__c,
                        PaymentMethod__c ,Billto__r.CustomerDiscountGroup__c,PricingMethod__c,Billto__c,Source__c,ShippingIndicationRule__c,ItemGroupCount__c,
                        Billto__r.OperatingCompany__c,ShippingCost__c,ShippingCostDomestic__c,ShippingCostNonDomestic__c,Shipto__r.NetsuiteInternalId__c,Shipto__r.OrderNotificationEmail2__c,
                        Account.BillingReminderEmail__c, Account.DigitalActivationEmail__c, Account.InvoicingEmail__c, Account.OrderNotificationEmail__c,
                        Account.BillingReminderEmail2__c, Account.InvoiceEmail2__c, Account.OrderNotificationEmail2__c,Account.BillingAddressNotes__c,Account.ShippingAddressNotes__c,ShippingAddressNote__c,BillingAddressNote__c,
                        BillingReminderEmail__c, DigitalActivationEmail__c, InvoiceEmail__c, OrderNotificationEmail__c,
                        BillingReminderEmail2__c, InvoiceEmail2__c, OrderNotificationEmail2__c,OperatingCompany__c,
                        Billto__r.InvoicingEmail__c, Shipto__r.OrderNotificationEmail__c, Shipto__c, TotalAmount FROM Order WHERE id IN: OrderId];

        List<String> Lst_OrdId = new List<String>();
        //String OrderLineType;
        
        Set<String> Set_Source = new Set<String>();
        Set<String> Set_Opco = new Set<String>();

        for(Order ord:lst_Order){
            Lst_OrdId.add(ord.id);
            ShiptoId.add(ord.Billto__c);
            Set_Opco.add(ord.OperatingCompany__c);
            Set_Source.add(ord.Source__c);
           // OrderLineType = ord.Type;
        }
        
        
        Set<String> Set_ProductSuccessor = new Set<String>();
        Set<String> Set_ProductStockLevel = new Set<String>();

        Date ReprintDateCheck = system.today();




        for(OrderItem item:lst_OrdItem){
            ShiptoId.add(item.ShipToAccount__c);
            OrdShip = item.OrderId;
            OrdShip += item.ShipToAccount__c;
            Map_ShipToOrd.put(OrdShip,item.ShipToAccount__c);
            lstOrderId.add(item.OrderId);
            
         
        }

        OrderShipto__c[] existingShipto = [Select ShipToAccount__c,Order__c from OrderShipto__c where Order__c in: OrderId  ]; 
       
        Set<String> Set_ExistShip = new Set<String>();
        
        for(OrderShipto__c shipto:existingShipto){
            
            OrdShip = shipto.Order__c;
            OrdShip += shipto.ShipToAccount__c;
            Set_ExistShip.add(OrdShip);

            

        }

        List<OrderShipto__c> lst_OrderShipto = new List<OrderShipto__c>();
        List<Map<String,String>> lst_AccSubMaps = new List<Map<String,String>>();
        
        lst_AccSubMaps =  Order_ProductSelectController.returnAccountSubsidiary(ShiptoId);

        Map<String,String> Map_Subsid = new Map<String,String>();
        Map<String,String> Map_Netsuite = new Map<String,String>(); 


        //Order_ProductSelectController.returnAccountSubsidiary(ShiptoId)[0];
        Map_Subsid =  lst_AccSubMaps[0];
        Map_Netsuite = lst_AccSubMaps[1];

        Map<String,String> Map_ShipToOrdChecker = new Map<String,String>();
        Set<String> Set_CusDiscountGroup = new Set<String>();
        Set<String> Set_OperatingCo = new Set<String>();
        Set<String> Set_ProdDiscountGroup = new Set<String>();
        Set<String> Set_OrderLineItemType = new Set<String>();
        Set<String> Set_MarketSegment = new Set<String>();

        Map<String,Date> Map_FixedStartDate = new Map<String,Date>();
        Map<String,Date> Map_FreeFromDate = new Map<String,Date>();
        Date FixedStartDate;
        Date FreeFromDate;
        Integer year;
        
        for(OrderItem item:lst_OrdItem){ 
             

            OrdShip = item.OrderId;
            OrdShip += item.ShipToAccount__c;


            if(Map_ShipToOrdChecker.get(OrdShip)  == null && Map_ShipToOrd.get(OrdShip) != null && !Set_ExistShip.Contains(OrdShip) ){
                
                   OrderShipto__c Shipto = new OrderShipto__c();  
                    Shipto.Order__c  = item.OrderId; 
                    Shipto.ShiptoAccount__c = Map_ShipToOrd.get(OrdShip);         
                    lst_OrderShipto.add(Shipto);
                    Map_ShipToOrdChecker.put(OrdShip,item.ShipToAccount__c);
            }  
            
            //List Price Discount Filters
            Set_CusDiscountGroup.add(item.Order.Billto__r.CustomerDiscountGroup__c); 
            Set_OperatingCo.add(item.Order.Billto__r.OperatingCompany__c);
            Set_ProdDiscountGroup.add(item.Product2.ProductDiscountGroup__c);
           // Set_OrderLineItemType.add(item.OrderLineItemType__c);
            Set_OrderLineItemType.add(item.OrderLineType__c);
            
           // Set_MarketSegment.add(item.Product2.MarketSegment__c);
            
            if(item.Product2.FixedStartDate__c != null){

                year = item.Order.ShipbyDate__c.year();

                FixedStartDate = date.newinstance(year, item.Product2.FixedStartDate__c.month(), item.Product2.FixedStartDate__c.day());
                Map_FixedStartDate.put(item.OrderId,FixedStartDate);

                FreeFromDate = date.newinstance(system.today().year()+1, 1, 1);
                Map_FreeFromDate.put(item.OrderId,FreeFromDate);
            }
            system.debug('**B2B**:FreeFromDate 1'+ FreeFromDate);


            if(item.Product2.FreeFromDate__c != null && item.Product2.FixedStartDate__c != null){
                FreeFromDate = date.newinstance(system.today().year()+1, item.Product2.FreeFromDate__c.month(), item.Product2.FreeFromDate__c.day());
                Map_FreeFromDate.put(item.OrderId,FreeFromDate);

                if(item.Order.ShipbyDate__c < FreeFromDate && year>system.today().year()){
                    year -= 1;
                    FixedStartDate = date.newinstance(year, item.Product2.FixedStartDate__c.month(), item.Product2.FixedStartDate__c.day());                
                    Map_FixedStartDate.put(item.OrderId,FixedStartDate);
                }

                

            }
            system.debug('**B2B**:FreeFromDate 2'+ FreeFromDate);
 
        }
	    

        for(OrderItem item:lst_OrdItem){
                item.AccountSubsidiary__c = Map_Subsid.get(item.ShipToAccount__c);
        }
            
    if(lst_OrdItem.size()>0){       
        try{

           
             
                        Date CurDate = system.today();
                      
/*
                        ListPriceDiscount__c[] lst_ListPriceDiscountRegular = [Select Id,DiscountType__c,StartAmount__c,ProductDiscountGroup__c,Subsidiary__c,CustomerDiscountGroup__c,OrderLineType__c, MarketSegment__c,Rate__c,StartQuantity__c From ListPriceDiscount__c  
                                                                                                        where  EndDate__c >=:CurDate 
                                                                                                        AND StartDate__c  <=:CurDate
                                                                                                        AND CustomerDiscountGroup__c in: Set_CusDiscountGroup
                                                                                                        AND Subsidiary__c in: Set_OperatingCo 
                                                                                                        AND ProductDiscountGroup__c in: Set_ProdDiscountGroup 
                                                                                                        AND OrderLineType__c in: Set_OrderLineItemType  
                                                                                                        AND MarketSegment__c in: Set_MarketSegment    
                                                                                                        ORDER BY StartQuantity__c DESC];
            // lst_ListPriceDiscountRegular = [Select Id,ProductDiscountGroup__c,Subsidiary__c,ValueType__c,StartAmount__c,    DiscountType__c,CustomerDiscountGroup__c,OrderLineType__c, MarketSegment__c,Rate__c,StartQuantity__c From ListPriceDiscount__c where  EndDate__c >=:CurDate AND StartDate__c  <=:CurDate AND CustomerDiscountGroup__c =: Order[0].Billto__r.CustomerDiscountGroup__c AND Subsidiary__c =: Order[0].Billto__r.OperatingCompany__c   
             // ORDER BY StartQuantity__c DESC];
*/

            //Successor Item
            //Item Groups
            
         ListPriceDiscount__c[] lst_ListPriceDiscountRegular;
            String Querystr;
            querystr = 'Select Id,DiscountType__c,StartAmount__c,ProductDiscountGroup__c,Subsidiary__c,CustomerDiscountGroup__c,OrderLineType__c, MarketSegment__c,Rate__c,StartQuantity__c From ListPriceDiscount__c  where  EndDate__c >=:CurDate  AND StartDate__c  <=:CurDate AND CustomerDiscountGroup__c in: Set_CusDiscountGroup AND Subsidiary__c in: Set_OperatingCo  AND ProductDiscountGroup__c in: Set_ProdDiscountGroup  AND OrderLineType__c in: Set_OrderLineItemType  '; //AND MarketSegment__c in: Set_MarketSegment
            if(lst_Order[0].PricingMethod__c=='OrderTotalAmount'){
                querystr += ' AND ValueType__c = \'Amount\' ';                
                querystr += ' ORDER BY StartAmount__c DESC';
            }
            else{
                querystr += ' AND ValueType__c = \'Quantity\' '; 
                querystr += ' ORDER BY StartQuantity__c DESC'; 
            }
           

            lst_ListPriceDiscountRegular =Database.query(querystr); 
            

            
            if(lst_Order[0].Source__c =='Trade' || lst_Order[0].Source__c =='B2B Shop' || lst_Order[0].Source__c =='B2B Salesforce'){
                lst_OrdItem = Order_UpdateOrderListPriceDiscountAll.ProcessUpdate(Null,Lst_OrdId,Null,lst_OrdItem,lst_ListPriceDiscountRegular);
            }


            system.debug('**B2B**:Source'+ lst_OrdItem[0].Order.ShippingIndicationRule__c);
            
            lst_OrdItem = Order_OrderandOrdeItemHandler.triggerhandler(lst_OrdItem);
           
            OrderActivationRules__mdt[] OrderActivationRules = [Select Source__c, Status__c,OperatingCompany__c from OrderActivationRules__mdt where Source__c in: Set_Source AND OperatingCompany__c in:Set_Opco];
            
    
            Map<String,String> Map_ActiveStatus = new Map<String,String>();

            String OpcoSource;
            for(OrderActivationRules__mdt act:OrderActivationRules){
                OpcoSource = act.OperatingCompany__c;
                OpcoSource += act.Source__c;
                Map_ActiveStatus.put(OpcoSource,act.Status__c);
            }

           
            system.debug('**OrderActivationRules**:Map_ActiveStatus'+ Map_ActiveStatus);

            
            for(Order ord:lst_Order){
               // ord.B2BJobRun__c = false;
                ord.AccountSubsidiary__c = Map_Subsid.get(ord.Billto__c);
                if(ord.PaymentMethod__c == null){
                    ord.PaymentMethod__c = ord.Billto__r.PaymentMethod__c;
                }
                ord.NetSuiteIdShiptoAccount__c = ord.Shipto__r.NetsuiteInternalId__c;
                ord.NetSuiteIdAccountSubsidiary__c = Map_Netsuite.get(ord.Billto__c); 
                ord.TriggerBusinessRules__c = false;

                system.debug('**B2B**:Source'+ ord.Source__c);

                if(ord.Source__c !='B2B Salesforce' ){ //ord.Source__c !='B2B Shop' && && ord.ItemGroupCount__c ==0
                     
                    
                    
                    OpcoSource = ord.OperatingCompany__c;
                    OpcoSource += ord.Source__c;

                    system.debug('**OrderActivationRules**:Status'+ Map_ActiveStatus.get(OpcoSource));

                    if(OrderActivationRules.size()>0 && Map_ActiveStatus.get(OpcoSource) == 'Active'){
                        ord.ActivateforBatchProcessing__c=true;
                    } 
                    else{
                        ord.ActivateforBatchProcessing__c=false;
                    }                   

                }
                
               
                // if an order has missing email values, retriggering business rules should check if the account email fields have values - if so, use those values

                ord.BillingAddressNote__c = ord.Account.BillingAddressNotes__c; 
                ord.ShippingAddressNote__c = ord.Account.ShippingAddressNotes__c;

                if(ord.BillingReminderEmail__c == null){
                    ord.BillingReminderEmail__c = ord.Account.BillingReminderEmail__c != null ? ord.Account.BillingReminderEmail__c : '';
                }
                
                if(ord.DigitalActivationEmail__c == null){
                    ord.DigitalActivationEmail__c = ord.Account.DigitalActivationEmail__c != null ? ord.Account.DigitalActivationEmail__c : '';
                }

                // use order's bill to invoice email
                if(ord.InvoiceEmail__c == null){
                    ord.InvoiceEmail__c = ord.Billto__r.InvoicingEmail__c != null ? ord.Billto__r.InvoicingEmail__c : '';
                }   
                
                system.debug('here');
                // use order's ship to order notification email
                if(ord.OrderNotificationEmail__c == null){
                    if(ord.Shipto__c != null){
                        ord.OrderNotificationEmail__c = ord.Shipto__r.OrderNotificationEmail__c;
                    } else {
                        ord.OrderNotificationEmail__c = ord.Account.OrderNotificationEmail__c;
                    }
                    
                    //ord.OrderNotificationEmail__c = ord.Shipto__r.OrderNotificationEmail__c != null ? ord.Shipto__r.OrderNotificationEmail__c : '';
                }   
                system.debug('here 2');
                if(ord.OrderNotificationEmail2__c == null){
                    if(ord.Shipto__c != null){
                        ord.OrderNotificationEmail2__c = ord.Shipto__r.OrderNotificationEmail2__c;
                    } else {
                        ord.OrderNotificationEmail2__c = ord.Account.OrderNotificationEmail2__c;
                    }
                    //ord.OrderNotificationEmail2__c = ord.Account.OrderNotificationEmail2__c != null ? ord.Account.OrderNotificationEmail2__c: '';
                } 
                
                if(ord.InvoiceEmail2__c == null){
                    ord.InvoiceEmail2__c = ord.Account.InvoiceEmail2__c != null ? ord.Account.InvoiceEmail2__c : '';
                } 
                
                if(ord.BillingReminderEmail2__c == null){
                    ord.BillingReminderEmail2__c = ord.Account.BillingReminderEmail2__c != null ? ord.Account.BillingReminderEmail2__c : '';
                } 

                system.debug('*** Order Date: STart Date**'+ord.EffectiveDate);
                system.debug('*** Order Date: FixedStartDate**'+Map_FixedStartDate.get(ord.id));
                

                if(ord.ShipbyDate__c > Map_FixedStartDate.get(ord.id) && ord.ShipbyDate__c  < Map_FreeFromDate.get(ord.id)){
                    ord.ShipbyDate__c = Map_FixedStartDate.get(ord.id)-1;   
                    ord.EffectiveDate = Map_FixedStartDate.get(ord.id)-1;  
                    
                    system.debug('*** Order STart Date**'+ord.EffectiveDate);
                }
                

            }
            
            
            
            lst_OrdItem =Order_ProductCalculationDates.UpdateOrderItemDate(lst_OrdItem,lst_Order);
            update lst_Order;

            update lst_OrdItem;

            
            
            Insert lst_OrderShipto;

            
            //TO handle shipping costs AND VAT
            if(!Test.isRunningTest()){
                System.enqueueJob(new Order_OrderItemTriggerQueueable(lst_Order,'Start'));
            }  

          //@future to update
        
            
            if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True){
                CalloutException e = new CalloutException();
                e.setMessage('Error');
                throw e;        
              }
        }
        catch(exception e){

            
            system.debug('**B2BOrderInv**: error: '+e.getmessage());
            HandleCustomException.LogException(e,lst_OrdItem[0].id);
        
        }
 
    }  


    }
   

}