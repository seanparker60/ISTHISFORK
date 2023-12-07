public with sharing class Order_OrderItemTriggerQueueable implements Queueable {
    
    
    Private List<Order> CurOrder;
    Private String load;

    
    
    
    public Order_OrderItemTriggerQueueable(List<Order> CurOrder, String load) {
      //  this.OrderItems = OrderItems;

      this.load = load;
      system.debug('**OrderItem Trigger: load**'+load);
      if(load == 'Start'){
          this.CurOrder = CurOrder;
         
            system.debug('**OrderItem Trigger: Queueable Constructor**'+CurOrder);
          
         
      }
      else {
        CurOrder.remove(0);
        this.CurOrder= CurOrder;
        system.debug('**OrderItem Trigger: load else**'+CurOrder);
      }   


    }

    public void execute(System.QueueableContext qc) {
      system.debug('**OrderItem Trigger: Queueable Constructor: Load**');
      
      if(CurOrder.size()>0){      
            
        system.debug('**OrderItem Trigger: Queueable Constructor: Size>0**'+CurOrder[0].ShippingIndicationRule__c);
          //  UTIL_TriggerController.OrderItemTriggerSwitch = false;
            
            OrderItem[] lstOrderItem = [Select Product2.VAT__c,DigitalActivationEMail__c,ShipToAccount__r.DigitalActivationEmail__c, 
            ShippingCity__c,ShipToAccount__r.ShippingCity,ShippingCountry__c,ShipToAccount__r.ShippingCountry,ShippingPostalCode__c,ShipToAccount__r.ShippingPostalCode,
            ShippingState__c,ShipToAccount__r.ShippingState,ShippingStreet__c,ShipToAccount__r.ShippingStreet,ShippingIndicationRule__c,Weight__c,Order.ShippingIndicationRule__c
            from OrderItem where OrderId =:CurOrder[0].id];

            //List<UTIL_GetVATIds.fieldwrapper> fieldwrappers = new List<UTIL_GetVATIds.fieldwrapper>();
            //UTIL_GetVATIds.fieldwrapper fw = new UTIL_GetVATIds.fieldwrapper();

            lstOrderItem =  Order_UpdateVatOnItems.UpdateVatOnItems(lstOrderItem);
            system.debug('**OrderItem Trigger: :ShippingIndicationRule**'+lstOrderItem[0].Order.ShippingIndicationRule__c);
            //if(lstOrderItem[0].Order.ShippingIndicationRule__c == null){
                Order_UpdateShippingCostsFromItems.UpdateShippingCostsFromItems(lstOrderItem,CurOrder[0]);
            //}  
              //Order_ProductCalculationDates.ProductCalculationDates();
            //Order_Activation;

              //VAT
              //Shipping Costs
            
              system.debug('**OrderItem Trigger: Queueable Constructor: Load:Size **'+CurOrder.size());
              system.debug('**OrderItem Trigger: Queueable Constructor: Load: CurOrder **'+CurOrder);
              
              if(!test.isrunningtest()){
                System.enqueueJob(new Order_OrderItemTriggerQueueable(CurOrder,'Next'));
              }
              
              
               
            }
            
    }    

}