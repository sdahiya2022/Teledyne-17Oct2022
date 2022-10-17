/*******************************************************************************************
* @author           DemandBlue
* @version          1.0 
* @date             10-OCT-2022
* @Status           In-Progress
* @Class Name       ForecastHelper
* @description      
*********************************************************************************************
 Version     Date      		Team         	 Comments
*********************************************************************************************
* 1.0      10-OCT-2022    	DemandBlue          Initial Creation
*********************************************************************************************/
/**
 * ForecastHelper is a helper class for populating Forecast records to be created for Masters
 */
public without sharing class ForecastHelper {
    /**
     * @description getForecastsForMasters(List<Master__c>,Boolean)
     * @return List<Forecast__c>
     * This method helps to create forecasts for Master records.
     * Inputs: masters = Master records which required to process for creating Forecasts
     *          futureOnly = # If this flag is true, then Forecasts will be created only for the sunday dates,
     *                       which are future dates of process running date
     *                       # If false, the all the missing date forecasts will be created.
     */
    public List<Forecast__c> getForecastsForMasters(List<Master__c> masters,Boolean futureOnly)
    {
        Set<Forecast__c> uniqueNewForecasts = new Set<Forecast__c>();
        List<Forecast__c> newForecasts = new List<Forecast__c>();
        List<Forecast__c> existingForcasts=new List<Forecast__c>();
        List<Date> sundayDatesOfFiscalYear = new List<Date>();
        Map<String,Forecast__c> mapMasterExistingForecast=new Map<String,Forecast__c>();
        Map<Id,List<Date>> mapMasterSundayDates = new Map<Id,List<Date>>();
        Forecast__c existingForecast = new Forecast__c();
        String key='';

        List<FiscalYearSettings> fiscalYear = [SELECT Name, StartDate, EndDate 
                                                FROM FiscalYearSettings 
                                                WHERE YearType='Custom' 
                                                AND StartDate <= TODAY AND EndDate >= TODAY 
                                                LIMIT 1];
        FiscalYearSettings fiscalYearSetting = fiscalYear[0];

        sundayDatesOfFiscalYear = getSundayDatesOfFiscalYear(futureOnly,fiscalYearSetting);       
        
        existingForcasts = [SELECT Id,Name, Date__c,FiscalYear__c,Master__c,Owner__c,Quarter__c,Week__c,Year__c,FiscalWeek__c
                            FROM Forecast__c
                            WHERE Master__c in:masters];
        
        for(Forecast__c forecast: existingForcasts)
        {
            key = forecast.master__c + '_'+String.valueOf(forecast.date__c);
            mapMasterExistingForecast.put(key,forecast);
        }

        for(Date sundayDate:sundayDatesOfFiscalYear)
        {
            for(Master__c master: masters)
            {
                key = master.Id + '_'+String.valueOf(sundayDate);
                existingForecast = mapMasterExistingForecast.get(key);
                if(existingForecast==null)
                {
                    Forecast__c newForecast = getNewForecast(sundayDate,master,fiscalYearSetting.Name);
                    uniqueNewForecasts.add(newForecast);
                }
            }
        }      
        if(uniqueNewForecasts.size()>0)
        {  
            newForecasts.addAll(uniqueNewForecasts);
        }
        return newForecasts;
    }
    
    private List<Date> getSundayDatesOfFiscalYear(Boolean futureOnly,FiscalYearSettings fiscalYearSetting)
    {
        List<Date> sundayDates= new List<Date>();        
        Date fromDate = futureOnly ? System.Today() : fiscalYearSetting.StartDate;
        sundayDates = DateUtility.getSundayDatesBetweenTwoDate(fromDate, fiscalYearSetting.EndDate);
        return sundayDates;
    }

    private Forecast__c getNewForecast(Date sundayDate,Master__c master,String fiscalYear)
    {
        MasterTagAndForecastPlanCreationHelper helper = new MasterTagAndForecastPlanCreationHelper();
        Forecast__c newForecast = new Forecast__c(
                            Name = master.Name + '_Forecast_W' + helper.isoWeekNumber(sundayDate) + '_Y' + sundayDate.year(),
                            Date__c = sundayDate, 
                            FiscalWeek__c = helper.isoWeekNumber(sundayDate),
                            Master__c = master.Id, 
                            FiscalYear__c = fiscalYear,
                            Owner__c = UserInfo.getUserId());        
        return newForecast;
    }
}