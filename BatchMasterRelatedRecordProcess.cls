/*******************************************************************************************
* @author           DemandBlue
* @version          1.0 
* @date             13-OCT-2022
* @Status           In-Progress
* @Class Name       BatchMasterRelatedRecordProcess
* @description      This batch class will be used to map/update Opportunity Product &
					Booking Products respective to Master record filters 
  Test class: 
*********************************************************************************************
 Version     Date      		Team         	 Comments
*********************************************************************************************
* 1.0      13-OCT-2022    	DemandBlue          Initial Creation
*********************************************************************************************/
public class BatchMasterRelatedRecordProcess implements Database.Batchable<Master__c>
{
    List<Master__c> mastersToProcess = new List<Master__c>();
	public BatchMasterRelatedRecordProcess(List<Master__c> masters)
    {
        this.mastersToProcess = masters;
    }
    
     //batch start
    public List<Master__c> start(Database.BatchableContext context)
    {
        System.debug('BatchMasterRelatedRecordProcess started');
        return this.mastersToProcess;
    }
    
    //batch execute
    public void execute(Database.BatchableContext batchContext, List<Master__c> masters)
    {
        Master__c master = new Master__c();
        System.debug('BatchMasterRelatedRecordProcess executing');
        if(masters.size()==1)
        {
            master = masters[0];
            if(String.isNotBlank(master.Booking_Product_Query_Filter__c)){
                updateBookingProducts(master);
            }
           
			if(String.isNotBlank(master.Opportunity_Product_Filter__c))
            {            
                updateOpportunityProducts(master);
            }
        }
    }    

    private void updateBookingProducts(Master__c master)
    {
        List<Bookings_Products__c> bookingProductsToUpdate= new List<Bookings_Products__c>();

        String bookingProductsQuery = 'SELECT Id,Master__c FROM Bookings_Products__c WHERE '+ master.Booking_Product_Query_Filter__c + ' AND Master__c = NULL LIMIT 10000';
        List<Bookings_Products__c> bookingProducts = Database.query(bookingProductsQuery);
        if(bookingProducts!=null && !bookingProducts.isEmpty())
        {
            for(Bookings_Products__c bookingProduct: bookingProducts)
            {
                bookingProduct.Master__c = master.Id;
                bookingProductsToUpdate.add(bookingProduct);
            }
            update bookingProductsToUpdate;
        }
    }

    private void updateOpportunityProducts(Master__c master)
    {
        List<OpportunityLineItem> oppsLineItemToUpdate= new List<OpportunityLineItem>();
        String oppsLineItemQuery = 'SELECT Id,Master__c FROM OpportunityLineItem WHERE '+ master.Opportunity_Product_Filter__c + ' AND Master__c = NULL LIMIT 10000';
        List<OpportunityLineItem> oppsLineItems = Database.query(oppsLineItemQuery);
        if(oppsLineItems!=null && !oppsLineItems.isEmpty())
        {
            for(OpportunityLineItem oppsLineItem: oppsLineItems)
            {
                oppsLineItem.Master__c = master.Id;
                oppsLineItemToUpdate.add(oppsLineItem);
            }
            update oppsLineItemToUpdate;
        }
    }

    //batch finish
    public void finish(Database.BatchableContext batchContext)
    {
        System.debug('BatchMasterRelatedRecordProcess finished');
    }    
}