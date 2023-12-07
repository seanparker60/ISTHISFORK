@isTest
public class FRM_scheduleFirstReleaseManagement_TEST {

    //public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    @IsTest
    public static void testSchedule(){
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        CRON_EXP = '0 0 0 ' + '01' +' ' + string.valueof(system.now().month() + 1) + ' ? ' + string.valueof(system.now().year());

        Test.startTest();

            String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new FRM_scheduleFirstReleaseManagement('Plantyn'));

            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
        
    }
}