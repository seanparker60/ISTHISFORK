trigger bg_Order on Order (Before insert, After insert, After Update) {

    AWSSwitches__mdt[] AWSSwitches = [Select DeveloperName,Active__c from AWSSwitches__mdt where DeveloperName='Order'];
    if (trigger.isAfter) {

        if(trigger.isInsert){
          //  LI_updateOrderLineItems.updateShippingIndicationRuleAfterInsert(trigger.new);
            if(AWSSwitches[0].Active__c){
                bg_AllObjectTriggerHandler.afterObjectInsert(trigger.newMap,'order');
            }
        }
         
        if(trigger.Isupdate){
            Map<Id,Order> newMap = trigger.newMap;
            Map<Id,Order> oldMap = trigger.oldMap;
           // NS_NetSuite.updateNsViaOrderTrigger(newMap, oldMap);
          //  LI_updateOrderLineItems.OrderTriggerHelper(newMap, oldMap);
            if(AWSSwitches[0].Active__c){
                bg_AllObjectTriggerHandler.afterObjectUpdate(newMap, oldMap,'order');
            }
        }
        
    }

}