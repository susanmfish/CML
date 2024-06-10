***************************************************************************
***  PROGRAM:     l_treat_probs.sas
***
***  COPIED FROM: 
***
***  AUTHOR:       Susan Fish
***
***  DATE WRITTEN: 06Apr2020
***
***  DESCRIPTION:  Create listing with 
***
***
***  Programming notes:
***
***   Structure: One record per patient.
***
***
***  ASSUMPTIONS: N/A
***
***  INSTRUCTIONS FOR USER: N/A
***
***  INPUT:  
***  
***  OUTPUT:  
***
***
***
***  FORMATS: N/A
***
***  MACROS:
***    Internal: 
***    External: none
***   
***
***  CHANGES:
***  
***
***************************************************************************;

libname rawcml '\\bertha\users\RegistriesRWDC\Data\CA180653_CML\RawData';
libname analcml '\\bertha\users\RegistriesRWDC\Data\CA180653_CML\AnalysisDatasets';

libname outcml '\\bertha\users\RegistriesRWDC\Projects\CA180653_CML_DataEval\outdata';


proc format;
  value yn
     0 = 'Yes'
	 1 = 'no'
	 ;
run;



proc sort data= rawcml.subject (keep=subject icdat) out=icdat;
  by subject;
run;


proc sort data=rawcml.dtkit (keep=subject dsstdat dst: dspri: dssec: dsint:) out=dtkit;
  by subject dsstdat;
run;

data dtkit2 dtkipats (keep=subject);
  set dtkit;
  output dtkipats;
  if dsterm1_std=99 then dsterm1='Other ('||left(trim(dsterm1))||')';
  if dstermsc_std=99 then dstermsc='Other ('||left(trim(dstermsc))||')';
  if dsprimsp_std=99 then dsprimsp='Other ('||left(trim(dsprimsp))||')';
  if dssecosp_std=99 then dssecosp='Other ('||left(trim(dssecosp))||')';
  if dsintgr_std=99 then dsintgr='Other ('||left(trim(dsintgr))||')';
    drop dsterm1_std dstermsc_std dsprimsp_std dssecosp_std dsintgr_std;
  output dtkit2;
run;

proc sort data=rawcml.ritki (keep=subject dattki hemresp cytog molec relap) out=ritki;
  by subject dattki;
run;
 

data dsrsp;
  merge dtkit2 (in=want) ritki;
  by subject;
  if want;
  if subject in ('530200001','530800002');
run;



proc export
  data=work.dsrsp  
  dbms=xlsx 
  outfile="\\bertha\users\RegistriesRWDC\Projects\CA180653_CML_DataEval\output\CML_Registry_Chk_TKIdisc_vs_TKIresp_20210413.xlsx" 
  replace;
run;

proc export
  data=work.dtkit2 
  dbms=xlsx 
  outfile="\\bertha\users\RegistriesRWDC\Projects\CA180653_CML_DataEval\output\CML_Registry_allTKIdisc_20210413.xlsx" 
  replace;
run;


