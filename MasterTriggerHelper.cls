/*******************************************************************************************
* @author           DemandBlue
* @version          1.0 
* @date             13-OCT-2022
* @Status           In-Progress
* @Class Name       MasterTriggerHelper
* @description      This is helper class, will be used by Master object trigger
  Test class: 
*********************************************************************************************
 Version     Date      		Team         	 Comments
*********************************************************************************************
* 1.0      13-OCT-2022    	DemandBlue          Initial Creation
*********************************************************************************************/
public class MasterTriggerHelper {    
    /**
    * @description getSundayDates(Integer,Integer,Integer)
    * @return List<Date>   
    * This method helps to map/update the related records for the Masters record to create record referecens.
    * Here it helps to update the "Opportunity Product" and "Booking Product" reference to respective Master record.
    */
    public void createMasterRelatedRecords(List<Master__c> masters)
    {
        List<Master__c> mastersToProcess = new List<Master__c>();
        //Do not change the batchSize. Master records needs to be processed one record per time due to more records
        //may involve for single Master record which may lead to limit error when processes as multiple batch
        Final Integer batchSize=1;
        for(Master__c master:masters)
        {
            if(master.Active__c && (String.isNotBlank(master.Opportunity_Product_Filter__c)
                                    || String.isNotBlank(master.Booking_Product_Query_Filter__c)))             
            {
                mastersToProcess.add(master);
            }
        }
        if(!mastersToProcess.isEmpty()) 
        {
			BatchMasterRelatedRecordProcess batchObject = new BatchMasterRelatedRecordProcess(mastersToProcess);
            database.executeBatch(batchObject,batchSize);            
        }
    }
}