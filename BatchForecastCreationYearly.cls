/*******************************************************************************************
* @author           DemandBlue
* @version          1.0 
* @date             10-OCT-2022
* @Class Name       BatchForecastCreationYearly
* @description      
*********************************************************************************************
 Version     Date      		Team         	 Comments
*********************************************************************************************
* 1.0      10-OCT-2022    	DemandBlue          Initial Creation
*********************************************************************************************/
/**
 * BatchForecastCreationYearly is a batch for populating Forecast records to be created for Masters yearly
 */
public class BatchForecastCreationYearly implements Database.Batchable<Master__c>, Schedulable
{
    //batch start
    public List<Master__c> start(Database.BatchableContext context)
    {
        List<Master__c> mastersToProcess= [SELECT Id,Name FROM Master__c WHERE Active__c = true];
        return mastersToProcess;
    }
    //batch execute
    public void execute(Database.BatchableContext batchContext, List<Master__c> masters)
    {
        List<Forecast__c> newForecasts = new List<Forecast__c>();
        try{
            //it will get the Forecost records to be created for future dates from the date the job executing.
            newForecasts = (new ForecastHelper()).getForecastsForMasters(masters,true);
            if(newForecasts!=null)
            {
                insert newForecasts;
            }
        }
        catch(Exception ex)
        {
            System.debug('Exception occured while inserting forecast records-BatchForecastCreationYearly!');
            System.debug('Error: '+ex.getMessage());
            System.debug('StackTrace: ' +ex.getStackTraceString());
        }
    }
    //batch finish
    public void finish(Database.BatchableContext batchContext)
    {
        System.debug('BatchForecastCreationYearly finished');
    }

    //Shedule execute
    public void execute(SchedulableContext sc) 
    {
        Database.executeBatch(new BatchForecastCreationYearly());
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