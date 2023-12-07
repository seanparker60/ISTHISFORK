({
	doInit : function(component, event, helper){
        
        helper.fetchAccountsUtil(component);
        helper.fetchOrderUtil(component);
        helper.fetchOrderItemsUtil(component);
        
        helper.fetchloadAssetsforRate(component);
        helper.fetchBilltoAccount(component);
        helper.fetchProductsUtil(component);
        var PricingMethod = component.get('v.PricingMethod');

        console.log("**PricingMethod XX**"+PricingMethod);
         
            helper.fetchListPriceDiscountUtil(component);

            /*
          var orderList =  component.get( 'v.OrderItemList');
          var OrderTotal = 0;
            for(var key in orderList){
                if(orderList[key].ItemGroupComponent != true){
                    OrderTotal = OrderTotal + orderList[key].Amount ;
                }
                
            }    
        console.log('**OrderTotal**'+OrderTotal);

        var totalOrderAmounts = {'sobjectType': 'Order','TotalAmount':OrderTotal,'TotalVat':0 }; 
        var CurrenOrderDisplay  = {'sobjectType': 'School',   'NoPupils':0, 'Name': '', 'TotalAmount':OrderTotal, 'TotalVat':0 };

        component.set( 'v.TotalOrder', totalOrderAmounts);
        component.set( 'v.CurrenOrderDisplay', CurrenOrderDisplay);
            */
     var Assetlist = component.get('v.Assetlist');

     /*
     for(var key in Assetlist){
        console.log('**Assetlist[key].Name**'+Assetlist[key].Name);

     }
       */

        var availableActions = component.get('v.availableActions');
      for (var i = 0; i < availableActions.length; i++) {
         if (availableActions[i] == "PAUSE") {
            component.set("v.canPause", true);
         } else if (availableActions[i] == "BACK") {
            component.set("v.canBack", true);
         } else if (availableActions[i] == "NEXT") {
            component.set("v.canNext", true);
         } else if (availableActions[i] == "FINISH") {
            component.set("v.canFinish", true);
         }
      }
    },

    onButtonPressed: function(component, event, helper) {
      
      // Figure out which action was called
      var actionClicked = event.getSource().getLocalId();

    //  var accountsData =  component.get('v.accountsData');

     // component.set('v.accountsData',[]);


      // Fire that action
      var navigate = component.get('v.navigateFlow');
      navigate(actionClicked); 
    
    },
    CompleteOrder: function(component, event, helper) {
      
         
        var ContractId =  component.get("v.ContractId");
        var OrderId =  component.get("v.OrderId");

        if(OrderId == undefined || OrderId == null){
            OrderId =  component.get("v.recordId");
        }

        var OrderItems = component.get("v.OrderItemList");  
        
        var action = component.get("c.InsertOrderItems");
        
        var AccountbyShipto = component.get("v.accountsData");

       var TotalNumberofStudents =  component.get("v.TotalNumberofStudents");

       /*
       for(var key in OrderItems){
            console.log('**OrderItems[key]**'+OrderItems[key].listPriceRateId);
       }
        */

 		 action.setParams({ 
            "ContractId": ContractId,
            "OrderId": OrderId,
             "OrderItems": OrderItems,
             "TotalNumberofStudents":TotalNumberofStudents,
             "AccountbyShipto":AccountbyShipto,
    	});
        
        component.set("v.isSpinner",true);
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var OrderId = response.getReturnValue();
       			//window.location.assign("/"+OrderId);
                   window.location.assign("/lightning/r/Order/"+OrderId+"/view");   
            }
            else if (state === "INCOMPLETE") {
                
            }
                else if (state === "ERROR") {
                    component.set("v.isSpinner",false);
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


                }
        });
        
        
        $A.enqueueAction(action);
	
    },
    
    AddProductstoAccInd : function(component, event, helper) {
        console.log("AddProductstoAccInd");
    	 helper.AddProductstoAcc(component,event,'Individual');          
    },    
    AddProductstoAccGroup : function(component, event, helper) {
    	helper.AddProductstoAcc(component,event,'Group');
    },
    AddProductstoAccAll : function(component, event, helper) {
    	helper.AddProductstoAcc(component,event,'All');
    },

    
    Selectallschools : function(component, event, helper) {
      
        var AllCheck = event.getSource().get('v.checked');
        var schoollist = component.get("v.accountsData");
        console.log('**allschoolsselected: In**'+AllCheck);
        for(var key in schoollist){
            if(AllCheck == true){
                schoollist[key].IsSelected = true;
            }
            else{
                schoollist[key].IsSelected = false;
            }
        }
        component.set("v.accountsData",schoollist);
    },  

    QuantityChangeProduct : function(component, event, helper) {
        var ProductId = event.target.id;
        var newquantity = event.target.value;
       // var FullProductList = component.get("v.FullProductList");
       var FullProductList = component.get("v.SchoolProductList");
       

        for(var keyP in FullProductList){             
            
            if(FullProductList[keyP].ProductId == ProductId){
                FullProductList[keyP].Quantity = newquantity;
            }
        }        
        component.set("v.SchoolProductList",FullProductList);

    },    
    AddProductsInd : function(component, event, helper) {
     
         
        var ProductId = event.target.id;
        var schoolOrder = component.get("v.ShoolOrderItemList"); 
        var OrderItems = component.get("v.OrderItemList");
        var SchoolProductList = component.get("v.SchoolProductList");

      //  var SchoolProductList = component.get("v.SelectedProductList"); 
        var OrderProdMap = component.get("v.OrderProdMap");
        var CurrenShipto = component.get("v.CurrenShipto");
        var CurrenOrderDisplay = component.get("v.CurrenOrderDisplay"); 
        var curOrder =  component.get("v.curOrder");
        var BillToAccount  = component.get("v.BillToAccount");
      
        
        var index=0;
       

        var IsMarketSegment;
        var RemoveFromSearch=false;
        
        var ItemGroupTotal=0; 
        var ItemGroupBasePrice=0;
        var ItemGroupUnitPrice=0;
        var ItemGroupSTDPrice=0;
        var ItemGroupQuantity=0;
        var  ComponentQuantityDisplay;

        var ItemId = [];
        var ItemIdCount=0;

        var t0 = performance.now();

       
     //   CurrenOrderDisplay.TotalAmount = 0;


     var ProductAlreadyExists = false;
    

  if(ProductAlreadyExists == false){     
        for(var keyP in SchoolProductList){
             
            
         if(SchoolProductList[keyP].ProductId == ProductId){  // Commented out for TEST  
 			    
               var Amount;
               var STDPrice;
               var UnitPrice;
               var BasePrice;
            
            //   var DiscountAmount;
                
               for(var keyS in CurrenShipto){ 
                 
                

                 
                var selectquantity; 
                
                
                if(SchoolProductList[keyP].QuantitySelectionType == 'Per number of students' && CurrenShipto[keyS].NoPupils>0){
                    
                    if(SchoolProductList[keyP].maxQuantity <= CurrenShipto[keyS].NoPupils){
                        selectquantity = SchoolProductList[keyP].maxQuantity;
                    }
                    else{
                        selectquantity = CurrenShipto[keyS].NoPupils;
                    }
                    
                }
                else if(SchoolProductList[keyP].Quantity>0) {
                    
                    if(SchoolProductList[keyP].maxQuantity <= SchoolProductList[keyP].Quantity){
                        selectquantity = SchoolProductList[keyP].maxQuantity;
                    }
                    else{
                        selectquantity = SchoolProductList[keyP].Quantity;
                    }
                }
                else{
                    selectquantity = 1;
                }
                
                
                
  //              if(IsMarketSegment == true){ 

                var STDPrice;
                var ProductItemId;
                var STPId;
                var STPRate;
                var listPriceSelected=false;
                var PriceDiscount;
                var PriceDiscountItemGrp = '--None--';
                        
                           STDPrice=SchoolProductList[keyP].BasePrice;
                           Amount = selectquantity * STDPrice;
                          
                           var TmpPriceDiscount=false;

                           PriceDiscount = 'Service';
                           if(curOrder.Type == 'RegularOrder'){
                                PriceDiscount = 'Regular';
                           }
                           else if(curOrder.Type == 'FreeOrder'){
                                PriceDiscount = 'Free';
                           }
                           if(PriceDiscount != 'Free'){
                                for(var type in SchoolProductList[keyP].listPriceProductType){
                                
                                         if(SchoolProductList[keyP].listPriceProductType[type] == 'Regular'){
                                            TmpPriceDiscount=true;
                                        }
                                } 
                                if(PriceDiscount == 'Regular' && TmpPriceDiscount == false){                                        
                                        PriceDiscount = 'Service';
                                }
                           }
                         
                            
                            
                              
                             
                            ItemGroupTotal = 0;
                            ItemGroupBasePrice=0;
                            ItemGroupUnitPrice=0;
                            ItemGroupSTDPrice=0;
                            for(var igroup in SchoolProductList[keyP].listItemGroupComponent){
                                if(SchoolProductList[keyP].listItemGroupComponent[igroup].ProductId == ProductId || OrderProdMap[SchoolProductList[keyP].listItemGroupComponent[igroup].ProductId] == 1){
                                    ProductAlreadyExists = true;
                                    alert('Product Already exists in Order.');
                                    break;
                                }



                                //For Summing up the main product in the component pack
                                ItemGroupQuantity = SchoolProductList[keyP].listItemGroupComponent[igroup].ComponentQuantity;

                                ItemGroupBasePrice = (SchoolProductList[keyP].listItemGroupComponent[igroup].BasePrice * ItemGroupQuantity) + ItemGroupBasePrice ;
                                itemSTDPrice = SchoolProductList[keyP].listItemGroupComponent[igroup].BasePrice * ItemGroupQuantity;
                             
                                ItemGroupUnitPrice = itemSTDPrice + ItemGroupUnitPrice;
                                ItemGroupSTDPrice =  itemSTDPrice + ItemGroupSTDPrice;

                                itemAmount = selectquantity * itemSTDPrice ;
                                ItemGroupTotal = itemAmount + ItemGroupTotal;

                                console.log('**ItemGroupQuantity**'+ItemGroupQuantity);
                                
                          
                            }    
            if(ProductAlreadyExists == true){  
                break;                 
            }    
                                
                             if(ItemGroupTotal>0 ){ 

                                
                                Amount=ItemGroupTotal;
                                console.log('**Amount: Before**'+Amount);
                                BasePrice= ItemGroupBasePrice; 
                                UnitPrice= ItemGroupUnitPrice; 
                                STDPrice= ItemGroupSTDPrice;
                                CurrenOrderDisplay.TotalAmount = CurrenOrderDisplay.TotalAmount + Amount;  
                            } 
                            else{
                               
                                BasePrice= SchoolProductList[keyP].BasePrice; 
                                UnitPrice= STDPrice; 
                                STDPrice= STDPrice;
                                CurrenOrderDisplay.TotalAmount = CurrenOrderDisplay.TotalAmount + Amount;  
                                
                            }
                            
                            console.log('**Amount: After**'+Amount);

                            RemoveFromSearch=true;
                            var today = new Date();
                            var RTime = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
                            ProductItemId = CurrenShipto[keyS].AccId+ProductId+RTime;

                            console.log('**ProductItemId**'+ProductItemId);
                            console.log('**Add Prod: Max quantity**'+SchoolProductList[keyP].maxQuantity);

                            schoolOrder.push({
                            'sobjectType': 'OrderLineItem',
                            'ShipToAccountName': CurrenShipto[keyS].Name,     
                            'ProductName': SchoolProductList[keyP].ProductName,
                            'ProductId': ProductId,
                            'Subsidiary': BillToAccount.OperatingCompany__c,
                            'listPriceRateId':STPId,                                                    //SchoolProductList[keyP].listPriceRateId,
                            'listPriceDiscountType':SchoolProductList[keyP].listPriceDiscountType, 
                            'listPriceProductType' :  SchoolProductList[keyP].listPriceProductType,
                            'ProductRateGroup': SchoolProductList[keyP].ProductRateGroup,
                            'listPriceDiscount':SchoolProductList[keyP].listPriceDiscount,
                            'PriceDiscount': PriceDiscount, // CHANGE TO ORDERLINE TYPE
                            'listAsset2Product':SchoolProductList[keyP].listAsset2Product,   
                            'listItemGroupComponent':SchoolProductList[keyP].listItemGroupComponent,
                            'ItemGroupComponent': SchoolProductList[keyP].ItemGroupComponent,
                            'ShipToAccountId': CurrenShipto[keyS].AccId,
                            'CustomerDiscountGroup': BillToAccount.CustomerDiscountGroup__c, // CurrenShipto[keyS].CustomerDiscountGroup, 
                            'STDPrice' : STDPrice,                                                       //SchoolProductList[keyP].STDPrice,
                            'UnitPrice' : UnitPrice,
                            'BasePrice' : BasePrice,     
                            'Rate' :SchoolProductList[keyP].Rate, 
                            'Quantity':selectquantity,
                            'MarketSegment':SchoolProductList[keyP].MarketSegment,
                            'Amount':Amount,
                            'NoDiscAmount' :Amount,    
                            'ManualDiscount':SchoolProductList[keyP].ManualDiscount ,
                            'DiscountOption':'--None--',
                            'DiscountPercentShow':false, 
                            'DiscountValueShow':false,     
                            'DiscountAmount':0,
                            'maxQuantity':SchoolProductList[keyP].maxQuantity,     
                            'ItemId': ProductItemId, //CurrenShipto[keyS].AccId+ProductId,
                            'PricebookEntryId': SchoolProductList[keyP].PricebookEntryId,                           
                            'IsnewItem':'True',            
                            'QuantitySelectionType':SchoolProductList[keyP].QuantitySelectionType,
                            'Stocknumber':SchoolProductList[keyP].Stocknumber,
                            'ProductTYPE':SchoolProductList[keyP].ProductTYPE,
                            'IsEdited':true        
                            });
                             
                            ItemId[ItemIdCount] = ProductItemId; // CurrenShipto[keyS].AccId+ProductId;
                             
                            var itemSTDPrice;
                            var itemSTPId;
                            var itemAmount; 

                            var ComponentQuantityDisplay;
                            var ComponentQuantityFinal;
                            var ComponentQuantityTitle;
                             

                            ItemGroupBasePrice=0;
                            ItemGroupUnitPrice=0;
                            ItemGroupSTDPrice=0;

                            for(var igroup in SchoolProductList[keyP].listItemGroupComponent){
                                   
                                PriceDiscountItemGrp = PriceDiscount; //'Service';                                     
                                listPriceSelected=false;
                                itemSTDPrice=SchoolProductList[keyP].listItemGroupComponent[igroup].BasePrice;
                                ItemGroupQuantity = SchoolProductList[keyP].listItemGroupComponent[igroup].ComponentQuantity
                                itemAmount = selectquantity * itemSTDPrice * ItemGroupQuantity;
                                if(PricingMethod =='AccountStudents'){
                                    if(STPId != null){
                                    // PriceDiscountItemGrp = 'Regular';
                                        itemSTDPrice =  SchoolProductList[keyP].listItemGroupComponent[igroup].BasePrice-(SchoolProductList[keyP].listItemGroupComponent[igroup].BasePrice*(STPRate/100));
                                        itemAmount = selectquantity * itemSTDPrice;
                                        itemSTPId =  STPId;

                                    }
                                }
                              
                                
                                
                                //For Summing up the main product in the component pack

                                ItemGroupTotal = itemAmount + ItemGroupTotal;
                                ItemGroupBasePrice = SchoolProductList[keyP].listItemGroupComponent[igroup].BasePrice + ItemGroupBasePrice;
                                ItemGroupUnitPrice = itemSTDPrice + ItemGroupUnitPrice;
                                ItemGroupSTDPrice =  itemSTDPrice + ItemGroupSTDPrice;

                             //   ComponentQuantityDisplay = 'Product Value: ' +'€ ' + SchoolProductList[keyP].listItemGroupComponent[igroup].ComponentQuantity * selectquantity * itemSTDPrice ;         
                                ComponentQuantityFinal = (SchoolProductList[keyP].listItemGroupComponent[igroup].ComponentQuantity * selectquantity);
                              //  ComponentQuantityTitle = 'Pack quantity: '+ ComponentQuantityFinal;
                                
                                
                                 console.log('**Add Item: ComponentQuantityDisplay**'+ ComponentQuantityDisplay);
                                 console.log('**Add Item: itemAmount**'+ itemAmount);
                                 

                                    schoolOrder.push({
                                        'sobjectType': 'OrderLineItem',
                                        'ShipToAccountName': CurrenShipto[keyS].Name,     
                                        'ProductName': SchoolProductList[keyP].listItemGroupComponent[igroup].ProductName,
                                        'ProductId': SchoolProductList[keyP].listItemGroupComponent[igroup].ProductId,
                                        'ItemGroupType': SchoolProductList[keyP].listItemGroupComponent[igroup].ItemGroupType,
                                        'ItemGroup': ProductItemId, //CurrenShipto[keyS].AccId+ProductId,
                                        'ItemGroupProductId': ProductId,
                                        'ItemGroupId': SchoolProductList[keyP].listItemGroupComponent[igroup].ItemGroupId,                                       
                                        'listPriceRateId': itemSTPId,                   //SchoolProductList[keyP].listItemGroupComponent[igroup].listPriceRateId,
                                        'listPriceDiscountType':SchoolProductList[keyP].listItemGroupComponent[igroup].listPriceDiscountType, 
                                        'listPriceProductType' :  SchoolProductList[keyP].listPriceProductType,
                                        'ProductRateGroup': SchoolProductList[keyP].ProductRateGroup,  
                                        'listPriceDiscount':SchoolProductList[keyP].listItemGroupComponent[igroup].listPriceDiscount,
                                        'MarketSegment':SchoolProductList[keyP].listItemGroupComponent[igroup].MarketSegment, 
                                        'listAsset2Product':SchoolProductList[keyP].listItemGroupComponent[igroup].listAsset2Product,
                                        'PriceDiscount': PriceDiscountItemGrp,      
                                        'ShipToAccountId': CurrenShipto[keyS].AccId,
                                        'CustomerDiscountGroup': BillToAccount.CustomerDiscountGroup__c, //  CurrenShipto[keyS].CustomerDiscountGroup, 
                                        'Subsidiary': BillToAccount.OperatingCompany__c,
                                        'STDPrice' :itemSTDPrice ,                      //SchoolProductList[keyP].listItemGroupComponent[igroup].STDPrice,
                                        'UnitPrice' : itemSTDPrice, //SchoolProductList[keyP].listItemGroupComponent[igroup].UnitPrice,
                                        'BasePrice' :SchoolProductList[keyP].listItemGroupComponent[igroup].BasePrice,     
                                        'Rate' :SchoolProductList[keyP].listItemGroupComponent[igroup].Rate, 
                                        'Quantity':ComponentQuantityFinal, //selectquantity,
                                        
                                        'ComponentQuantityTitle': ComponentQuantityTitle, //SchoolProductList[keyP].listItemGroupComponent[igroup].ComponentQuantityTitle,
                                        'ComponentQuantity':SchoolProductList[keyP].listItemGroupComponent[igroup].ComponentQuantity,
                                        'ComponentQuantityFinal': ComponentQuantityFinal, // SchoolProductList[keyP].listItemGroupComponent[igroup].ComponentQuantityFinal,
                                        'ComponentQuantityDisplay':ComponentQuantityDisplay,

                                        'Amount':itemAmount,                            //Amount,
                                        'NoDiscAmount' :itemAmount,                     //Amount,    
                                        'ManualDiscount':SchoolProductList[keyP].listItemGroupComponent[igroup].ManualDiscount ,
                                        'DiscountOption':'--None--',
                                        'DiscountPercentShow':false, 
                                        'DiscountValueShow':false,     
                                        'DiscountAmount':0,     
                                        'ItemId':CurrenShipto[keyS].AccId+SchoolProductList[keyP].listItemGroupComponent[igroup].ProductId,
                                        'PricebookEntryId': SchoolProductList[keyP].listItemGroupComponent[igroup].PricebookEntryId,                                           
                                       
                                        'IsnewItem':'True',
                                        'IsEdited':true        
                                        });
                               // CurrenOrderDisplay.TotalAmount = CurrenOrderDisplay.TotalAmount +Amount; 
                                //'PriceDiscount': 'Regular',      
                             }
                             

               ItemIdCount++;                  
               }
                        
           break;        
         }              
                        
         index++;          
        
        if(ProductAlreadyExists == true){  
            break;                 
        }

       }
    if(ProductAlreadyExists == false){  
        
       var t1 = performance.now();
       console.log("ADD PRODUCT TOOK: " + (t1 - t0) + " milliseconds.");
  
       var t2 = performance.now();
       if(RemoveFromSearch == true){  
            SchoolProductList.splice(index,1); 
        }                                      

       
     
      
  
        var t2 = performance.now();
        console.log("ITEM GROUP TOOK: " + (t2 - t1) + " milliseconds.");

      
        
        var PricingMethod = component.get('v.PricingMethod');
       
        var t3 = performance.now();
        console.log("ADD SET TOOK: " + (t3 - t2) + " milliseconds.");

   
           component.set("v.SchoolProductList",SchoolProductList); // Commented out for TEST 
           
          //helper.UpdateListPriceDiscount(component,'AddProduct',ItemId,PricingMethod,schoolOrder);
          helper.UpdateListPriceDiscountNew(component,'AddProduct',ItemId,PricingMethod,schoolOrder);
                         
        }
    }
    component.set("v.OrderProdMap",[]);   
      
    },
   
   RemoveOrderItem : function(component, event, helper) {
       var OrderItemId = event.target.id;
       var fullOrderList = component.get("v.OrderItemList"); 
        var schoolOrder = component.get("v.ShoolOrderItemList");
       var SchoolProductList = component.get("v.SchoolProductList");
        var CurrenShipto = component.get("v.CurrenOrderDisplay");
       var totalOrderAmounts = component.get( 'v.TotalOrder');
       
      console.log('**CurrenShipto**'+CurrenShipto.TotalAmount);
       var index=0;
       var ProductId;

       var groupItem = [];
       for(var key in fullOrderList){
       	  
        console.log('**OrderItemId**'+OrderItemId+'*****'+fullOrderList[key].ItemGroupId);
           if(fullOrderList[key].ItemId ==OrderItemId || fullOrderList[key].ItemGroup == OrderItemId){
               
               groupItem.push(index);
               
              // break;
           }

           if(fullOrderList[key].ItemId == OrderItemId){
            ProductId = fullOrderList[key].ProductId;
           }
           
           index++;
       }
 
       for(var i = groupItem.length -1; i >= 0; i--){
            console.log('**Splice: one**'+i);
            fullOrderList.splice(groupItem[i],1);
       }

       console.log('**Remove 1**');


       
       totalOrderAmounts.TotalAmount =0;
       for(var key in fullOrderList){
            if(fullOrderList[key].ItemGroup== undefined){
                totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
                fullOrderList[key].PriceDiscount = fullOrderList[key].PriceDiscount;
                console.log('**fullOrderList[key].PriceDiscount**'+fullOrderList[key].PriceDiscount);
            }    
       }
        
       console.log('**Remove 2**');
      

  
       component.set("v.OrderItemList",fullOrderList); 

       var PricingMethod = component.get('v.PricingMethod');
        console.log('**OrderProductQuantity**'+PricingMethod);
      // if(PricingMethod !='AccountStudents'){   
            var varItemId = [];
            varItemId[0] = ProductId;          
           helper.UpdateListPriceDiscount(component,'Existing',varItemId,PricingMethod,fullOrderList);
     //  }
   }, 


   RemoveOrderItemSelection : function(component, event, helper) {
    var OrderItemId = event.target.id;
    var fullOrderList = component.get("v.OrderItemList"); 
     var schoolOrder = component.get("v.ShoolOrderItemList");
    var SchoolProductList = component.get("v.SchoolProductList");
     var CurrenShipto = component.get("v.CurrenOrderDisplay");
    var totalOrderAmounts = component.get( 'v.TotalOrder');
    
    var index=0;
    console.log('**OrderItemId: Out**'+OrderItemId);
   
    index=0;
    var groupItem = [];
    for(var key in schoolOrder){
        console.log('**OrderItemId: School**');

        if(schoolOrder[key].ItemId ==OrderItemId && schoolOrder[key].ItemGroup == null){  
            SchoolProductList.push({
             'sobjectType': 'ProductListPrice',
             'ProductName': schoolOrder[key].ProductName,
            'UnitPrice': schoolOrder[key].UnitPrice,
               'STDPrice': schoolOrder[key].STDPrice,
             'BasePrice': schoolOrder[key].BasePrice,     
             'ProductId': schoolOrder[key].ProductId,     
               'Rate': schoolOrder[key].Rate,
              'PricebookEntryId': schoolOrder[key].PricebookEntryId,
              'listPriceDiscount':schoolOrder[key].listPriceDiscount,
              'listAsset2Product':schoolOrder[key].listAsset2Product,
              'listPriceRateId':schoolOrder[key].listPriceRateId,            
             'QuantitySelectionType':schoolOrder[key].QuantitySelectionType,
             'listItemGroupComponent':schoolOrder[key].listItemGroupComponent,
             'ItemGroupComponent': schoolOrder[key].ItemGroupComponent,
             'ProductTYPE':schoolOrder[key].ProductTYPE,
             'ManualDiscount':schoolOrder[key].ManualDiscount,
             'listPriceDiscountType':schoolOrder[key].listPriceDiscountType,
             'listPriceProductType' :  schoolOrder[key].listPriceProductType,
             'Stocknumber':schoolOrder[key].Stocknumber
         });                        


        }
        console.log('**OrderItemId: In**'+OrderItemId+'*****'+schoolOrder[key].ItemGroupId);
        if(schoolOrder[key].ItemId ==OrderItemId || schoolOrder[key].ItemGroup == OrderItemId){
                 groupItem.push(index);
        }
        index++;
    }
    //schoolOrder.splice(index,1);

    for(var i = groupItem.length -1; i >= 0; i--){
         schoolOrder.splice(groupItem[i],1);
     }
      
    CurrenShipto.TotalAmount = 0;
    for(var key in schoolOrder){
         if(schoolOrder[key].ItemGroup== undefined){
             CurrenShipto.TotalAmount = CurrenShipto.TotalAmount + schoolOrder[key].Amount;
             schoolOrder[key].PriceDiscount = schoolOrder[key].PriceDiscount;   
             console.log('*CurrenShipto.TotalAmount**'+CurrenShipto.TotalAmount);
         }
     }    
    

 
	   component.set("v.ShoolOrderItemList",schoolOrder);
       component.set("v.SchoolProductList",SchoolProductList);

    
     
   }, 
    


    SaveProduct : function(component, event, helper) {
        var schoolOrder = component.get("v.ShoolOrderItemList");
        var totalOrderAmounts = component.get( 'v.TotalOrder');

        var fullOrderList = component.get("v.OrderItemList");
        console.log('**SP1**');
        var t1 = performance.now();
        
        

        for(var key in schoolOrder){
            console.log('**S1: maxQuantity**'+schoolOrder[key].maxQuantity);
            
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
     

    SaveProductCloseModal : function(component, event) {   
        
        /*
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        var schoolOrder = component.get("v.ShoolOrderItemList");
       // component.set("v.OrderItemList",schoolOrder);
       // $A.util.toggleClass(spinner, "slds-hide");
        

        var t2 = performance.now();

       var action = component.get('c.SaveProductCloseModal');
 
     
        action.setCallback(this, function(response) {
            
            var t3 = performance.now();
            console.log("SAVE SET TOOK: " + (t3 - t2) + " milliseconds.");
            
            var state = response.getState();
            console.log("state: " + state);
            component.set("v.OrderItemList",schoolOrder);
            $A.util.toggleClass(spinner, "slds-hide");
            if (state === "SUCCESS") {
                
                
            }
            else if (state === "INCOMPLETE") {
                
            }
            else if (state === "ERROR") {
                  
            }
        });
        $A.enqueueAction(action);
       
       */
        
      
    },
    
    closeAccOrd : function(component, event, helper){
        component.set("v.isOpenAccOrd",false);
        component.set("v.ShoolOrderItemList",[]);
        component.set("v.SchoolProductList",[]);
        component.set("v.CurrenOrderDisplay",[]);
    },
    
    handleShowList : function(component, event, helper){
        component.set( 'v.newRec', false);
        component.set( 'v.showList', true);
        helper.fetchAccountsUtil(component);
    },
    
    QuantityChangeforRate : function(component, event, helper){
        var ItemId = event.target.id;
        var newquantity = event.target.value;
        var CurrenOrderDisplay = component.get("v.CurrenOrderDisplay");
        
        var totalOrderAmounts = component.get( 'v.TotalOrder');
        
        var schoolOrder = component.get("v.ShoolOrderItemList");
        var fullOrderList = component.get("v.OrderItemList"); 
        var MaxQuantity = null;
        var TotalShipto;
        var TotalOrder; 
        
        newquantity = parseFloat(newquantity).toFixed(0);
        
        
        if(newquantity>=1){
            
            CurrenOrderDisplay.TotalAmount =0;
        
            
                totalOrderAmounts.TotalAmount=0; 
                
                var ItemGroupTotalAmount=0;
                var ItemGroupUnitPrice=0;
                
                var NegativeNSPrice = false;

                for(var key in fullOrderList){            
                    
                    
                    console.log('**Order: ItemId **'+fullOrderList[key].ItemId);
                    console.log('**ItemId: **'+ItemId);

                    if((fullOrderList[key].ItemId == ItemId || fullOrderList[key].ItemGroup == ItemId) ){
                        console.log('**maxQuantity: **'+fullOrderList[key].maxQuantity);


                        if(fullOrderList[key].maxQuantity == null || fullOrderList[key].maxQuantity == undefined || newquantity <= fullOrderList[key].maxQuantity){



                                    //fullOrderList[key].DiscountAmount = newquantity * (fullOrderList[key].UnitPrice - fullOrderList[key].ListPrice);
                                    fullOrderList[key].UnitPrice = fullOrderList[key].BasePrice;
                                    fullOrderList[key].STDPrice = fullOrderList[key].BasePrice;

                                    var tmpQuantity;
                                    if(fullOrderList[key].ItemGroup == ItemId){
                                        tmpQuantity = newquantity * fullOrderList[key].ComponentQuantity;
                                    }
                                    else{
                                        tmpQuantity = newquantity;  
                                    }

                                    if(fullOrderList[key].DiscountOption=='One-Off Amount' || fullOrderList[key].DiscountOption=='Recurring Amount'){
                                        
                                        fullOrderList[key].UnitPrice = fullOrderList[key].STDPrice-fullOrderList[key].DiscountAmount;
                                        fullOrderList[key].Amount = tmpQuantity * parseFloat(fullOrderList[key].UnitPrice).toFixed(2);

                                        if(fullOrderList[key].Amount < 0){
                                            fullOrderList[key].DiscountAmount = 0;
                                            fullOrderList[key].UnitPrice = fullOrderList[key].STDPrice;
                                            fullOrderList[key].Amount = tmpQuantity * parseFloat(fullOrderList[key].UnitPrice).toFixed(2);
                                            NegativeNSPrice = true;
                                        }
                                        
                                    }
                                    else if(fullOrderList[key].DiscountOption=='One-Off Amount (Subtotal)'){
                                        fullOrderList[key].Amount = parseFloat((tmpQuantity * fullOrderList[key].STDPrice)-fullOrderList[key].DiscountAmount).toFixed(2);
                                        console.log('**DiscountOption: **'+fullOrderList[key].Amount);
                                        
                                        fullOrderList[key].UnitPrice = fullOrderList[key].Amount/tmpQuantity;

                                        if(fullOrderList[key].Amount < 0){
                                            fullOrderList[key].DiscountAmount = 0;
                                            fullOrderList[key].UnitPrice = fullOrderList[key].STDPrice;
                                            fullOrderList[key].Amount = tmpQuantity * parseFloat(fullOrderList[key].UnitPrice).toFixed(2);
                                            NegativeNSPrice = true;
                                        }
                                    }
                                    else if(fullOrderList[key].DiscountOption=='One-Off Percentage' || fullOrderList[key].DiscountOption=='Recurring Percentage'){
                                        fullOrderList[key].UnitPrice = parseFloat(fullOrderList[key].STDPrice-(fullOrderList[key].STDPrice*(fullOrderList[key].DiscountPercent/100))).toFixed(2);
                                        fullOrderList[key].Amount = tmpQuantity * parseFloat(fullOrderList[key].UnitPrice).toFixed(2);
                                    }
                                    else{
                                        fullOrderList[key].Amount = parseFloat(tmpQuantity * parseFloat(fullOrderList[key].UnitPrice).toFixed(2)).toFixed(2);   
                                    }
                                    fullOrderList[key].NoDiscAmount = fullOrderList[key].Quantity * fullOrderList[key].STDPrice;
                                    console.log('**AFter Quantity change Amount **'+fullOrderList[key].Amount);
                                    
                                    fullOrderList[key].Quantity = newquantity;

                                 //   fullOrderList[key].ComponentQuantityDisplay = 'Product Value: ' +'€ ' + fullOrderList[key].ComponentQuantity * newquantity * fullOrderList[key].Amount;
                                    fullOrderList[key].ComponentQuantityFinal = (fullOrderList[key].ComponentQuantity * newquantity);

                                 //   fullOrderList[key].ComponentQuantityTitle = 'Pack quantity: '+ fullOrderList[key].ComponentQuantityFinal;

                                    if(fullOrderList[key].ItemGroup == ItemId){
                                        fullOrderList[key].Quantity = fullOrderList[key].ComponentQuantityFinal;
                                        //fullOrderList[key].ComponentQuantityFinal = newquantity;
                                    }

                                    


                                    fullOrderList[key].IsEdited=true;

                                //  console.log('**ProductName: **'+fullOrderList[key].ProductName + '**Amount: **' + fullOrderList[key].Amount);

                                }
                                else{

                                    MaxQuantity = fullOrderList[key].maxQuantity;
                                    break; 
                                } 

                                if(fullOrderList[key].ItemGroup== undefined){
                                    totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
                                }   
                
                    

                                //   console.log('**Prod: Item Group**'+ fullOrderList[key].ItemGroup);
                                //   console.log('**Prod: ID**'+ fullOrderList[key].ItemId);
                                    
                                    
                                    if(fullOrderList[key].ItemGroup == ItemId){
                                    
                                        ItemGroupTotalAmount = parseFloat(ItemGroupTotalAmount) + parseFloat(fullOrderList[key].Amount);
                                        ItemGroupUnitPrice =  parseFloat(ItemGroupUnitPrice) + parseFloat(fullOrderList[key].UnitPrice);
                                    //   console.log('**Unit Price: **'+fullOrderList[key].UnitPrice);
                                    }
                                    

                    }   
                            
                }
                if(MaxQuantity == null){
                          
                        console.log('**ItemGroupTotalAmount : **'+ItemGroupTotalAmount );
                        if(ItemGroupTotalAmount > 0){
                            totalOrderAmounts.TotalAmount=0;
                            for(var key in fullOrderList){ 

                                if((fullOrderList[key].ItemId == ItemId) ){
                                    fullOrderList[key].Amount = ItemGroupTotalAmount;
                                    fullOrderList[key].UnitPrice = ItemGroupUnitPrice;
                                }
                                if(fullOrderList[key].ItemGroup== undefined){
                                    totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
                                }
                            }        
                        }


                        component.set( 'v.TotalOrder', totalOrderAmounts);
                        var PricingMethod = component.get('v.PricingMethod');
                        console.log('**OrderProductQuantity**'+PricingMethod);
                        var varItemId = [];
                        varItemId[0] = ItemId;        
                        helper.UpdateListPriceDiscount(component,'Existing',varItemId,PricingMethod,fullOrderList);

                        if(NegativeNSPrice == true){
                            alert('Discount Amount was greater than Line Amount. Please enter a new discount');
                        }
                }   
                else{
                    component.set("v.ShoolOrderItemList",schoolOrder);
                    component.set("v.OrderItemList",fullOrderList);    
                    alert('This product has maximum quantity of: ' + MaxQuantity+': please select correct quantity');
                } 

            }
            else{
                component.set("v.ShoolOrderItemList",schoolOrder);
                component.set("v.OrderItemList",fullOrderList);
            }    
    },
     
    
    
    ManualDiscount : function(component, event, helper) {
        
        console.log('**Manual Discount 1***');

        var schoolOrder = component.get("v.ShoolOrderItemList");
        var fullOrderList = component.get("v.OrderItemList"); 
        var ItemId = event.target.id;        
        var DiscountOption = event.target.value;       
        var CurrenOrderDisplay = component.get("v.CurrenOrderDisplay");
        
        var totalOrderAmounts = component.get( 'v.TotalOrder');
         
        console.log('**Manual Discount 2***');

        totalOrderAmounts.TotalAmount=0; CurrenOrderDisplay.TotalAmount =0;
        

        var ItemGroupTotal=0;         
        var ItemGroupUnitPrice=0;
        var ItemGroup;

        for(var key in fullOrderList){            
             
            if(fullOrderList[key].ItemId == ItemId){
                if(fullOrderList[key].ItemGroup == undefined){
                    ItemGroup=ItemId;
                }   
                else{
                    ItemGroup = fullOrderList[key].ItemGroup;
                }
                
            }
        }       
        ItemGroupTotal=0;         
        ItemGroupUnitPrice=0;
        for(var key in fullOrderList){            
             
            if(fullOrderList[key].ItemId == ItemId){
                fullOrderList[key].IsEdited = true;
             
             if(DiscountOption == 'One-Off Percentage'){
                fullOrderList[key].DiscountOption = DiscountOption;
                fullOrderList[key].DiscountPercentShow=true; 
                fullOrderList[key].DiscountValueShow=false;  
            }
            else if(DiscountOption== 'Recurring Percentage'){
                fullOrderList[key].DiscountOption = DiscountOption;
                fullOrderList[key].DiscountPercentShow=true; 
                fullOrderList[key].DiscountValueShow=false;
            }
            else if(DiscountOption== 'One-Off Amount'){
                fullOrderList[key].DiscountOption = DiscountOption;
                fullOrderList[key].DiscountValueShow=true;
                fullOrderList[key].DiscountPercentShow=false;
            }
            else if(DiscountOption== 'One-Off Amount (Subtotal)'){
                fullOrderList[key].DiscountOption = DiscountOption;
                fullOrderList[key].DiscountValueShow=true;
                fullOrderList[key].DiscountPercentShow=false;
            }
            
            else if(DiscountOption== 'Recurring Amount'){
                fullOrderList[key].DiscountOption = DiscountOption;
                fullOrderList[key].DiscountValueShow=true;
                fullOrderList[key].DiscountPercentShow=false;
            }
           else{
               fullOrderList[key].DiscountOption = '--None--'; 
               fullOrderList[key].DiscountPercentShow=false;
               fullOrderList[key].DiscountValueShow=false;    
           }
               fullOrderList[key].PriceDiscount = fullOrderList[key].PriceDiscount;
               
               fullOrderList[key].DiscountAmount = 0;
               fullOrderList[key].DiscountPercent = 0; 
               fullOrderList[key].UnitPrice=   fullOrderList[key].STDPrice;
               
               console.log('**STDPrice**'+ fullOrderList[key].STDPrice);

               if(fullOrderList[key].ItemGroup != null){ 
                    fullOrderList[key].Amount = fullOrderList[key].STDPrice*(fullOrderList[key].Quantity/fullOrderList[key].ComponentQuantity);
               }
               else{
                    fullOrderList[key].Amount = fullOrderList[key].STDPrice*fullOrderList[key].Quantity;
               }    
               //
               console.log('**Amount**'+ fullOrderList[key].Amount);

               console.log('**ComponentQuantity**'+ fullOrderList[key].ComponentQuantity);
            }
            if(fullOrderList[key].ItemGroup == ItemGroup ){
                
                if(fullOrderList[key].ItemId == ItemId ){
                    fullOrderList[key].IsEdited = true;
                    console.log('**ComponentQuantity 2**'+ fullOrderList[key].ComponentQuantity);
                  //   fullOrderList[key].Amount = fullOrderList[key].STDPrice * fullOrderList[key].Quantity;
                  //  fullOrderList[key].Amount = fullOrderList[key].STDPrice * fullOrderList[key].ComponentQuantity;
                  if(fullOrderList[key].ItemGroup != null){ 
                        fullOrderList[key].Amount = fullOrderList[key].STDPrice*(fullOrderList[key].Quantity);
                   }
                   else{
                     fullOrderList[key].Amount = fullOrderList[key].STDPrice*fullOrderList[key].Quantity;
                   }   
                    
                    fullOrderList[key].UnitPrice=   fullOrderList[key].STDPrice;   
                }
                
                
                ItemGroupTotal = parseFloat(fullOrderList[key].Amount) + parseFloat(ItemGroupTotal);               
                ItemGroupUnitPrice = parseFloat(fullOrderList[key].UnitPrice * fullOrderList[key].ComponentQuantity) + parseFloat(ItemGroupUnitPrice);
                console.log('**ItemGroupTotal**'+ ItemGroupTotal);           
            }
            
           // totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
        }
        for(var key in fullOrderList){

            if(ItemGroupTotal>0 && fullOrderList[key].ItemGroup== undefined && fullOrderList[key].ItemId == ItemGroup ){
                fullOrderList[key].IsEdited = true;
              fullOrderList[key].Amount=ItemGroupTotal;              
              fullOrderList[key].UnitPrice= ItemGroupUnitPrice;              
              totalOrderAmounts.TotalAmount = parseFloat(totalOrderAmounts.TotalAmount) + parseFloat(fullOrderList[key].Amount);
              console.log('**totalOrderAmounts.TotalAmount**'+ totalOrderAmounts.TotalAmount);
            }
            else if(fullOrderList[key].ItemGroup== undefined){
                

              totalOrderAmounts.TotalAmount = parseFloat(totalOrderAmounts.TotalAmount) + parseFloat(fullOrderList[key].Amount);
              
            } 
             
            

        }
      
        

        component.set("v.CurrenOrderDisplay",CurrenOrderDisplay);
        component.set( 'v.TotalOrder', totalOrderAmounts);
        component.set("v.ShoolOrderItemList",schoolOrder);
    	component.set("v.OrderItemList",fullOrderList); 
    },
    ManualDiscountPercent: function(component, event, helper) {
      
        var schoolOrder = component.get("v.ShoolOrderItemList");
        var fullOrderList = component.get("v.OrderItemList"); 
        
        var CurrenOrderDisplay = component.get("v.CurrenOrderDisplay");
        var totalOrderAmounts = component.get( 'v.TotalOrder');
        
        var ItemId = event.target.id;
    	var DiscountPercent = event.target.value; 
        
        var ItemGroupTotal=0;         
        var ItemGroupUnitPrice=0;
        var ItemGroup;
        DiscountPercent = parseFloat(DiscountPercent).toFixed(2);
        if(DiscountPercent >= 0 && DiscountPercent <=100){ 
                        for(var key in fullOrderList){            
                            
                            if(fullOrderList[key].ItemId == ItemId){
                                ItemGroup = fullOrderList[key].ItemGroup;
                            }
                        }    

                        totalOrderAmounts.TotalAmount=0; CurrenOrderDisplay.TotalAmount =0;

                        for(var key in fullOrderList){
                            
                            if(fullOrderList[key].ItemId == ItemId){
                                
                                fullOrderList[key].IsEdited = true;

                                fullOrderList[key].DiscountPercent = DiscountPercent;
                                
                                fullOrderList[key].DiscountAmount = 0;
                                fullOrderList[key].UnitPrice = parseFloat(fullOrderList[key].STDPrice - (fullOrderList[key].STDPrice *(DiscountPercent/100))).toFixed(2);
 
                                console.log('**Prod: Item Group**'+ fullOrderList[key].ItemGroup);
                                if(fullOrderList[key].ItemGroup != null){ 
                                    fullOrderList[key].Amount = fullOrderList[key].UnitPrice *(fullOrderList[key].Quantity);
                               }
                               else{
                                    fullOrderList[key].Amount =  fullOrderList[key].UnitPrice * fullOrderList[key].Quantity;
                               }
                            }

 
                            if((fullOrderList[key].ItemGroup == ItemGroup && ItemGroup != undefined) || fullOrderList[key].ItemGroup == ItemId){                               
                                ItemGroupTotal = parseFloat(fullOrderList[key].Amount) + parseFloat(ItemGroupTotal);               
                                ItemGroupUnitPrice = parseFloat(fullOrderList[key].UnitPrice * fullOrderList[key].ComponentQuantity) + parseFloat(ItemGroupUnitPrice);  
                            }
                         
                        }

            
                        for(var key in fullOrderList){

                            if(ItemGroupTotal>0 && fullOrderList[key].ItemGroup== undefined && fullOrderList[key].ItemId == ItemGroup){

                                console.log('**Main: UnitPrice**'+ ItemGroupUnitPrice); 

                                fullOrderList[key].IsEdited = true;
                                fullOrderList[key].Amount=ItemGroupTotal;              
                                fullOrderList[key].UnitPrice= ItemGroupUnitPrice;              
                                totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
                            }
                            else if(fullOrderList[key].ItemGroup== undefined){
                                totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
                            } 
                            
                                      
                        }
        


                        component.set("v.CurrenOrderDisplay",CurrenOrderDisplay);
                        component.set( 'v.TotalOrder', totalOrderAmounts);
                }                
                        component.set("v.ShoolOrderItemList",schoolOrder); 
                        component.set("v.OrderItemList",fullOrderList);
            

    },
    AllDiscountPercent: function(component, event, helper) {
      
         
        var fullOrderList = component.get("v.OrderItemList"); 
        
        var ItemGroupTotal = component.get("v.VarMap"); 
        
        var totalOrderAmounts = component.get( 'v.TotalOrder');
        
        
    	var DiscountPercent = component.find("AllDiscount").get("v.value");
        
        
        DiscountPercent = parseFloat(DiscountPercent).toFixed(2);
        
        if(DiscountPercent >= 0 && DiscountPercent <=100){ 
                        

                        totalOrderAmounts.TotalAmount=0;  
                        var HasItemGroups = false;

                        for(var key in fullOrderList){

                            console.log('*AllDiscountPercent: ItemGroup1**'+fullOrderList[key].ItemGroup);

                         //   console.log('*AllDiscountPercent: ItemGroupComponent**'+ fullOrderList[key].ItemGroupComponent);
                         fullOrderList[key].IsEdited = true;
                         
                            if(fullOrderList[key].ItemGroupComponent == false || fullOrderList[key].ItemGroupComponent == undefined){// && fullOrderList[key].ItemGroup==undefined ){
                                
                                fullOrderList[key].DiscountPercent = DiscountPercent;
                                fullOrderList[key].DiscountPercentShow=true; 
                                fullOrderList[key].DiscountValueShow=false; 
                                fullOrderList[key].DiscountAmount = 0;
                                fullOrderList[key].DiscountOption = 'One-Off Percentage';                                                        
                                
                                if(fullOrderList[key].ItemGroupComponent == false){
                                    fullOrderList[key].UnitPrice = parseFloat(fullOrderList[key].STDPrice - (fullOrderList[key].STDPrice *(DiscountPercent/100))).toFixed(2);
                                    fullOrderList[key].Amount =  fullOrderList[key].UnitPrice * fullOrderList[key].Quantity;                             
                                }
                                else if(fullOrderList[key].ItemGroupComponent == undefined){
                                    HasItemGroups = true;
                                    fullOrderList[key].UnitPrice = parseFloat(fullOrderList[key].STDPrice - (fullOrderList[key].STDPrice *(DiscountPercent/100))).toFixed(2);
                                    fullOrderList[key].Amount =  fullOrderList[key].UnitPrice * fullOrderList[key].ComponentQuantityFinal;  
                                    
                                  //  console.log('*AllDiscountPercent: ItemGroup**'+fullOrderList[key].ItemGroup);
                                    
                                    if(ItemGroupTotal[fullOrderList[key].ItemGroup] == undefined){
                                        ItemGroupTotal[fullOrderList[key].ItemGroup] = parseFloat(fullOrderList[key].UnitPrice);
                                    }
                                    else{
                                        ItemGroupTotal[fullOrderList[key].ItemGroup] = parseFloat(ItemGroupTotal[fullOrderList[key].ItemGroup]) + parseFloat(fullOrderList[key].UnitPrice);
                                    }
                                    
                                }
                                
                                totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
                            }
                            else if(fullOrderList[key].ItemGroup==undefined){

                                  
                               // fullOrderList[key].UnitPrice = parseFloat(fullOrderList[key].STDPrice - (fullOrderList[key].STDPrice *(DiscountPercent/100))).toFixed(2);
                               // fullOrderList[key].Amount =  fullOrderList[key].UnitPrice * fullOrderList[key].Quantity;  
                                //totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
                            }
                            
                        }   
                      //  console.log('*AllDiscountPercent: HasItemGroups**'+HasItemGroups);
                        if(HasItemGroups = true){

                            
                            for(var key in fullOrderList){
                             
                                console.log('*AllDiscountPercent: ItemGroup2**'+fullOrderList[key].ItemGroup);

                                if(fullOrderList[key].ItemGroup==undefined && ItemGroupTotal[fullOrderList[key].ItemId] != undefined){
                                    fullOrderList[key].UnitPrice = ItemGroupTotal[fullOrderList[key].ItemId];
                                    fullOrderList[key].Amount =  fullOrderList[key].UnitPrice * fullOrderList[key].Quantity; 
                                    fullOrderList[key].IsEdited = true; 
                                }

                            }  
                        }
                          

                        component.set("v.VarMap",[]); 
                        component.set( 'v.TotalOrder', totalOrderAmounts);
                        component.set("v.OrderItemList",fullOrderList);
        }                
                         
                        
            

    },
    
    ManualDiscountAmount: function(component, event, helper) {
    	var schoolOrder = component.get("v.ShoolOrderItemList");
        var fullOrderList = component.get("v.OrderItemList"); 
        var ItemId = event.target.id;
    	var DiscountAmount = event.target.value; 
        

        DiscountAmount = parseFloat(DiscountAmount).toFixed(2);

        if(DiscountAmount>0){

        

                        var CurrenOrderDisplay = component.get("v.CurrenOrderDisplay");
                        var totalOrderAmounts = component.get( 'v.TotalOrder');
                        
                        var ItemGroupTotal=0;         
                        var ItemGroupUnitPrice=0;
                        var ItemGroup;

                        for(var key in fullOrderList){            
                            
                            if(fullOrderList[key].ItemId == ItemId){
                                ItemGroup = fullOrderList[key].ItemGroup;
                            }
                        } 

                        totalOrderAmounts.TotalAmount=0; CurrenOrderDisplay.TotalAmount =0;
                        
                        for(var key in fullOrderList){
                            
                          //  console.log('**UnitPrice1**'+fullOrderList[key].UnitPrice); 
                            // console.log('**UnitPrice2**'+fullOrderList[key].UnitPrice); 
                            //  console.log('**Amount2**'+fullOrderList[key].Amount);
                            //  console.log('**Quantity2**'+fullOrderList[key].Quantity);
                            if(fullOrderList[key].ItemId == ItemId){
                                fullOrderList[key].IsEdited = true;
                                var tmpval;
                                if(fullOrderList[key].DiscountOption == 'One-Off Amount (Subtotal)'){
                                    
                    //                console.log('**tmpval**'+tmpval);
                    //                console.log('**DiscountAmount**'+DiscountAmount);
                                    console.log('**ItemGroup**'+fullOrderList[key].ItemGroup);
                                    if(fullOrderList[key].ItemGroup == null){
                                        tmpval = (fullOrderList[key].STDPrice*fullOrderList[key].Quantity) ;
                                        if(tmpval >= DiscountAmount){
                                            console.log('**tmpval1 **'+tmpval);
                                            
                                            
                                            fullOrderList[key].Amount = (fullOrderList[key].STDPrice*fullOrderList[key].Quantity) - DiscountAmount;
                                            console.log('**Amount **'+ fullOrderList[key].Amount);
                                            fullOrderList[key].UnitPrice =  (fullOrderList[key].Amount / fullOrderList[key].Quantity).toFixed(2);
                                            console.log('**UnitPrice **'+fullOrderList[key].UnitPrice);

                                            
                                            fullOrderList[key].Amount =  fullOrderList[key].UnitPrice * fullOrderList[key].Quantity;

                                            fullOrderList[key].DiscountAmount = DiscountAmount;
                                        }
                                        
                                    }    
                                    else if(fullOrderList[key].ItemGroup != undefined){ 
                                        tmpval = (fullOrderList[key].STDPrice*(fullOrderList[key].Quantity)) ;
                                        if(tmpval >= DiscountAmount){
                                            fullOrderList[key].Amount = (fullOrderList[key].STDPrice*(fullOrderList[key].Quantity)) - DiscountAmount;
                                            fullOrderList[key].UnitPrice =  fullOrderList[key].Amount / (fullOrderList[key].Quantity);
                                            fullOrderList[key].DiscountAmount = DiscountAmount;    
                                        }    
                                    }
                                    
                                }
                                else{
                                    console.log('**ItemGroup**'+fullOrderList[key].ItemGroup);
                                    if(fullOrderList[key].ItemGroup == undefined){ 
                                        tmpval = fullOrderList[key].STDPrice;
                                        if(tmpval >= DiscountAmount){
                                            console.log('**tmpval2 **'+tmpval);
                                            fullOrderList[key].UnitPrice = fullOrderList[key].STDPrice - DiscountAmount; 
                                            fullOrderList[key].Amount = fullOrderList[key].UnitPrice * fullOrderList[key].Quantity;
                                            fullOrderList[key].DiscountAmount = DiscountAmount;
                                        }
                                    }
                                    else if(fullOrderList[key].ItemGroup != undefined){
                                        tmpval = fullOrderList[key].STDPrice;
                                        if(tmpval >= DiscountAmount){
                                            fullOrderList[key].UnitPrice = fullOrderList[key].STDPrice - DiscountAmount; 
                                            fullOrderList[key].Amount = fullOrderList[key].UnitPrice * (fullOrderList[key].Quantity);
                                            fullOrderList[key].DiscountAmount = DiscountAmount;
                                        }
                                    }    
                                    
                                }
                            
                                
                            //    console.log('**UnitPrice2**'+fullOrderList[key].UnitPrice); 
                           //     console.log('**Amount2**'+fullOrderList[key].Amount);
                           //     console.log('**Quantity2**'+fullOrderList[key].Quantity);
                                
                                fullOrderList[key].DiscountPercent = 0;
                            // schoolOrder[key].DiscountOption = 'Value';


                            }
             //               console.log('**Prod: Item Group**'+ fullOrderList[key].ItemGroup);
              //              console.log('**Prod: ID**'+ fullOrderList[key].ItemId);
              //              console.log('**Prod: IG **'+ ItemGroup);

                            if((fullOrderList[key].ItemGroup == ItemGroup && ItemGroup != undefined) || fullOrderList[key].ItemGroup == ItemId){ //
                       //         console.log('**fullOrderList[key].UnitPrice3**'+fullOrderList[key].UnitPrice); 
                                
             //                   console.log('**Prod: IG 1**'+ItemGroupUnitPrice);
                                
                                ItemGroupTotal = parseFloat(fullOrderList[key].Amount) + parseFloat(ItemGroupTotal);               
                                ItemGroupUnitPrice = parseFloat(fullOrderList[key].UnitPrice * fullOrderList[key].ComponentQuantity) + parseFloat(ItemGroupUnitPrice); 
                //                console.log('**Prod: IG 2**'+ItemGroupUnitPrice);               
                            }

                            //totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;  
                        }
 
                        console.log('**ItemGroupTotal**'+ItemGroupTotal);
                        
                        
                        for(var key in fullOrderList){
                            
               //             console.log('**Main: Item Group**'+ fullOrderList[key].ItemGroup);
               //             console.log('**Main: ID**'+ fullOrderList[key].ItemId);
              //              console.log('**Main: IG **'+ ItemGroup);


                            if(ItemGroupTotal>0 && fullOrderList[key].ItemGroup== undefined && fullOrderList[key].ItemId == ItemGroup){

            //                    console.log('**Main: Unit**'+ ItemGroupUnitPrice);
                                fullOrderList[key].IsEdited = true;    
                                fullOrderList[key].Amount=ItemGroupTotal;              
                                    fullOrderList[key].UnitPrice= ItemGroupUnitPrice;              
                                    totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
                            }
                            else if(fullOrderList[key].ItemGroup== undefined ){
                                    totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
                            } 
                            
               //             console.log('**fullOrderList[key].listPriceRateId**'+ fullOrderList[key].listPriceRateId);           
                        }
                    

                


                        component.set("v.CurrenOrderDisplay",CurrenOrderDisplay);
                        component.set( 'v.TotalOrder', totalOrderAmounts); 
                        
        }    
        component.set("v.ShoolOrderItemList",schoolOrder); 
        component.set("v.OrderItemList",fullOrderList);             
    },

    ChangeOrderLineType: function(component, event, helper) {
        

        
                        var schoolOrder = component.get("v.ShoolOrderItemList");
                        var fullOrderList = component.get("v.OrderItemList"); 
                        
                        var CurrenOrderDisplay = component.get("v.CurrenOrderDisplay");
                        var totalOrderAmounts = component.get( 'v.TotalOrder');
                        
                        var ItemId = event.target.id;
                        var OrderLineType = event.target.value; 
                        
                        var selected;

                        totalOrderAmounts.TotalAmount=0; CurrenOrderDisplay.TotalAmount =0;


                      var curOrder =  component.get("v.curOrder");
                      
                       var blockchange =false;
                    
                     if(curOrder.Type == 'RegularOrder' && (OrderLineType =='Service' || OrderLineType =='Free')){

                            blockchange=true;
                            alert('These order line types cannot be mixed, create a separate order');
                     }
                     else if(curOrder.Type == 'FreeOrder' || curOrder.Type == 'ServiceOrder'){
                            
                            if(OrderLineType !='Service' && OrderLineType !='Free'){
                                blockchange=true;
                                alert('These order line types cannot be mixed, create a separate order');
                            }
                     }
                     


                     if(blockchange==false){

                        var CurOrderLineType;
                        var CustomerDiscountGroup;
                        for(var key in fullOrderList){
                            console.log('**ChangeOrderLineType OrdId**:'+fullOrderList[key].ItemId);
                            console.log('**ChangeOrderLineType Selected Item**:'+ItemId);

                            if(fullOrderList[key].ItemId == ItemId){
                                fullOrderList[key].IsEdited = true;
                               // ProductId = fullOrderList[key].ProductId;
                                for(var item in fullOrderList[key].listPriceDiscount){
                                    console.log('**CUS GRP**:'+fullOrderList[key].listPriceDiscount[item].CustomerDiscountGroup);

                                    if(OrderLineType == fullOrderList[key].listPriceDiscount[item].OrderLineType && fullOrderList[key].listPriceDiscount[item].CustomerDiscountGroup == fullOrderList[key].CustomerDiscountGroup && selected == false){
                                        CurOrderLineType = OrderLineType;
                                        CustomerDiscountGroup = fullOrderList[key].listPriceDiscount[item].CustomerDiscountGroup;
                                    }    
                                }    
        
                            }
                        }        
 
                     //  console.log('*CurOrderLineType**'+CurOrderLineType);
                     //  console.log('*CustomerDiscountGroup**'+CustomerDiscountGroup);

                        var NewRate;
                        var LPDID;
                       
               //                 console.log('**OUT LOOP2**');


                        for(var key in fullOrderList){
                            
                            if(fullOrderList[key].ItemId == ItemId || fullOrderList[key].ItemGroup == ItemId){
                //                console.log('**Before loop'+OrderLineType);
                                fullOrderList[key].PriceDiscount = OrderLineType;
                                fullOrderList[key].IsEdited = true;
                                selected = false;

                                console.log('*selected == false: '+fullOrderList[key].BasePrice);  
                                fullOrderList[key].UnitPrice = fullOrderList[key].BasePrice;
                                fullOrderList[key].STDPrice = fullOrderList[key].BasePrice; 
                                fullOrderList[key].PriceDiscount = OrderLineType; 
                                fullOrderList[key].listPriceRateId = null;

                                if(fullOrderList[key].PriceDiscount == 'Free' || fullOrderList[key].PriceDiscount =='Service'){

                                    fullOrderList[key].DiscountOption='--None--';
                                    fullOrderList[key].DiscountAmount = 0;
                                    fullOrderList[key].DiscountPercent = 0; 
                                    fullOrderList[key].DiscountValueShow = false;
                                    fullOrderList[key].DiscountPercentShow = false;
    
                                }
                                else{
                                    for(var item in fullOrderList[key].listPriceDiscount){

                                        
                                    
                    //                   console.log('**fullOrderList[key].ItemGroup**'+fullOrderList[key].ItemGroup);   
                    //                   console.log('**fullOrderList[key].ProductName**'+fullOrderList[key].ProductName );

                    //                    console.log('**RATE2** '+OrderLineType +'***'+fullOrderList[key].listPriceDiscount[item].OrderLineType +'**selected**'+selected);
                    //                    console.log('**LPD Customer grp** '+fullOrderList[key].listPriceDiscount[item].CustomerDiscountGroup +'**Account Customer grp*'+fullOrderList[key].CustomerDiscountGroup);
                                    
                                        if(fullOrderList[key].ItemGroup == undefined && OrderLineType == fullOrderList[key].listPriceDiscount[item].OrderLineType && fullOrderList[key].listPriceDiscount[item].CustomerDiscountGroup == fullOrderList[key].CustomerDiscountGroup && selected == false){
                                            console.log('*selected == true: '+fullOrderList[key].BasePrice);     
                                            selected = true;                 
                                            fullOrderList[key].STDPrice=fullOrderList[key].BasePrice - ((fullOrderList[key].listPriceDiscount[item].Discount/100) * fullOrderList[key].BasePrice);
                                            fullOrderList[key].UnitPrice=fullOrderList[key].STDPrice;
                                            
                                            fullOrderList[key].PriceDiscount = OrderLineType;                                       
                                            fullOrderList[key].listPriceRateId = fullOrderList[key].listPriceDiscount[item].LPDId;

                                            LPDID = fullOrderList[key].listPriceDiscount[item].LPDId;
                                            NewRate = fullOrderList[key].listPriceDiscount[item].Discount;

                //                           console.log('**fullOrderList[key].listPriceRateId'+fullOrderList[key].listPriceRateId); 
                                        }
    
                                        else if(selected == false){
                                        //   console.log('*selected == false: '+fullOrderList[key].BasePrice);  
                                        //    fullOrderList[key].UnitPrice = fullOrderList[key].BasePrice;
                                        //    fullOrderList[key].STDPrice = fullOrderList[key].BasePrice; 
                                        //    fullOrderList[key].PriceDiscount = OrderLineType; 
                                        //    fullOrderList[key].listPriceRateId = null;
                                        }

                                    }
                             //   
                                    if(fullOrderList[key].DiscountOption=='One-Off Amount' || fullOrderList[key].DiscountOption=='Recurring Amount'){
                                        fullOrderList[key].UnitPrice = fullOrderList[key].STDPrice - fullOrderList[key].DiscountAmount;
                                        fullOrderList[key].Amount = fullOrderList[key].Quantity * (fullOrderList[key].UnitPrice);  

                                    }
                                    else if(fullOrderList[key].DiscountOption=='One-Off Amount (Subtotal)'){
                                        fullOrderList[key].Amount = (fullOrderList[key].Quantity * fullOrderList[key].STDPrice)-fullOrderList[key].DiscountAmount;
                                        fullOrderList[key].UnitPrice = fullOrderList[key].Amount/fullOrderList[key].Quantity;
                                    }
                                    else if(fullOrderList[key].DiscountOption=='One-Off Percentage' || fullOrderList[key].DiscountOption=='Recurring Percentage'){
                                        fullOrderList[key].UnitPrice = fullOrderList[key].STDPrice-(fullOrderList[key].STDPrice*(fullOrderList[key].DiscountPercent/100));
                                        fullOrderList[key].Amount = fullOrderList[key].Quantity * fullOrderList[key].UnitPrice;
                                    }
                                    else{
                                        fullOrderList[key].Amount = fullOrderList[key].Quantity * fullOrderList[key].UnitPrice;   
                                    }
                                    fullOrderList[key].NoDiscAmount = fullOrderList[key].Quantity * fullOrderList[key].STDPrice;
                             //   }
                                
 
                                }
                            }
                            if(fullOrderList[key].ItemGroup == undefined){
                                totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount; 
                            }    
                    }


                    for(var key in fullOrderList){
                            
                        if(fullOrderList[key].ItemGroup == ItemId){

                            if(fullOrderList[key].PriceDiscount == 'Free' || fullOrderList[key].PriceDiscount =='Service'){

                                fullOrderList[key].DiscountOption='--None--';
                                fullOrderList[key].DiscountAmount = 0;
                                fullOrderList[key].DiscountPercent = 0; 
                                fullOrderList[key].DiscountValueShow = false;
                                fullOrderList[key].DiscountPercentShow = false;

                            }
                            else if(NewRate != undefined){ 

                  
           //                 console.log('**Step 1**');
                                    fullOrderList[key].STDPrice=fullOrderList[key].BasePrice - ((NewRate/100) * fullOrderList[key].BasePrice);
                                    fullOrderList[key].UnitPrice=fullOrderList[key].STDPrice;
           //                 console.log('**Step 2**');      
                                    fullOrderList[key].PriceDiscount = OrderLineType;                                       
                                    fullOrderList[key].listPriceRateId = LPDID;
                                    fullOrderList[key].IsEdited = true;
            //                console.log('**Step 3**');

                                    
                                    if(fullOrderList[key].DiscountOption=='One-Off Amount' || fullOrderList[key].DiscountOption=='Recurring Amount'){
                                        fullOrderList[key].Amount = fullOrderList[key].Quantity * (fullOrderList[key].UnitPrice);  
                                    }
                                    else if(fullOrderList[key].DiscountOption=='One-Off Amount (Subtotal)'){
                                        fullOrderList[key].Amount = (fullOrderList[key].Quantity * fullOrderList[key].STDPrice)-fullOrderList[key].DiscountAmount;
                                        fullOrderList[key].UnitPrice = fullOrderList[key].Amount/fullOrderList[key].Quantity;
                                    }
                                    else if(fullOrderList[key].DiscountOption=='One-Off Percentage' || fullOrderList[key].DiscountOption=='Recurring Percentage'){
                                        fullOrderList[key].UnitPrice = fullOrderList[key].STDPrice-(fullOrderList[key].STDPrice*(fullOrderList[key].DiscountPercent/100));
                                        fullOrderList[key].Amount = fullOrderList[key].Quantity * fullOrderList[key].UnitPrice;
                                    }
                                    else{
                                        fullOrderList[key].Amount = fullOrderList[key].Quantity * fullOrderList[key].UnitPrice;   
                                    }
                                    fullOrderList[key].NoDiscAmount = fullOrderList[key].Quantity * fullOrderList[key].STDPrice;
                                    fullOrderList[key].PriceDiscount = OrderLineType;
                                        
                        }  
                        
                    }  
                }   
                        component.set("v.CurrenOrderDisplay",CurrenOrderDisplay);
                        component.set( 'v.TotalOrder', totalOrderAmounts);
                       // component.set("v.ShoolOrderItemList",schoolOrder); 
                        component.set("v.OrderItemList",fullOrderList);
        
                        var PricingMethod = component.get('v.PricingMethod');
                       // if(PricingMethod !='AccountStudents'){ 
                            var varItemId = [];
                            varItemId[0] = ItemId;            
                            helper.UpdateListPriceDiscount(component,'Existing',varItemId,PricingMethod,fullOrderList);
                           
                      //  }
            }
            else{
                component.set("v.OrderItemList",fullOrderList);
            }

                               
    },

 
    DynamicSearchProductOnEnter : function(component, event, helper){
        
        var searchString = component.find("DynamicSearch").get("v.value");
        console.log('**searchString**'+searchString.length);
        if (event.which == 13 || searchString.length == 0){
            console.log('**Enter**');  
            
            //var action = component.get('c.DynamicSearchProduct');

            var action = component.get('c.DynamicSearchProductSOQL');
            $A.enqueueAction(action);
        }
        
    },    
    DynamicSearchProductSOQL : function(component, event, helper){
        
        var searchString = component.find("DynamicSearch").get("v.value");
        if(searchString.length > 2 || searchString.length == 0 ){
            var t0 = performance.now();
            
    
            component.set("v.isSpinner",true);

            /*List to exclude
            var schoolOrder = component.get("v.ShoolOrderItemList");
                 for(var key in schoolOrder){
               //     console.log('**Search2**');
                    OrderProdMap[schoolOrder[key].ProductId] = schoolOrder[key].ProductId;
                }  

            */

                console.log('**searchString**'+searchString);
            var action = component.get("c.loadProductsbySearch");
                var OrderId =  component.get("v.OrderId");
                var OrderItems = component.get("v.OrderItemList");
                var SelectedItems = component.get("v.ShoolOrderItemList");

                if(OrderItems[0] != undefined){
                    console.log('**OrderItems-ProductId**'+OrderItems[0].ProductId);
                }
                
                action.setParams({ 
                    "OrderItems" : OrderItems,
                    "SelectedItems":  SelectedItems,
                    "OrderId": OrderId,
                    "searchString": searchString
                });
                
                

                action.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log(state);
                    if (state === "SUCCESS") {
                        var returnValue = response.getReturnValue();
                        
                        component.set("v.SchoolProductList",returnValue);
                        var t1 = performance.now();
                        console.log("SOQL SEARCH took " + (t1 - t0) + " milliseconds.");
                        component.set("v.isSpinner",false);
                    }
                    else if (state === "INCOMPLETE") {
                        
                    }
                        else if (state === "ERROR") {
                            component.set("v.isSpinner",false);
                            var errors = response.getError();
                            if (errors) {
                                alert("Error message: " + errors[0].message);
                                if (errors[0] && errors[0].message) {
                                    console.log("Error message: " + errors[0].message);
                                    component.set("v.isSpinner",false);
                                }
                            } else {
                                component.set("v.isSpinner",false);
                                alert("Something went wrong: Please contact System Administrator");
                            }
                        }
                        else{


                        }
                });

                $A.enqueueAction(action);
        }        
        
       
    },



  
    
})