({
    OrderRefresh : function(component) {

        var action = component.get("c.refreshOrder");
        var OrderId =   component.get("v.recordId");
        
        action.setParams({ 
            "OrderId": OrderId,             
    	});

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                console.log('**Order:Refresh Return 1**');
                var isFresh;
                isFresh =  response.getReturnValue();

                if(isFresh == true){
                    console.log('**Order:Refresh Return True**'); 
                    $A.get('e.force:refreshView').fire();
                   //location.reload();
                    
                }
                else{
                    console.log('**Order:Refresh Return False**');
                 //   window.clearInterval(cmp.get("v.setIntervalId"));
                    $A.get('e.force:refreshView').fire();
                  // location.reload();
                    

                }
                
            }
            else if (state === "INCOMPLETE") {

                window.clearInterval(cmp.get("v.setIntervalId"));

                
            }
                else if (state === "ERROR") {
                    window.clearInterval(cmp.get("v.setIntervalId"));

                    var errors = response.getError();
                    if (errors) {
                        alert("Error message: " + errors[0].message);
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            
                        }
                    } else {
                        alert("Something went wrong: Please contact System Administrator");
                    }
                }
                else{
                    window.clearInterval(cmp.get("v.setIntervalId"));

                }
        });
        
        
        $A.enqueueAction(action);
    }
})