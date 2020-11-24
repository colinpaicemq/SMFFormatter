# SMF Formatter
C formatter for z/OS SMF records, including 
1.  SMF120 from WebSpere Liberty 
1.  SMF123 from z/OS Connect.
1.  SMF30 jobs and step resource usage 
1.  SMF 42.6 Data set statistics
1.  SMF 42.5 VTOC statistics
1.  SMF 42.1 SMS buffer manager (PDSE)

Also provide a [formatter for SMS /VSAM DCOLLECT records](DCOLLECT.md),  as the DCOLLECT records have a similar structure.


## Overview
This formatter uses C macros to define fields, and automatically print/noprint fields.  It has basic support to summarise fields, for example 
display the total, average,maximum,minmum CPU and elapsed time for user/URI.
It formats STCK(E) values into date and time, and gives long long value of a STCK when used as a duration or CPU used.

## What to do next
If you want to run the formatter with SMF123 or SMF120 records( from Liberty and z/OS connect).  Create a PDS with recfm FB LRECL80.  FTP XMIT.bin in binary to the PDS.   Then use TSO receive indsn('your.pds(XMIT)') this should prompt you for a data set.  

If you want to change the processing or write your own, upload the other members in ASCII.   Submit the member COMPILE, to compile, and RUN to run.

## run the program
 
    //SMFPRINT EXEC PGM=SMFPROG,REGION=0M 
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
    //S306     DD SYSOUT=*,DCB=(LRECL=200) 
    //SUM30    DD SYSOUT=*,DCB=(LRECL=200) 
    //SYSUDUMP DD SYSOUT=*,DCB=(LRECL=200)
    //S426     DD SYSOUT=*,DCB=(LRECL=200) 
    //SUM42    DD SYSOUT=*,DCB=(LRECL=200) 
    //S421     DD SYSOUT=*,DCB=(LRECL=200) 
    //SUM425   DD SYSOUT=*,DCB=(LRECL=200) 
    //S425     DD SYSOUT=*,DCB=(LRECL=200) 
    //S425V    DD SYSOUT=*,DCB=(LRECL=200) 
    //S425VM   DD SYSOUT=*,DCB=(LRECL=200) 
    //S425VR   DD SYSOUT=*,DCB=(LRECL=200) 
    //SUM421   DD SYSOUT=*,DCB=(LRECL=200) 
    //SYSOUT   DD SYSOUT=* 
    //SYSERR   DD SYSOUT=* 
    //SUMMARY  DD SYSOUT=* 
 
Where the SMF 123 subtype 11 data comes out in //S12311, the summary information for SMF120 comes out in //SMF120UM.  

Data summaries by key fields comes out in //S120SUM and //S123IP etc. 

## Definition fields
You define fields within records with C macros.  You can choose to print the value or not( many fields are not interesting).
If you want it printed, then it will print it.  For example 

    xi(subtype    ,2,%     ,"SMF subtype",  NOPRINT); 
    
is for an integer, with field name subtype, it is of length 2, % says use the default formatting, the field description in the output is "SMF subtype", NOPRINT, says do not print it.

The following are available.
1.  1 byte integer
1.  2 byte interger
1.  4 byte integer
1.  8 byte integer
1.  hex string 
1.  character string.  
1.  STCKE - a 16 byte Store Clock Extended.  It will convert to printable date, and creates a long long variable of the value in microseconds
1.  STCK - an 8 byte Store Clock.  It will convert to printable date, and creates a long long variable of the value in microseconds
1.  STCK/STCKE as a STCK value of an interval, for example CPU, or duration.  It calculates STCK/4096, or STCKE/16 as appropriate
1.  User specified function for decoding a field.
1.  TRIPLET(..)  ETRIPLET will generate the code to loop round for each section
1.  Hundredth's of a second - used in SMF 30
1.  Units of 128 microseconds - used in SMF 30 IO times
1.  Lookup fields to map bit masks to descriptions

## Accumulate fields
From my work with MQ performance, I know that it is very useful to be able to summarise CPU and response times.
You define a key, using sprintf, and pass the elapsed time, and CPU time to a function addTree, and it will summarise the data.
For example 

    sprintf(key,"%-*.*s\0",len,len,URI); 
    addTree(key,lduration,CPUUsedll,&S120TotCPU);
    
It accumulates the data where the key is the same.

After all the records have been processed you use

     printTree("dd:S120TOT",S120TotCPU ,"URI     \n"); 
     
and it prints out

     count et:avg    max    min !CPU:tot    avg    max    min URI                     
       20, 0.082, 0.116, 0.048,!  1.049, 0.052, 0.061, 0.044,/stockmanager/api-docs    
      336, 0.101, 0.259, 0.054,! 25.607, 0.076, 0.185, 0.034,/stockmanager/stock/items/999999  
       
1. count of records
1. average elapsed time of the requests
1. the maxium elapsed time of the records
1. the minium elapsed time of the records
1. !
1. total CPU used - useful for seeing where your CPU is being used.
1. the average CPU (total CPU/count of requests)
1. the maximum CPU
1. the minimum CPU
    
I have used a substring of the formatted time to collect data on an hourly boundary.
For z/OS connect I have accumulated it on userid, IP address, HTTP code, URL which allows me to see which userids are issuing the requests, which IP address the request came from, any HTTP errors, and the URL which was used. 

