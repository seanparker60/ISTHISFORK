public with sharing class Order_AssetRenewalDatesInvoc {

    @InvocableMethod(label ='resetAssetsRenewalDates')
    public static void resetAssetsRenewalDates(List<List<String>> assetsIdList) {
        system.debug('**Order_AssetRenewalDatesInvoc.resetAssetsRenewalDates**');
        system.debug('**assetsIdList**: ' + assetsIdList);
        system.debug('**assetsIdList[0]**: ' + assetsIdList[0]);
        //Set<Id> assetIdSet = new Set<Id>();
        
        /*for(OrderItem item : orderItemList){
            assetIdSet.add(item.Id);
        }*/

        List<Asset> assetList = [SELECT Id, RenewalDate__c, PreviousRenewalDate__c FROM Asset WHERE ID IN : assetsIdList[0]];

        if(assetList != null && assetList.size() > 0){

            for(Asset asset : assetList){
                asset.RenewalDate__c = asset.PreviousRenewalDate__c;
                asset.PreviousRenewalDate__c = null;
                asset.AssetRenewalTrigger__c = true;
            }

            try{
                update assetList;
            } catch (Exception e) {
                system.debug('**Order_AssetRenewalDatesInvoc.resetAssetsRenewalDates: Error** ' + e.getMessage());
                HandleCustomException.LogException(e, assetList[0].id);
            }
        }
    }
}