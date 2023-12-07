@RestResource(urlMapping='/Order/*')
global with sharing class Order_OrderActivateRESTAPI {
    
    @HttpPost
    global static String doPost(String OrdId) {
        
        Order[] lstOrder = [Select id,Billto__c,AccountId,status,ActivateforBatchProcessing__c from Order where Id =: OrdId];
        String resp='Success';
        try{
            
            OrderItem[] lst_OrdItem = [Select id,Order.Status,OrderStatus__c,OrderId from OrderItem where OrderId =: OrdId];

            for(OrderItem item:lst_OrdItem){
                item.OrderStatus__c = 'Activated';            
            }
            update lst_OrdItem;
            
            lstOrder[0].status='Activated';
           //lstOrder[0].ActivateforBatchProcessing__c=false;



            update lstOrder;
        }
        catch(exception e){
            resp=e.getmessage();
        }

        return resp;
    }

    /*
    public static String OrderActivateRESTAPI(Set<String> Set_OrderId) {


        JSONParser parser;
        HttpResponse res1;
        
        String accessToken,endPoint,DMLType,reqbody,objbody;

        DMLType = 'PATCH';
        endPoint= URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v49.0/composite/sobjects'; //'https://CS128.salesforce.com
        accessToken= userinfo.getSessionId();
        reqbody =     '{"records" :[';
        objbody= '';
        for(String oId:Set_OrderId){
            objbody +=     '{"attributes" :{"type" : "Order"},"Id" : "'+oId+'","status" : "Activated","ActivateforBatchProcessing__c":"true"},';
        }
        reqbody += objbody.RemoveEnd(',');
        reqbody += ']}';


        Http h2 = new Http();
        HttpRequest req1 = new HttpRequest();
        req1.setHeader('Authorization','Bearer ' + accessToken);
        req1.setHeader('Content-Type','application/json');
        req1.setHeader('accept','application/json');
        req1.setTimeout(120000);   
     
        system.debug('**reqbody**'+reqbody);
        system.debug('**DMLType**'+DMLType);
        system.debug('**endPoint**'+endPoint);

        req1.setEndpoint(endPoint);
        req1.setBody(reqbody);
        req1.setMethod(DMLType);
        res1 = h2.send(req1);
        
        system.debug('**result*'+res1.getbody());

        return res1.getbody();

    } 
    */

    public static String IntegrateOrders(Set<String> Set_OrderId){

        JSONParser parser;
        HttpResponse res1;
        
        String accessToken,endPoint,DMLType,reqbody,objbody;
        String OrderId;
        for(String oid:Set_OrderId){
            OrderId = oid;
        }

        DMLType = 'POST';
        endPoint= URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/Order/'; //'https://CS128.salesforce.com
        accessToken= userinfo.getSessionId();
        reqbody =     '{"OrdId" : "'+OrderId+'"}';


        Http h2 = new Http();
        HttpRequest req1 = new HttpRequest();
        req1.setHeader('Authorization','Bearer ' + accessToken);
        req1.setHeader('Content-Type','application/json');
        req1.setHeader('accept','application/json');
        req1.setTimeout(120000);   
     
        system.debug('**reqbody**'+reqbody);
        system.debug('**DMLType**'+DMLType);
        system.debug('**endPoint**'+endPoint);

        req1.setEndpoint(endPoint);
        req1.setBody(reqbody);
        req1.setMethod(DMLType);

        string result;
        if(!Test.isRunningTest()){
            res1 = h2.send(req1);
            result = res1.getbody();
        }
        else{
            result = 'failed';
        }
        
        
        system.debug('**result*'+result);

        if(result.contains('failed')){

            ErrorLog__c errorLog = new ErrorLog__c();
            errorLog.Errororigin__c = 'Apex';
            errorLog.RelatedToId__c = OrderId;
            errorLog.ExceptionMessage__c = result;
            errorLog.ExceptionType__c = 'API Order Activation';
            database.insert(errorLog);
        }

        return result;
    }
/*
    public static void IntegrateAccounts(String OrderId){

        JSONParser parser;
        HttpResponse res1;
        
        String accessToken,endPoint,DMLType,reqbody,objbody;
        
        DMLType = 'POST';
        endPoint= URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/Accounts/'; //'https://CS128.salesforce.com
        accessToken= userinfo.getSessionId();
        reqbody =     '{"OrdId" : "'+OrderId+'"}';


        Http h2 = new Http();
        HttpRequest req1 = new HttpRequest();
        req1.setHeader('Authorization','Bearer ' + accessToken);
        req1.setHeader('Content-Type','application/json');
        req1.setHeader('accept','application/json');
        req1.setTimeout(120000);   
     
        system.debug('**reqbody**'+reqbody);
        system.debug('**DMLType**'+DMLType);
        system.debug('**endPoint**'+endPoint);

        req1.setEndpoint(endPoint);
        req1.setBody(reqbody);
        req1.setMethod(DMLType);
        res1 = h2.send(req1);
        
        system.debug('**result*'+res1.getbody());

        
    }
    */
    
}