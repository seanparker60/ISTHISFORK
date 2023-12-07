({
	fetchAccountsUtil : function(component) {
        
        console.time('Start Accounts'); 
     

        var AccountList = []; // = component.get("v.AccountList");
        
        var Schoollist = component.get("v.accountsData");
        
        var index = 0;
        for(var key in Schoollist){
			AccountList[index] = Schoollist[key].Id;
            index++;
        }
		var OrderId =  component.get("v.OrderId"); 

        if(OrderId == undefined || OrderId == null){
            OrderId =  component.get("v.recordId");
        }

     	var action = component.get("c.loadAccountbyShipto");
 		 action.setParams({ 
            "OrderId": OrderId,  
        	"ShiptoId": AccountList
    	});
        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set( 'v.accountsData', returnValue);
               // console.log(returnValue);
                
                var NoPupils=0;
                for(var key in returnValue){
					NoPupils = NoPupils + returnValue[key].NumberofStudents;

                    if(returnValue.length==1){
                        returnValue[key].IsSelected = true;
                        var checkCmp = component.find("allschools");
                        checkCmp.set("v.checked", true);                      
                    }
                   // console.log('**NoPupils**'+returnValue[key].NumberofStudents);
                }
                component.set("v.SchoolNumberofStudents",NoPupils);
                

               // component.set("v.allschools",true);
                console.log('**NoPupils**'+NoPupils);
             //   component.set("v.TotalNumberofStudents",NoPupils);
            }
            else if (state === "INCOMPLETE") {
                
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            alert("Error message: " + errors[0].message);
                        }
                    } else {
                        alert("Something went wrong: Please contact System Administrator");
                    }
                }
        });
        
        
        $A.enqueueAction(action);
        console.timeEnd('End Accounts');
	},
    fetchOrderUtil : function(component) {
		
        var OrderId =  component.get("v.OrderId"); 

        if(OrderId == undefined || OrderId == null){
            OrderId =  component.get("v.recordId");
        }
        
       

        var action = component.get("c.returnOrder");
 		 action.setParams({ 
        	"OrderId": OrderId
    	});
   
        action.setCallback(this, function(response) {
           
            var state = response.getState();
            
           if (state === "SUCCESS") {
               var returnValue = response.getReturnValue();
               component.set("v.curOrder",returnValue);
           }
           else if (state === "INCOMPLETE") {
               
           }
               else if (state === "ERROR") {
                   var errors = response.getError();
                   if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        alert("Error message: " + errors[0].message);
                    }
                } else {
                    alert("Something went wrong: Please contact System Administrator");
                }
               }
               
       });
       $A.enqueueAction(action);

   },

    fetchOrderItemsUtil : function(component) {
	    
        var OrderId =  component.get("v.OrderId"); 
        console.log('**Order Items: OrderId**'+OrderId);

        if(OrderId == undefined || OrderId == null){
            OrderId =  component.get("v.recordId");
        }
        console.log('**Order Items: OrderId2**'+OrderId);

        if(OrderId != null){

            
            var action = component.get("c.loadOrderItems");
            var NoStudents = component.get("v.TotalNumberofStudents");
            var PricingMethod = component.get('v.PricingMethod');
            
            console.log('**PricingMethod**'+ PricingMethod );
            action.setParams({ 
                "OrderId": OrderId,
                "NoStudents":NoStudents,
                "PricingMethod":PricingMethod
            });

            console.log('**OrderId**');

            action.setCallback(this, function(response) {
                
                console.log('**IN RESPNSE**');

                var state = response.getState();
                console.log(state);
                if (state === "SUCCESS") {
                    var returnValue = response.getReturnValue();
                    component.set( 'v.OrderItemList', returnValue);
                    
                    console.log(returnValue);
                    
                    var OrderTotal = 0;
                    
                    for(var key in returnValue){
                        if(returnValue[key].ItemGroupComponent != true){
                            OrderTotal = OrderTotal + returnValue[key].Amount ;
                        }
                        
                    }
                    
                   console.log('**OrderTotal**'+OrderTotal);
                     var totalOrderAmounts = {'sobjectType': 'Order','TotalAmount':OrderTotal,'TotalVat':0 };  
                     
                    var CurrenOrderDisplay  = {'sobjectType': 'School',   'NoPupils':0, 'Name': '', 'TotalAmount':OrderTotal, 'TotalVat':0 };
                    
                    component.set( 'v.showList', true); 
                    component.set( 'v.TotalOrder', totalOrderAmounts);
                component.set( 'v.CurrenOrderDisplay', CurrenOrderDisplay);
                  //  console.log('**totalOrderAmounts**'+totalOrderAmounts.TotalAmount);
                    console.log('**SUCCESS ORDERS**');
                    
                }
                else if (state === "INCOMPLETE") {
                    console.log('**INCOMPLETE**');
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + errors[0].message);
                                alert("Error message: " + errors[0].message);
                            }
                        } else {
                            alert("Something went wrong: Please contact System Administrator");
                        }
                    }
            });

            $A.enqueueAction(action);

        }
        
        
    },

    fetchProductsUtil : function(component) {
	    
        var ContractId =  component.get("v.ContractId");  
        var OrderId =  component.get("v.OrderId");  
        if(OrderId == undefined || OrderId == null){
            OrderId =  component.get("v.recordId");
        }

        
        var ExistingContract =  component.get("v.ExistingContract");
        var ContractRenewal =  component.get("v.ContractRenewal");
        var PricingMethod =  component.get("v.PricingMethod"); 
        var NoStudents = component.get("v.TotalNumberofStudents"); // 167;
        var OrderItems = component.get("v.OrderItemList");

        var action;
       
        

        var AccountList = []; // = component.get("v.AccountList");
        
        var Schoollist = component.get("v.accountsData");
        
        var index = 0;
        for(var key in Schoollist){
			AccountList[index] = Schoollist[key].Id;
            index++;
        }

        console.log('**Products before Order Items**');
        for(var key in OrderItems){
			console.log('**Products IN Order Items**'+OrderItems[key].Id);
        }
         
        if(ContractId != null && ContractId != undefined){
            action = component.get("c.loadProductsbyPriceBookContract");
           
            action.setParams({ 
                "OrderItems" : OrderItems,
                "ContractId": ContractId,
                 "NoStudents": NoStudents,
                 "ShiptoId": AccountList,
                 "ExistingContract": ExistingContract,
                 "ContractRenewal": ContractRenewal,
                 "PricingMethod": PricingMethod,
            });
        }
        else{
            action = component.get("c.loadProductsbyPriceBookOrder");
             
            action.setParams({ 
                "OrderItems" : OrderItems, 
                "OrderId": OrderId,
                 "NoStudents": NoStudents,
                 "ShiptoId": AccountList,
                 "ExistingContract": ExistingContract,
                 "ContractRenewal": ContractRenewal,
                 "PricingMethod": PricingMethod,
            });

        }
        
        
       
        
        console.log('**ExistingContract**'+ExistingContract);
        
        

        component.set("v.isSpinner",true);
 		 
        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set( 'v.FullProductList', returnValue);
                
                

               // component.set('v.TotalNumberofStudents',NoStudents);
                console.log(returnValue);
                
             //    var totalOrderAmounts = {'sobjectType': 'Order','TotalAmount':0,'TotalVat':0 };  
               // console.log('**totalOrderAmounts**'+totalOrderAmounts.TotalAmount);
                 
             //   component.set( 'v.TotalOrder', totalOrderAmounts);

                component.set("v.isSpinner",false);
                
            }
            else if (state === "INCOMPLETE") {
                
            }
                else if (state === "ERROR") {
                    component.set("v.isSpinner",false);
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            alert("Error message: " + errors[0].message);
                        }
                    } else {
                        alert("Something went wrong: Please contact System Administrator");
                    }
                }
        });
        
        
        $A.enqueueAction(action);
    },
    fetchBilltoAccount : function(component) {
		
        var action = component.get("c.loadAccountbyBillto");
        
        var OrderId =  component.get("v.OrderId"); 
        
        console.log('**Order Items: OrderId**'+OrderId);

        if(OrderId == undefined || OrderId == null){
            OrderId =  component.get("v.recordId");
        }
        action.setParams({ 
            "OrderId": OrderId
        });
   
        action.setCallback(this, function(response) {
           var state = response.getState();
           if (state === "SUCCESS") {
               var returnValue = response.getReturnValue();
               component.set("v.BillToAccount",returnValue);

               var loopc=0;
               //for(var keyLP in returnValue){ 
              //     loopc++;
              // }    
               console.log('**Bill to**'+returnValue.OperatingCompany__c);
           }
           else if (state === "INCOMPLETE") {
               
           }
               else if (state === "ERROR") {
                   var errors = response.getError();
                   if (errors) {
                       if (errors[0] && errors[0].message) {
                           console.log("Error message: " + errors[0].message);
                           alert("Error message: " + errors[0].message);
                       }
                   } else {
                       alert("Something went wrong: Please contact System Administrator");
                   }
               }
       });
       $A.enqueueAction(action);
   },
    fetchListPriceDiscountUtil : function(component) {
		
     	var action = component.get("c.loadListPriceDiscountType");

         var OrderId =  component.get("v.OrderId"); 
        
        console.log('**Order Items: OrderId**'+OrderId);

        if(OrderId == undefined || OrderId == null){
            OrderId =  component.get("v.recordId");
        }
        action.setParams({ 
            "OrderId": OrderId
        });
    
         action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set("v.ListPriceDiscount",returnValue);

                var loopc=0;
                //for(var keyLP in returnValue){ 
               //     loopc++;
               // }    
                console.log('**loopc**'+loopc);
            }
            else if (state === "INCOMPLETE") {
                
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            alert("Error message: " + errors[0].message);
                        }
                    } else {
                        alert("Something went wrong: Please contact System Administrator");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    fetchloadAssetsforRate : function(component) {
		
         
        var PricingMethod = component.get('v.PricingMethod');

        var AccountList = []; // = component.get("v.AccountList");
        
        var Schoollist = component.get("v.accountsData");
        
        var index = 0;
        for(var key in Schoollist){
			AccountList[index] = Schoollist[key].Id;
            index++;
        }
        var OrderId =  component.get("v.OrderId"); 
        if(OrderId == undefined || OrderId == null){
            OrderId =  component.get("v.recordId");
        }

        var action = component.get("c.loadAssetsforRate");
 		 action.setParams({ 
            "OrderId":OrderId, 
        	"ShiptoId": AccountList,
            "PricingMethod": PricingMethod
    	});
   
        action.setCallback(this, function(response) {
           
            var state = response.getState();
            
           if (state === "SUCCESS") {
               var returnValue = response.getReturnValue();
               component.set("v.Assetlist",returnValue);
               console.log('**Asset SUCCES**');
               /*
               for(var key in returnValue){
                console.log('**returnValue.Name**'+returnValue[key].Name);       
             }
             */

               
           }
           else if (state === "INCOMPLETE") {
               
           }
               else if (state === "ERROR") {
                   var errors = response.getError();
                   if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        alert("Error message: " + errors[0].message);
                    }
                } else {
                    alert("Something went wrong: Please contact System Administrator");
                }
               }
               
       });
       $A.enqueueAction(action);

   },

    AddProductstoAcc : function(component, event,Type) {
        
		
        var isOpenAccOrd = component.get("v.isOpenAccOrd"); 
        var schoolOrder = component.get("v.ShoolOrderItemList");
        var fullOrderList = component.get("v.OrderItemList"); 
        
        var FullProductList = component.get("v.FullProductList"); 
        var SchoolProductList = component.get("v.SchoolProductList"); 
        var schoollist = component.get("v.accountsData");
        var OrderProdMap = component.get("v.OrderProdMap");
        var totalOrderAmounts = component.get( 'v.TotalOrder');
            
        var selectedItem;  
        var recId;  
        
        var Pleaseselectschool = false; 
        
   //     component.set("v.isSpinner",true);

        if(Type == 'Individual'){
            	 selectedItem = event.currentTarget;
        		 recId = selectedItem.dataset.record;  
        }
        else{
             
            recId = Type;
        }
        
        
        
      //   console.log('***TOTAL AM**'+totalOrderAmounts.TotalAmount);  
        var CurrenShipto = [];
        var CurrenOrderDisplay;
        

        var Displayname='';
        var NumberofPupils=0;

       // var CustomerDiscountGroup;
        for(var key in schoollist){
         
            if(schoollist[key].Id == recId){
                Pleaseselectschool = true;
                
                Displayname= schoollist[key].Name;
                NumberofPupils = schoollist[key].NumberofStudents;
                CurrenShipto.push ({
                    			'sobjectType': 'School', 
                    			'NoPupils':schoollist[key].NumberofStudents,
                                'CustomerDiscountGroup': schoollist[key].CustomerDiscountGroup,
                                'AccId': schoollist[key].Id,
                    			'Name': schoollist[key].Name,
                     			'TotalAmount':0,
                     			'TotalVat':0
                    			});
                                break;
             }
            else if(Type == 'Group'){
                if(schoollist[key].IsSelected == true){ 
                    
                    Pleaseselectschool = true;

              	 	Displayname= 'Group Selection';
                    NumberofPupils = NumberofPupils+schoollist[key].NumberofStudents;
               		CurrenShipto.push ({
                    			'sobjectType': 'School', 
                    			'NoPupils':schoollist[key].NumberofStudents,
                                'CustomerDiscountGroup': schoollist[key].CustomerDiscountGroup,
                                'AccId': schoollist[key].Id,
                    			'Name': schoollist[key].Name,
                     			'TotalAmount':0,
                     			'TotalVat':0
                        }); 
             //     console.log('***IsSelected**'+schoollist[key].Id);  
               } 
            }
            else if(Type == 'All'){

                Pleaseselectschool = true;

                 Displayname='All Schools';
                NumberofPupils = NumberofPupils+schoollist[key].NumberofStudents;
                	CurrenShipto.push  ({
                    			'sobjectType': 'School', 
                    			'NoPupils':schoollist[key].NumberofStudents,
                                'CustomerDiscountGroup': schoollist[key].CustomerDiscountGroup,
                                'AccId': schoollist[key].Id,
                    			'Name': schoollist[key].Name,
                     			'TotalAmount':0,
                     			'TotalVat':0
                        });
                
           	 }
        }
         
              CurrenOrderDisplay  = {
                    			'sobjectType': 'School', 
                    			'NoPupils':NumberofPupils,
                             //   'AccId': schoollist[key].Id,
                    			'Name': Displayname,
                     			'TotalAmount':0,
                     			'TotalVat':0
                };
         			
          //      CurrenOrderDisplay.TotalAmount =0;

      if(Pleaseselectschool == true){  
          
        /*
        for(var keyO in fullOrderList){
                    
             
                    
          // if(OrderProdMap[fullOrderLiOrst[key].ProductId] ==undefined){
            	for(var keyS in CurrenShipto){ 
               
                 
                        if(fullOrderList[keyO].ShipToAccountId == CurrenShipto[keyS].AccId){ 
                          
                            OrderProdMap[fullOrderList[keyO].ProductId] = fullOrderList[keyO].ProductId ;
                     
                     //Commeneted out all below       
                     //   console.log('**ItemGroup*'+fullOrderList[keyO].ItemGroup);      
                            schoolOrder.push({
                              'sobjectType': 'OrderLineItem',
                               'ShipToAccountName': CurrenShipto[keyS].Name, 
                              'ProductName':fullOrderList[keyO].ProductName,
                              'ItemGroup': fullOrderList[keyO].ItemGroup,
                              'ItemGroupId': fullOrderList[keyO].ItemGroupId,                                  
                              'ProductId': fullOrderList[keyO].ProductId, 
                              'ShipToAccountId': CurrenShipto[keyS].AccId,
                              'CustomerDiscountGroup': fullOrderList[keyO].CustomerDiscountGroup, 
                              'Subsidiary':  fullOrderList[keyO].Subsidiary,
                              'Quantity':  fullOrderList[keyO].Quantity, 
                              'ComponentQuantity':fullOrderList[keyO].ComponentQuantity, 
                              'UnitPrice' :fullOrderList[keyO].UnitPrice,
                               'BasePrice' :fullOrderList[keyO].BasePrice,
                               'STDPrice' :fullOrderList[keyO].STDPrice,
                               'listPriceRateId':fullOrderList[keyO].listPriceRateId,
                               'listPriceDiscountType':fullOrderList[keyO].listPriceDiscountType,
                               'ProductRateGroup': fullOrderList[keyO].ProductRateGroup, 
                               'PriceDiscount':fullOrderList[keyO].PriceDiscount,
                               'listPriceProductType' : fullOrderList[keyO].listPriceProductType,
                               'NoDiscAmount' :fullOrderList[keyO].NoDiscAmount, 
                              'Rate' :fullOrderList[keyO].Rate,                   
                              'Amount':fullOrderList[keyO].Amount,
                              'ManualDiscount':fullOrderList[keyO].ManualDiscount ,
                              'DiscountOption':fullOrderList[keyO].DiscountOption,  
                              'DiscountAmount':fullOrderList[keyO].DiscountAmount,
                                'DiscountPercent': fullOrderList[keyO].DiscountPercent,
                                'DiscountPercentShow': fullOrderList[keyO].DiscountPercentShow,
                                'DiscountValueShow': fullOrderList[keyO].DiscountValueShow,
                              'ItemId':fullOrderList[keyO].ItemId,
                              'PricebookEntryId': fullOrderList[keyO].PricebookEntryId,
                              'ItemGroupComponent': fullOrderList[keyO].ItemGroupComponent,
                              'listPriceDiscount':fullOrderList[keyO].listPriceDiscount,
                              'listAsset2Product':fullOrderList[keyO].listAsset2Product
                                
                               
                        });
                    //   console.log('**DiscOption*'+fullOrderList[keyO].DiscountOption); 
                    // Commeneted out all above

                       if(fullOrderList[keyO].ItemGroupComponent != true){    
                            CurrenOrderDisplay.TotalAmount = CurrenOrderDisplay.TotalAmount + fullOrderList[keyO].Amount;    
                       }     
           	  		}
                   
            	}
          //	}      
     
         }
         */


        var ProductCount = 0;
       for(var key in FullProductList){
        ProductCount++;
    //    console.log('**ProductCount**'+ProductCount);
        if(ProductCount == 101){
            break;
        }
          console.log('**maxQuantity*'+FullProductList[key].maxQuantity); 
         // console.log('**OrderProdMap2*'+OrderProdMap[recId+FullProductList[key].ProductId]);
           if(OrderProdMap[FullProductList[key].ProductId] == undefined){
                
            
                 SchoolProductList.push({
            	'sobjectType': 'ProductListPrice',
                 'ProductName': FullProductList[key].ProductName,
                 'BasePrice' :FullProductList[key].BasePrice,
                'STDPrice' :FullProductList[key].STDPrice,
              	'UnitPrice': FullProductList[key].UnitPrice,
                'ComponentQuantity':FullProductList[key].ComponentQuantity,   
                'ProductId': FullProductList[key].ProductId,
                'listPriceRateId':FullProductList[key].listPriceRateId,
                'listPriceProductType' :  FullProductList[key].listPriceProductType,
                'listPriceDiscountType':FullProductList[key].listPriceDiscountType,
                'ProductRateGroup': FullProductList[key].ProductRateGroup,
                'ManualDiscount':FullProductList[key].ManualDiscount ,
              	'Rate': FullProductList[key].Rate,
                'PricebookEntryId': FullProductList[key].PricebookEntryId,
                'listPriceDiscount':FullProductList[key].listPriceDiscount,
                'QuantitySelectionType':FullProductList[key].QuantitySelectionType,
                'Quantity':FullProductList[key].Quantity,
                'MarketSegment': FullProductList[key].MarketSegment,
                'listItemGroupComponent':FullProductList[key].listItemGroupComponent,
                'ItemGroupComponent': FullProductList[key].ItemGroupComponent,
                'ProductSKU':FullProductList[key].ProductSKU,
                'ProductEAN':FullProductList[key].ProductEAN,
                'ProductTYPE': FullProductList[key].ProductTYPE,
                'DeliveryStatus': FullProductList[key].DeliveryStatus,
                'listAsset2Product':FullProductList[key].listAsset2Product,  
                'Stocknumber':FullProductList[key].Stocknumber,
                'maxQuantity':FullProductList[key].maxQuantity                                   
        	});
               
           }   
           
        } 
    }
       
    //    component.set("v.isSpinner",false);
    //   component.set("v.CurrenShiptoId",recId);
        
      
     //  component.set("v.ShoolOrderItemList",schoolOrder);

     if(Pleaseselectschool != true){
        alert('Please select a school!');
     }
     else{
        component.set("v.SchoolProductList",SchoolProductList);
         component.set("v.CurrenShipto",CurrenShipto); 
        component.set("v.CurrenOrderDisplay",CurrenOrderDisplay); 
        component.set("v.OrderProdMap",[]); 
        component.set("v.isOpenAccOrd",true);
     }
       
    },

    

    UpdateListPriceDiscount: function(component,Type,ItemId,PricingMethod,fullOrderList) {

     
       var NoStudents;
      // var fullOrderList;
       if( PricingMethod=='AccountStudents'){
         NoStudents = component.get("v.TotalNumberofStudents");
       }
       if(Type=='Existing'){
     //   fullOrderList = component.get("v.OrderItemList");
       }
        var ListPriceDiscountFull = component.get("v.ListPriceDiscount");
        var OrderProdMap = component.get("v.OrderProdMap");
        var ListPriceMap = component.get("v.VarMap");
        var ItemGrpMap = component.get("v.ItemGrpMap");
        
        
        var CurrenOrderDisplay = component.get("v.CurrenOrderDisplay");
        var totalOrderAmounts = component.get( 'v.TotalOrder');
        var Assetlist = component.get( 'v.Assetlist');

        var ProdGroup;
        var ProductId;
        var PriceDiscount;
        var ProductRateGroup;
        var curItemId;

        var MultiShiptoSelect;
        MultiShiptoSelect = 0;

        
        
        ListPriceMap = [];
       //Map of CustomerType and ProductType
       OrderProdMap = [];
     //  var UsageQuantity;
        ProductId ='';
        var varTotal;
        varTotal = 0;
        for(var key in fullOrderList){
          //  console.log('**LPD Update 1: CustomerDiscountGroup**'+ fullOrderList[key].CustomerDiscountGroup);
          //  console.log('**LPD Update 1: ProductDiscountGroup**'+ fullOrderList[key].listPriceDiscountType);
          //  console.log('**LPD Update 1: Subsidiary**'+ fullOrderList[key].Subsidiary);
            //too reduce the size of the LPF search
            if(ListPriceMap[fullOrderList[key].CustomerDiscountGroup] == undefined){
                ListPriceMap[fullOrderList[key].CustomerDiscountGroup] = 1;
            }
            if(ListPriceMap[fullOrderList[key].listPriceDiscountType] == undefined){
                ListPriceMap[fullOrderList[key].listPriceDiscountType] = 1;
            }
            if(ListPriceMap[fullOrderList[key].Subsidiary] == undefined){
                ListPriceMap[fullOrderList[key].Subsidiary] = 1;
            }
             
            //For Multiple ship tos
            for(var i in ItemId){
                if(fullOrderList[key].ItemId == ItemId[i]){
                    curItemId = fullOrderList[key].ItemId;
                    ProductId =  fullOrderList[key].ProductId;   
                    ProductRateGroup = fullOrderList[key].ProductRateGroup;
                    MultiShiptoSelect++;                          
                }
                
            } 
            
           // varTotal = varTotal+fullOrderList[key].BasePrice;
            //Get Usage totals to be grouped for use below. Includes all items of the same Product
        }

        if(ProductId == ''){
            
                ProductId =  ItemId[0];
                console.log('**ProductId one**'+ ProductId);
        }
        
        console.log('**varTotal 1**'+ varTotal);

        if(PricingMethod=='ProductDiscountGroupUsageBased' || PricingMethod=='ProductUsageBased' || PricingMethod=='OrderProductQuantity' || PricingMethod=='OrderTotalAmount'){ 
                for(var key in fullOrderList){
                    
                    
                   // console.log('**ProductId Two:a**'+ ProductId);
                   // console.log('**ProductId Two:b**'+ fullOrderList[key].ProductId);
                    console.log('**ProductId Two:c**'+ fullOrderList[key].ItemGroupProductId);
                    console.log('**ProductId Two:d**'+ fullOrderList[key].ItemGroupComponent);
                  //  console.log('**ProductId Two:e**'+ PricingMethod);

                        if(PricingMethod=='OrderTotalAmount' && (fullOrderList[key].ItemGroupComponent == false || fullOrderList[key].ItemGroupProductId != undefined)){  
                                ProdGroup = 'OrderTotal';
                                console.log('**ProductId Two:b**'+ fullOrderList[key].ProductId);
                                varTotal = fullOrderList[key].BasePrice;
                                if(OrderProdMap[ProdGroup] == NaN || OrderProdMap[ProdGroup] == undefined || OrderProdMap[ProdGroup] == null){
                                    OrderProdMap[ProdGroup] = parseFloat(varTotal)*parseFloat(fullOrderList[key].Quantity);
                                }
                                else{
                                    OrderProdMap[ProdGroup] = OrderProdMap[ProdGroup] + (parseFloat(varTotal)*parseFloat(fullOrderList[key].Quantity));
                                }
                                 
                                
                                 
                                console.log('**varTotal 2**'+ OrderProdMap[ProdGroup]);
                            
                        }
                        else if((ProductId ==  fullOrderList[key].ProductId && fullOrderList[key].ItemGroupComponent == false) || fullOrderList[key].ItemGroupProductId == ProductId){ // Commented out for TEST
                                var varQuantity;



                                if(ProductId ==  fullOrderList[key].ProductId){                                    
                                    varQuantity = fullOrderList[key].Quantity; 
                                }
                                else{
                                    varQuantity = fullOrderList[key].Quantity; 
                                    // varQuantity = fullOrderList[key].ComponentQuantityFinal;
                                }
        
                                
                                ProdGroup = fullOrderList[key].ProductName;
                               
                                        if(OrderProdMap[ProdGroup] != NaN && OrderProdMap[ProdGroup] != undefined && OrderProdMap[ProdGroup] != null){
                                            OrderProdMap[ProdGroup] =parseFloat( OrderProdMap[ProdGroup]) + parseFloat(varQuantity);
                                        }
                                        else{
                                            OrderProdMap[ProdGroup] = parseFloat(varQuantity);
                                        }                                    
                        }                                                 
                }
        }
        
        if(PricingMethod=='ProductDiscountGroupUsageBased' || PricingMethod=='ProductUsageBased'){
                for(var key in Assetlist){

                        if(PricingMethod=='ProductDiscountGroupUsageBased'){ 
                             
                            console.log('**ProductDiscountGroupUsageBased a1:'+ProductRateGroup); 
                            console.log('**ProductDiscountGroupUsageBased a2:'+Assetlist[key].ProductRateGroup);
                            if(ProductRateGroup ==  Assetlist[key].ProductRateGroup){
                                    if(OrderProdMap[Assetlist[key].ProductRateGroup]== null || OrderProdMap[Assetlist[key].ProductRateGroup]== undefined){
                                        
                                        OrderProdMap[Assetlist[key].ProductRateGroup] = Assetlist[key].Quantity;
                                    }
                                    else{
                                        OrderProdMap[Assetlist[key].ProductRateGroup] =parseFloat(OrderProdMap[Assetlist[key].ProductRateGroup])+parseFloat(Assetlist[key].Quantity);
                                    }
                            }   
                            
                            console.log('**ProductDiscountGroupUsageBased b:'+OrderProdMap[Assetlist[key].ProductRateGroup] );
                            console.log('**ProductDiscountGroupUsageBased b:'+Assetlist[key].ProductRateGroup);
                            console.log('**ProductDiscountGroupUsageBased id:'+Assetlist[key].ProductName );
                        }
                        else{
                            //ProdGroup = 'ProductUsageBased';
                            ProdGroup = Assetlist[key].ProductName;

                            console.log('**ProductUsageBased 1:'+Assetlist[key].ProductName);
                                if(OrderProdMap[ProdGroup]== null || OrderProdMap[ProdGroup]== undefined){                                            
                                    OrderProdMap[ProdGroup] = Assetlist[key].Quantity;
                                }
                                else{
                                    OrderProdMap[ProdGroup] =parseFloat(OrderProdMap[ProdGroup])+parseFloat(Assetlist[key].Quantity);
                                }

                                console.log('**ProductUsageBased 2:'+OrderProdMap[ProdGroup] );   
                                   
                        }        
                                                
                }
        }
        



        var listPriceSelected;
        var STPlistPriceRateId;
        var STPRate;

        totalOrderAmounts.TotalAmount=0; 
        var index=0; 
        ProdGroup='';
         
        var loopCount=0;

       //too reduce the size of the LPF search compare customer group and product group and create new list 
       var ListPriceDiscount=[]; 
       var tl0 = performance.now();
       for(var key in ListPriceDiscountFull){ 
       // console.log('**LPD Update 2: CustomerDiscountGroup**'+ ListPriceMap[ListPriceDiscountFull[key].CustomerDiscountGroup__c] );
       // console.log('**LPD Update 2: ProductDiscountGroup**'+ ListPriceMap[ListPriceDiscountFull[key].ProductDiscountGroup__c]);
       // console.log('**LPD Update 2: Subsidiary**'+ ListPriceMap[ListPriceDiscountFull[key].Subsidiary__c]);
       console.log('**LPD Update 2: StartAmount**'+ ListPriceDiscountFull[key].StartAmount__c);
            if(ListPriceMap[ListPriceDiscountFull[key].CustomerDiscountGroup__c] ==1  && ListPriceMap[ListPriceDiscountFull[key].Subsidiary__c] == 1 && (ListPriceMap[ListPriceDiscountFull[key].ProductDiscountGroup__c] == 1 || PricingMethod=='OrderTotalAmount' )){
                    ListPriceDiscount.push({
                        'sobjectType': 'ProductListPrice',
                        'CustomerDiscountGroup__c': ListPriceDiscountFull[key].CustomerDiscountGroup__c,
                        'StartQuantity__c': ListPriceDiscountFull[key].StartQuantity__c,
                        'StartAmount__c': ListPriceDiscountFull[key].StartAmount__c,
                        'ValueType__c': ListPriceDiscountFull[key].ValueType__c,                        
                        'Subsidiary__c': ListPriceDiscountFull[key].Subsidiary__c,
                        'ProductDiscountGroup__c': ListPriceDiscountFull[key].ProductDiscountGroup__c,
                        'OrderLineType__c': ListPriceDiscountFull[key].OrderLineType__c,     
                        'MarketSegment__c': ListPriceDiscountFull[key].MarketSegment__c,
                        'DiscountType__c': ListPriceDiscountFull[key].DiscountType__c,
                        'Rate__c': ListPriceDiscountFull[key].Rate__c,
                        'Id': ListPriceDiscountFull[key].Id
                    });
                    loopCount++;    
            }
              
        }    
        console.log('**loopCount**'+loopCount);
        loopCount=0;

        
        var loopCountLPD=0;
        var loopCountPRODDTYEE=0;


        totalOrderAmounts.TotalAmount =0;
        ItemGrpMap =[];
         for(var key in fullOrderList){
            loopCount++;
            
            if((ProductId ==  fullOrderList[key].ProductId && fullOrderList[key].ItemGroupComponent == false) || fullOrderList[key].ItemGroupProductId == ProductId || PricingMethod=='OrderTotalAmount'){ 
                console.log('**Component Update: Before 1**');
                
                if(fullOrderList[key].PriceDiscount == 'Free' || fullOrderList[key].PriceDiscount =='Service'){
                   // fullOrderList[key].STDPrice = 0;
                    fullOrderList[key].UnitPrice = 0;
                    fullOrderList[key].Amount = 0;
                    fullOrderList[key].NoDiscAmount = fullOrderList[key].Quantity * fullOrderList[key].BasePrice;
                } 
                else{

                
                         listPriceSelected=false;
                         var varQuantity;
                         if(ProductId ==  fullOrderList[key].ProductId){    
                                
                            varQuantity = fullOrderList[key].Quantity; 
                        }
                        else{
                            varQuantity = fullOrderList[key].Quantity; 
                           // varQuantity = fullOrderList[key].ComponentQuantityFinal;
                        }
                     //   console.log('**Component Update: Before 1a**'+fullOrderList[key].ComponentQuantityFinal);
                     //   console.log('**Component Update: Before 1b**'+fullOrderList[key].Quantity);
                     //   console.log('**Component Update: Before 1c**'+varQuantity);

                        if(PricingMethod=='OrderProductQuantity'){
 
                            ProdGroup = fullOrderList[key].ProductName;
                        }
                        if(PricingMethod=='OrderTotalAmount'){
 
                            ProdGroup = 'OrderTotal';
                        }
                         
                        else if(PricingMethod=='ProductDiscountGroupUsageBased'){ 
 
                          ProdGroup = fullOrderList[key].ProductName;


                            if(OrderProdMap[fullOrderList[key].ProductRateGroup] != NaN && OrderProdMap[fullOrderList[key].ProductRateGroup] != undefined && OrderProdMap[fullOrderList[key].ProductRateGroup] != null){
                                OrderProdMap[fullOrderList[key].ItemId] =parseFloat( OrderProdMap[ProdGroup]) + parseFloat( OrderProdMap[fullOrderList[key].ProductRateGroup]);
                            }
                            else{
                                OrderProdMap[fullOrderList[key].ItemId] =parseFloat( OrderProdMap[ProdGroup]);     
                            }
                           
                            ProdGroup = fullOrderList[key].ItemId;
                         }
                         
                        else if(PricingMethod=='ProductUsageBased'){ 
                            ProdGroup = fullOrderList[key].ProductName;

                        }    
                        else if(PricingMethod=='AccountStudents'){
                            ProdGroup = 'NoStudents';
                            OrderProdMap[ProdGroup] = parseFloat(NoStudents);
                        }
                    //    console.log('**PricingMethod 2:ProdGroup**'+ ProdGroup);

                  //     console.log('**Update 1: CustomerDiscountGroup:' + fullOrderList[key].CustomerDiscountGroup);
                  //      console.log('**Update 1: StartQuantity:' + OrderProdMap[ProdGroup]);
                  //      console.log('**Update 1: Subs' + fullOrderList[key].Subsidiary);
                        
                  //      console.log('**Update: Before 2**');

                             


                        for(var keyLP in ListPriceDiscount){     
                            loopCountLPD++;

                        //    console.log('**Update 2: CustomerDiscountGroup** '+ListPriceDiscount[keyLP].CustomerDiscountGroup__c);
                           // console.log('**Update 2: StartQuantity** '+ListPriceDiscount[keyLP].StartQuantity__c);
                            //console.log('**Update 2: Subsidiary** '+ListPriceDiscount[keyLP].Subsidiary__c);
                            console.log('**Component Update: Before 2**'+ListPriceDiscount[keyLP].StartAmount__c);
                                if((ListPriceDiscount[keyLP].CustomerDiscountGroup__c == fullOrderList[key].CustomerDiscountGroup)  && listPriceSelected==false && ListPriceDiscount[keyLP].Subsidiary__c == fullOrderList[key].Subsidiary){
                             
                                   console.log('**Component Update: AFter 2**'+ListPriceDiscount[keyLP].StartAmount__c);
                                    console.log('**Component Update: AFter 2**'+OrderProdMap[ProdGroup]);
                                 //   console.log('**Component Update: AFter 2**'+PricingMethod);
                                 //   console.log('**Component Update: AFter 2**'+ListPriceDiscount[keyLP].StartQuantity__c);


                                    if((OrderProdMap[ProdGroup] >= ListPriceDiscount[keyLP].StartAmount__c && PricingMethod =='OrderTotalAmount') ||
                                     (OrderProdMap[ProdGroup] >= ListPriceDiscount[keyLP].StartQuantity__c && PricingMethod !='OrderTotalAmount')){


                                    console.log('**Component Update: Before 3a**'+ListPriceDiscount[keyLP].ProductDiscountGroup__c);
                                    console.log('**Component Update: Before 3a**'+fullOrderList[key].listPriceDiscountType);
                                    
                                 if(ListPriceDiscount[keyLP].ProductDiscountGroup__c == fullOrderList[key].listPriceDiscountType ){ 
                                          loopCountPRODDTYEE++;
                                            console.log('**Component Update: Before 3b**'+ListPriceDiscount[keyLP].OrderLineType__c);
                                            console.log('**Component Update: Before 3b**'+fullOrderList[key].PriceDiscount);
                                            
                                            if(((ListPriceDiscount[keyLP].OrderLineType__c == fullOrderList[key].PriceDiscount) ) && listPriceSelected==false){
                                                console.log('**Component Update: Before 4** MarketSegment:' + fullOrderList[key].MarketSegment);
                                               console.log('**Component Update: Before 4** MarketSegment__c:' + ListPriceDiscount[keyLP].MarketSegment__c);
                                                
                                            if((ListPriceDiscount[keyLP].DiscountType__c!='Market Segment' || (ListPriceDiscount[keyLP].DiscountType__c=='Market Segment' && ListPriceDiscount[keyLP].MarketSegment__c == fullOrderList[key].MarketSegment))){
                                               
                                                            listPriceSelected=true;
                                           
                                                            console.log('**Component Update: In 5a**'+fullOrderList[key].Amount);
                                                            console.log('**Component Update: In 5a**'+ListPriceDiscount[keyLP].Id);

                                                          fullOrderList[key].listPriceRateId =  ListPriceDiscount[keyLP].Id;
                                                          fullOrderList[key].IsEdited = true;
                                                            fullOrderList[key].STDPrice = (fullOrderList[key].BasePrice - (fullOrderList[key].BasePrice * (ListPriceDiscount[keyLP].Rate__c/100))).toFixed(2);
                                                            fullOrderList[key].UnitPrice = fullOrderList[key].STDPrice;

                                                            if(fullOrderList[key].DiscountOption=='One-Off Amount' || fullOrderList[key].DiscountOption=='Recurring Amount'){
                                                                
                                                                fullOrderList[key].UnitPrice = fullOrderList[key].STDPrice - fullOrderList[key].DiscountAmount;
                                                                if(ProductId ==  fullOrderList[key].ProductId){
                                                                    fullOrderList[key].Amount = parseFloat(fullOrderList[key].Quantity * parseFloat((fullOrderList[key].UnitPrice)).toFixed(2)).toFixed(2);                                                                
                                                                }
                                                                else{
                                                                    fullOrderList[key].Amount = fullOrderList[key].ComponentQuantityFinal * (fullOrderList[key].UnitPrice); 
                                                                }                                                              

                                                            }
                                                            else if(fullOrderList[key].DiscountOption=='One-Off Amount (Subtotal)'){
                                                                
                                                                if(ProductId ==  fullOrderList[key].ProductId){
                                                                    fullOrderList[key].Amount = parseFloat((fullOrderList[key].Quantity * fullOrderList[key].STDPrice)-fullOrderList[key].DiscountAmount).toFixed(2);
                                                                    fullOrderList[key].UnitPrice = fullOrderList[key].Amount/fullOrderList[key].Quantity;
                                                                }
                                                                else{
                                                                    fullOrderList[key].Amount = (fullOrderList[key].ComponentQuantityFinal * fullOrderList[key].STDPrice)-fullOrderList[key].DiscountAmount;
                                                                    fullOrderList[key].UnitPrice = fullOrderList[key].Amount/fullOrderList[key].ComponentQuantityFinal;
                                                                }    

                                                            }  
                                                            else if(fullOrderList[key].DiscountOption=='One-Off Percentage' || fullOrderList[key].DiscountOption=='Recurring Percentage'){
                                                                
                                                                if(ProductId ==  fullOrderList[key].ProductId){
                                                                    fullOrderList[key].UnitPrice = parseFloat(fullOrderList[key].STDPrice-(fullOrderList[key].STDPrice*(fullOrderList[key].DiscountPercent/100))).toFixed(2);
                                                                    fullOrderList[key].Amount = fullOrderList[key].Quantity* parseFloat(fullOrderList[key].UnitPrice).toFixed(2);
                                                                }
                                                                else{
                                                                    fullOrderList[key].UnitPrice = fullOrderList[key].STDPrice-(fullOrderList[key].STDPrice*(fullOrderList[key].DiscountPercent/100));
                                                                    fullOrderList[key].Amount = fullOrderList[key].ComponentQuantityFinal * fullOrderList[key].UnitPrice;
                                                                }  
                                                                
                                                                
                                                               
                                                            }
                                                            else{
                                                                if(ProductId ==  fullOrderList[key].ProductId){    
                                                                    fullOrderList[key].Amount = parseFloat(fullOrderList[key].Quantity * parseFloat(fullOrderList[key].UnitPrice).toFixed(2)).toFixed(2);   
                                                                }
                                                                else if (fullOrderList[key].ComponentQuantityFinal > 0){
                                                                    fullOrderList[key].Amount = fullOrderList[key].ComponentQuantityFinal * fullOrderList[key].UnitPrice;
                                                                }
                                                                else if(PricingMethod=='OrderTotalAmount'){
                                                                    fullOrderList[key].Amount = fullOrderList[key].Quantity * fullOrderList[key].UnitPrice;
                                                                }
                                                                    
                                                            }

                                                          
                                                        if(ProductId ==  fullOrderList[key].ProductId){ 
                                                             fullOrderList[key].NoDiscAmount = fullOrderList[key].Quantity * fullOrderList[key].UnitPrice; 
                                                        }
                                                        else if(fullOrderList[key].ComponentQuantityFinal > 0){
                                                            fullOrderList[key].NoDiscAmount = fullOrderList[key].ComponentQuantityFinal * fullOrderList[key].STDPrice;
                                                        }   
                                                        else if(PricingMethod=='OrderTotalAmount'){
                                                            fullOrderList[key].NoDiscAmount = fullOrderList[key].Quantity * fullOrderList[key].UnitPrice;
                                                        } 
                                                  
                                                        for(var i in ItemId){
                                                            if(fullOrderList[key].ItemId == ItemId[i]){
                                                                STPlistPriceRateId=fullOrderList[key].listPriceRateId; 
                                                                STPRate=ListPriceDiscount[keyLP].Rate__c                                
                                                            }
                                                        }    
                                                    
                                                }  
                                            
                                             }   
                                             console.log('**Component Update: In 1a**'+fullOrderList[key].Amount);
                                    }
                                }    
                            }  
        
                        fullOrderList[key].listPriceDiscountType = fullOrderList[key].listPriceDiscountType;
                    } 
                }   
                    ProdGroup='';
                   
                    totalOrderAmounts.TotalAmount = parseFloat(totalOrderAmounts.TotalAmount) + parseFloat(fullOrderList[key].Amount);
                   // console.log('**Component Update: In 2**');
                    if(fullOrderList[key].ItemGroupProductId == ProductId){
                        var STDPrice = fullOrderList[key].ItemGroup+'STDPrice';
                        var unitPrice = fullOrderList[key].ItemGroup+'unit';
                        var AmountPrice = fullOrderList[key].ItemGroup+'amount';

                       // console.log('**Discount Price: STD**'+fullOrderList[key].STDPrice);
                       // console.log('**Discount Price: Unit**'+fullOrderList[key].UnitPrice);

                       // console.log('**Discount Price: ComponentQuantity**'+fullOrderList[key].ComponentQuantity);
        
                        if(ItemGrpMap[STDPrice] == undefined){
                            ItemGrpMap[STDPrice] = parseFloat(fullOrderList[key].STDPrice)*parseFloat(fullOrderList[key].ComponentQuantity);
                            ItemGrpMap[unitPrice] = parseFloat(fullOrderList[key].UnitPrice)*parseFloat(fullOrderList[key].ComponentQuantity);
                            ItemGrpMap[AmountPrice] = parseFloat(fullOrderList[key].Amount);
                        }
                        else{
                            ItemGrpMap[STDPrice] = parseFloat(ItemGrpMap[STDPrice]) + (parseFloat(fullOrderList[key].STDPrice) *parseFloat(fullOrderList[key].ComponentQuantity));
                            ItemGrpMap[unitPrice] = parseFloat(ItemGrpMap[unitPrice]) + (parseFloat(fullOrderList[key].UnitPrice)*parseFloat(fullOrderList[key].ComponentQuantity));
                            ItemGrpMap[AmountPrice] = parseFloat(ItemGrpMap[AmountPrice]) + parseFloat(fullOrderList[key].Amount);
                        }  
                        
                      //  console.log('**Component Update: ItemGrpMap[STDPrice]**'+ItemGrpMap[STDPrice]);
                     //   console.log('**Component Update: ItemGrpMap[unitPrice]**'+ItemGrpMap[unitPrice]);
                     //   console.log('**Component Update: ItemGrpMap[AmountPrice]**'+ItemGrpMap[AmountPrice]);
                    }                 
            
                 

            }

        }

        console.log('**loopCount**'+loopCount);
        console.log('**loopCountLPD**'+loopCountLPD);
        console.log('**loopCountPRODDTYEE**'+loopCountPRODDTYEE);

        var OrderItemsLength=1;
        for(var key in fullOrderList){

            console.log('**Item group Update: Before**');
            if(ProductId ==  fullOrderList[key].ProductId && fullOrderList[key].ItemGroupComponent == true){
                
                

                var STDPrice = fullOrderList[key].ItemId+'STDPrice';
                var unitPrice = fullOrderList[key].ItemId+'unit';
                var AmountPrice = fullOrderList[key].ItemId+'amount';
                
                
               

                fullOrderList[key].IsEdited = true;
                fullOrderList[key].STDPrice = ItemGrpMap[STDPrice] ;
                fullOrderList[key].UnitPrice = ItemGrpMap[unitPrice] ;
                fullOrderList[key].Amount = ItemGrpMap[AmountPrice] ;

            }
            fullOrderList[key].Count = OrderItemsLength;
            OrderItemsLength++;

        }    
   

  
      //  component.set("v.ShoolOrderItemList",schoolOrder);    

      var tl1 = performance.now();
      console.log("LPD LOOP TOOK: " + (tl1 - tl0) + " milliseconds."); 
        
        
        if(Type=='Existing'){
            component.set("v.OrderItemList",fullOrderList);
            component.set( 'v.TotalOrder', totalOrderAmounts);
        }
        else{
           // component.set("v.OrderItemList",fullOrderList);
            //component.set("v.SelectedProductList",[]);
            //component.set("v.ShoolOrderItemList",[]);
           
            // component.set("v.ShoolOrderItemList",fullOrderList);

            console.log("Save Product Out");

           // this.SaveProduct(component,fullOrderList);
            
            this.updateOrder(component,fullOrderList);
            

        }
        
        component.set("v.OrderProdMap",[]);
        component.set("v.VarMap",[]);       
        component.set("v.CurrenOrderDisplay",CurrenOrderDisplay);
        
        var tl2 = performance.now();
        console.log("LPD SET TOOK: " + (tl2 - tl1) + " milliseconds."); 
        
    },

    showSpinner: function(component) {
        console.log('**SPin ON**');
        component.set("v.isSpinner",true);
   },


   hideSpinner: function(component) {
        console.log('**SPin Off**');
        component.set("v.isSpinner",false);
   },


   UpdateListPriceDiscountNew: function(component,Type,ItemId,PricingMethod,schoolOrder) {
    var fullOrderList = component.get("v.OrderItemList");
    console.log('**S1**');
    var t1 = performance.now();
    
    

    for(var key in schoolOrder){
         
        
                    fullOrderList.push({
                  'sobjectType': 'OrderLineItem',
                   'ShipToAccountName': schoolOrder[key].ShipToAccountName, 
                  'ProductName':schoolOrder[key].ProductName,
                  'ItemGroup': schoolOrder[key].ItemGroup,
                  'ItemGroupId': schoolOrder[key].ItemGroupId,                                  
                  'ProductId': schoolOrder[key].ProductId, 
                  'ShipToAccountId': schoolOrder[key].ShipToAccountId,
                  'CustomerDiscountGroup': schoolOrder[key].CustomerDiscountGroup, 
                  'Subsidiary':  schoolOrder[key].Subsidiary,
                  'Quantity':  schoolOrder[key].Quantity, 
                   
                  'UnitPrice' :schoolOrder[key].UnitPrice,
                   'BasePrice' :schoolOrder[key].BasePrice,
                   'STDPrice' :schoolOrder[key].STDPrice,
                   'listPriceRateId':schoolOrder[key].listPriceRateId,
                   'listPriceDiscountType':schoolOrder[key].listPriceDiscountType,
                   'ProductRateGroup': schoolOrder[key].ProductRateGroup, 
                   'PriceDiscount':schoolOrder[key].PriceDiscount,
                   'listPriceProductType' : schoolOrder[key].listPriceProductType,
                   'NoDiscAmount' :schoolOrder[key].NoDiscAmount,
                   'maxQuantity': schoolOrder[key].maxQuantity,
                  'Rate' :schoolOrder[key].Rate,                   
                  'Amount':schoolOrder[key].Amount,
                  'ManualDiscount':schoolOrder[key].ManualDiscount ,
                  'DiscountOption':schoolOrder[key].DiscountOption,  
                  'DiscountAmount':schoolOrder[key].DiscountAmount,
                    'DiscountPercent': schoolOrder[key].DiscountPercent,
                    'DiscountPercentShow': schoolOrder[key].DiscountPercentShow,
                    'DiscountValueShow': schoolOrder[key].DiscountValueShow,
                  'ItemId':schoolOrder[key].ItemId,
                  'PricebookEntryId': schoolOrder[key].PricebookEntryId,
                  'MarketSegment': schoolOrder[key].MarketSegment,
                  'listPriceDiscount':schoolOrder[key].listPriceDiscount,
                  'listAsset2Product':schoolOrder[key].listAsset2Product,
                  'ComponentQuantityTitle': schoolOrder[key].ComponentQuantityTitle,
                  'ComponentQuantity': schoolOrder[key].ComponentQuantity,   
                  'ComponentQuantityFinal': schoolOrder[key].ComponentQuantityFinal,
                  'ComponentQuantityDisplay': schoolOrder[key].ComponentQuantityDisplay,   
                  'ItemGroupComponent': schoolOrder[key].ItemGroupComponent,
                  'ItemGroupProductId': schoolOrder[key].ItemGroupProductId,
                  'ItemGroupType':schoolOrder[key].ItemGroupType,
                  'ItemGroup':schoolOrder[key].ItemGroup,
                  'ItemGroupId':schoolOrder[key].ItemGroupId, 
                  'IsEdited':schoolOrder[key].IsEdited                     
                   
            });
             
    }
    this.UpdateListPriceDiscount(component,Type,ItemId,PricingMethod,fullOrderList);

   },
   updateOrder : function(component,fullOrderList) {
    
    var totalOrderAmounts = component.get( 'v.TotalOrder');
            totalOrderAmounts.TotalAmount =0;
            for(var key in fullOrderList){
                if(fullOrderList[key].ItemGroup== undefined){
                    totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
                } 
            }    

            var t3 = performance.now();
           

            component.set( 'v.TotalOrder', totalOrderAmounts);
            
            component.set("v.OrderItemList",fullOrderList); 
            component.set("v.ShoolOrderItemList",[]);
            component.set("v.CurrenOrderDisplay",[]);

   }, 


   SaveProduct : function(component,schoolOrder) {

    console.log("Save Product IN");

    var schoolOrder = component.get("v.ShoolOrderItemList");
    var totalOrderAmounts = component.get( 'v.TotalOrder');

    var fullOrderList = component.get("v.OrderItemList");
    console.log('**S1**');
    var t1 = performance.now();
    
    

    for(var key in schoolOrder){
         
        
                    fullOrderList.push({
                  'sobjectType': 'OrderLineItem',
                   'ShipToAccountName': schoolOrder[key].ShipToAccountName, 
                  'ProductName':schoolOrder[key].ProductName,
                  'ItemGroup': schoolOrder[key].ItemGroup,
                  'ItemGroupId': schoolOrder[key].ItemGroupId,                                  
                  'ProductId': schoolOrder[key].ProductId, 
                  'ShipToAccountId': schoolOrder[key].ShipToAccountId,
                  'CustomerDiscountGroup': schoolOrder[key].CustomerDiscountGroup, 
                  'Subsidiary':  schoolOrder[key].Subsidiary,
                  'Quantity':  schoolOrder[key].Quantity, 
                   
                  'UnitPrice' :schoolOrder[key].UnitPrice,
                   'BasePrice' :schoolOrder[key].BasePrice,
                   'STDPrice' :schoolOrder[key].STDPrice,
                   'listPriceRateId':schoolOrder[key].listPriceRateId,
                   'listPriceDiscountType':schoolOrder[key].listPriceDiscountType,
                   'ProductRateGroup': schoolOrder[key].ProductRateGroup, 
                   'PriceDiscount':schoolOrder[key].PriceDiscount,
                   'listPriceProductType' : schoolOrder[key].listPriceProductType,
                   'NoDiscAmount' :schoolOrder[key].NoDiscAmount,
                   'maxQuantity': schoolOrder[key].maxQuantity,
                  'Rate' :schoolOrder[key].Rate,                   
                  'Amount':schoolOrder[key].Amount,
                  'ManualDiscount':schoolOrder[key].ManualDiscount ,
                  'DiscountOption':schoolOrder[key].DiscountOption,  
                  'DiscountAmount':schoolOrder[key].DiscountAmount,
                    'DiscountPercent': schoolOrder[key].DiscountPercent,
                    'DiscountPercentShow': schoolOrder[key].DiscountPercentShow,
                    'DiscountValueShow': schoolOrder[key].DiscountValueShow,
                  'ItemId':schoolOrder[key].ItemId,
                  'PricebookEntryId': schoolOrder[key].PricebookEntryId,
                  'MarketSegment': schoolOrder[key].MarketSegment,
                  'listPriceDiscount':schoolOrder[key].listPriceDiscount,
                  'listAsset2Product':schoolOrder[key].listAsset2Product,
                  'ComponentQuantityTitle': schoolOrder[key].ComponentQuantityTitle,
                  'ComponentQuantity': schoolOrder[key].ComponentQuantity,   
                  'ComponentQuantityFinal': schoolOrder[key].ComponentQuantityFinal,
                  'ComponentQuantityDisplay': schoolOrder[key].ComponentQuantityDisplay,   
                  'ItemGroupComponent': schoolOrder[key].ItemGroupComponent,
                  'ItemGroupProductId': schoolOrder[key].ItemGroupProductId,
                  'ItemGroupType':schoolOrder[key].ItemGroupType,
                  'ItemGroup':schoolOrder[key].ItemGroup,
                  'ItemGroupId':schoolOrder[key].ItemGroupId, 
                  'IsEdited':schoolOrder[key].IsEdited                     
                   
            });
             
    }
    var t2 = performance.now();     
    console.log("time 2 " + (t2 - t1) + " milliseconds.");
  
    totalOrderAmounts.TotalAmount =0;
    for(var key in fullOrderList){
        if(fullOrderList[key].ItemGroup== undefined){
            totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
        } 
    }    

    var t3 = performance.now();
     console.log("time 3 " + (t3 - t2) + " milliseconds.");

    component.set( 'v.TotalOrder', totalOrderAmounts);
    
    component.set("v.OrderItemList",fullOrderList); 
    component.set("v.ShoolOrderItemList",[]);
    component.set("v.CurrenOrderDisplay",[]);
 //  component.set("v.SchoolProductList",[]);

    var t4 = performance.now();
     console.log("time 3 " + (t4 - t3) + " milliseconds.");
    

 //  component.set("v.isOpenAccOrd",false);
   var t5 = performance.now();
     console.log("time 3 " + (t5 - t4) + " milliseconds.");
    
},
    


})