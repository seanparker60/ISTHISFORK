({
	doInit : function(component, event, helper) {
        
        console.log('**one');
		var ContractId =  component.get("v.ContractId");
        var AccountId =  component.get("v.AccountId");
        console.log('**two');
        if(ContractId != null){
           	component.set("v.showExisting",true);  
           	  component.set("v.showRenewal",true);  
        }
        else if(AccountId != null){
              component.set("v.showPricing",true);  
              component.set("v.showRequired",true);
              component.set("v.showShipping",true);  
              component.set("v.showPayment",true);
        }
	},
    ExistingContract : function(component, event, helper) {
		 
         var ExistingContract = event.target.value;
        
        component.set("v.ExistingContract",ExistingContract);
        console.log('**ExistingContract**'+ExistingContract);
	},
    ContractRenewal : function(component, event, helper) {
		 
         var ContractRenewal = event.target.value;
        
        component.set("v.ContractRenewal",ContractRenewal);
        console.log('**ContractRenewal**'+ContractRenewal);
	},
    PricingMethod : function(component, event, helper) {
		 
         var PricingMethod = event.target.value;
        
        component.set("v.PricingMethod",PricingMethod);
        console.log('**PricingMethod**'+PricingMethod);
	},
     ShippingCostMethod : function(component, event, helper) {
		 
         var ShippingCostMethod = event.target.value;
        
        component.set("v.ShippingCostMethod",ShippingCostMethod);
        console.log('**ShippingCostMethod**'+ShippingCostMethod);
	},
     PaymentMethod : function(component, event, helper) {
		 
         var PaymentMethod = event.target.value;
        
        component.set("v.PaymentMethod",PaymentMethod);
        console.log('**PaymentMethod**'+PaymentMethod);
	},
    ContractRequired : function(component, event, helper) {
		 
         var ContractRequired = event.target.value;
        
        component.set("v.ContractRequired",ContractRequired);
        console.log('**ContractRequired**'+ContractRequired);
	},
    GroupBasedType : function(component, event, helper) {
		 
         var GroupBasedType = event.target.value;
        
         component.set("v.GroupBasedType",GroupBasedType);
         console.log('**GroupBasedType**'+GroupBasedType);
	},
    listofIds : function(component, event, helper) {
		 
         var object = event.target.value;
        
         var ListOfIds = component.get("v.ListOfIds");
         ListOfIds[0] = object;
        
         console.log('**ListOfIds[0]**'+ListOfIds[0]);
        
         component.set("v.ListOfIds",ListOfIds); 
         //console.log('**GroupBasedType**'+GroupBasedType);
	},
    
    
})