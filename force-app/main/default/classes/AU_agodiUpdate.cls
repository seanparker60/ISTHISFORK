/*/
*
*   Created By: Jannes Kleerebezem
*   Date: 14-01-2022
*   Use to start the queue for the Agodi Updates (Chains queueable classes till process is finished)
*   System.enqueueJob(new AU_agodiUpdate());
*
/*/

public class AU_agodiUpdate implements Queueable, Database.AllowsCallouts {

    public void execute(QueueableContext context) {
        System.debug('AU_agodiUpdate - execute - START');
        // LIMIT ON FILES IS ~ 4000 LINES, IF THE FILE GETS BIGGER USE THE SPLIT FUNCTION ==> SplitFileInHalf(file) ==> this will return a List<String> with the split results
        
        Map<String,String> downloadLocations = getFileWithMostRecentDownloadLocations();
        String inrichtendeMachtenRawFile = getFile(downloadLocations.get('Inrichtende_machten').escapeHtml4());
        String scholenGemeenschappenRawFile = getFile(downloadLocations.get('Scholengemeenschappen').escapeHtml4());
        String scholenRawFile = getFile(downloadLocations.get('Scholen').escapeHtml4());

        List<String> finalFourScholenFiles = new List<String>();
        if (scholenRawFile.length() > 1) {
            List<String> splitScholenFiles = splitFileInHalf(scholenRawFile);
            for(String s : splitScholenFiles) {
                finalFourScholenFiles.addAll(splitFileInHalf(s));
            }
        }

        AgodiUpdate__c au = new AgodiUpdate__c();
        insert au;

        if (inrichtendeMachtenRawFile.length() > 1) {
            insertFile(inrichtendeMachtenRawFile, 'inrichtendeMachten.txt', au.Id);
        }
        if (scholenGemeenschappenRawFile.length() > 1) {
            insertFile(scholenGemeenschappenRawFile, 'scholenGemeenschappen.txt', au.Id);
        }
        if (finalFourScholenFiles.size() == 4 && !Test.isRunningTest()) {
            for (Integer i = 0; i < 4; i++) {
                insertFile(finalFourScholenFiles[i], 'Scholen' + (i+1) + '.txt', au.Id);
            }
        } else if (scholenRawFile.length() > 1 && Test.isRunningTest()) {
            insertFile(scholenRawFile, 'Scholen1.txt', au.Id);
        }

        au.filesUploaded__c = true;
        update au;

        System.debug('AU_agodiUpdate - execute - END');
    }

    public static Map<String,String> getFileWithMostRecentDownloadLocations() {

        map<String, String> downloadLocationMap = new Map<String, String>();
        List<String> files = new List<String>();

        // Instantiate a new http object
        Http h = new Http();
        
        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://agodi.be/sites/default/files/atoms/files/links_meest_recent_0.txt');
        req.setTimeout(60000); //sets maximum timeout
        req.setMethod('GET');

        // Send the request, and return a response
        HttpResponse res = h.send(req);
        Blob body = res.getBodyAsBlob();
        
        // Create Map from downloaded file
        files = body.toString().split('\r\n');
        for(String row : files) {
            if(row.length() > 1) {
                List<String> seperatedLine = new List<String>();
                seperatedLine = row.replace('"','').split(';');
                downloadLocationMap.put(seperatedLine[0],seperatedLine[2]);
            }
        }

        System.debug('Scholen Download Location = ' + downloadLocationMap.get('Scholen'));
        System.debug('Scholengemeenschappen Download Location = ' + downloadLocationMap.get('Scholengemeenschappen'));
        System.debug('Inrichtende_machten Download Location = ' + downloadLocationMap.get('Inrichtende_machten'));

        return downloadLocationMap;

    }

    public static String getFile(String location) {

        System.debug('Location = ' + location);

        // Instantiate a new http object
        Http h = new Http();

        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();

        // req.setEndpoint(location+'&Format=txt');
        req.setEndpoint(location);
        req.setTimeout(60000); //sets maximum timeout
        req.setMethod('GET');

        System.debug('EndPoint = ' + req.getEndpoint());

        // Send the request, and return a response
        HttpResponse res = h.send(req);

        // Check if redirect is needed just as long untill we get the correct response
        Integer redirect = 1;
        System.debug('StatusCode: ' + res.getStatusCode());
        if(res.getStatusCode() == 301 || res.getStatusCode() == 302 || res.getStatusCode() == 308) {
            while(res.getStatusCode() == 301 || res.getStatusCode() == 302 || res.getStatusCode() == 308) {
                System.debug('REDIRECT ' + redirect);
                System.debug('StatusCode  ==> ' + res.getStatusCode());
                System.debug('new Header ==> ' + res.getHeader('Location'));
                req.setEndpoint(res.getHeader('Location'));
                res = new Http().send(req);
                redirect ++;
            }
        }
        res.setHeader('Content-Type','text/html; charset=windows-1252');

        System.debug('##### WE HAVE GOT THE FILE! #####');
        String rawFile = res.getBody();

        return rawFile;
    }
  
    private static void insertFile(String content, String name, Id parentRecordId){
        System.debug('AU_agodiUpdate - insert file: ' + name);
    
        // create File (ContentVersion)
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = name;
        conVer.Title = name;
        conVer.VersionData = Blob.valueOf(content);
        insert conVer;

        // Link file to object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = parentRecordId;
        conDocLink.ContentDocumentId = conDoc;
        conDocLink.shareType = 'V';
        insert conDocLink;

        System.debug('==> Inserted ContentDocumentLink with ParentId ==> ' + conDocLink.LinkedEntityId);

    }

    private static List<String> splitFileInHalf(String content) {
        Integer halfCount = content.indexOf('\r\n',(content.length()/2));

        String headers = content.Substring(0,content.indexOf('\r\n',0));
        String firstString = content.Substring(0,halfCount+2);
        String secondString = headers + content.Substring(halfCount-2);

        List<String> returnList = new List<String>();
        returnList.add(firstString);
        returnList.add(secondString);

        return returnList;
    }
}