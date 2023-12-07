public with sharing class Order_OrderItemTriggerQueueable implements Queueable {
    
    
    Private List<Order> CurOrder;
    Private List<Order> MaxOrder;
    Private String load;

    
    
    
    public Order_OrderItemTriggerQueueable(List<Order> CurOrder, String load, List<Order> MaxOrder) {
      //  this.OrderItems = OrderItems;

      this.load = load;
      system.debug('**OrderItem Trigger: load**'+load);
      if(load == 'Start'){
          this.CurOrder = CurOrder;
          // this.MaxOrder = MaxOrder;
          this.MaxOrder = new List<Order>();
          
           for(Order ord:CurOrder){
              this.MaxOrder.add(ord);
           }
            system.debug('**OrderItem Trigger: Queueable Constructor**'+CurOrder);
            system.debug('**OrderItem Trigger: Queueable Constructor: MaxOrder**'+MaxOrder);
         
      }
      else {
        
        CurOrder.remove(0);
        this.CurOrder= CurOrder;
        this.MaxOrder = MaxOrder;
        system.debug('**OrderItem Trigger: load else**'+CurOrder);
        system.debug('**OrderItem Trigger: load else:MaxOrder**'+MaxOrder);
      }   


    }

    public void execute(System.QueueableContext qc) {
      system.debug('**OrderItem Trigger: Queueable Constructor: Load**'+MaxOrder[0].id);

      
      if(CurOrder.size()>0){      
            
        system.debug('**OrderItem Trigger: Queueable Constructor: Size>0**'+CurOrder[0].ShippingIndicationRule__c);
          //  UTIL_TriggerController.OrderItemTriggerSwitch = false;
            
            OrderItem[] lstOrderItem = [Select Product2.VAT__c,DigitalActivationEMail__c,ShipToAccount__r.DigitalActivationEmail__c, 
            ShippingCity__c,ShipToAccount__r.ShippingCity,ShippingCountry__c,ShipToAccount__r.ShippingCountry,ShippingPostalCode__c,ShipToAccount__r.ShippingPostalCode,
            ShippingState__c,ShipToAccount__r.ShippingState,ShippingStreet__c,ShipToAccount__r.ShippingStreet,ShippingIndicationRule__c,Weight__c,Order.ShippingIndicationRule__c
            from OrderItem where OrderId =:CurOrder[0].id];

           try{

            system.debug('**OrderItem Trigger: Queueable Constructor: Dates Load **'+lstOrderItem);
            lstOrderItem =  Order_UpdateVatOnItems.UpdateVatOnItems(lstOrderItem);
           }
          catch(exception e){
            system.debug('**OrderItem Trigger: Queueable Constructor: Dates Error **'+e.getmessage());
          }
 
          Order_UpdateShippingCostsFromItems.UpdateShippingCostsFromItems(lstOrderItem,CurOrder[0]);
         
              system.debug('**OrderItem Trigger: Queueable Constructor: Load:Size **'+CurOrder.size());
              system.debug('**OrderItem Trigger: Queueable Constructor: Load: CurOrder **'+CurOrder);
              
              if(!test.isrunningtest()){
                System.enqueueJob(new Order_OrderItemTriggerQueueable(CurOrder,'Next',MaxOrder));
              }
              
              
               
      }
      else{
        List<Id> Set_OrdId = new List<Id>();

        for(Order ord: MaxOrder){
          Set_OrdId.add(ord.id);
        }

        /*
        Order[] lst_Order = [SELECT id,EffectiveDate,ShipByDate__c,LineCount__c,OrderImportLineCount__c,MasterOrder__c,Pricebook2Id,Billto__r.PaymentMethod__c,Type,NetSuiteIdAccountSubsidiary__c,
        PaymentMethod__c ,Billto__r.CustomerDiscountGroup__c,PricingMethod__c,Billto__c,Source__c,ShippingIndicationRule__c,ItemGroupCount__c,AccountSubsidiary__c,
        Billto__r.OperatingCompany__c,ShippingCost__c,ShippingCostDomestic__c,ShippingCostNonDomestic__c,Shipto__r.NetsuiteInternalId__c,NetSuiteIdShiptoAccount__c,
        Account.BillingReminderEmail__c, Account.DigitalActivationEmail__c, Account.InvoicingEmail__c, Account.OrderNotificationEmail__c,
        Account.BillingReminderEmail2__c, Account.InvoiceEmail2__c, Account.OrderNotificationEmail2__c,Account.BillingAddressNotes__c,Account.ShippingAddressNotes__c,ShippingAddressNote__c,BillingAddressNote__c,
        BillingReminderEmail__c, DigitalActivationEmail__c, InvoiceEmail__c, OrderNotificationEmail__c,Status,
        BillingReminderEmail2__c, InvoiceEmail2__c, OrderNotificationEmail2__c,OperatingCompany__c,
        Billto__r.InvoicingEmail__c, Shipto__r.OrderNotificationEmail__c, Shipto__c, TotalAmount ,BillingCity,BillingStreet,BillingPOstalcode,BillingCountry,ShippingCity,ShippingStreet,ShippingPOstalcode,ShippingCountry 
        
        FROM Order WHERE id IN: Set_OrdId];
        */

        Order[] lst_Order = Order_OrderandOrdeItemHandler.returnQueryOrder(Set_OrdId, null);

        system.debug('**OrderItem Trigger: lst_Order Conut size 400 **'+lst_Order.size());

        if(!test.isrunningtest()){
          System.enqueueJob(new Order_OrderLineCountManager(lst_Order,'Start'));
        }
        

        /*
       if(lst_Order[0].LineCount__c>400){
          Order_OrderLineCountManager.ProcessLineCount([0]);       
       }
       */


    }    
    }    

}