@isTest
public with sharing class AU_AgodiUpdateTrigger_TEST {

    @TestSetup
    static void makeData(){

        Id recordTypeId = [SELECT Id FROM Recordtype WHERE sObjectType = 'Account' AND Name = 'B2B Educational' LIMIT 1].Id;
        
        List<Account> accountList = new List<Account>();
        for (Integer i=0; i < 5; i++) {
            Account Acc = new Account();
            Acc.RecordTypeId = recordTypeId;
            Acc.Name = 'School'+i;
            Acc.OperatingCompany__c = 'Plantyn';
            acc.CustomerCategory__c = 'Educational Institution';
            //Acc.CustomerDiscountGroup__c = acc.CustomerCategory__c;
            Acc.NetsuiteInternalId__c = '1234'+i;
            Acc.ShippingCity = 'Amsterdam';
            Acc.ShippingCountry = 'Netherlands';
            Acc.BillingCountry = 'Netherlands';
            Acc.ShippingPostalCode = '1224AM';
            Acc.ShippingStreet = 'DePijp22';
            Acc.invoicingEmail__c = 'test@test.be';
            Acc.Phone = '0123456789';
            Acc.Website = 'http://www.testwebsite.be';
            Acc.Type = 'Customer';
            Acc.Area__c = 'Dutch';
            Acc.ExternalDatabase__c = 'Agodi';
            Acc.ConverseImport__c = 'Plantyn Converse migration';
            Acc.NumberofStudents__c = 0;
            AccountList.Add(Acc);
        }
        accountList[0].ExternalCustomerId__c = '123456';
        accountList[1].ExternalCustomerId__c = '123457';
        accountList[2].ExternalCustomerId__c = '123458';
        accountList[3].ExternalCustomerId__c = '654321';
        accountList[4].ExternalCustomerId__c = '987654';
        insert accountList;

        AgodiUpdate__c au = new AgodiUpdate__c();
        insert au;

    }

    @IsTest
    static void Test01(){
        
        List<AgodiUpdate__c> auList = [SELECT Id, filesUploaded__c, updateIsRunning__c, Processed__c FROM AgodiUpdate__c];
        auList[0].filesUploaded__c = true;

        String fakeFileContentIM = 'crab_straat;huisnr;huisnr_ext;lange_naam_instelling;nummer;postcode;fusiegemeente;telefoon;telefax;e_mail;website\r\n'+
                'testStraat;1;b;TestAccount;123456;12345;testGemeente;0123456789;0123456798;test@test.be;www.testwebsite.be\r\n';

        insertFile(fakeFileContentIM, 'inrichtendeMachten.txt', auList[0].Id);

        Test.startTest();
            update auList;
        Test.stopTest();

        Account updatedPurchasingGroup = [SELECT Name, LegalName__c, BillingStreet, BillingPostalCode, BillingCity, Phone, invoicingEmail__c, Website, Type, BillingCountry FROM Account WHERE ExternalCustomerId__c = '123456' LIMIT 1];

        // Check PurchasingGroup
        System.assertEquals('TestAccount', updatedPurchasingGroup.LegalName__c);
        System.assertEquals(null, updatedPurchasingGroup.BillingStreet);
        System.assertEquals(null, updatedPurchasingGroup.BillingPostalCode);
        System.assertEquals(null, updatedPurchasingGroup.BillingCity);
        System.assertEquals('Netherlands', updatedPurchasingGroup.BillingCountry);
        System.assertEquals('0123456789', updatedPurchasingGroup.Phone);
        System.assertEquals('test@test.be', updatedPurchasingGroup.invoicingEmail__c);
        System.assertEquals('http://www.testwebsite.be', updatedPurchasingGroup.Website);
        
    }

    private static void insertFile(String content, String name, Id parentRecordId){
    
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

    }

}