public class VAT_checkVat {

    public static Boolean triggerFutureClass;
    
    public static void CheckVatOnUpdate(Map<Id, Account> accountMap, Map<Id, Account> oldMap) {
        System.debug('VAT_checkVat - CheckVatOnUpdate - start');

        Map<Id,Map<String,String>> accountMapForCallout = new Map<Id,Map<String,String>>();
        List<Account> accountUpdateList = new List<Account>();

        for (Account acc : accountMap.values()) {

            if (acc.VATNumber__c != oldMap.get(acc.Id).VATNumber__c) {
                Account newAcc = new Account();
                if (acc.VATNumber__c == null || acc.VATNumber__c == '') {
                    // If we do not have a VAT number set VAT Status to NA
                    newAcc.Id = acc.Id;
                    newAcc.VATStatus__c = 'NA';
                } else {
                    Map<String,String> tempMap = new Map<String,String>();
                    // get Vat info from Account and store in temporary Map
                    String countryCode = acc.BillingCountryCode;
                    String vatNumber = acc.VATNumber__c;
                    tempMap.put('countryCode',acc.BillingCountryCode);
                    tempMap.put('vatNumber',acc.VATNumber__c);

                    // create Map for callouts
                    accountMapForCallout.put(acc.Id,tempMap);

                    // Set temp status to processing (will be overwritten when the correct status is received from the VIES callout)
                    newAcc.Id = acc.Id;
                    newAcc.VATStatus__c = 'Processing';
                    newAcc.VATErrorMessage__c = '';
                }
                accountUpdateList.add(newAcc);
            }
        }

        if (accountUpdateList.size() > 0) {
            update accountUpdateList;
        }

        if (accountMapForCallout.keySet().size() > 0) {

            for (Id accountId : accountMapForCallout.keySet()) {

                String cc = accountMapForCallout.get(accountId).get('countryCode');
                String vatnr = accountMapForCallout.get(accountId).get('vatNumber');

                if (triggerFutureClass == null) {
                    // Call @future method to get VIES Check of VAT number
                    VAT_ViesCallout.MakeCallout(accountId, cc, vatnr);
                }

            }
        }

        System.debug('VAT_checkVat - CheckVatOnUpdate - end');
    }

    public static void CheckVatOnInsert(List<Account> accounts) {
        System.debug('VAT_checkVat - CheckVatOnInsert - start');

        Map<Id,Map<String,String>> accountMapForCallout = new Map<Id,Map<String,String>>();
        List<Account> accountUpdateList = new List<Account>();

        for (Account acc : accounts) {

            Account newAcc = new Account();
            // if VAT number is not empty update the VAT number Status
            if (acc.VATNumber__c != null && acc.VATNumber__c != '') {

                Map<String,String> tempMap = new Map<String,String>();
                // get Vat info from Account and store in temporary Map
                String countryCode = acc.BillingCountryCode;
                String vatNumber = acc.VATNumber__c;
                tempMap.put('countryCode',acc.BillingCountryCode);
                tempMap.put('vatNumber',acc.VATNumber__c);

                // create Map for callouts
                accountMapForCallout.put(acc.Id,tempMap);
                
                // Set temp status to processing (will be overwritten when the correct status is received from the VIES callout)
                newAcc.Id = acc.Id;
                newAcc.VATStatus__c = 'Processing';
                newAcc.VATErrorMessage__c = '';
            } else {
                // If we do not have a VAT number set VAT Status to NA
                newAcc.Id = acc.Id;
                newAcc.VATStatus__c = 'NA';
            }
            accountUpdateList.add(newAcc);
        }

        if (accountUpdateList.size() > 0) {
            update accountUpdateList;
        }

        if (accountMapForCallout.keySet().size() > 0) {

            for (Id accountId : accountMapForCallout.keySet()) {

                String cc = accountMapForCallout.get(accountId).get('countryCode');
                String vatnr = accountMapForCallout.get(accountId).get('vatNumber');

                if (triggerFutureClass == null) {
                    // Call @future method to get VIES Check of VAT number
                    VAT_ViesCallout.MakeCallout(accountId, cc, vatnr);
                }

            }
        }

        System.debug('VAT_checkVat - CheckVatOnInsert - end');
    }

}