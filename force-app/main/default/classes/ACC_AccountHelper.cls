public class ACC_AccountHelper {
    
    @InvocableMethod(label='Update Account with Location RecordType' description='Updates Accounts with the Location RecordType' category='Account')
    public static void GetUpdateAccountLocationRecordType(List<Id> accountIds) {
        System.debug('ACC_AccountHelper - GetLocationRecordType');

        Id locationRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2B_Educational_Location').getRecordTypeId();
        System.debug('locationRecordTypeId = ' + locationRecordTypeId);
        List<Account> acclst = new List<Account>();
        for (Id accId : accountIds) {
            Account acc = new Account();
            acc.Id = accId;
            acc.RecordTypeId = locationRecordTypeId;
            acclst.add(acc);
        }
        update acclst;
    }

    public static void legalNameHelperUpdate(Map<Id,Account> newMap, Map<Id,Account> oldMap) {

        for (Account acc : newMap.values()) {
            Boolean calculate = false;

            // decide if the Account is an Agodi Account or not
            if (acc.ExternalDatabase__c == 'Agodi' && acc.ExternalCustomerId__c != '' && acc.ExternalCustomerId__c != null) {
                
                // If Agodi Account
                if (acc.LegalName__c != oldMap.get(acc.Id).LegalName__c && !acc.AgodiUpdateInProgress__c) {
                
                    if (acc.LegalName__c == '') {
                        acc.LegalName__c = acc.Name;
                    }

                    acc.LegalName2__c = '';
    
                    if (acc.LegalName__c.length() > 83) {
                        calculate = true;
                    }
    
                }

            } else {

                // If non Agodi Account
                if (acc.Name != oldMap.get(acc.Id).Name) {
                
                    acc.LegalName2__c = '';
    
                    acc.LegalName__c = acc.Name;
    
                    if (acc.LegalName__c.length() > 83) {
                        calculate = true;
                    }

                }
            }
            
            if (calculate) {   
                            
                String originalLegalName = acc.LegalName__c;
                Integer split = originalLegalName.left(83).lastIndexOf(' ');
                acc.LegalName__c = originalLegalName.left(split);
                acc.LegalName2__c = originalLegalName.right(originalLegalName.length()-split);

            }
            
        }
    }

    public static void legalNameHelperInsert(List<Account> accounts) {

        for (Account acc : accounts) {

            // decide if the Account is an Agodi Account or not
            if (acc.ExternalDatabase__c == 'Agodi' && acc.ExternalCustomerId__c != '' && acc.ExternalCustomerId__c != null) {
                
                // If Agodi Account
                Boolean calculate = false;
                
                if (acc.LegalName__c == '') {
                    acc.LegalName__c = acc.Name;
                }
                
                acc.LegalName2__c = '';
            
                if (!acc.AgodiUpdateInProgress__c) {
                
                    if (acc.LegalName__c == null) {
                        acc.LegalName__c = acc.Name;
                    }
                    
                    if (acc.LegalName__c.length() > 83) {
                        calculate = true;
                    }
        
                    if (calculate) { 
                        
                        String originalLegalName = acc.LegalName__c;
                        Integer split = originalLegalName.left(83).lastIndexOf(' ');
                        acc.LegalName__c = originalLegalName.left(split);
                        acc.LegalName2__c = originalLegalName.right(originalLegalName.length()-split);

                    }
                }

            } else if (acc.LegalName__c != '') {

                // If non Agodi Account
                Boolean calculate = false;

                if (acc.LegalName__c == null) {
                    acc.LegalName__c = acc.Name;
                }
                
                if (acc.LegalName__c.length() > 83) {
                    calculate = true;
                }
    
                if (calculate) { 
                    
                    String originalLegalName = acc.LegalName__c;
                    Integer split = originalLegalName.left(83).lastIndexOf(' ');
                    acc.LegalName__c = originalLegalName.left(split);
                    acc.LegalName2__c = originalLegalName.right(originalLegalName.length()-split);

                }
            }

        }
    }

    public static void ValidateAccountBeforeTriggerDelete(List<Account> accounts){
        System.debug('### MERGE_StoreDeletedRecords - ValidateBeforeTriggerDelete');
        
        List<Id> accountIds = new List<Id>();
        Map<Id, Boolean> accountToAllowToDeleteMap = new Map<Id, Boolean>();
        
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }
        System.debug('### ValidateBeforeTriggerDelete accountIds: ' + accountIds);
        
        if (accountIds.size() > 0) {
            List<AccountSubsidiary__c> accountSubsidiariesDeleteList = [SELECT Id, Name, OutstandingBalance__c, Account__c FROM AccountSubsidiary__c WHERE Account__c IN : accountIds];
            System.debug('### ValidateBeforeTriggerDelete accountSubsidiariesDeleteList: ' + accountSubsidiariesDeleteList.size());
            
            for(AccountSubsidiary__c accSub : accountSubsidiariesDeleteList){
                if(accSub.OutstandingBalance__c > 0){
                    accountToAllowToDeleteMap.put(accSub.Account__c, false);
                }
            }
            System.debug('### ValidateBeforeTriggerDelete accountToAllowToDeleteMap: ' + accountToAllowToDeleteMap);
            
            for (Account acc : accounts) {
                
                if(accountToAllowToDeleteMap.containsKey(acc.Id) && accountToAllowToDeleteMap.get(acc.Id) == false){
                    acc.addError('Cannot delete the Account! an Account Subsidiary related to the Account has an Outstanding Balance!');
                }
            }
        }
    }

}