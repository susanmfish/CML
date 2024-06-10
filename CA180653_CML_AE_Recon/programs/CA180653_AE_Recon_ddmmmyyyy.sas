
**************************************************************************
***  PROGRAM:     l_ae_recon_ddmmmyyyy.sas
***
***  COPIED FROM: 
***
***  AUTHOR:       Susan Fish
***
***  DATE WRITTEN: 08Mar2021
***
***  DESCRIPTION:  Create combined AE/Safety dataset for SAE Recon.
***
***
***  Programming notes:
***
***   Structure: Varies.
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

libname rawcmlae '\\bertha.celgene.com\users\RegistriesRWDC\Data\CA180653_CML\RawData';

libname outcmlae '\\bertha.celgene.com\users\RegistriesRWDC\Projects\CA180653_CML_AE_Recon\outdata';

%let today=02AUG2022;
%put &today;


proc export
  data=outcmlae.Sae_recon_&today. 
  outfile="\\bertha.celgene.com\users\RegistriesRWDC\Projects\CA180653_CML_AE_Recon\output\CA180653_AE_recon_&today..xlsx" 
  label 
  dbms=xlsx 
  replace;
  sheet="AE/SAE Recon";
run;

proc export
  data=outcmlae.EDC_AE_recon_&today. 
  outfile="\\bertha.celgene.com\users\RegistriesRWDC\Projects\CA180653_CML_AE_Recon\output\CA180653_AE_recon_&today..xlsx" 
  label 
  dbms=xlsx 
  replace;
  sheet="AE EDC";
run;

proc export
  data=outcmlae.Ca180653_recon_obiee_&today. 
  outfile="\\bertha.celgene.com\users\RegistriesRWDC\Projects\CA180653_CML_AE_Recon\output\CA180653_AE_recon_&today..xlsx" 
  label 
  dbms=xlsx 
  replace;
  sheet="SAFETY";
run;
