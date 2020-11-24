# DCOLLECT formatter
SMS/VSAM can produce a file containing information about
1.  Data sets
1.  Volumes
1.  Management classes
1.  Storage classes
1.  Data classes

I have not been able to find a formatter for these records, so I extended the SMF Formatter to format the records.

## Collect the DCOLLECT file. 
    
    //IBMJCOLL JOB (0),CLASS=A,NOTIFY=&SYSUID,REGION=0M,COND=(4,LE) 
    //S1 EXEC PGM=IDCAMS,REGION=  0M 
    //SYSIN DD * 
      DCOLLECT OUTFILE(REPORT) - 
          VOLUMES(*)  - 
          SMSDATA(ACTIVE) 
    //SYSPRINT DD SYSOUT=* 
    //REPORT   DD DISP=OLD,DSN=COLIN.DCOLLECT 
    // 

## Format the records

     //BAQCOLL JOB (0),CLASS=A,NOTIFY=&SYSUID,REGION=0M,COND=(4,LE), 
     //       RESTART=S1 
     // SET LOADLIB=IBMUSER.LOAD
     //RUN      EXEC PGM=DCOLLECT,REGION=0M 
     //STEPLIB  DD DISP=SHR,DSN=&LOADLIB 
     //SMFIN    DD DISP=SHR,DSN=COLIN.DCOLLECT 
     //SYSUDUMP DD SYSOUT=*,DCB=(LRECL=200) 
     //SYSOUT   DD SYSOUT=* 
     //SYSERR   DD SYSOUT=* 
     //SYSPRINT DD SYSOUT=* 
     //SUMMARY  DD SYSOUT=* 
     //DATASET  DD SYSOUT=* 
     //MC       DD SYSOUT=*,DCB=(LRECL=200) 
     //SC       DD SYSOUT=*,DCB=(LRECL=200) 
     //DC       DD SYSOUT=*,DCB=(LRECL=200) 
     //VOLUME   DD SYSOUT=*,DCB=(LRECL=200) 
     //ASSOC    DD SYSOUT=*,DCB=(LRECL=200) 
     // 
     
## The output
The fields are taken from  [IBM'sDCOLLECT Output Record Structure](https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.3.0/com.ibm.zos.v2r3.idai200/recstr.htm).
Ive just done a cut and paste type job, I have not tried to add value to what the fields mean.  The fields match pretty well with what comes out of 
[ISMF](https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.1.0/com.ibm.zos.v2r1.idai500/erick3.htm).

     


formatter for z/OS SMF records, including 
1.  SMF120 from WebSpere Liberty 
1.  SMF123 from z/OS Connect.
1.  SMF30 jobs and step resource usage 
1.  SMF 42.6 Data set statistics
1.  SMF 42.5 VTOC statistics
1.  SMF 42.1 SMS buffer manager (PDSE)

Also support for the SMS/VSAM DCOLLECT data - as the DCOLLECT records have a similar structure.


## Overview
This formatter uses C macros to define fields, and automatically print/noprint fields.  It has basic support to summarise fields, for example 
display the total, average,maximum,minmum CPU and elapsed time for user/URI.

## Example output for data set 

    Dataset name        :COLIN.JCL                                                       
    error flags         :00                                                              
    Flags1              :Data set is SMS managed                                         
                        :Data set is PDSE                                                
                        :Change indicator
    Flags3              :Compress field is valid                                         
    DSORG0              :PO Paritioned                                                   
    Record format       :Blocked                                                         
    Number of extents   :1                                                               
    Volser              :A4USR1                                                          
    Block length        :3200                                                            
    Record length       :80                                                              
    Space alloc KB      :4150                                                            
    Space used  KB      :719                                                             
    31 sec alloc KB     :4150                                                            
    expiry   date       :0000000F                                                        
    Serial number       :A4USR1                                                          
    vol seq number      :0001                                                            
    Last backup time    :00000000 00000000     
   
##Example for Storage class

    ID               :S0W1                                     
    Time                :15:23:52.15                              
    Date                :2020/11/24                               
    Storage class       :SCAPPL                                   
    Last updater        :IBMUSER                                  
    Date last updated   :2020/11/23                               
    Time last updated   :09:27                                    
    Description         :APPLICATION DATA STORAGE CLASS           
    flag1               :Availability                             
                        :Use Direct response time                 
                        :Use Seq response time                    
    flag2               :Guaranteed space yes                     
    Accesibility        :3                                        
    Dir ms rate (MSR)   :9                                        
    Direct MSR 9 means May  CACHE                                 
    Seq ms rate (MSR)   :20                                       
    FLAG   CF weight    :64                                       


