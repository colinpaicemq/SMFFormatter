# SMFFormatter
C formatter for z/OS SMF records, including SMF120 from WebSpere Liberty and SMF123 from z/OS Connect.

## Overview
This formatter uses C macros to define fields, and automatically print/noprint fields.  It has basic support to summarise fields, for example 
display the total, average,maximum,minmum CPU and elapsed time for user/URI.
It formats STCK(E) values into date and time, and gives long long value of a STCK when used as a duration or CPU used.

## run the program
 
    //SMFPRINT EXEC PGM=COLIN,REGION=0M 
    //STEPLIB  DD DISP=SHR,DSN=&LOADLIB 
    //*MFIN    DD DISP=SHR,DSN=*.SMFDUMP.DUMPOUT 
    //SMFIN    DD DISP=SHR,DSN=COLIN.SMF.OUT 
    //SYSPRINT DD SYSOUT=*,DCB=(LRECL=200) 
    //SYSABEND DD SYSOUT=*,DCB=(LRECL=200) 
    //S120SUM  DD SYSOUT=*,DCB=(LRECL=200) 
    //S120TOT  DD SYSOUT=*,DCB=(LRECL=200) 
    //S12302   DD SYSOUT=*,DCB=(LRECL=200) 
    //S12311   DD SYSOUT=*,DCB=(LRECL=200) 
    //S123IP   DD SYSOUT=* 
    //SYSUDUMP DD SYSOUT=*,DCB=(LRECL=200) 
    //SYSOUT   DD SYSOUT=* 
    //SYSERR   DD SYSOUT=* 
    //SUMMARY  DD SYSOUT=* 
 
Where the SMF 123 subtype 11 data comes out in //S12311, the summary information for SMF120 comes out in //SMF120UM


## Example of field definitions

     xs(ssid       ,4,%     ,"SMF subsystem_id",  PRINT); 
     xi(subtype    ,2,%     ,"SMF subtype",  PRINT); 
     xSTCKDT(Startdisp,8,%       ,"Start        ",PRINT); 
     xSTCKDT(Stopdisp,8 ,%       ,"Stop          ",PRINT); 
     unsigned long long lduration =  Stopdispll - Startdispll; 
     float duration =  ((float) lduration )/1000000; 
     printfloat("duration",duration,"Tran dur in secs"); 
 
 
 
 xs(ssid       ,4,%     ,"SMF subsystem_id",  PRINT); 
 is
 1. xs format this as a string
 1. ssid variable name
 1. 4 four bytes
 1. % default formatting ( you can specify a printf style formatting instead
 1. "SMF subsystem_id" the description of the field.   This goes in the report
 1. NOPRINT  when to print. This is statement that goes in an if (,,,) statement for example NOPRINT comes out as if(0) {} PRINT comes out as if(1) {}
 
 creates in the output file
  SMF subsystem_id    :WAS                       
           
 
xi(subtype    ,2,%     ,"SMF subtype", PRINT); 
 1. xi format this as an integer
 1. subtype variable name
 1. 2  two bytes
 1. % default formatting ( you can specify a printf style formatting instead
 1. "SMF subtype" the description of the field.   This goes in the report
 1. NOPRINT  when to print. This is statement that goes in an if (,,,) statement for example NOPRINT comes out as if(0) {} PRINT comes out as if(1) {}
creates in the output file
SMF subtype         :11              

 xSTCKDT(Startdisp,8,%       ,"Start        ",PRINT); 
 1. xSTCKDT converts the field to a STCK value
 1. Startdisp variable name  the date time is in Startdispdt, the conversion to microseconds is in Startdispll
 1. 8 this is an 8 byte STCK
 1. % default formatting 
 1. Start .. field descriptor
 1. Print
 
 From the Startdisp and Stopdisp you can calculate the duration  unsigned long long lduration =  Stopdispll - Startdispll; 

In the output file you get 

 Start               :2020/09/30 15:11:32.553189       
 Stop                :2020/09/30 15:11:32.963574       
 Tran dur in secs    : 0.410385                        

## Example of summary processing

You can use build up a string of summary information using sprintf
 sprintf(vsbuffer,"%4.4s0 %8.8s  %-64.64s\0", 
  Startdispdt+11,      //hh:m  part of date time 
  Userid, 
  URI); 
  
  Then add it to the saved information using 
  
  addTree(vsbuffer,lduration,CPUUsedll,&S120Root); 
  
At the end of the job you run a printTree() and it produces
  count   et avg   et max   et min !  Tot CPU  CPUavg   CPUmax   CPUMin  HH:MM Userid  URI                                     
                                                                                                                             
    4, 4152494,14120542,  410385,!  12252104, 3063026,11007511,  311650 15:10 ADCDC     /zosConnect/services/stockQuery      

