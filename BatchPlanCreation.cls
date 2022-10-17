/*******************************************************************************************
* @author           DemandBlue
* @version          1.0 
* @date             10-OCT-2022
* @Status           In-Progress
* @Class Name       BatchPlanCreationYearly
* @description      
*********************************************************************************************
 Version     Date      		Team         	 Comments
*********************************************************************************************
* 1.0      10-OCT-2022    	DemandBlue          Initial Creation
*********************************************************************************************/
/**
 * BatchPlanCreationYearly is a batch for populating Forecast records to be created for Masters yearly
 */
public class BatchPlanCreationYearly implements Database.Batchable<Master__c>, Schedulable
{
    //batch start
    public List<Master__c> start(Database.BatchableContext context)
    {
        List<Master__c> mastersToProcess= [SELECT Id,Name FROM Master__c WHERE Active__c = true ];
        return mastersToProcess;
    }
    //batch execute
    public void execute(Database.BatchableContext batchContext, List<Master__c> masters)
    {
        List<Plan__c> newPlans = new List<Plan__c>();
        try{
            //it will get the Forecost records to be created for future dates from the date the job executing.
            newPlans = (new PlanHelper()).getPlansForMasters(masters,true);
            if(newPlans!=null)
            {
                insert newPlans;
            }
        }
        catch(Exception ex)
        {
            System.debug('Exception occured while inserting forecast records-BatchPlanCreationYearly!');
            System.debug('Error: '+ex.getMessage());
            System.debug('StackTrace: ' +ex.getStackTraceString());
        }
    }
    //batch finish
    public void finish(Database.BatchableContext batchContext)
    {
        System.debug('BatchPlanCreationYearly finished');
    }

    //Shedule execute
    public void execute(SchedulableContext sc) 
    {
        Database.executeBatch(new BatchPlanCreationYearly());
    }

    public void unschedule(String scheduleName) {
        List<CronTrigger> scheduledJobs = [SELECT Id, CronJobDetail.Name
                                          FROM CronTrigger
                                          WHERE CronJobDetail.Name =:scheduleName];
        for(CronTrigger c:scheduledJobs) {
          System.abortJob(c.Id);
        }
    }
}