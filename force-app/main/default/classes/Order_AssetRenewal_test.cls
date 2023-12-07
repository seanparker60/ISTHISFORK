@istest
public with sharing class Order_AssetRenewal_test {  
   
   public static testmethod void OrderAssetRenewal1 (){

      test.startTest();
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true); 
        
        
        List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Asset>lst_Asset = TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,false);
        Insert lst_Asset;

       List<Id> AssetId = new List<Id>();
       for(Asset ass:lst_Asset){
         AssetId.add(ass.Id);
       } 

       Order_AssetRenewal.RenewAssets(AssetId);

       test.stoptest();


   }
    
   public static testmethod void OrderAssetRenewal2 (){
      test.startTest();
      List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true);     
      List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
      Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
      List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
      List<Asset>lst_Asset = TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,false);
      
      List<Id> AssetId = new List<Id>();
      
      for(Asset ass:lst_Asset){        
         ass.PricingMethod__c ='AccountStudents';
      } 
    
      insert lst_Asset;
      for(Asset ass:lst_Asset){
         AssetId.add(ass.Id);        
      } 

      Order_AssetRenewal.RenewAssets(AssetId);


      test.stoptest();
 }


 public static testmethod void OrderAssetRenewal3 (){
   test.startTest();
   List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true);     
   List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
   Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
   List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
   
   List<ListPriceDiscount__c> ListPriceDiscount = Order_TestDataFactory.insertListPriceDiscount(5,'Regular','Workbooks',true);
        ListPriceDiscount = Order_TestDataFactory.insertListPriceDiscount(1,'Inspection Copy','Workbooks',false); 
   
   
   List<Asset>lst_Asset = TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,false);
   
   List<Id> AssetId = new List<Id>();
   for(Asset ass:lst_Asset){        
      ass.PricingMethod__c ='ProductUsageBased';
   } 

   insert lst_Asset;
   
   for(Asset ass:lst_Asset){
      AssetId.add(ass.Id);     
   } 
   Order_AssetRenewal.RenewAssets(AssetId);
   test.stoptest();
}


public static testmethod void OrderAssetRenewal4 (){
   test.startTest();
   List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true);     
   List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
   Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
   List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
   List<Asset>lst_Asset = TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,false);
   
   for(Asset ass:lst_Asset){
      ass.PricingMethod__c ='ProductDiscountGroupUsageBased';
   }     
   
   insert lst_Asset;

   UTIL_TestClassExceptions.TESTCLASSEXCEPTION=true;
   List<Id> AssetId = new List<Id>();
   for(Asset ass:lst_Asset){
      AssetId.add(ass.Id);     
   } 
   Order_AssetRenewal.RenewAssets(AssetId);

   test.stoptest();
}

public static testmethod void OrderAssetRenewal5 (){
   test.startTest();
   List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true);     
   List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
   Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
   List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
   List<Asset>lst_Asset = TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,false);
   
   for(Asset ass:lst_Asset){
      ass.PricingMethod__c ='ProductDiscountGroupUsageBased';
   }     
   
   insert lst_Asset;

   UTIL_TestClassExceptions.TESTCLASSEXCEPTION=true;
   List<Id> AssetId = new List<Id>();
   for(Asset ass:lst_Asset){
      AssetId.add(ass.Id);     
   } 
   Order_AssetRenewal.RenewAssets();

   test.stoptest();
}


}