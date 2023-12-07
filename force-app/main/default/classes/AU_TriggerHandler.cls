public class AU_TriggerHandler {
    
    public static void passFilesToBatch(List<AgodiUpdate__c> agodiUpdates) {
        System.debug('AU_TriggerHandler - passFilesToBatch - START');

        for (AgodiUpdate__c au : agodiUpdates) {

            if (au.filesUploaded__c && !au.UpdateIsRunning__c && !au.Processed__c) {
                //ID jobID = System.enqueueJob(new AU_queueBatchJob(au.Id));

                Id agodiUpdateId = au.Id;

                List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :agodiUpdateId];
                System.debug('### We have ' + contentDocumentLinks.size() + ' ContentDocumentLinks');

                List<Id> contentDocumentIds = new List<Id>();
                for (ContentDocumentLink cdl : contentDocumentLinks) {
                    contentDocumentIds.add(cdl.ContentDocumentId);
                }

                ContentVersion inrichtendeMachtenContentVersion = [SELECT Id, VersionData, Title FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds AND Title = 'inrichtendeMachten.txt' LIMIT 1];
                String file = inrichtendeMachtenContentVersion.VersionData.toString();

                Map<String,Account> currentPlantynAccounts = AU_createAccountsFromAgodiData.getCurrentPlantynAccounts();

                System.debug('We found the file for Inrichtende Machten');
                ID jobID = System.enqueueJob(new AU_createInrichtendemachten_queueable(file, currentPlantynAccounts, agodiUpdateId, contentDocumentIds));
                System.debug('AU_createInrichtendemachten_queueable is enqueued with Job Id: ' + jobID);
            }
        }
        System.debug('AU_TriggerHandler - passFilesToBatch - END');
    }

}