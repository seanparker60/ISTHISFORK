trigger bg_OrderItem on OrderItem (Before insert, After insert, After Update) {

    AWSSwitches__mdt[] AWSSwitches = [Select DeveloperName,Active__c from AWSSwitches__mdt where DeveloperName='OrderItem'];

   /* 
    system.debug('**OrderItem Trigger: Start out**');
   if(UTIL_TriggerController.OrderItemTriggerSwitch != false){ 
       
    system.debug('**OrderItem Trigger: Start In**');
        
    if (trigger.isBefore) {
        if(trigger.isInsert){
        // LI_updateOrderLineItems.updateOrderItemAfterInsert(trigger.new);
            if(AWSSwitches[0].Active__c){
                system.debug('**OrderItem Trigger: Start Insert**'+trigger.new.size());
                Order_OrderandOrdeItemHandler.triggerhandler(trigger.new);
                Order_OrderandOrdeItemHandler.OrderItemTriggerProductCalculationDates(trigger.new);
               //replaced bg_AllObjectTriggerHandler.afterObjectInsert(trigger.newMap,'OrderItem');
            
            }
        }      
        if(trigger.Isupdate){
            if(AWSSwitches[0].Active__c){
                system.debug('**OrderItem Trigger: Start Update**'+trigger.new.size());
                Order_OrderandOrdeItemHandler.triggerhandler(trigger.new);
                Order_OrderandOrdeItemHandler.OrderItemTriggerProductCalculationDates(trigger.new);

               // replaced bg_AllObjectTriggerHandler.afterObjectUpdate(trigger.newMap, trigger.oldMap,'OrderItem');            
            }
        }
    }

    //AFTER

        if (trigger.isAfter) {
            if(trigger.isInsert){
            
                if(AWSSwitches[0].Active__c){
                    system.debug('**OrderItem Trigger: Start Insert**'+trigger.new.size());

                 //   Order_OrderandOrdeItemHandler.OrderItemTriggerActivated(trigger.new, trigger.old);
                    Order_OrderandOrdeItemHandler.OrderItemTriggerQueable(trigger.new);
                   //replaced bg_AllObjectTriggerHandler.afterObjectInsert(trigger.newMap,'OrderItem');
                
               }
            }
            
            if(trigger.Isupdate){
                if(AWSSwitches[0].Active__c){
                    system.debug('**OrderItem Trigger: Start Update**'+trigger.new.size());
                    Order_OrderandOrdeItemHandler.OrderItemTriggerActivated(trigger.new, trigger.old);
                    Order_OrderandOrdeItemHandler.OrderItemTriggerQueable(trigger.new);
                   // replaced bg_AllObjectTriggerHandler.afterObjectUpdate(trigger.newMap, trigger.oldMap,'OrderItem');
                
                }
            }
        }

        
    } 
   */
   
}