@isTest
public class AU_processFiles_TEST {
    
    // @TestSetup
    // static void makeData(){
        
    //     Id recordTypeId = [SELECT Id FROM Recordtype WHERE sObjectType = 'Account' AND Name = 'B2B Educational' LIMIT 1].Id;

    //     List<Account> accountList = new List<Account>();
    //     for (Integer i=0; i < 5; i++) {
    //         Account Acc = new Account();
    //         Acc.RecordTypeId = recordTypeId;
    //         Acc.Name = 'School'+i;
    //         Acc.OperatingCompany__c = 'Plantyn';
    //         Acc.CustomerCategory__c = 'Educational Institution';
    //         Acc.NumberofStudents__c = 0;
    //         Acc.NetsuiteInternalId__c = '1234'+i;
    //         Acc.ShippingCity = 'Amsterdam';
    //         Acc.ShippingCountry = 'Netherlands';
    //         Acc.BillingCountry = 'Netherlands';
    //         Acc.ShippingPostalCode = '1224AM';
    //         Acc.ShippingStreet = 'DePijp22';
    //         Acc.invoicingEmail__c = 'test@test.be';
    //         Acc.Phone = '0123456789';
    //         Acc.Website = 'http://www.testwebsite.be';
    //         Acc.Type = 'Customer';
    //         Acc.Area__c = 'Dutch';
    //         Acc.ExternalDatabase__c = 'Agodi';
    //         Acc.ConverseImport__c = 'Plantyn Converse migration';
    //         AccountList.Add(Acc);
    //     }
    //     accountList[0].ExternalCustomerId__c = '123456';
    //     accountList[1].ExternalCustomerId__c = '123457';
    //     accountList[2].ExternalCustomerId__c = '123458';
    //     accountList[3].ExternalCustomerId__c = '654321';
    //     accountList[4].ExternalCustomerId__c = '987654';
    //     insert accountList;

    //     AgodiUpdate__c au = new AgodiUpdate__c();
    //     insert au;

    // }

    // @IsTest
    // static void TestInrichtendeMachtBatch(){
        
    //     AgodiUpdate__c au = [SELECT Id FROM AgodiUpdate__c LIMIT 1];
        
    //     String fakeFileContentIM = 'crab_straat;huisnr;huisnr_ext;lange_naam_instelling;nummer;postcode;fusiegemeente;telefoon;telefax;e_mail;website\r\n'+
    //             'testStraat;1;b;TestAccount;123456;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be\r\n';

    //     insertFile(fakeFileContentIM, 'inrichtendeMachten.txt', au.Id);

    //     List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :au.Id];

    //     List<Id> contentDocumentIds = new List<Id>();
    //     for (ContentDocumentLink cdl : contentDocumentLinks) {
    //         contentDocumentIds.add(cdl.ContentDocumentId);
    //     }

    //     Test.startTest();
    //         Id batchJobId = Database.executeBatch(new AU_processFiles(contentDocumentIds, au.Id), 1);
    //     Test.stopTest();

    //     Account updatedPurchasingGroup = [SELECT Name, LegalName__c, BillingStreet, BillingPostalCode, BillingCity, Phone, invoicingEmail__c, Website, Type, BillingCountry FROM Account WHERE ExternalCustomerId__c = '123456' LIMIT 1];

    //     // Check PurchasingGroup
    //     System.assertEquals('TestAccount', updatedPurchasingGroup.LegalName__c);
    //     System.assertEquals(null, updatedPurchasingGroup.BillingStreet);
    //     System.assertEquals(null, updatedPurchasingGroup.BillingPostalCode);
    //     System.assertEquals(null, updatedPurchasingGroup.BillingCity);
    //     System.assertEquals('Netherlands', updatedPurchasingGroup.BillingCountry);
    //     System.assertEquals('0123456789', updatedPurchasingGroup.Phone);
    //     System.assertEquals('test@test.be', updatedPurchasingGroup.invoicingEmail__c);
    //     System.assertEquals('http://www.testwebsite.be', updatedPurchasingGroup.Website);        
        
    // }

    // @IsTest
    // static void TestScholenGemeenschapBatch(){
        
    //     AgodiUpdate__c au = [SELECT Id FROM AgodiUpdate__c LIMIT 1];

    //     String fakeFileContentSG = 'crab_straat;huisnr;huisnr_ext;lange_naam_instelling;nummer;postnummer;fusiegemeente;telefoon;telefax;e_mail;website\r\n'+
    //             'testStraat;1;b;TestAccount;123457;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be\r\n';
        
