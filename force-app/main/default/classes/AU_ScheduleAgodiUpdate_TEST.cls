@isTest
public class AU_ScheduleAgodiUpdate_TEST {

    public static String CRON_EXP = '0 0 0 15 3 ? 2023';

    public static final String fakeLocationBody = '"tabel";"datum_publicatie";"link_tabel";"link_wijz"\r\n' +
    '"Scholen";21/12/2020 0:00:00;"fakeFileLocation1";"fakeFileLocation1_2"\r\n' +
    '"Scholengemeenschappen";7/1/2019 0:00:00;"fakeFileLocation2";"fakeFileLocation2_2"\r\n' +
    '"Inrichtende_machten";16/5/2011 0:00:00;"fakeFileLocation3";"fakeFileLocation3_2"';

    public static final String fakeScholenBody = 'crab_straat;huisnr;huisnr_ext;lange_naam_instelling;nummer;postcode;fusiegemeente;telefoon;telefax;e_mail;website;scholengemeenschap;IM_nummer\r\n'+
    'testStraat;1;b;TestAccount;123458;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be;654321;987654\r\n';
    public static final String fakeScholenGemeenschappenBody = 'crab_straat;huisnr;huisnr_ext;lange_naam_instelling;nummer;postnummer;fusiegemeente;telefoon;telefax;e_mail;website\r\n'+
    'testStraat;1;b;TestAccount;123457;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be\r\n';
    public static final String fakeInrichtendeMachtenBody = 'crab_straat;huisnr;huisnr_ext;lange_naam_instelling;nummer;postcode;fusiegemeente;telefoon;telefax;e_mail;website\r\n'+
    'testStraat;1;b;TestAccount;123456;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be\r\n';

    public static Boolean testInrichtendeMachten = false;
    public static Boolean testScholenGemeenschappen = false;
    public static Boolean testScholen = false;

    private class Mock implements HttpCalloutMock {

        public HttpResponse respond (HttpRequest req) {
            
            String body = '';

            if(req.getEndpoint() == 'https://agodi.be/sites/default/files/atoms/files/links_meest_recent_0.txt') {
                body = fakeLocationBody;
            } else if (req.getEndpoint() == 'fakeFileLocation1') {
                body = fakeScholenBody;
            } else if (req.getEndpoint() == 'fakeFileLocation2') {
                body = fakeScholenGemeenschappenBody;
            } else if (req.getEndpoint() == 'fakeFileLocation3') {
                body = fakeInrichtendeMachtenBody;
            } else {
                System.debug('==> Unknown Endpoint found: ' + req.getEndpoint());
            }
            
            HttpResponse res = new HttpResponse();

            res.setBody(body);
            res.setStatusCode(200);
            return Res;
        }
    }

    @IsTest
    public static void TestSchedule() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock());

            String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new AU_ScheduleAgodiUpdate());

        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2023-03-15 00:00:00', String.valueOf(ct.NextFireTime));

    }
}