## Example of field definitions

     xs(ssid       ,4,%     ,"SMF subsystem_id",NOPRINT); 
     xi(subtype    ,2,%     ,"SMF subtype",  PRINT); 
     xSTCKDT(Startdisp,8,%       ,"Start        ",PRINT); 
     xSTCKDT(Stopdisp,8 ,%       ,"Stop          ",PRINT); 
     xSTCKll(EncDelCZAAT ,8  ,%nz   ,"Enclave ZAAP time ",  PRINT); 
     unsigned long long lduration =  Stopdispll - Startdispll; 
     float duration =  ((float) lduration )/1000000; 
     printfloat("duration",duration,"Tran dur in secs"); 
 
 
 
 xs(ssid       ,4,%     ,"SMF subsystem_id",NOPRINT); 
 is
 1. xs format this as a string
 1. ssid variable name
 1. 4 four bytes
 1. % default formatting %nb says print if non blank.  You can specify your own formatting.  
 1. "SMF subsystem_id" the description of the field.   This goes in the report
 1. NOPRINT  when to print. This is statement that goes in an if (...) statement for example NOPRINT comes out as if(0) {...} PRINT comes out as if(1) {...}
 
 If PRINT was specified, it creates in the output file
 
    SMF subsystem_id    :WAS                       
 
xj(TCN              ,4  ,%nz   ,"IO Total conn time",  PRINT); 
1.  xj this is the number in 128 microsecond units.   The macro converts the field to float and multiplies it by 128E-06 to convert it to seconds
1.  TCN is from SMF30TCN, variable name
1.  4 a four byte field 
1.   %nz only print this if the value is non zero
1.  "IO Total conn time" the description of the field.  
1.  PRINT when to print. This is statement that goes in an if (,,,) statement for example NOPRINT comes out as if(0) {} PRINT comes out as if(1) {}
creates in the output file

    IO Total conn time  : 0.002176   

xh(CPT              ,4  ,%     ,"All TCB on CP     ",  PRINT); 
1.  xh this is the number in hundredths of a second.   The macro converts the field to float and multiplies it by 0.010 to convert it to seconds
1.  CPT is from SMF30CPT, variable name
1.  4 a four byte field 
1.  % or %nz.  If this is %nz then only print if the value is non zero.  % print as default, any other value is used in the printf statement format field. 
1.  "All TCB on CP     "  the description of the field.  
1.  PRINT when to print. This is statement that goes in an if (,,,) statement for example NOPRINT comes out as if(0) {} PRINT comes out as if(1) {}
creates in the output file
      All TCB on CP       : 0.770000        
 
xi(subtype    ,2,%     ,"SMF subtype", PRINT); 
 1. xi format this as an integer
 1. subtype variable name
 1. 2  two bytes.   This field can be 1,2,4,8 
 1. % default formatting ( you can specify a printf style formatting instead) %nz says only print if it is non zero
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
 
 xSTCKll(EncDelCZAAT ,8  ,%nz   ,"Enclave ZAAP time ",  PRINT); 
 1. xSTCKll treats the 8 byte field as a STCK value, for example duration or CPU used.  It creates an unsigned long long value of microseconds.
 1. EncDelCZAAT is the field name 
 1. 8 it is a field of length8
 1. %nz print it if non zero.
 1. "Enclave ZAAP time " the description of the field
 1. PRINT this field is printed (unless overridden by %nz);
 
 
 
  xflag(DMCSPEC1 ,1  ,SPEC1 ,"spec 1             ",  PRINT); 
  1. xflag takes a 1 byte fiels and prints out the values depending on the values.
  1.DMCSPEC1 is the filed name
  1. 1 is the length of the field
  1. SPEC1 is the name of a structure, see below
  1. "spec 1             " is the field description
  1. PRINT say print it. (NOPRINT says do not print it
  
  The structure is define as follows
  
    struct flagTable SPEC1[] = 
       { 
         {0x80,  0x80,"BWO    specified    " }, 
         {0x80,  0x00,"BWO not pecified    " }, 
         {0x40,  0x40,"Sphere recover given" }, 
       }; 
  
The logic works as follows.
1.  Logically AND the field from the record with the first data field.  
1.  If it equals the second field then print the third field.
    
  Another example is
  
     struct flagTable CYTP[] = 
     { 
       {0xFF,   0   ,"Standard copy       " }, 
       {0xFF,   1   ,"Concurrent preferred" }, 
       {0xFF,   2   ,"Concurrent required " }, 
     }; 
This field has a list of values

## Output data in its own file.
I have a source file for each record type.  In the file I have
    
The print routines use fprintf(fHandle).   This is set up in each file
    
    void  doSMF123_1_1(char * pSMF,long count){ 
       if  (S12302 == 0 ) S12302 = MYOPEN("dd:S12302"); 
       if  (S12302 == (FILE *)     -1)return; 
       if (S12302 ==0 ) return;
       fHandle =  S12302; 
This would write the output to the //S12302 JCL statement

## unescape
Fields like the URI have escaped characters.  So %name=Server@Info is stored in the SMF record as %25name=Server%40Info.   The function unescape(char *,length) takes the string, and un-escapes the characters, and overwrites the original string.  It returns the address of the string.


