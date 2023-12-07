public with sharing class bg_LogResponse {
    

    Public static void logresponse(String json,Set<ID> ids){

        List<SystemMonitor__c> lstSystemMonitor = new List<SystemMonitor__c>();


        List<string> recordIdStrings = new List<string>();
        String ObjName;
        if(ids.size()>0){

            for(Id recId:ids){
                recordIdStrings.add(string.valueof(recId));
                break;
            }
            
            ObjName=UTIL_getObjectName.returnObjectName(recordIdStrings)[0];
        }

        Boolean Success = false;
        for(ID recId : ids)
        {
            SystemMonitor__c SystemMonitor;
            if(Success == false){
                SystemMonitor = new SystemMonitor__c();
                SystemMonitor.Type__c = 'Integration';
                SystemMonitor.Message__c = json;
                SystemMonitor.RecordId__c =  recId;
                SystemMonitor.Object__c = ObjName;
                lstSystemMonitor.add(SystemMonitor);
                Success = true;
            }            
            else if(!json.contains('Success')){
                SystemMonitor = new SystemMonitor__c();
                SystemMonitor.Type__c = 'Integration';
                SystemMonitor.Message__c = json;
                SystemMonitor.RecordId__c =  recId;
                SystemMonitor.Object__c = ObjName;
                lstSystemMonitor.add(SystemMonitor);
            }
                        
        }

        database.insert(lstSystemMonitor);

    }


}