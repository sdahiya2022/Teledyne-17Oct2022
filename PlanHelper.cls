/*******************************************************************************************
* @author           DemandBlue
* @version          1.0 
* @date             10-OCT-2022
* @Status           In-Progress
* @Class Name       PlanHelper
* @description      
*********************************************************************************************
 Version     Date      		Team         	 Comments
*********************************************************************************************
* 1.0      10-OCT-2022    	DemandBlue          Initial Creation
*********************************************************************************************/
/**
 * PlanHelper is a helper class for populating Forecast records to be created for Masters
 */
public without sharing class PlanHelper {
    /**
     * @description getPlanForMasters(List<Master__c>,Boolean)
     * @return List<Plan__c>
     * This method helps to create Plans for Master records.
     * Inputs: masters = Master records which required to process for creating Plans
     *          futureOnly = # If this flag is true, then Plans will be created only for the sunday dates,
     *                       which are future dates of process running date
     *                       # If false, the all the missing date Plans will be created.
     */
    public List<Plan__c> getPlansForMasters(List<Master__c> masters,Boolean futureOnly)
    {
        Set<Plan__c> uniqueNewPlans = new Set<Plan__c>();
        List<Plan__c> newPlans = new List<Plan__c>();
        List<Plan__c> existingPlans=new List<Plan__c>();
        List<Date> sundayDatesOfFiscalYear = new List<Date>();
        Map<String,Plan__c> mapMasterExistingPlan =new Map<String,Plan__c>();
        Map<Id,List<Date>> mapMasterSundayDates = new Map<Id,List<Date>>();
        Plan__c existingPlan = new Plan__c();
        String key='';

        List<FiscalYearSettings> fiscalYear = [SELECT Name, StartDate, EndDate 
                                                FROM FiscalYearSettings 
                                                WHERE YearType='Custom' 
                                                AND StartDate <= TODAY AND EndDate >= TODAY 
                                                LIMIT 1];
        FiscalYearSettings fiscalYearSetting = fiscalYear[0];

        sundayDatesOfFiscalYear = getSundayDatesOfFiscalYear(futureOnly,fiscalYearSetting);       
        
        existingPlans = [SELECT Id,Name, Date__c,FiscalYear__c,Master__c,Owner__c,Quarter__c,FiscalWeek__c,Week__c,Year__c

                            FROM Plan__c
                            WHERE Master__c in:masters ];
        
        for(Plan__c Plan: existingPlans)
        {
            key = Plan.master__c + '_'+String.valueOf(Plan.date__c);
            mapMasterExistingPlan.put(key,Plan);
        }

        for(Date sundayDate:sundayDatesOfFiscalYear)
        {
            for(Master__c master: masters)
            {
                key = master.Id + '_'+String.valueOf(sundayDate);
                existingPlan = mapMasterExistingPlan.get(key);
                if(existingPlan == null)
                {
                    Plan__c newPlan = getNewPlan(sundayDate,master,fiscalYearSetting.Name);
                    uniqueNewPlans.add(newPlan);
                }
            }
        }      
        if(uniqueNewPlans.size()>0)
        {  
            newPlans.addAll(uniqueNewPlans);
        }
        return newPlans;
    }
    
    private List<Date> getSundayDatesOfFiscalYear(Boolean futureOnly,FiscalYearSettings fiscalYearSetting)
    {
        List<Date> sundayDates= new List<Date>();        
        Date fromDate = futureOnly ? System.Today() : fiscalYearSetting.StartDate;
        sundayDates = DateUtility.getSundayDatesBetweenTwoDate(fromDate, fiscalYearSetting.EndDate);
        return sundayDates;
    }

    private Plan__c getNewPlan(Date sundayDate,Master__c master,String fiscalYear)
    {
        MasterTagAndForecastPlanCreationHelper helper = new MasterTagAndForecastPlanCreationHelper();
        Plan__c newPlan = new Plan__c(
                            Name = master.Name + '_Plan_W' + helper.isoWeekNumber(sundayDate) + '_Y' + sundayDate.year(),
                            Date__c = sundayDate, 
                            FiscalWeek__c = helper.isoWeekNumber(sundayDate),
                            Master__c = master.Id, 
                            FiscalYear__c = fiscalYear,
                            Owner__c = UserInfo.getUserId());        
        return newPlan;
    }
}