/*******************************************************************************************
* @author           Suman
* @version          1.0 
* @date             20-SEP-2022
* @Status           In-Progress
* @Class Name       MasterTrigger
* @description      Trigger for custom object "Master". 
					This shall update the OLI & PB records with Master whenever a new Master is created or a master is activated.
*********************************************************************************************
 Version     Date      Team          Comments
*********************************************************************************************
* 1      Sep 2022    Suman          Initial Creation
*********************************************************************************************/
trigger MasterTrigger on Master__c (after insert,after update) {
    public MasterTagAndForecastPlanCreationHelper helper = new MasterTagAndForecastPlanCreationHelper();
    /*
    if(Trigger.isInsert && helper.checkIfRecCountWithActiveFlagTrueIsMoreThan5(Trigger.NewMap)){
        Trigger.NewMap.get(new List<Id>(Trigger.NewMap.keySet()).get(0)).addError('More than 5 records with \'Active\' flag as true not allowed ! Either insert less than 5 records or make the flag \'Active\' false for records more than 5.');
        return;
    }
    else if(Trigger.isUpdate && helper.checkIfRecCountWithActiveFlagTrueIsMoreThan5(Trigger.NewMap, Trigger.OldMap)){
        Trigger.NewMap.get(new List<Id>(Trigger.NewMap.keySet()).get(0)).addError('More than 5 records with \'Active\' flag as true not allowed ! Either update less than 5 records or make the flag \'Active\' false for records more than 5.');
        return;
    }*/
    
    List<Master__c> activeMasters = new List<Master__c>();
    for(Master__c master : Trigger.new){
    	if(master.Active__c)
        {
            activeMasters.add(master);
        }
    }
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate))
    {
       //Forecast record creation for the fiscal year against master record    
        List<Forecast__c> newForecasts = new List<Forecast__c>();        
        //it will get the Forecost records to be created for future dates from the date the of execution.
        //getForecastsForMasters(Master records,True=create Forecast only for remaining weeks(sundays) of fiscal year | 
        //										False=create Forecast for all missing weeks(sundays) of fiscal year)
        newForecasts = (new ForecastHelper()).getForecastsForMasters(activeMasters,true); 
        if(newForecasts!=null)
        {            
            insert newForecasts;             
        }
        List<Plan__c> newPlans = new List<Plan__c>();
        //it will get the Plan records to be created for future dates from the date the of execution.
        //getPlansForMasters(Master records,True=create Plan only for remaining weeks(sundays) of fiscal year | 
        //										False=create Forecast for all missing weeks(sundays) of fiscal year)
        newPlans = (new PlanHelper()).getPlansForMasters(activeMasters,true); 
        if(newPlans!=null)
        {            
            insert newPlans;
        }        
    }        
    //calling the trigger helper to run the batch job for updating the 
    //Master lookup value in 1. Opportunity Products and 2.Booking Products
    MasterTriggerHelper triggerHelper= new MasterTriggerHelper();
    triggerHelper.createMasterRelatedRecords(Trigger.New);
    
    /*
    for(Id masterId : Trigger.NewMap.keySet()){
        if(!Trigger.NewMap.get(masterId).Active__c || Trigger.isUpdate && Trigger.OldMap.get(masterId).Active__c ||
           (String.isBlank(Trigger.NewMap.get(masterId).Opportunity_Product_Filter__c) && String.isBlank(Trigger.NewMap.get(masterId).Booking_Product_Query_Filter__c)))
            continue;
          
        if(helper.checkIfBatchJobsAlreadyRunning()){
            Trigger.NewMap.get(masterId).addError('Batch job(s) to tag Master in Opportunity Product/Booking Product is/are already running. Please try after some time!!');
            System.debug('@@@ Batch job -BatchMapMasterToOppLineItemRecs/BatchMapMasterToProdBookingRecs - already running!!');
            return;
        }
        
        if(String.isBlank(Trigger.NewMap.get(masterId).Opportunity_Product_Filter__c))
            database.executeBatch(new BatchMapMasterToProdBookingRecs(masterId, Trigger.NewMap.get(masterId).Booking_Product_Query_Filter__c ));
        else    
            database.executeBatch(new BatchMapMasterToOppLineItemRecs(masterId, Trigger.NewMap.get(masterId).Opportunity_Product_Filter__c, Trigger.NewMap.get(masterId).Booking_Product_Query_Filter__c ));
    }*/
}