@isTest
public with sharing class AU_GetAgodiFiles_TEST {

    // public static final String fakeLocationBody = '"tabel";"datum_publicatie";"link_tabel";"link_wijz"\r\n' +
    // '"Scholen";21/12/2020 0:00:00;"fakeFileLocation1";"fakeFileLocation1_2"\r\n' +
    // '"Scholengemeenschappen";7/1/2019 0:00:00;"fakeFileLocation2";"fakeFileLocation2_2"\r\n' +
    // '"Inrichtende_machten";16/5/2011 0:00:00;"fakeFileLocation3";"fakeFileLocation3_2"';

    // public static final String fakeScholenBody = 'crab_straat;huisnr;huisnr_ext;lange_naam_instelling;nummer;postcode;fusiegemeente;telefoon;telefax;e_mail;website;scholengemeenschap;IM_nummer\r\n'+
    // 'testStraat;1;b;TestAccount;123458;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be;654321;987654\r\n';
    // public static final String fakeScholenGemeenschappenBody = 'crab_straat;huisnr;huisnr_ext;lange_naam_instelling;nummer;postnummer;fusiegemeente;telefoon;telefax;e_mail;website\r\n'+
    // 'testStraat;1;b;TestAccount;123457;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be\r\n';
    // public static final String fakeInrichtendeMachtenBody = 'crab_straat;huisnr;huisnr_ext;lange_naam_instelling;nummer;postcode;fusiegemeente;telefoon;telefax;e_mail;website\r\n'+
    // 'testStraat;1;b;TestAccount;123456;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be\r\n';

    // public static Boolean testInrichtendeMachten = false;
    // public static Boolean testScholenGemeenschappen = false;
    // public static Boolean testScholen = false;

    // private class Mock implements HttpCalloutMock {

    //     public HttpResponse respond (HttpRequest req) {
            
    //         String body = '';

    //         if(req.getEndpoint() == 'https://agodi.be/sites/default/files/atoms/files/links_meest_recent_0.txt') {
    //             body = fakeLocationBody;
    //         } else if (req.getEndpoint() == 'fakeFileLocation1' && testScholen) {
    //             body = fakeScholenBody;
    //         } else if (req.getEndpoint() == 'fakeFileLocation2' && testScholenGemeenschappen) {
    //             body = fakeScholenGemeenschappenBody;
    //         } else if (req.getEndpoint() == 'fakeFileLocation3' && testInrichtendeMachten) {
    //             body = fakeInrichtendeMachtenBody;
    //         } else {
    //             System.debug('==> Unknown Endpoint found: ' + req.getEndpoint());
    //         }

    //         HttpResponse res = new HttpResponse();

    //         res.setBody(body);
    //         res.setStatusCode(200);
    //         return Res;
    //     }
    //}

    @TestSetup
    static void makeData(){
        
        // Id recordTypeId = [SELECT Id FROM Recordtype WHERE sObjectType = 'Account' AND Name = 'B2B Educational' LIMIT 1].Id;

        // List<Account> accountList = new List<Account>();
        // for (Integer i=0; i < 5; i++) {
        //     Account Acc = new Account();
        //     Acc.RecordTypeId = recordTypeId;
        //     Acc.Name = 'School'+i;
        //     Acc.OperatingCompany__c = 'Plantyn';
        //     acc.CustomerCategory__c = 'Educational Institution';
        //     //Acc.CustomerDiscountGroup__c = acc.CustomerCategory__c;
        //     Acc.NetsuiteInternalId__c = '1234'+i;
        //     Acc.ShippingCity = 'Amsterdam';
        //     Acc.ShippingCountry = 'Netherlands';
        //     Acc.ShippingPostalCode = '1224AM';
        //     Acc.ShippingStreet = 'DePijp22';
        //     Acc.invoicingEmail__c = 'test@test.be';
        //     Acc.Phone = '0123456789';
        //     Acc.Website = 'http://www.testwebsite.be';
        //     Acc.Type = 'Customer';
        //     Acc.ExternalDatabase__c = 'Agodi';
        //     Acc.Area__c = 'Dutch';
        //     Acc.ConverseImport__c = 'Plantyn Converse migration';
        //     AccountList.Add(Acc);
        // }
        // accountList[0].ExternalCustomerId__c = '123456';
        // accountList[1].ExternalCustomerId__c = '123457';
        // accountList[2].ExternalCustomerId__c = '123458';
        // accountList[3].ExternalCustomerId__c = '654321';
        // accountList[4].ExternalCustomerId__c = '987654';
        // insert accountList;

        // AgodiUpdate__c au = new AgodiUpdate__c();
        // insert au;

    }

    @isTest
    static void TestInrichtendeMachten(){

        // Test.startTest();
        //     testScholen = false;
        //     testInrichtendeMachten = true;
        //     testScholenGemeenschappen = false;
        //     Test.setMock(HttpCalloutMock.class, new Mock());
            
        //     System.enqueueJob(new AU_agodiUpdate());
        // Test.stopTest();

        // Account updatedPurchasingGroup = [SELECT Name, LegalName__c, BillingStreet, BillingPostalCode, BillingCity, Phone, invoicingEmail__c, Website, Type, BillingCountry FROM Account WHERE ExternalCustomerId__c = '123456' LIMIT 1];

        // // Check PurchasingGroup
        // System.assertEquals('TestAccount', updatedPurchasingGroup.LegalName__c);
        // System.assertEquals('testStraat 1 b', updatedPurchasingGroup.BillingStreet);
        // System.assertEquals('12345', updatedPurchasingGroup.BillingPostalCode);
        // System.assertEquals('testGemeente', updatedPurchasingGroup.BillingCity);
        // System.assertEquals('Belgium', updatedPurchasingGroup.BillingCountry);
        // System.assertEquals('0123456789', updatedPurchasingGroup.Phone);
        // System.assertEquals('test@test.be', updatedPurchasingGroup.invoicingEmail__c);
        // System.assertEquals('http://www.testwebsite.be', updatedPurchasingGroup.Website);
        
    }

    @isTest
    static void TestScholenGemeenschappen(){

        // Test.startTest();
        //     testScholen = false;
        //     testInrichtendeMachten = false;
        //     testScholenGemeenschappen = true;
        //     Test.setMock(HttpCalloutMock.class, new Mock());
            
        //     System.enqueueJob(new AU_agodiUpdate());
        // Test.stopTest();

        // Account updatedFoundation = [SELECT Name, LegalName__c, BillingStreet, BillingPostalCode, BillingCity, Phone, invoicingEmail__c, Website, Type, BillingCountry FROM Account WHERE ExternalCustomerId__c = '123457' LIMIT 1];
        
        // // Check Foundation
        // System.assertEquals('TestAccount', updatedFoundation.LegalName__c);
        // System.assertEquals('testStraat 1 b', updatedFoundation.BillingStreet);
        // System.assertEquals('12345', updatedFoundation.BillingPostalCode);
        // System.assertEquals('testGemeente', updatedFoundation.BillingCity);
        // System.assertEquals('Belgium', updatedFoundation.BillingCountry);
        // System.assertEquals('0123456789', updatedFoundation.Phone);
        // System.assertEquals('test@test.be', updatedFoundation.invoicingEmail__c);
        // System.assertEquals('http://www.testwebsite.be', updatedFoundation.Website);
        
    }

    @IsTest
    static void TestScholen(){

        // Test.startTest();
        //     testScholen = true;
        //     testInrichtendeMachten = false;
        //     testScholenGemeenschappen = false;
        //     Test.setMock(HttpCalloutMock.class, new Mock());

        //     System.enqueueJob(new AU_agodiUpdate());
        // Test.stopTest();

        // Account updatedSchool = [SELECT Name, LegalName__c, BillingStreet, BillingPostalCode, BillingCity, Phone, invoicingEmail__c, Website, Type, BillingCountry, ParentId, PurchasingGroup__c FROM Account WHERE ExternalCustomerId__c = '123458' LIMIT 1];
        // Id ParentId = [SELECT Id FROM Account WHERE ExternalCustomerId__c = '654321' LIMIT 1].Id;
        // Id PurchasingGroupId = [SELECT Id FROM Account WHERE ExternalCustomerId__c = '987654' LIMIT 1].Id;

        // // Check School
        // System.assertEquals('TestAccount', updatedSchool.LegalName__c);
        // System.assertEquals('testStraat 1 b', updatedSchool.BillingStreet);
        // System.assertEquals('12345', updatedSchool.BillingPostalCode);
        // System.assertEquals('testGemeente', updatedSchool.BillingCity);
        // System.assertEquals('Belgium', updatedSchool.BillingCountry);
        // System.assertEquals('0123456789', updatedSchool.Phone);
        // System.assertEquals('test@test.be', updatedSchool.invoicingEmail__c);
        // System.assertEquals('http://www.testwebsite.be', updatedSchool.Website);
        // System.assertEquals(ParentId, updatedSchool.ParentId);
        // System.assertEquals(PurchasingGroupId, updatedSchool.PurchasingGroup__c);
        
    }

    @isTest
    static void TestSchedulableInrichtendeMachten(){

        // AgodiUpdate__c au = [SELECT Id FROM AgodiUpdate__c LIMIT 1];

        // Test.startTest();

        //     testScholen = false;
        //     testInrichtendeMachten = true;
        //     testScholenGemeenschappen = false;
        //     Test.setMock(HttpCalloutMock.class, new Mock());
            
        //     System.enqueueJob(new AU_agodiUpdate());
        // Test.stopTest();

        // Account updatedPurchasingGroup = [SELECT Name, LegalName__c, BillingStreet, BillingPostalCode, BillingCity, Phone, invoicingEmail__c, Website, Type, BillingCountry FROM Account WHERE ExternalCustomerId__c = '123456' LIMIT 1];

        // // Check PurchasingGroup
        // System.assertEquals('TestAccount', updatedPurchasingGroup.LegalName__c);
        // System.assertEquals('testStraat 1 b', updatedPurchasingGroup.BillingStreet);
        // System.assertEquals('12345', updatedPurchasingGroup.BillingPostalCode);
        // System.assertEquals('testGemeente', updatedPurchasingGroup.BillingCity);
        // System.assertEquals('Belgium', updatedPurchasingGroup.BillingCountry);
        // System.assertEquals('0123456789', updatedPurchasingGroup.Phone);
        // System.assertEquals('test@test.be', updatedPurchasingGroup.invoicingEmail__c);
        // System.assertEquals('http://www.testwebsite.be', updatedPurchasingGroup.Website);
        
    }

}