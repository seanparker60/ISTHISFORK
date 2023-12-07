public class KLOPOTEK_ManageClassifications {
    
    public static void createClassifications(List<KlopotekClassification__c> klopotekClassificationList) {

        List<String> teacherNumbers = new List<String>();
        List<String> schoolNumbers = new List<String>();
        for (KlopotekClassification__c kc : klopotekClassificationList) {
                teacherNumbers.add(kc.DocNr__c);
                if (kc.SchNr__c != '' && kc.SchNr__c != null) {
                    schoolNumbers.add(kc.SchNr__c);
                }
        }

        // Get Noordhoff Data
        Map<String, ClassificationAttributeTemplate__c> noordhoffTemplates = getTemplates('Noordhoff');
        Map<String, Id> noordhoffContacts = getContacts('Noordhoff', teacherNumbers);
        Map<String, Id> noordhoffAccounts = getAccounts('Noordhoff', schoolNumbers);
        // Get Plantyn Data
        Map<String, ClassificationAttributeTemplate__c> plantynTemplates = getTemplates('Plantyn');
        Map<String, Id> plantynContacts = getContacts('Plantyn',teacherNumbers);
        Map<String, Id> plantynAccounts = getAccounts('Plantyn', schoolNumbers);
        // Get Liber Data
        Map<String, ClassificationAttributeTemplate__c> liberTemplates = getTemplates('Liber');
        Map<String, Id> liberContacts = getContacts('Liber', teacherNumbers);
        Map<String, Id> liberAccounts = getAccounts('Liber', schoolNumbers);

        List<ClassificationData__c> cdInsertList = new List<ClassificationData__c>();
        List<KlopotekClassification__c> kcUpdateList = new List<KlopotekClassification__c>();

        for (KlopotekClassification__c kc : klopotekClassificationList) {

            kc.ErrorMessage__c = '';

            Boolean createClassificationData = true;
            Boolean templateFound = false;
            ClassificationAttributeTemplate__c cat = new ClassificationAttributeTemplate__c();

            ClassificationData__c cd = new ClassificationData__c();
            
            if (kc.OperatingCompany__c == 'Noordhoff') {

                cd.OperatingCompany__c = 'Noordhoff';
                cat = noordhoffTemplates.get(kc.CatCode__c);

                if (kc.DocNr__c != null && kc.DocNr__c != '') {
                    cd.Contact__c = noordhoffContacts.get(kc.DocNr__c);
                    cd.ContactClassificationAccount__c = noordhoffAccounts.get(kc.SchNr__c);
                } else {
                    cd.Account__c = noordhoffAccounts.get(kc.SchNr__c);
                    if (kc.ValueDecimal__c != null) {
                        cd.NumberOfStudents__c = kc.ValueDecimal__c;
                    }
                }

            } else if (kc.OperatingCompany__c == 'Plantyn') {

                cd.OperatingCompany__c = 'Plantyn';
                cat = plantynTemplates.get(kc.CatCode__c);

                if (kc.DocNr__c != null && kc.DocNr__c != '') {
                    cd.Contact__c = plantynContacts.get(kc.DocNr__c);
                    cd.ContactClassificationAccount__c = plantynAccounts.get(kc.SchNr__c);
                } else {
                    cd.Account__c = plantynAccounts.get(kc.SchNr__c);
                    if (kc.ValueDecimal__c != null) {
                        cd.NumberOfStudents__c = kc.ValueDecimal__c;
                    }
                }

            } else if (kc.OperatingCompany__c == 'Liber') {

                cd.OperatingCompany__c = 'Liber';
                cat = liberTemplates.get(kc.CatCode__c);

                if (kc.DocNr__c != null && kc.DocNr__c != '') {
                    cd.Contact__c = liberContacts.get(kc.DocNr__c);
                    cd.ContactClassificationAccount__c = liberAccounts.get(kc.SchNr__c);
                } else {
                    cd.Account__c = liberAccounts.get(kc.SchNr__c);
                    if (kc.ValueDecimal__c != null) {
                        cd.NumberOfStudents__c = kc.ValueDecimal__c;
                    }
                }

            } else {
                System.debug('No OperatingCompany found on Klopotek Classification Record with Id ' + kc.Id);
                kc.ErrorMessage__c = 'No OperatingCompany found on Klopotek Classification Record';
                createClassificationData = false;
            }

            if (cat != null) {
                cd.ClassificationAttribute__c = cat.ClassificationAttributeId__c;
                cd.ClassificationAttributeValue__c = cat.ClassificationAttributeValueId__c;
                cd.ClassificationAttributeSubValue__c = cat.ClassificationAttributeSubValueId__c;
                cd.ClassificationAttributeSubValue2__c = cat.ClassificationAttributeSubValueId2__c;
                cd.ClassificationAttributeSubValue3__c = cat.ClassificationAttributeSubValueId3__c;
                cd.ClassificationAttributeSubValue4__c = cat.ClassificationAttributeSubValueId4__c;
                cd.Active__c = true;
            } else {
                System.debug('No template found for ==> ' + kc.CatCode__c);
                kc.ErrorMessage__c = 'No template found for ==> ' + kc.CatCode__c;
                createClassificationData = false;
            }
            

            if (createClassificationData) {
                cdInsertList.add(cd);

                kc.IsProcessed__c = true;
            }

            kcUpdateList.add(kc);

        }

        try {
            update kcUpdateList;
        } catch (Exception e) {
            HandleCustomException.LogException(e);
            System.debug('ERROR updating the Classification Template List ==> ' + e.getMessage());
        }

        try {
            insert cdInsertList;
        } catch (Exception e) {
            HandleCustomException.LogException(e);
            System.debug('ERROR inserting the Classification Data List ==> ' + e.getMessage());
        }

    }

    public static Map<String, ClassificationAttributeTemplate__c> getTemplates(String opCo) {

        List<ClassificationAttributeTemplate__c> templateList = new List<ClassificationAttributeTemplate__c>();
        Map<String, ClassificationAttributeTemplate__c> templateMap = new Map<String, ClassificationAttributeTemplate__c>();

        templateList = [SELECT Id, 
                            ClassificationCode__c, 
                            ClassificationAttributeId__c, 
                            ClassificationAttributeValueId__c, 
                            ClassificationAttributeSubValueId__c, 
                            ClassificationAttributeSubValueId2__c, 
                            ClassificationAttributeSubValueId3__c, 
                            ClassificationAttributeSubValueId4__c 
                            FROM ClassificationAttributeTemplate__c
                            WHERE OperatingCompany__c = :opCo];

        for (ClassificationAttributeTemplate__c cat : templateList) {
            templateMap.put(cat.ClassificationCode__c, cat);
        } 

        return templateMap;
    }

    public static Map<String, Id> getContacts(String opCo, List<String> teacherNumbers) {

        List<Contact> contactList = new List<Contact>();
        Map<String, Id> contactIdMap = new Map<String, Id>();

        // create ContactId Map
        contactList = [SELECT Id, TeacherNumber__c FROM Contact WHERE OperatingCompany__c = :opCo AND TeacherNumber__c != '' AND TeacherNumber__c IN :teacherNumbers];
        for (Contact c : contactList) {
            contactIdMap.put(c.TeacherNumber__c, c.Id);
        }

        return contactIdMap;
    }

    public static Map<String, Id> getAccounts(String opCo, List<String> schoolNumbers) {

        List<Account> accountList = new List<Account>();
        Map<String, Id> accountIdMap = new Map<String, Id>();

        // create AccountId Map
        accountList = [SELECT Id, ExternalCustomerId__c FROM Account WHERE OperatingCompany__c = :opCo AND ExternalCustomerId__c != '' AND ExternalCustomerId__c IN :schoolNumbers];
        for (Account a : accountList) {
            accountIdMap.put(a.ExternalCustomerId__c, a.Id);
        }

        return accountIdMap;
    }

}