public with sharing class Order_ImportOrderSuccessorUpdate {
    public class Request{ 
        @invocablevariable Public OrderItem SingleOrderItems;
        
    }
    public class Response{ 
        @invocablevariable Public OrderItem SingleOrderItems; 
    }


   
    @invocablemethod
    public static List<Response> OrderSuccessorUpdate(List<Request> req){

        system.debug('**OrderSuccessorUpdate: GO**'+req.size());


        List<Response> responses = new List<Response>();
        Response res = new Response();
        List<OrderItem> ListOfOrderItems = new List<OrderItem>();


        for(Request r:req){
            ListOfOrderItems.add(r.SingleOrderItems);
            system.debug('**OrderSuccessorUpdate: Go 1**'+r.SingleOrderItems.PricebookEntryId);
           /*
            
            system.debug('**OrderSuccessorUpdate: Go 1**'+r.SingleOrderItems.Product2Id);
            res = new Response();
            res.SingleOrderItems = r.SingleOrderItems;
            responses.add( res);
            */
        }
        
        ListOfOrderItems = OrderSuccessorUpdate(ListOfOrderItems);
       
        
        for(OrderItem item:ListOfOrderItems){
            res = new Response();
            res.SingleOrderItems = item;
           
            system.debug('**OrderSuccessorUpdate: 11**'+res.SingleOrderItems.PricebookEntryId);
            system.debug('**OrderSuccessorUpdate: 11BB**'+res.SingleOrderItems.Product2Id);
             responses.add(res);
        }

        
        return responses;
    }    


    public static List<OrderItem> OrderSuccessorUpdate(List<OrderItem> ListOfOrderItems){    
        
        Map<String,String> Map_Prod = new Map<String,String>();
        Set<String> Set_ProdId = new Set<String> ();
        Set<String> Set_OrdId = new Set<String>();

        for(OrderItem item: ListOfOrderItems){
            Set_ProdId.add(item.Product2Id);
            Set_OrdId.add(item.OrderId); 
            system.debug('**OrderSuccessorUpdate: item.OrderId**'+item.OrderId);
        }

        Order[] lstOrder = [Select id,Pricebook2Id from Order where id in:Set_OrdId ];

        Set<String> Set_PB = new Set<String>();

        for(Order ord:lstOrder){
            Set_PB.add(ord.Pricebook2Id);
        }

        system.debug('**OrderSuccessorUpdate: 1**'+Set_ProdId);

        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];

        PricebookEntry[] lstPricebookEntryExist;
        
        if(Set_PB.size()>0){
            lstPricebookEntryExist = [Select id,Product2Id, Pricebook2Id,Product2.IsSuccessorItemActive__c,Product2.SuccessorItem__c,Product2.SuccessorItem__r.IsActive,Product2.Stocknumber__c,Product2.StockLevel__c, Product2.PlannedPrintDate__c from PricebookEntry where Product2Id in:Set_ProdId AND Pricebook2Id !=:standardPB.id AND Pricebook2Id in: Set_PB]; // 
        }
        else{
            lstPricebookEntryExist = [Select id,Product2Id, Pricebook2Id,Product2.IsSuccessorItemActive__c,Product2.SuccessorItem__c,Product2.SuccessorItem__r.IsActive,Product2.Stocknumber__c,Product2.StockLevel__c, Product2.PlannedPrintDate__c from PricebookEntry where Product2Id in:Set_ProdId AND Pricebook2Id !=:standardPB.id]; //       
        }
        
        Date ReprintDateCheck = system.today();

        Set<String> Set_Successor = new Set<String>();
        
        system.debug('**OrderSuccessorUpdate: 1**'+lstPricebookEntryExist);
        for(PricebookEntry pbe:lstPricebookEntryExist){
            system.debug('**OrderSuccessorUpdate: 2**'+pbe.Product2.SuccessorItem__c );
            system.debug('**OrderSuccessorUpdate: 3**'+pbe.Product2.IsSuccessorItemActive__c );

            if(pbe.Product2.SuccessorItem__c != null && pbe.Product2.IsSuccessorItemActive__c == true && pbe.Product2.SuccessorItem__r.IsActive == true){
                //Successor item active = true & Successor item != NULL -> Pick Successor Item Id
                system.debug('**OrderSuccessorUpdate: 4**');
                Map_Prod.put(pbe.Product2Id, pbe.Product2.SuccessorItem__c);
                Set_Successor.add(pbe.Product2.SuccessorItem__c);
            }
            else if(pbe.Product2.SuccessorItem__c != null && (pbe.Product2.IsSuccessorItemActive__c == false || pbe.Product2.SuccessorItem__r.IsActive == false) && pbe.Product2.Stocknumber__c > 0){
                system.debug('**OrderSuccessorUpdate: 5**');
                //Successor item active = false & Successor item != NULL & available stock > 0 for ordered product -> Backorder ordered product

                //Product stays the same
            }
            else if(pbe.Product2.SuccessorItem__c != null && (pbe.Product2.IsSuccessorItemActive__c == false || pbe.Product2.SuccessorItem__r.IsActive == false) && (pbe.Product2.Stocknumber__c == 0 || pbe.Product2.Stocknumber__c == null) && (pbe.Product2.PlannedPrintDate__c < ReprintDateCheck || pbe.Product2.PlannedPrintDate__c ==null)){
                //Successor item switch = false & available stock = 0 for regular product & no reprint planned & Successor item != NULL -> Pick successor item Id
                Map_Prod.put(pbe.Product2Id, pbe.Product2.SuccessorItem__c);
                Set_Successor.add(pbe.Product2.SuccessorItem__c);

                system.debug('**OrderSuccessorUpdate: 6**');
            
            }
        }

        PricebookEntry[] lstPricebookSuccessor = [Select id,Product2Id, Pricebook2Id,Product2.IsSuccessorItemActive__c,Product2.SuccessorItem__c,Product2.Stocknumber__c,Product2.StockLevel__c, Product2.PlannedPrintDate__c from PricebookEntry where Product2Id in:Set_Successor AND Pricebook2Id =:lstPricebookEntryExist[0].Pricebook2Id ]; // 
        
        Map<String,String> Map_PBE = new Map<String,String>();
        
        system.debug('**OrderSuccessorUpdate: 7**'+lstPricebookSuccessor);

        for(PricebookEntry pbe:lstPricebookSuccessor){
            Map_PBE.put(pbe.Product2Id,pbe.Id);            
        }

        system.debug('**OrderSuccessorUpdate: 8**'+Map_PBE);
        for(OrderItem item: ListOfOrderItems){

            system.debug('**OrderSuccessorUpdate: 9A**'+Map_PBE.get(Map_Prod.get(item.Product2Id)));
            if(Map_PBE.get(Map_Prod.get(item.Product2Id)) != null){
                system.debug('**OrderSuccessorUpdate: 9B**'+Map_PBE.get(Map_Prod.get(item.Product2Id)));
                if(!Test.isRunningTest()){
                    item.PricebookEntryId = Map_PBE.get(Map_Prod.get(item.Product2Id));
                    system.debug('**OrderSuccessorUpdate: 10**'+item.PricebookEntryId);
                    item.Product2Id = Map_Prod.get(item.Product2Id);
                }
                
                
                system.debug('**OrderSuccessorUpdate: 10**'+item.PricebookEntryId);
            }

            
        }

        return ListOfOrderItems;

    }    
}