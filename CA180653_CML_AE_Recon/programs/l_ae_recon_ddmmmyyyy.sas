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

libname rawcmlae '\\bertha\users\RegistriesRWDC\Data\CA180653_CML\rawdata';

libname outcmlae '\\bertha\users\RegistriesRWDC\Projects\CA180653_CML_AE_Recon\outdata';

%let today=09MAY2022;
%put &today;

proc format;
  value yn
     1 = 'Yes'
	 0 = 'No'
	 ;
run;

*** Get EDC and coded AE datasets, merge to apply coding;

proc sort data=outcmlae.Ca180653_recon_obiee_&today. (drop=protnumber rephl sercat) out=safety_&today. (rename=(AEPTS=AEPT));
  by SITENUMBER SUBJECTID AEPTS AESTDATS;
run;

data safety_&today.;
  set safety_&today.;
  format mergedat date9.;
  mergedat=AESTDATS;
run;


proc sort data=outcmlae.Edc_ae_recon_&today. (keep = SITENUMBER SUBJECTID AETERM AEPT AESTDAT AESTDAT_RAW AEREL AEOUT) out=edc_&today.;
  by SITENUMBER SUBJECTID AEPT AESTDAT;
run;

data edc_&today.;
  set edc_&today.;
  format mergedat date9.;
  mergedat=AESTDAT;
run;

data both edcmis (keep = SITENUMBER SUBJECTID CASENUMBER AETERMS AEPT AESTDATS AESTDATS_RAW REPCAUSE AEOUTS EDCF SAFF) safmis (keep=SITENUMBER SUBJECTID AETERM AEPT AESTDAT AESTDAT_RAW AEREL AEOUT EDCF SAFF);
  merge safety_&today. (in=saf) edc_&today. (in=edc) ;
   by SITENUMBER SUBJECTID AEPT mergedat;
   if edc then EDCF=1;
   if saf then SAFF=1;
   if edcf=1 and saff=. then output safmis;
   else if saff=1 and edcf=. then output edcmis; 
   else if (edcf=1 and saff=1) and (AESTDAT^=AESTDATS) then do;
       output safmis;
	   output edcmis;
   end;
	  
   else output both;
run;

options ls=150;
/*
proc freq data=both;
  format AEPT $char50. ;
  tables SITENUMBER*SUBJECTID*AEPT /list missing;
run;
*/
data all;
  set both edcmis safmis;
run;

proc sort data=all out=allsort;
  by SITENUMBER SUBJECTID AEPT;
run;

proc sort data=edc_&today. (keep=SITENUMBER SUBJECTID DTXSTDT DTXENDT DTXONGO) out=dtx;
  by SITENUMBER SUBJECTID;
run;

data allsort2;
  retain SITENUMBER SUBJECTID CASENUMBER AETERM AETERMS  AEPT DTXSTDT DTXENDT DTXONGO AESTDAT_RAW AESTDAT AESTDATS_RAW AESTDATS AEOUT AEOUTS AEREL REPCAUSE DEATHDT; 
  merge allsort dtx;
  by SITENUMBER SUBJECTID;
run;


data sae_recon_&today.;

 attrib DATASC label= "Source"
        SITENUMBER	label = "Site Number"	length=$4	format=$char4.
		SUBJECTID	label = "Subject Number"	length=$10	format=$char5.
		CASENUMBER label = "Safety Case Number" length=$15 format=$char15.
		COMBTERM	label="Adverse Event"	length=$200	format=$char200.
		AEPT	label="MedDRA Preferred Term"	length=$100	format=$char100.
		STARTDT	label="AE Start Date (Imputed)"	length=8	format=DATE9.
        STARTDT_RAW label="AE Start Date (Raw)" length=$11 format=$char11.
		AEOUTS	label="Outcome"	length=$30 format=$char30.
		DEATHDT	label="Date of Death"	length=$11	format=$char11. 
		AEREL	label="AE Relationship to Treatment (Rave)"	length=$33	format=char33. 
		REPCAUSE	label="Reporter Causality/Relationship (Safety)"	length=$15	format=$char15.

		;
   set allsort2;
   If AETERM^='' and AETERMS^=' ' then do;
     DATASC='Safety & Rave';
	 if AETERM ^= AETERMS then COMBTERM="Rave:"||left(trim(AETERM))||"/ Safety:"||left(trim(AETERMS));
	   else COMBTERM=left(trim(AETERM));
	   STARTDT=AESTDAT;
	   STARTDT_RAW=AESTDAT_RAW;
     end;
     else if AETERM^='' and AETERMS=' ' then do;
       DATASC='Rave';
	   COMBTERM=left(trim(AETERM));
	   STARTDT=AESTDAT;
	   STARTDT_RAW=AESTDAT_RAW;
     end;
     else if AETERM='' and AETERMS^=' ' then do;
       DATASC='Safety';
	   COMBTERM=left(trim(AETERMS));
	   STARTDT=AESTDATS;
	   STARTDT_RAW=AESTDATS_RAW;
   end;
drop AETERM: AESTDAT:;
run;

data sae_recon_&today.;
 retain DATASC SITENUMBER SUBJECTID CASENUMBER COMBTERM AEPT DTXSTDT DTXENDT DTXONGO STARTDT STARTDT_RAW AEREL REPCAUSE AEOUT AEOUTS DEATHDT; 

  set sae_recon_&today.; 
run;
      
*** Add Flag for Obs in previous review: Merge with prior version by site, subject, preferred term, imputed start date***;

%let prior=25JAN2022;
%put &prior;

%let today=09MAY2022;
%put &today;



proc sort data=outcmlae.sae_recon_&prior. out=chk_sae_recon_&prior. (drop=flag);
  by SITENUMBER SUBJECTID CASENUMBER AEPT COMBTERM STARTDT /*STARTDT_RAW*/;
run;

proc sort data=sae_recon_&today. out=sae_recon_&today.;
  by SITENUMBER SUBJECTID CASENUMBER AEPT COMBTERM STARTDT /*STARTDT_RAW*/;
run;

data flagprev (keep= SITENUMBER SUBJECTID CASENUMBER AEPT COMBTERM STARTDT FLAG);
  merge chk_sae_recon_&prior. (in=old) sae_recon_&today. (in=new) ;
  by SITENUMBER SUBJECTID CASENUMBER AEPT COMBTERM STARTDT /*STARTDT_RAW*/;
  if new and not old then FLAG='New';
  if FLAG^='New' then delete;
run;

data outcmlae.sae_recon_&today. (drop=edcf saff);
  merge sae_recon_&today. flagprev;
  by SITENUMBER SUBJECTID CASENUMBER AEPT COMBTERM STARTDT;

run;

/* New to select rave only patients for emergency case creation */

proc sort data=outcmlae.sae_recon_25JAN2022 (keep= sitenumber subjectid datasc) out=raveonly nodupkey;
  by sitenumber subjectid;
  where DATASC='Rave';
run;

proc sort data=outcmlae.Edc_ae_recon_05OCT2021 out=edc_ae;
  by SITENUMBER SUBJECTID AEPT AESTDAT;
run;

data ravepats;
  merge raveonly (in=want) edc_ae;
  by SITENUMBER SUBJECTID;
  if want;
run;
