@istest
public class AU_CreateAccountsFromAgodiData_TEST {

    @TestSetup
    static void makeData(){

        Id recordTypeId = [SELECT Id FROM Recordtype WHERE sObjectType = 'Account' AND Name = 'B2B Educational' LIMIT 1].Id;

        List<Account> accountList = new List<Account>();
        for (Integer i=0; i < 3; i++) {
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
            Acc.ExternalDatabase__c = 'Agodi';
            acc.Area__c = 'Dutch';
            acc.ConverseImport__c = 'Plantyn Converse migration';
            AccountList.Add(Acc);
        }
        accountList[0].ExternalCustomerId__c = '123456';
        accountList[1].ExternalCustomerId__c = '654321';
        accountList[2].ExternalCustomerId__c = '987654';
        insert accountList;

        AgodiUpdate__c au = new AgodiUpdate__c();
        insert au;

    }

    @IsTest
    static void TestgetCurrentPlantynAcsounts(){
        
        Map<String,Account> currentPlantynAccounts = new Map<String,Account>();
        Test.startTest();
            currentPlantynAccounts = AU_createAccountsFromAgodiData.getCurrentPlantynAccounts();
        Test.stopTest();
        
        system.assertEquals(3, currentPlantynAccounts.size());

    }

    // @IsTest
    // static void TestInrichtendeMachtenFileHandlingUpdate(){

    //     Id AgodiUpdateId = [SELECT Id FROM AgodiUpdate__c LIMIT 1].Id;
    //     Map<String,Account> currentPlantynAccounts = AU_createAccountsFromAgodiData.getCurrentPlantynAccounts();
    //     String fakeFileContent = 'crab_straat;huisnr;huisnr_ext;lange_naam_instelling;nummer;postcode;fusiegemeente;telefoon;telefax;e_mail;website\r\n'+
    //                             'testStraat;1;b;TestAccount;123456;12345;testGemeente;0123456789;0123456798;test@test.be;http://www.testwebsite.be\r\n';
    //     Test.startTest();
    //         AU_createAccountsFromAgodiData.inrichtendeMachten(fakeFileContent, currentPlantynAccounts, AgodiUpdateId);
    //     Test.stopTest();

    //     Account updatedAccount = [SELECT Name, LegalName__c, BillingStreet, BillingPostalCode, BillingCity, Phone, invoicingEmail__c, Website, Type, BillingCountry FROM Account WHERE ExternalCustomerId__c = '123456' LIMIT 1];

    //     System.assertEquals('TestAccount', updatedAccount.LegalName__c);
    //     System.assertEquals(null, updatedAccount.BillingStreet);
    //     System.assertEquals(null, updatedAccount.BillingPostalCode);
    //     System.assertEquals(null, updatedAccount.BillingCity);
    //     System.assertEquals('Netherlands', updatedAccount.BillingCountry);
    //     System.assertEquals('0123456789', updatedAccount.Phone);
    //     System.assertEquals('test@test.be', updatedAccount.invoicingEmail__c);
    //     System.assertEquals('http://www.testwebsite.be', updatedAccount.Website);
    //     System.assertEquals('Customer', updatedAccount.Type);
        
    // }

    // @IsTest
    // static void TestInrichtendeMachtenFileHandlingInsert(){
        
    //     Id AgodiUpdateId = [SELECT Id FROM AgodiUpdate__c LIMIT 1].Id;
    //     Map<String,Account> currentPlantynAccounts = AU_createAccountsFromAgodiData.getCurrentPlantynAccounts();
    //     String fakeFileContent = 'crab_straat;huisnr;huisnr_ext;lange_naam_instelling;nummer;postcode;fusiegemeente;telefoon;telefax;e_mail;website\r\n'+
    //                             'testStraat;1;b;TestAccount;456789;12345;testGemeente;0123456789;0123456798;test@test.be;http://www.testwebsite.be\r\n';
    //     Test.startTest();
    //         AU_createAccountsFromAgodiData.inrichtendeMachten(fakeFileContent, currentPlantynAccounts, AgodiUpdateId);
    //     Test.stopTest();

    //     Account insertedAccount = [SELECT Name, LegalName__c, BillingStreet, BillingPostalCode, BillingCity, Phone, invoicingEmail__c, Website, Type, BillingCountry, ExternalCustomerId__c FROM Account WHERE ExternalCustomerId__c = '456789' LIMIT 1];
    //     Integer numberOfAccounts = [SELECT COUNT() FROM Account];

    //     System.assertEquals('TestAccount', insertedAccount.LegalName__c);
    //     System.assertEquals('456789', insertedAccount.ExternalCustomerId__c);
    //     System.assertEquals('testStraat 1 b', insertedAccount.BillingStreet);
    //     System.assertEquals('12345', insertedAccount.BillingPostalCode);
    //     System.assertEquals('testGemeente', insertedAccount.BillingCity);
    //     System.assertEquals('Belgium', insertedAccount.BillingCountry);
    //     System.assertEquals('0123456789', insertedAccount.Phone);
    //     System.assertEquals('test@test.be', insertedAccount.invoicingEmail__c);
    //     System.assertEquals('http://www.testwebsite.be', insertedAccount.Website);
    //     System.assertEquals('Customer', insertedAccount.Type);
    //     System.assertEquals(4, numberOfAccounts);
        
