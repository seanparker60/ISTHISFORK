public with sharing class Order_OrderInsertQueueable implements Queueable {
    
   // Private List<Order_ProductSelectController.OrderLineItem> OrderItems;
   // Private List<OrderItem> lstOrderItem;
   //List<Order_ProductSelectController.OrderLineItem> OrderItems,
    Private String ContractId;
    Private String OrderId; 
    Private Decimal TotalNumberofStudents;
    Private Boolean AddShiptos;
    Private List<Account> AccountbyShipto;

    public Order_OrderInsertQueueable(String ContractId,String OrderId, Decimal TotalNumberofStudents,Boolean AddShiptos,List<Account> AccountbyShipto) {
      //  this.OrderItems = OrderItems;
        this.OrderId = OrderId;
        this.TotalNumberofStudents = TotalNumberofStudents;
        this.AccountbyShipto = AccountbyShipto;
        this.AddShiptos = AddShiptos;
        this.ContractId = ContractId;
    }

    public void execute(System.QueueableContext qc) {

        Contract[] Contract = [Select AccountId,NumberofUsers__c,SoldUsers__c,StartDate,Pricebook2Id,PaymentMethod__c,ShippingCostMethod__c,PricingMethod__c,defaultBilltoAccount__c from Contract where id =: ContractId];
        
        system.debug('**OrderItems 1**');

        //GET Subsidoaries
        if(Contract.size()>0){    
            /*
            if(Contract[0].SoldUsers__c == null){
              //  Contract[0].SoldUsers__c =TotalNumberofStudents;                
            }
            update Contract;
            */
        }

        Id NewOrderId = OrderId;
         

        Set<String> Set_Sub = new Set<String>();
        Map<String,String> Map_Sub = new Map<String,String>(); 
        Map<String,String> Map_Netsuite = new Map<String,String>(); 
        
        Order[] CurOrder = [Select AccountSubsidiary__c,Pricebook2Id,ValidateItemHfdstructuur__c, Pricebook2.Name, MultipleShippingLocations__c,Shipto__r.NetsuiteInternalId__c ,Account.NetsuiteInternalId__c,OperatingCompany__c,Source__c,InsertProductSelector__c,CustomerReference__c,NumberOfStudents__c,Billto__c,ContractId,EffectiveDate,ShipByDate__c from Order where id=: NewOrderId];
        
        List<Id> OrderId = new List<Id>();
        if(CurOrder.size()>0){
            OrderId.add(CurOrder[0].Id);
        }
        
        
        OrderItem[]   lst_OrdItem = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);
        
        Map<String,Date> Map_FixedStartDate = new Map<String,Date>();
        Map<String,Date> Map_FreeFromDate = new Map<String,Date>();
        Date FixedStartDate;
        Date FreeFromDate;
        Integer year;
        for(OrderItem item:lst_OrdItem){
            if(item.Product2.FixedStartDate__c != null){

                year = item.Order.ShipbyDate__c.year();

                FixedStartDate = date.newinstance(year, item.Product2.FixedStartDate__c.month(), item.Product2.FixedStartDate__c.day());                
                Map_FixedStartDate.put(item.OrderId,FixedStartDate);

                FreeFromDate = date.newinstance(system.today().year()+1, 1, 1);
                Map_FreeFromDate.put(item.OrderId,FreeFromDate);             
                
            }
            system.debug('**B2B**:FreeFromDate 1**'+ FreeFromDate);
            system.debug('**B2B**:FixedStartDate 1**'+ FixedStartDate);

            if(item.Product2.FreeFromDate__c != null && item.Product2.FixedStartDate__c != null){
                FreeFromDate = date.newinstance(system.today().year()+1, item.Product2.FreeFromDate__c.month(), item.Product2.FreeFromDate__c.day());
                Map_FreeFromDate.put(item.OrderId,FreeFromDate);
                system.debug('**B2B**:year 1**'+ year);
                
                if(item.Order.ShipbyDate__c < FreeFromDate && year>system.today().year()){
                    year -= 1;
                    FixedStartDate = date.newinstance(year, item.Product2.FixedStartDate__c.month(), item.Product2.FixedStartDate__c.day());                
                    Map_FixedStartDate.put(item.OrderId,FixedStartDate);
                }
                system.debug('**B2B**:year 2**'+ year);

                
                
            }

            system.debug('**B2B**:FreeFromDate 2**'+ FreeFromDate);
            system.debug('**B2B**:FixedStartDate 2**'+ FixedStartDate);
        }    


        List<Map<String,String>> lst_AccSubMaps = new List<Map<String,String>>();
        if(Contract.size()>0){
            Set_Sub.add(Contract[0].defaultBilltoAccount__c);

            lst_AccSubMaps = Order_ProductSelectController.returnAccountSubsidiary(Set_Sub);
        }
        else if(CurOrder.size()>0){
            Set_Sub.add(CurOrder[0].Billto__c);
            
            lst_AccSubMaps = Order_ProductSelectController.returnAccountSubsidiary(Set_Sub);
            if(CurOrder[0].ContractId != null){
                ContractId = CurOrder[0].ContractId;
            }
        }    
        
        system.debug('**CurOrder**'+CurOrder);
        system.debug('**lst_AccSubMaps**'+lst_AccSubMaps);
        Map_Sub = lst_AccSubMaps[0];
        Map_Netsuite = lst_AccSubMaps[1];


        
        Boolean varNewOrder=false;
        Order NewOrder;
        if(NewOrderId == null){ 
            NewOrder = new Order();
            if(ContractId != null){
                NewOrder.ContractId = ContractId;
                NewOrder.AccountId = Contract[0].AccountId;
                NewOrder.EffectiveDate = Contract[0].StartDate;
                NewOrder.Pricebook2Id = Contract[0].Pricebook2Id;
                NewOrder.Status = 'Draft';
                NewOrder.PaymentMethod__c = Contract[0].PaymentMethod__c;
                NewOrder.PricingMethod__c = Contract[0].PricingMethod__c;
                NewOrder.Billto__c = Contract[0].defaultBilltoAccount__c; 
                NewOrder.AccountSubsidiary__c =  Map_Sub.get(Contract[0].defaultBilltoAccount__c);
                NewOrder.NumberOfStudents__c = TotalNumberofStudents;
                if(NewOrder.Source__c == null){
                    NewOrder.Source__c ='B2B Salesforce';
                }
                
                NewOrder.ShipByDate__c = Contract[0].StartDate; //system.today(); 
                NewOrder.PaymentStatus__c = 'payment_pending'; 
                NewOrder.PaymentMethodType__c = 'Invoice'; 

                if(Test.isRunningTest()){
                    NewOrder.OperatingCompany__c = 'Plantyn';
                }
              
              //Deleted  NewOrder.ShippingCostMethod__c = Contract[0].ShippingCostMethod__c;
              
                Insert NewOrder;
            }

            //Add Subsidoaries Bill to
            varNewOrder=true;
            NewOrderId = NewOrder.id;

            CurOrder= new Order[]{NewOrder};
         //   system.debug('**BILL TO 1**'+NewOrder.Account.NetsuiteInternalId__c);
         //   system.debug('**BILL TO 1: Contract[0].AccountId**'+Contract[0].AccountId);
        }
        else{
          //  CurOrder[0].InsertProductSelector__c = true; 
          
          system.debug('**Map_Sub**'+Map_Sub.get(CurOrder[0].Billto__c));
            CurOrder[0].AccountSubsidiary__c =  Map_Sub.get(CurOrder[0].Billto__c);  
            CurOrder[0].NetSuiteIdAccountSubsidiary__c = Map_Netsuite.get(CurOrder[0].Billto__c); 
            CurOrder[0].NetSuiteIdShiptoAccount__c = CurOrder[0].Shipto__r.NetsuiteInternalId__c;        
            CurOrder[0].NumberOfStudents__c = TotalNumberofStudents;
            if(CurOrder[0].Source__c == null){
                CurOrder[0].Source__c ='B2B Salesforce';
            }

            if(CurOrder[0].Pricebook2.Name.Contains('Informat') && CurOrder[0].MultipleShippingLocations__c ==true){
                CurOrder[0].ValidateItemHfdstructuur__c = 1;
            }

            CurOrder[0].PaymentStatus__c = 'payment_pending'; 
            CurOrder[0].PaymentMethodType__c = 'Invoice'; 
         //   system.debug('**BILL TO 2**'+CurOrder[0].Account.NetsuiteInternalId__c);
            
            if(CurOrder[0].ShipbyDate__c > Map_FixedStartDate.get(CurOrder[0].id) && CurOrder[0].ShipbyDate__c  < Map_FreeFromDate.get(CurOrder[0].id)){
                CurOrder[0].ShipbyDate__c = Map_FixedStartDate.get(CurOrder[0].id)-1;   
                CurOrder[0].EffectiveDate = Map_FixedStartDate.get(CurOrder[0].id)-1;              
                system.debug('*** Order STart Date**'+CurOrder[0].EffectiveDate);
            }
            
            try{
                update CurOrder;

                if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True){
                    CalloutException e = new CalloutException();
                    e.setMessage('Error');
                    throw e;        
                }
            }
            catch(exception e){
                HandleCustomException.LogException(e,CurOrder[0].id);
            }

        }


      /*
     
                system.debug('**Send AGain: '+OrderItemSend.size());
                if(OrderItemSend.size()>0){
                    System.enqueueJob(new Order_TestOrderInsertQueueable(OrderItemSend,ContractId,OrderId, TotalNumberofStudents,false,AccountbyShipto));
                }
                else{
                    CurOrder[0].InsertProductSelector__c = false;
                   update CurOrder;
                }
        }
       */  
}
 



}