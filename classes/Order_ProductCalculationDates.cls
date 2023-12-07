public with sharing class Order_ProductCalculationDates {
    
    @invocablemethod
    Public static void ProductCalculationDates(List<OrderItem> lstOrderItem){

       // OrderItem[] lstOrderItem = [Select id,OrderId,Product2Id,StartDate__c,ServiceDate,OrderItemEndDate__c,EndDate,TrialStartDate__c,TrialEndDate__c from OrderItem where id in:OrdeItemId];
        
        Set<String> Set_Order = new Set<String>();
        for(OrderItem item:lstOrderItem){
            
            Set_Order.add(item.OrderId);
        } 
        
        Order[] CurOrder = [Select EffectiveDate,ShipByDate__c,Type from Order where id in: Set_Order];
        UpdateOrderItemDate(lstOrderItem,CurOrder);
       // ProductCalculationDatesTrigger(lstOrderItem);

    }

    public static List<OrderItem> UpdateOrderItemDate(List<OrderItem> lstOrderItem, List<Order> CurOrder){ //List<string> OrderId,
        
        Map<String,Date> Map_EffectiveDate = new Map<String,Date>();
        Map<String,Date> Map_ShipByDate = new Map<String,Date>();
        Map<String,String> Map_OrderType = new Map<String,String>();

         for(Order  ord:CurOrder){
            
             Map_EffectiveDate.put(ord.id,ord.EffectiveDate); 
             Map_ShipByDate.put(ord.id,ord.ShipByDate__c);
             Map_OrderType.put(ord.id,ord.Type);

             system.debug('***Dates :EffectiveDate'+ord.EffectiveDate);
                     system.debug('***Dates :ShipByDate__c'+ord.ShipByDate__c);
                     system.debug('***Dates :ord.id'+ord.id);
         }
                 
 
                 Set<String> Set_Products = new Set<String>();
 
                 for(OrderItem item:lstOrderItem){
                     Set_Products.add(item.Product2Id);
                 }    
 
 
                 Product2[] lstProduct = [Select id,FreeFromDate__c,FixedStartDate__c,StartDate__c,LicenseDuration__c from Product2 where id in: Set_Products];
 
                 Map<String,Date> Map_FreeFromDate = new Map<String,Date>();
                 Map<String,Date> Map_FixedStartDate = new Map<String,Date>();
                 Map<String,Date> Map_StartDate = new Map<String,Date>();
                 Map<String,Decimal> Map_LicenseDuration = new Map<String,Decimal>();
 
                 Date FixedStartDate;
                 Date FreeFromDate;
                 for(Product2 prod:lstProduct){
                     
                     if(prod.FixedStartDate__c != null){
                         FixedStartDate = date.newinstance(system.today().year(), prod.FixedStartDate__c.month(), prod.FixedStartDate__c.day());
                         Map_FixedStartDate.put(prod.id,FixedStartDate);
                     }
                     
                     if(prod.FreeFromDate__c != null){
                        FreeFromDate = date.newinstance(system.today().year(), prod.FreeFromDate__c.month(), prod.FreeFromDate__c.day());
                        Map_FreeFromDate.put(prod.id,FreeFromDate);
                     }

                     Map_StartDate.put(prod.id,prod.StartDate__c );
                     if(prod.LicenseDuration__c != null){
                         Map_LicenseDuration.put(prod.id,decimal.valueof(prod.LicenseDuration__c));
                     }        
                     
                 }
 
 
 
                 for(OrderItem item:lstOrderItem){

                    if(!item.Order.Pricebook2.Name.contains('Professional') || item.StartDate__c == null ){

                            if(Map_OrderType.get(item.OrderId) !='RenewalOrder' || (Map_OrderType.get(item.OrderId) =='RenewalOrder' && item.StartDate__c ==null )){

                            
                                Date EndDate=null;
                                
                                    item.StartDate__c = Map_ShipByDate.get(item.OrderId);
                                
                                    item.ServiceDate = Map_ShipByDate.get(item.OrderId);
                                
                                
                        
                                system.debug('***Dates :FixedStartDate'+Map_FixedStartDate);
                                system.debug('***Dates :LicenseDuration'+Map_LicenseDuration);
                                system.debug('***Dates :FreeFromDate'+Map_FreeFromDate);
            
                                    if (Map_FixedStartDate.get(item.Product2Id) != NULL 
                                        && Map_LicenseDuration.get(item.Product2Id) != null 
                                        && Map_FixedStartDate.get(item.Product2Id) > item.StartDate__c
                                        ){ 
            
                                        Date StartDate  = date.newinstance(system.today().year(), Map_FixedStartDate.get(item.Product2Id).month(), Map_FixedStartDate.get(item.Product2Id).day());      
                                        EndDate = date.newinstance(StartDate.year(), StartDate.month()+integer.valueof(Map_LicenseDuration.get(item.Product2Id)), StartDate.day());  

                                    
                                        system.debug('***Item Dates :ONE'+StartDate);
                                            
                                        // EndDate = date.newinstance(StartDate.year()+1, StartDate.month(), StartDate.day());      
                                        
                                        item.StartDate__c = StartDate;
                                        item.ServiceDate = StartDate;
                        
                                        item.OrderItemEndDate__c = EndDate-1;  
                                        item.EndDate = EndDate-1;   

                                        if(Map_FreeFromDate.get(item.Product2Id) != null){

                                            if(item.StartDate__c == Map_ShipByDate.get(item.OrderId)){
                                                item.TrialStartDate__c = null; 
                                                item.TrialEndDate__c = null;
                                            }
                                            else if(Map_FreeFromDate.get(item.Product2Id) < Map_ShipByDate.get(item.OrderId)){
                                                item.TrialStartDate__c = Map_ShipByDate.get(item.OrderId); 
                                                item.TrialEndDate__c = item.StartDate__c - 1;
                                            }
                                            else{
                                                item.TrialStartDate__c = Map_FreeFromDate.get(item.Product2Id); 
                                                item.TrialEndDate__c = item.StartDate__c - 1;
                                            }
                                        }
                                        else{
                                            item.TrialStartDate__c = null; 
                                            item.TrialEndDate__c = null;
                                        }
                                        
                                    } 
                                    // Checking if the date is before the month in the current year then use current year else use next year
                                    else if(Map_FixedStartDate.get(item.Product2Id) != NULL && Map_LicenseDuration.get(item.Product2Id) != null && Map_FixedStartDate.get(item.Product2Id) < item.StartDate__c){ //(Map_FreeFromDate.get(item.Product2Id) == null ||  Map_FreeFromDate.get(item.Product2Id) > system.today()) ){ //&& Map_StartDate.get(item.Product2Id) != null
                                        
                                        Date StartDate  = date.newinstance(system.today().year(), Map_FixedStartDate.get(item.Product2Id).month(), Map_FixedStartDate.get(item.Product2Id).day());      
                                        EndDate = date.newinstance(StartDate.year(), StartDate.month()+integer.valueof(Map_LicenseDuration.get(item.Product2Id)), StartDate.day());  

                                        system.debug('***Item Dates :TWO'+ EndDate);
                        
                                        StartDate = date.newinstance(StartDate.year()+1, StartDate.month(), StartDate.day());
                                            EndDate = date.newinstance(EndDate.year()+1, EndDate.month(), EndDate.day());
                                            item.StartDate__c = StartDate;
                                            item.ServiceDate = StartDate;
                                            
                                            item.OrderItemEndDate__c = EndDate-1;
                                            item.EndDate = EndDate-1;

                                            if(Map_FreeFromDate.get(item.Product2Id) != null){                                  
                                                    item.TrialStartDate__c = date.newinstance(Map_FreeFromDate.get(item.Product2Id).year()+1, Map_FreeFromDate.get(item.Product2Id).month(), Map_FreeFromDate.get(item.Product2Id).day()); 
                                                    item.TrialEndDate__c = item.StartDate__c - 1;
                                            }
                                            else{
                                                item.TrialStartDate__c = null; 
                                                item.TrialEndDate__c = null;
                                            }

                                        
                                    } 
                                    
                                    else if(Map_FixedStartDate.get(item.Product2Id) == NULL && Map_LicenseDuration.get(item.Product2Id) != null && item.StartDate__c != null){
                        
                                        system.debug('***Item Dates :THREE'+Map_ShipByDate.get(item.OrderId));
                                        EndDate = date.newinstance(item.StartDate__c.year(), item.StartDate__c.month()+integer.valueof(Map_LicenseDuration.get(item.Product2Id)), item.StartDate__c.day());  
                                    
                                        item.OrderItemEndDate__c = EndDate-1; 
                                        item.EndDate = EndDate-1;  
                        
                                        item.TrialStartDate__c = null; 
                                        item.TrialEndDate__c = null; 
                                        
                                    }    
                                    } 
                        }

                 } 
         
         
           return  lstOrderItem;
 
         }




}