public class AU_processFiles {
// public class AU_processFiles implements Database.Batchable<sObject>, Database.Stateful {

    // public List<Id> contentDocumentIds;
    // public Id agodiUpdateId;
    // public Set<String> handledAgodiScholen;

    // public AU_processFiles(List<Id> contetDocumentIdList, Id agodiUpdateRecordId) {
        // contentDocumentIds = contetDocumentIdList;
        // agodiUpdateId = agodiUpdateRecordId;
        // System.debug(LoggingLevel.INFO, 'AU_processFiles(contentDocumentIds:' + contentDocumentIds + ', agodiUpdateId: ' + agodiUpdateId + ')');
    // }

    // public Database.QueryLocator start (Database.BatchableContext BC) {
    //     System.debug('AU_processFiles - Start');
    //     String query = 'SELECT Id, VersionData, Title FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds';
    //     return Database.getQueryLocator(query);
    // }

    // public void execute (Database.BatchableContext BC, List<ContentVersion> scope) {
        // System.debug('AU_processFiles - Execute');

        // if (scope.size() != 1) {
        //     System.debug('##### ERROR ==> Incorrect Scope, size should be 1 but is ' + scope.size() + '!');
        // } else {
            
        //     String scholen;
        //     String scholenGemeenschappen;
        //     String inrichtendeMachten;

        //     Map<String,Account> currentPlantynAccounts = AU_createAccountsFromAgodiData.getCurrentPlantynAccounts();
            
        //     for (ContentVersion cv : scope) {
        //         if (cv.Title == 'scholen1.txt') {
        //             if (handledAgodiScholen == null) {
        //                 handledAgodiScholen = new Set<String>();
        //             }
        //             scholen = cv.VersionData.toString();
        //             System.debug('We found the first file for Scholen');
        //             handledAgodiScholen = AU_createAccountsFromAgodiData.scholen(scholen, currentPlantynAccounts, agodiUpdateId, 1, handledAgodiScholen);
        //         } else if (cv.Title == 'scholen2.txt') {
        //             if (handledAgodiScholen == null) {
        //                 handledAgodiScholen = new Set<String>();
        //             }
        //             scholen = cv.VersionData.toString();
        //             System.debug('We found the second file for Scholen');
        //             handledAgodiScholen = AU_createAccountsFromAgodiData.scholen(scholen, currentPlantynAccounts, agodiUpdateId, 2, handledAgodiScholen);
        //         }else if (cv.Title == 'scholen3.txt') {
        //             if (handledAgodiScholen == null) {
        //                 handledAgodiScholen = new Set<String>();
        //             }
        //             scholen = cv.VersionData.toString();
        //             System.debug('We found the third file for Scholen');
        //             handledAgodiScholen = AU_createAccountsFromAgodiData.scholen(scholen, currentPlantynAccounts, agodiUpdateId, 3, handledAgodiScholen);
        //         }else if (cv.Title == 'scholen4.txt') {
        //             if (handledAgodiScholen == null) {
        //                 handledAgodiScholen = new Set<String>();
        //             }
        //             scholen = cv.VersionData.toString();
        //             System.debug('We found the fourth file for Scholen');
        //             handledAgodiScholen = AU_createAccountsFromAgodiData.scholen(scholen, currentPlantynAccounts, agodiUpdateId, 4, handledAgodiScholen);
        //         } else if (cv.Title == 'scholenGemeenschappen.txt') {
        //             scholenGemeenschappen = cv.VersionData.toString();
        //             System.debug('We found the file for Scholengemeenschappen');
        //             AU_createAccountsFromAgodiData.scholenGemeenschappen(scholenGemeenschappen, currentPlantynAccounts, agodiUpdateId);
        //         } else if (cv.title == 'inrichtendeMachten.txt') {
        //             inrichtendeMachten = cv.VersionData.toString();
        //             System.debug('We found the file for Inrichtende Machten');
        //             System.enqueueJob(new AU_createInrichtendemachten_queueable(inrichtendeMachten, currentPlantynAccounts, agodiUpdateId));
        //             //AU_createAccountsFromAgodiData.inrichtendeMachten(inrichtendeMachten, currentPlantynAccounts, agodiUpdateId);
        //         }
        //     }
        // }
    // }

    // public void finish (Database.BatchableContext BC) {
        // System.debug('AU_processFiles - Finish');

        // System.debug('AGODI UPDATE FINISHED, RESULTS CAN BE FOUND IN AGODI UPDATE RECORD WITH ID: ' + agodiUpdateId);
        // AgodiUpdate__c au = [SELECT Id, Processed__c FROM AgodiUpdate__c WHERE Id = :agodiUpdateId LIMIT 1];
        // au.Processed__c = true;
        // au.UpdateIsRunning__c = false;
        // update au;

        // System.debug('VAT_checkVat.triggerFutureClass ==> ' + VAT_checkVat.triggerFutureClass);
        // VAT_checkVat.triggerFutureClass = null;

        // System.debug('AU_AWSSwitches__mdt.Active__c ==> ' + [Select DeveloperName,Active__c from AWSSwitches__mdt where DeveloperName='Account' LIMIT 1].Active__c);

    // }
    
}