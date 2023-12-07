@IsTest
public class KLOPOTEK_ManageClassificationsSch_TEST {

    @IsTest
    public static void testSchedule(){
        String CRON_EXP = '0 0 0 ' + '01' + ' ' + string.valueof(system.now().month()+1) + ' ? ' + string.valueof(system.now().year());

        Test.startTest();

            String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new KLOPOTEK_ManageClassifications_scheduler());

            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
        
    }
}