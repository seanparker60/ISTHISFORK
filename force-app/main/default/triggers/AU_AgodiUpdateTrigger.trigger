trigger AU_AgodiUpdateTrigger on AgodiUpdate__c (after update, after insert) {

    if (trigger.isUpdate) {

        if (trigger.isAfter) {
            AU_TriggerHandler.passFilesToBatch(trigger.new);
        }
    }

}