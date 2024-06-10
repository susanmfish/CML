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


proc sort data=rawcml.ds (keep=subject rsres rsdat) out=ds;
  by subject rsdat;
run;

data firstds;
  set ds;
  by subject rsdat;
  if first.subject;
run;

data chkdur;
  merge icdat firstds (in=want);
  by subject;
  if want;
run;


proc export
  data=work.chkdur  
  dbms=xlsx 
  outfile="\\bertha\users\RegistriesRWDC\Projects\CA180653_CML_DataEval\output\CML_Registry_Chk_DisStat_Enrol_20210330.xlsx" 
  replace;
run;

