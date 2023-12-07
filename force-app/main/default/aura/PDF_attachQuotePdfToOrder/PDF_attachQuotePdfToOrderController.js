({
	doInit : function(component) {
       var action = component.get('c.attachQuotePdfToOrder');
        action.setCallback(this, function(response) {
            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
            }
        });
        $A.enqueueAction(action);
    }
})