    // }

    // @IsTest
    // static void TestScholengemeenschappenFileHandlingUpdate(){
        
    //     Id AgodiUpdateId = [SELECT Id FROM AgodiUpdate__c LIMIT 1].Id;
    //     Map<String,Account> currentPlantynAccounts = AU_createAccountsFromAgodiData.getCurrentPlantynAccounts();
    //     String fakeFileContent = 'crab_straat;huisnr;huisnr_ext;lange_naam_instelling;nummer;postnummer;fusiegemeente;telefoon;telefax;e_mail;website\r\n'+
    //                             'testStraat;1;b;TestAccount;123456;12345;testGemeente;0123456789;0123456798;test@test.be;www.testwebsite.be\r\n';
    //     Test.startTest();
    //         AU_createAccountsFromAgodiData.scholenGemeenschappen(fakeFileContent, currentPlantynAccounts, AgodiUpdateId);
    //     Test.stopTest();

    //     Account updatedAccount = [SELECT Name, LegalName__c, BillingStreet, BillingPostalCode, BillingCity, Phone, invoicingEmail__c, Website, Type, BillingCountry FROM Account WHERE ExternalCustomerId__c = '123456' LIMIT 1];

    //     System.assertEquals('TestAccount', updatedAccount.LegalName__c);
    //     System.assertEquals(null, updatedAccount.BillingStreet);
    //     System.assertEquals(null, updatedAccount.BillingPostalCode);
    //     System.assertEquals(null, updatedAccount.BillingCity);
    //     System.assertEquals('Netherlands', updatedAccount.BillingCountry);
    //     System.assertEquals('0123456789', updatedAccount.Phone);
    //     System.assertEquals('test@test.be', updatedAccount.invoicingEmail__c);
    //     System.assertEquals('http://www.testwebsite.be', updatedAccount.Website);
    //     System.assertEquals('Customer', updatedAccount.Type);
        
    // }

    // @IsTest
    // static void TestScholengemeenschappenFileHandlingInsert(){
        
    //     Id AgodiUpdateId = [SELECT Id FROM AgodiUpdate__c LIMIT 1].Id;
    //     Map<String,Account> currentPlantynAccounts = AU_createAccountsFromAgodiData.getCurrentPlantynAccounts();
    //     String fakeFileContent = 'crab_straat;huisnr;huisnr_ext;lange_naam_instelling;nummer;postnummer;fusiegemeente;telefoon;telefax;e_mail;website\r\n'+
    //                             'testStraat;1;b;TestAccount;456789;12345;testGemeente;0123456789;0123456798;test@test.be;www.testwebsite.be\r\n';
    //     Test.startTest();
    //         AU_createAccountsFromAgodiData.scholenGemeenschappen(fakeFileContent, currentPlantynAccounts, AgodiUpdateId);
    //     Test.stopTest();

    //     Account insertedAccount = [SELECT Name, LegalName__c, BillingStreet, BillingPostalCode, BillingCity, Phone, invoicingEmail__c, Website, Type, BillingCountry, ExternalCustomerId__c FROM Account WHERE ExternalCustomerId__c = '456789' LIMIT 1];
    //     Integer numberOfAccounts = [SELECT COUNT() FROM Account];
        
    //     System.assertEquals('TestAccount', insertedAccount.LegalName__c);
    //     System.assertEquals('456789', insertedAccount.ExternalCustomerId__c);
    //     System.assertEquals('testStraat 1 b', insertedAccount.BillingStreet);
    //     System.assertEquals('12345', insertedAccount.BillingPostalCode);
    //     System.assertEquals('testGemeente', insertedAccount.BillingCity);
    //     System.assertEquals('Belgium', insertedAccount.BillingCountry);
    //     System.assertEquals('0123456789', insertedAccount.Phone);
    //     System.assertEquals('test@test.be', insertedAccount.invoicingEmail__c);
    //     System.assertEquals('http://www.testwebsite.be', insertedAccount.Website);
    //     System.assertEquals('Customer', insertedAccount.Type);
    //     System.assertEquals(4, numberOfAccounts);
        
    // }

    // @IsTest
    // static void TestScholenFileHandlingUpdate(){

    //     Set<String> handledAgodiNumbers = new Set<String>();
        
