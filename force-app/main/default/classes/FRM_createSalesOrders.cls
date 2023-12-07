public class FRM_createSalesOrders {
    
    public static Map<String, List<ImportOrder__c>> createSalesOrdersForPlantyn(List<Product2> products) {
        System.debug('FRM_createSalesOrders - createSalesOrdersForPlantyn');

        List<firstReleasePartner__c> frpLst = [SELECT Id, Quantity__c, Account__c, Account__r.ExternalCustomerId__c, OperatingCompany__c FROM firstReleasePartner__c WHERE OperatingCompany__c = 'Plantyn'];
        String todaysDateString = String.valueOf(Date.today().format());

        List<ImportOrder__c> importOrderList = new List<ImportOrder__c>();
        List<ImportOrder__c> importOrderItemList = new List<ImportOrder__c>();

        Map<String, List<ImportOrder__c>> returnMap = new Map<String, List<ImportOrder__c>>();

        for (firstReleasePartner__c frp : frpLst) {

            String externalOrderId = frp.Account__r.ExternalCustomerId__c + '-' + todaysDateString;
            
            // Create order Header
            ImportOrder__c order = new ImportOrder__c();
            order.customerNo__c = frp.Account__r.ExternalCustomerId__c;
            order.orderDate__c = todaysDateString;
            order.Source__c = 'B2B Salesforce';
            order.OperatingCompany__c = frp.OperatingCompany__c;
            order.ExternalOrderId__c = externalOrderId;
            order.LineCount__c = products.size();
            importOrderList.add(order);

            // Create Order Items
            List<ImportOrder__c> orderItemList = New List<ImportOrder__c>();
            for (Product2 product : products) {
                ImportOrder__c orderItem = new ImportOrder__c();
                OrderItem.customerNo__c = frp.Account__r.ExternalCustomerId__c;
                orderItem.ProductId__c = product.ISBN__c;
                orderItem.quantity__c = frp.Quantity__c;
                orderItem.orderRef__c = '';
                orderItem.orderDate__c = todaysDateString;
                OrderItem.ExternalOrderId__c = externalOrderId;
                orderItem.TriggerBusinessLogic__c = false;
                importOrderItemList.add(orderItem);
            }
        }

        returnMap.put('orders',importOrderList);
        returnMap.put('orderItems', importOrderItemList);

        return returnMap;
        
    }

    public static void createSalesOrdersForNoordhoff(List<Product2> products) {
        System.debug('FRM_createSalesOrders - createSalesOrdersForNoordhoff');

    }

    public static void createSalesOrdersForLiber(List<Product2> products) {
        System.debug('FRM_createSalesOrders - createSalesOrdersForLiber');

    }

}