    //     insertFile(fakeFileContentSG, 'scholenGemeenschappen.txt', au.Id);

    //     List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :au.Id];

    //     List<Id> contentDocumentIds = new List<Id>();
    //     for (ContentDocumentLink cdl : contentDocumentLinks) {
    //         contentDocumentIds.add(cdl.ContentDocumentId);
    //     }

    //     Test.startTest();
    //         Id batchJobId = Database.executeBatch(new AU_processFiles(contentDocumentIds, au.Id), 1);
    //     Test.stopTest();

    //     Account updatedFoundation = [SELECT Name, LegalName__c, BillingStreet, BillingPostalCode, BillingCity, Phone, invoicingEmail__c, Website, Type, BillingCountry FROM Account WHERE ExternalCustomerId__c = '123457' LIMIT 1];
        
    //     // Check Foundation
    //     System.assertEquals('TestAccount', updatedFoundation.LegalName__c);
    //     System.assertEquals(null, updatedFoundation.BillingStreet);
    //     System.assertEquals(null, updatedFoundation.BillingPostalCode);
    //     System.assertEquals(null, updatedFoundation.BillingCity);
    //     System.assertEquals('Netherlands', updatedFoundation.BillingCountry);
    //     System.assertEquals('0123456789', updatedFoundation.Phone);
    //     System.assertEquals('test@test.be', updatedFoundation.invoicingEmail__c);
    //     System.assertEquals('http://www.testwebsite.be', updatedFoundation.Website);
        
    // }

    // @IsTest
    // static void TestScholenBatch(){
        
    //     AgodiUpdate__c au = [SELECT Id FROM AgodiUpdate__c LIMIT 1];

    //     String fakeFileContentS = 'crab_straat;huisnr;huisnr_ext;lange_naam_instelling;nummer;postcode;fusiegemeente;telefoon;telefax;e_mail;website;scholengemeenschap;IM_nummer\r\n'+
    //             'testStraat;1;b;TestAccount;123458;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be;654321;987654\r\n';

    //     insertFile(fakeFileContentS, 'scholen1.txt', au.Id);

    //     List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :au.Id];

    //     List<Id> contentDocumentIds = new List<Id>();
    //     for (ContentDocumentLink cdl : contentDocumentLinks) {
    //         contentDocumentIds.add(cdl.ContentDocumentId);
    //     }

    //     Test.startTest();
    //         Id batchJobId = Database.executeBatch(new AU_processFiles(contentDocumentIds, au.Id), 1);
    //     Test.stopTest();

    //     Account updatedSchool = [SELECT Name, LegalName__c, BillingStreet, BillingPostalCode, BillingCity, Phone, invoicingEmail__c, Website, Type, BillingCountry, ParentId, PurchasingGroup__c FROM Account WHERE ExternalCustomerId__c = '123458' LIMIT 1];
    //     Id ParentId = [SELECT Id FROM Account WHERE ExternalCustomerId__c = '654321' LIMIT 1].Id;
    //     Id PurchasingGroupId = [SELECT Id FROM Account WHERE ExternalCustomerId__c = '987654' LIMIT 1].Id;

    //     // Check School
    //     System.assertEquals('TestAccount', updatedSchool.LegalName__c);
    //     System.assertEquals(null, updatedSchool.BillingStreet);
    //     System.assertEquals(null, updatedSchool.BillingPostalCode);
    //     System.assertEquals(null, updatedSchool.BillingCity);
    //     System.assertEquals('Netherlands', updatedSchool.BillingCountry);
    //     System.assertEquals('0123456789', updatedSchool.Phone);
    //     System.assertEquals('test@test.be', updatedSchool.invoicingEmail__c);
    //     System.assertEquals('http://www.testwebsite.be', updatedSchool.Website);
    //     System.assertEquals(ParentId, updatedSchool.ParentId);
    //     System.assertEquals(PurchasingGroupId, updatedSchool.PurchasingGroup__c);
        
    // }

    // private static void insertFile(String content, String name, Id parentRecordId){
    
    //     // create File (ContentVersion)
    //     ContentVersion conVer = new ContentVersion();
    //     conVer.ContentLocation = 'S';
    //     conVer.PathOnClient = name;
    //     conVer.Title = name;
    //     conVer.VersionData = Blob.valueOf(content);
    //     insert conVer;

    //     // Link file to object
    //     Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
    //     ContentDocumentLink conDocLink = New ContentDocumentLink();
    //     conDocLink.LinkedEntityId = parentRecordId;
    //     conDocLink.ContentDocumentId = conDoc;
    //     conDocLink.shareType = 'V';
    //     insert conDocLink;

    // }

}