    //     Id AgodiUpdateId = [SELECT Id FROM AgodiUpdate__c LIMIT 1].Id;
    //     Map<String,Account> currentPlantynAccounts = AU_createAccountsFromAgodiData.getCurrentPlantynAccounts();
    //     String fakeFileContent = 'crab_straat;huisnr;huisnr_ext;lange_naam_instelling;nummer;postcode;fusiegemeente;telefoon;telefax;e_mail;website;scholengemeenschap;IM_nummer\r\n'+
    //                             'testStraat;1;b;TestAccount;123456;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be;654321;987654\r\n'+
    //                             'testStraat;1;b;TestAccount;456799;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be;654321;987654\r\n'+
    //                             'testStraat;1;b;TestAccount;456799;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be;654321;987654\r\n'+
    //                             'testStraat;1;b;TestAccount;456799;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be;654321;987654\r\n'+
    //                             'testStraat;1;b;TestAccount;456799;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be;654321;987654\r\n'+
    //                             'testStraat;1;b;TestAccount;456799;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be;654321;987654\r\n'+
    //                             'testStraat;1;b;TestAccount;456799;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be;654321;987654\r\n'+
    //                             'testStraat;1;b;TestAccount;456799;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be;654321;987654\r\n';
    //     Test.startTest();
    //         AU_createAccountsFromAgodiData.scholen(fakeFileContent, currentPlantynAccounts, AgodiUpdateId, 1, handledAgodiNumbers);
    //     Test.stopTest();

    //     Account updatedAccount = [SELECT Name, LegalName__c, BillingStreet, BillingPostalCode, BillingCity, Phone, invoicingEmail__c, Website, Type, BillingCountry, ParentId, PurchasingGroup__c FROM Account WHERE ExternalCustomerId__c = '123456' LIMIT 1];
    //     Id ParentId = [SELECT Id FROM Account WHERE ExternalCustomerId__c = '654321' LIMIT 1].Id;
    //     Id PurchasingGroupId = [SELECT Id FROM Account WHERE ExternalCustomerId__c = '987654' LIMIT 1].Id;

    //     System.assertEquals('TestAccount', updatedAccount.LegalName__c);
    //     System.assertEquals(null, updatedAccount.BillingStreet);
    //     System.assertEquals(null, updatedAccount.BillingPostalCode);
    //     System.assertEquals(null, updatedAccount.BillingCity);
    //     System.assertEquals('Netherlands', updatedAccount.BillingCountry);
    //     System.assertEquals('0123456789', updatedAccount.Phone);
    //     System.assertEquals('test@test.be', updatedAccount.invoicingEmail__c);
    //     System.assertEquals('http://www.testwebsite.be', updatedAccount.Website);
    //     System.assertEquals('Customer', updatedAccount.Type);
    //     System.assertEquals(ParentId, updatedAccount.ParentId);
    //     System.assertEquals(PurchasingGroupId, updatedAccount.PurchasingGroup__c);
        
    // }

    // @IsTest
    // static void TestScholenFileHandlingInsert(){

    //     Set<String> handledAgodiNumbers = new Set<String>();
        
    //     Id AgodiUpdateId = [SELECT Id FROM AgodiUpdate__c LIMIT 1].Id;
    //     Map<String,Account> currentPlantynAccounts = AU_createAccountsFromAgodiData.getCurrentPlantynAccounts();
    //     String fakeFileContent = 'crab_straat;huisnr;huisnr_ext;lange_naam_instelling;nummer;postcode;fusiegemeente;telefoon;telefax;e_mail;website;scholengemeenschap;IM_nummer\r\n'+
    //                             'testStraat;1;b;TestAccount;456789;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be;654321;987654\r\n';
    //     Test.startTest();
    //         AU_createAccountsFromAgodiData.scholen(fakeFileContent, currentPlantynAccounts, AgodiUpdateId, 1, handledAgodiNumbers);
    //     Test.stopTest();

    //     Account insertedAccount = [SELECT Name, LegalName__c, BillingStreet, BillingPostalCode, BillingCity, Phone, invoicingEmail__c, Website, Type, BillingCountry, ParentId, PurchasingGroup__c, ExternalCustomerId__c FROM Account WHERE ExternalCustomerId__c = '456789' LIMIT 1];
    //     Id ParentId = [SELECT Id FROM Account WHERE ExternalCustomerId__c = '654321' LIMIT 1].Id;
    //     Id PurchasingGroupId = [SELECT Id FROM Account WHERE ExternalCustomerId__c = '987654' LIMIT 1].Id;
    //     Integer numberOfAccounts = [SELECT COUNT() FROM Account];

    //     System.assertEquals('TestAccount', insertedAccount.LegalName__c);
    //     System.assertEquals('testStraat 1 b', insertedAccount.BillingStreet);
    //     System.assertEquals('456789', insertedAccount.ExternalCustomerId__c);
    //     System.assertEquals('12345', insertedAccount.BillingPostalCode);
    //     System.assertEquals('testGemeente', insertedAccount.BillingCity);
    //     System.assertEquals('Belgium', insertedAccount.BillingCountry);
    //     System.assertEquals('0123456789', insertedAccount.Phone);
    //     System.assertEquals('test@test.be', insertedAccount.invoicingEmail__c);
    //     System.assertEquals('http://www.testwebsite.be', insertedAccount.Website);
    //     System.assertEquals('School', insertedAccount.Type);
    //     System.assertEquals(ParentId, insertedAccount.ParentId);
    //     System.assertEquals(PurchasingGroupId, insertedAccount.PurchasingGroup__c);
    //     System.assertEquals(4, numberOfAccounts);
        
    // }

}