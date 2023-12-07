public class AU_queueBatchJob {
//public class AU_queueBatchJob implements Queueable {

    // public Id agodiUpdateId;
    // public List<ContentDocumentLink> contentDocumentLinks;

    // public AU_queueBatchJob(Id agodiUpdateRecordId) {
    //     // agodiUpdateId = agodiUpdateRecordId;
    // }

    // public void execute(QueueableContext context) {

        // List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :agodiUpdateId];
        // System.debug('### We have ' + contentDocumentLinks.size() + ' ContentDocumentLinks');

        // List<Id> contentDocumentIds = new List<Id>();
        // for (ContentDocumentLink cdl : contentDocumentLinks) {
        //     contentDocumentIds.add(cdl.ContentDocumentId);
        // }

        // ContentVersion inrichtendeMachtenContentVersion = [SELECT Id, VersionData, Title FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds AND Title = 'inrichtendeMachten.txt' LIMIT 1];
        // String file = inrichtendeMachtenContentVersion.VersionData.toString();

        // Map<String,Account> currentPlantynAccounts = AU_createAccountsFromAgodiData.getCurrentPlantynAccounts();

        // System.debug('We found the file for Inrichtende Machten');
        // System.enqueueJob(new AU_createInrichtendemachten_queueable(file, currentPlantynAccounts, agodiUpdateId, contentDocumentIds));

    // }
}