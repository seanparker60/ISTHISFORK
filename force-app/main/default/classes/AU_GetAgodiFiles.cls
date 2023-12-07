public with sharing class AU_GetAgodiFiles {

    @AuraEnabled
    public static void updateData() {

        // LIMIT ON FILES IS ~ 4000 LINES, IF THE FILE GETS BIGGER USE THE SPLIT FUNCTION ==> SplitFileInHalf(file) ==> this will return a List<String> with the split results
        
        // Map<String,String> downloadLocations = getFileWithMostRecentDownloadLocations();
        // String inrichtendeMachtenRawFile = getFile(downloadLocations.get('Inrichtende_machten').escapeHtml4());
        // String scholenGemeenschappenRawFile = getFile(downloadLocations.get('Scholengemeenschappen').escapeHtml4());
        // String scholenRawFile = getFile(downloadLocations.get('Scholen').escapeHtml4());

        // List<String> finalFourScholenFiles = new List<String>();
        // if (scholenRawFile.length() > 1) {
        //     List<String> splitScholenFiles = splitFileInHalf(scholenRawFile);
        //     for(String s : splitScholenFiles) {
        //         finalFourScholenFiles.addAll(splitFileInHalf(s));
        //     }
        // }

        // AgodiUpdate__c au = new AgodiUpdate__c();
        // insert au;

        // if (inrichtendeMachtenRawFile.length() > 1) {
        //     insertFile(inrichtendeMachtenRawFile, 'inrichtendeMachten.txt', au.Id);
        // }
        // if (scholenGemeenschappenRawFile.length() > 1) {
        //     insertFile(scholenGemeenschappenRawFile, 'scholenGemeenschappen.txt', au.Id);
        // }
        // if (finalFourScholenFiles.size() == 4 && !Test.isRunningTest()) {
        //     for (Integer i = 0; i < 4; i++) {
        //         insertFile(finalFourScholenFiles[i], 'Scholen' + (i+1) + '.txt', au.Id);
        //     }
        // } else if (scholenRawFile.length() > 1 && Test.isRunningTest()) {
        //     insertFile(scholenRawFile, 'Scholen1.txt', au.Id);
        // }

        // au.filesUploaded__c = true;
        // update au;
    }

}