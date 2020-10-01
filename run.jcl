//COLINSMF JOB CLASS=A,NOTIFY=&SYSUID,REGION=0M,COND=(4,LE)
// SET LOADLIB=IBMUSER.LOAD
// SET SMFPDS=SYS1.S0W1.MAN1
// SET SMFSDS=SYS1.S0W1.MAN2
//JOBLIB JCLLIB ORDER=(CBC.SCCNPRC)
//*
//* Dump the SMF datasets
//*
//SMFDUMP  EXEC PGM=IEFBR14
//* FDUMP  EXEC PGM=IFASMFDP
//DUMPINA  DD   DSN=&SMFPDS,DISP=SHR,AMP=('BUFSP=65536')
//DUMPINB  DD   DSN=&SMFSDS,DISP=SHR,AMP=('BUFSP=65536')
//DUMPOUT  DD   DISP=(NEW,PASS),DSN=&TEMP,SPACE=(CYL,(1,1))
//* MPOUT  DD   DISP=(MOD,CATLG),DSN=COLIN.SMF.OUT,SPACE=(CYL,(1,1))
//SYSPRINT DD   SYSOUT=*
//SYSIN  DD *
  INDD(DUMPINA,OPTIONS(DUMP))
  INDD(DUMPINB,OPTIONS(DUMP))
  OUTDD(DUMPOUT,TYPE(120,123))
  START(0000)
  END(2359)
/*
//*
//*
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