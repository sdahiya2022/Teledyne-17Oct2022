/*******************************************************************************************
* @author           DemandBlue
* @version          1.0 
* @date             10-OCT-2022
* @Class Name       DateUtility
* @description      This is a utility/helper class for date related functions 
					Example: To get the dates of sundays in a month getSundayDates
*********************************************************************************************
 Version     Date      		Team         	 Comments
*********************************************************************************************
* 1.0      10-OCT-2022    	DemandBlue          Initial Creation
*********************************************************************************************/
/**
 * DateUtility is a utility/helper class for date related functions
 */
public class DateUtility {
    /**
     * @description getRemainingMonthsOfCurrentYear(Integer)
     * @return List<Integer>
     * Example: If month is October, it will return 10,11,12
     */
    public static List<Integer> getRemainingMonthsOfCurrentYear(Integer monthNumber)
    {
        List<Integer> remaingMonthNumbers= new List<Integer>();
        Final Integer MONTHS_IN_A_YEAR = 12;
        if(monthNumber>=1 && monthNumber<=12){
            for(Integer i= monthNumber; i<=MONTHS_IN_A_YEAR; i++ )
            {
                remaingMonthNumbers.add(i);
            }
        }           
        return remaingMonthNumbers;
    }
    /**
	* @description getSundayDates(Integer,Integer,Integer)
     * @return List<Date>   
     * This method helps to get all sunday dates from a specified date of a month 
	*/
	public static List<Date> getSundayDates(Integer year,Integer monthNumber,Integer fromDate)
    {
        List<Date> sundayDates = new List<Date>();
        Integer incrementDays = 0;
        DateTime fromDateTime;
        String dayOfWeek ='';
        if((monthNumber>=1 && monthNumber <=12) && (fromDate>=1 && fromDate<=31))
        {
            fromDateTime = datetime.newInstance(year, monthNumber, fromDate, 0, 0, 1);
            dayOfWeek = fromDateTime.format('EEEE','Eastern Standard Time');
            //System.debug('input date time ='+fromDateTime);
            //System.debug('input dayOfWeek='+dayOfWeek);
            
            Switch on dayOfWeek{         
                When 'Monday'{
                    incrementDays = 6;
                }
                When 'Tuesday'{
                    incrementDays = 5;
                }
                When 'Wednesday'{
                    incrementDays = 4;
                }
                When 'Thursday'{
                    incrementDays = 3;
                }
                When 'Friday'{
                    incrementDays = 2;
                }
                When 'Saturday'{
                    incrementDays = 1;
                }
                When 'Sunday'{
                    incrementDays = 0;
                }  
            }
            fromDateTime = fromDateTime.addDays(incrementDays);
            //sundayDates.add(fromDateTime.date());
            //system.debug('fromDateTime start sunday='+fromDateTime);
            
            While(fromDateTime.Date().year() == year && fromDateTime.Date().month()==monthNumber)
            {            
                dayOfWeek= fromDateTime.format('EEEE','Eastern Standard Time');
                if (dayOfWeek=='Sunday' && fromDateTime.Date().month()==monthNumber)
                {
                   sundayDates.add(fromDateTime.date());
                }        
                fromDateTime = fromDateTime.addDays(7);
            }
        }
        system.debug('sundayDates: ' +sundayDates);
        return sundayDates;
    }
    
    
    /**
	* @description getSundayDatesBetweenTwoDate(Date,Date)
     * @return List<Date>   
     * This method helps to get all sunday dates between specified two dates. 
     * For EST time zone
	*/
	public static List<Date> getSundayDatesBetweenTwoDate(Date fromDate,Date toDate)
    {
        List<Date> sundayDates = new List<Date>();
        Integer incrementDays = 0;
        DateTime fromDateTime;
        String dayOfWeek ='';
        String orgDateString = '';
        Date orgDate;
        fromDateTime = datetime.newInstance(fromDate.year(),fromDate.month(), fromDate.day(), 12, 0, 0);
        //System.debug('before timezone= '+fromDateTime);
        String orgTimeZone = [select TimeZoneSidKey from organization LIMIT 1].TimeZoneSidKey;
        orgDateString =fromDateTime.format('YYYY-MM-dd HH:mm:ss',orgTimeZone);
        //system.debug('formatted timezone time='+orgDateString);
        fromDateTime = datetime.valueOf(orgDateString);
        //system.debug('after timezone= '+fromDateTime);
        dayOfWeek = fromDateTime.format('EEEE',orgTimeZone);
        //system.debug('input date time ='+fromDateTime);
        //system.debug('input dayOfWeek='+dayOfWeek);
        //system.debug('toDate='+toDate);
        
        switch on dayOfWeek{         
            When 'Monday'{
                incrementDays = 6;
            }
            When 'Tuesday'{
                incrementDays = 5;
            }
            When 'Wednesday'{
                incrementDays = 4;
            }
            When 'Thursday'{
                incrementDays = 3;
            }
            When 'Friday'{
                incrementDays = 2;
            }
            When 'Saturday'{
                incrementDays = 1;
            }
            When 'Sunday'{
                incrementDays = 0;
            }  
        }
        fromDateTime = fromDateTime.addDays(incrementDays);
        //sundayDates.add(fromDateTime.date());
        //system.debug('fromDateTime start sunday='+fromDateTime);
        
        while(fromDateTime.Date()>=fromDate && fromDateTime.Date() <=toDate)
        {   
            //system.debug('fromDateTime= '+fromDateTime);
            //taking out sundays             
            dayOfWeek= fromDateTime.format('u'); //getting weekday number Sunday = 7
            //system.debug('dayOfWeek= '+dayOfWeek);
            if (dayOfWeek== '7' && fromDateTime.Date() <=toDate)
            {
                sundayDates.add(fromDateTime.date());
                //system.debug('Sunday = '+fromDateTime.date());
            }        
            fromDateTime = fromDateTime.addDays(7);
        }
        //system.debug('sundayDates: ' +sundayDates);
        //system.debug('size = '+ sundayDates.size());
        return sundayDates;
    }
}