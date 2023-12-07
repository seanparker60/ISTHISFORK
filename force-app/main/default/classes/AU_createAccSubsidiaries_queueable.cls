public class AU_createAccSubsidiaries_queueable implements Queueable {

    public List<Id> createdAccountIdList,updatedAccountIdList;
    
    public AU_createAccSubsidiaries_queueable(List<Id> createdAccountIds, List<Id> updatedAccountIds) {
        this.createdAccountIdList = createdAccountIds;
        this.updatedAccountIdList = updatedAccountIds;
    }

    public void execute(QueueableContext context) {
        System.debug('AU_createAccSubsidiaries_queueable - execute - START');
        
        List<Account> accountUpdateList = new List<Account>();
        List<AccountSubsidiary__c> accSubList = new List<AccountSubsidiary__c>();

        List<Id> newCreatedAccountIdList = new List<Id>();
        List<Id> newUpdatedAccountIdList = new List<Id>();
        Integer accountCount = 0;
        Integer accSubCount = 0;

        for (Id accId : this.createdAccountIdList) {

            if (accountCount < 500) {
                Account acc = new Account();
                acc.Id = accId;
                acc.AgodiUpdateInProgress__c = false;
                accountUpdateList.add(acc);

                AccountSubsidiary__c accSub = new AccountSubsidiary__c();
                accSub.Account__c = accId;
                accSub.LegalName__c = 'Plantyn';
                accSub.AgodiUpdateIsRunning__c = true;
                accSubList.add(accSub);

                accountCount ++;
            } else {
                newCreatedAccountIdList.add(accId);
            }            
        }

        for (Id accId : this.updatedAccountIdList) {

            if (accountCount < 500) {
                Account acc = new Account();
                acc.Id = accId;
                acc.AgodiUpdateInProgress__c = false;
                accountUpdateList.add(acc);
                
                accountCount ++;
            } else {
                newUpdatedAccountIdList.add(accId);
            }
        }

        update accountUpdateList;
        insert accSubList;

        if (accountCount == 500) {
            Id jobId = System.enqueueJob(new AU_createAccSubsidiaries_queueable(newCreatedAccountIdList, newUpdatedAccountIdList));
            System.debug('AU_createAccSubsidiaries_queueable is enqueued with Job Id: ' + jobID);
        } else {
            System.debug('AU_createAccSubsidiaries_queueable = FINISHED!!!');
            if (!Test.isRunningTest()) {
                Id jobId = System.enqueueJob(new AU_activateAccSubsidiaries_queueable());
                System.debug('AU_activateAccSubsidiaries_queueable is enqueued with Job Id: ' + jobID);
            }
        }
        System.debug('AU_createAccSubsidiaries_queueable - execute - END');
    }
}