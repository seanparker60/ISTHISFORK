public with sharing class MERGE_StoreDeletedRecords_test {
    

    public static testmeothod void (){
    static void methodName(){
        
        Test.startTest();
            List<Account> createAccounts =  MERGE_TestDataFactory.createAccounts(1, 1);
            delete createAccounts;
        Test.stopTest();
        
    }


}
