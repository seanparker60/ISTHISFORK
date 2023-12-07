public with sharing class Order_OrderActivateQueueHandler implements Queueable,Database.AllowsCallouts {
    
    Private  Set<String> Set_QOrderId;
    Private  String Qchecked;
    Public  String checked;
    Public String Status;
    Private  Set<String> Set_Checked;

    public Order_OrderActivateQueueHandler(Set<String> Set_QOrderId,String Qchecked,String Status,Set<String> Set_Checked) {
        this.Set_QOrderId = Set_QOrderId;
        this.Qchecked = Qchecked;
        this.Status =  Status;
        this.Set_Checked = Set_Checked;
    }

    public void execute(System.QueueableContext qc) {
       
        string response;
        if(Status == 'Activated'){
            //response = Order_OrderActivateRESTAPI.OrderActivateRESTAPI(Set_QOrderId);
            response = Order_OrderActivateRESTAPI.IntegrateOrders(Set_QOrderId);
        }
       
        system.System.debug('**response**'+response);

        if( Status != 'Activated' || response == null || (response != null && response.contains('failed'))){
            checknextOrder(Qchecked,Set_Checked);
        }

        

    }    

    public static void checknextOrder(String checked,Set<String> Set_Checked){

        
       // Date CurrrentDay = system.today()-1;   AND createddate >=: CurrrentDay 
               // Order[] nextOrder = [SELECT Id,Billto__c,Source__c,ValidateB2BLineCountError__c FROM Order where  (Source__c =:'Salesforce'  OR (Source__c !=:'Salesforce' AND ValidateB2BLineCountError__c=:0)) AND (id not in: Set_Checked AND id !=:checked AND ActivateforBatchProcessing__c =:true AND createddate >=: CurrrentDay and Status !=: 'Activated' and ValidationErrorsOrder__c =:0 and ValidationErrorsOrderProducts__c =:0) and LineCount__c >:0 Order by LineCount__c ASC limit 1];
                Order[] nextOrder = [SELECT Id,Billto__c,Source__c,ValidateB2BLineCountError__c FROM Order where id not in: Set_Checked AND id !=:checked AND  ActivateforBatchProcessing__c =:true AND ValidateB2BLineCountError__c=:0 AND  ActivateforBatchProcessing__c =:true  and Status !=: 'Activated' and ValidationErrorsOrder__c =:0 and ValidationErrorsOrderProducts__c =:0 and LineCount__c >:0 Order by LineCount__c ASC limit 1];
               
               
               system.debug('**Order Created:Set_checked'+checked);
                system.debug('**Order Created:nextOrder'+nextOrder.size());

                Set<String> Set_OrderId = new Set<String>();
                String CurOrder; 

                for(Order ord:nextOrder){
                   
                        Set_OrderId.add(ord.Id);
                        checked = ord.id;
                }

                system.debug('**Order Created: 1'+Set_OrderId);
        
                
                //OrderItem[] lstOrdeItems = [Select id,Asset__c,OrderId from OrderItem where OrderId in: Set_OrderId AND Asset__r.LastRenewalUpdate__c =:CurrrentDay ];
                OrderItem[] lstOrdeItems = [Select id,Asset__c,OrderId from OrderItem where OrderId in: Set_OrderId ];
                

                Set_OrderId = new Set<String>();
                //String OrderId;
                for (OrderItem item:lstOrdeItems) {
                    Set_OrderId.add(item.OrderId);
                    CurOrder = item.OrderId;
                  //  OrderId = item.OrderId;
                }
                system.debug('**Order Created: 2'+Set_OrderId);
                //Order[] ActivateOrder = [Select id,Status from Order where id in:Set_OrderId FOR UPDATE];
                //system.debug('**Order Created: 3'+ActivateOrder);
                
                if( Set_OrderId.size()>0){    
                    
                    if((checked == null || CurOrder != null) && nextOrder.size()>0){
                     //   Set_checked.Add(CurOrder);
                        Set_checked.Add(checked);
                        System.enqueueJob(new Order_OrderActivateQueueHandler(Set_OrderId,checked,'Activated',Set_Checked));
                    }
                    
                } 
                else if((checked == null || CurOrder == null) && nextOrder.size()>0 ){
                    Set_checked.Add(checked);
                    System.enqueueJob(new Order_OrderActivateQueueHandler(null,checked,'Failed',Set_Checked));

                }   
                
    }

}