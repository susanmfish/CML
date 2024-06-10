**************************************************************************
***  PROGRAM:     convert_CA180-653_Recon_OBIEE_ddmmmyyyy.sas
***
***  COPIED FROM: 
***
***  AUTHOR:       Susan Fish
***
***  DATE WRITTEN: 08Mar2021
***
***  DESCRIPTION:  Create dataset for SAE Recon. from EDC AEs for dasatinib tx patients.
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

libname rawcmlae '\\bertha.celgene.com\users\RegistriesRWDC\Data\CA180653_CML\safety_aerecon';

libname outcmlae '\\bertha.celgene.com\users\RegistriesRWDC\Projects\CA180653_CML_AE_Recon\outdata';

%let today=02AUG2022;
%put &today;



proc format;
  value yn
     1 = 'Yes'
	 0 = 'No'
	 ;
run;

*** Get EDC and coded AE datasets, merge to apply coding;

proc sort data=rawcmlae.ae (keep = SUBJECT AETERM AESER AETOXGR AESTDAT AESTDAT_INT AESTDAT_RAW AEENDAT_INT AEENDAT_RAW AEONGO AEACN AEREL RELTKI AEOUT ) out=ae (rename=(AESTDAT=AESTDATdel));
  by SUBJECT AETERM AESTDAT_INT AESTDAT_RAW AEENDAT_INT AEENDAT_RAW;
run;

proc sort data=rawcmlae.ae_coded (keep = SUBJECT AETERM AEPT AESTDAT AESTDAT_INT AESTDAT_RAW AEENDAT_INT AEENDAT_RAW) out=ae_coded (rename=(AESTDAT=AESTDATdel));
  by SUBJECT AETERM AESTDAT_INT AESTDAT_RAW AEENDAT_INT AEENDAT_RAW;
run;

data aeall;
  merge ae_coded (in=want) ae;
  by SUBJECT AETERM AESTDAT_INT AESTDAT_RAW AEENDAT_INT AEENDAT_RAW;
  if want;
  format AESTDAT AEENDAT date9.;
  SUBJECTID=substr(SUBJECT,5,5);
  AESTDAT=datepart(AESTDAT_INT);
  AEENDAT=datepart(AEENDAT_INT);
  temp=put(AEONGO,yn.);
  tempae1=upcase(AETERM);
  tempae2=upcase(AEPT);
  drop AESTDAT_INT AEENDAT_INT AEONGO AETERM AEPT;
run;

*** Get dasatinib treatment info ;

proc sort data=rawcmlae.dt (keep = SITENUMBER subject ecstdat ecstdat_raw ecendat  econgo)  out=dt;
  by subject;
run;

data dt2;
  set dt;
  format dtxstdt dtxendt date9.;
  DTXSTDT=datepart(ecstdat);
  DTXENDT=datepart(ecendat);
  DTXONGO=put(econgo,yn.);
  SUBJECTID=substr(SUBJECT,5,5);
  dtxsmoyr=compress(substr(ecstdat_raw,4,8));
drop ecstdat ecstdat_raw ecendat econgo;
run;


data mergeall;
  merge dt2 (in=want) aeall (in=ae);
  by subject;
  if want and ae;
    aestmoyr=compress(substr(aestdat_raw,4,8));
run;

data aedt  nodt;
  set mergeall;
    if (AESTDAT < DTXSTDT) and (dtxsmoyr ^= aestmoyr) then output nodt;
	  else if (AESTDAT < DTXSTDT) and (AESTDATdel^=.) then output nodt;
      else if (AESTDAT < DTXSTDT) and (dtxsmoyr=aestmoyr) then output aedt;
      else if (AESTDAT >= DTXSTDT >.z) then do;
        if DTXENDT=. then output aedt;
	    else if (.z<DTXENDT) and (AESTDAT <=DTXENDT) then output aedt;
	    else output nodt;
  end;
  else output nodt;
 
run;

proc sort data=aedt out=aedtsort;
  by subject aestdat aeterm;
run;

data outcmlae.EDC_AE_recon_&today.;
      attrib SITENUMBER	label = "Protocol Site ID"	length=$4	format=$char4.
		SUBJECTID	label = "Protocol Subject ID"	length=$10	format=$char5.
		DTXSTDT	label="Dasatinib Start Date"	length=8 format=Date9.
		DTXENDT	label="Dasatinib End Date"	length=8	format=Date9.
		DTXONGO label="Dasatinib Ongoing?" length=$3 format=$char3.
		AETERM	label="AE Verbatim Term (EDC)"	length=$100	format=$char100.
		AEPT	label="AE Preferred Term (EDC)"	length=$100	format=$char100.
		AESER	label="AE Serious?"	length=$9	format=char9.
		AETOXGR	label="AE Grade"	length=$21	format=char21.
		AESTDAT	label="AE Start Date Imputed (EDC)"	length=8	format=DATE9.
		AESTDAT_RAW	label="AE Start Date Raw (EDC)"	length=$11	format=$char11.
		AEENDAT	label="AE Stop Date Imputed (EDC) "	length=8	format=DATE9.
		AEENDAT_RAW	label="AE Stop Date Raw (EDC)"	length=$11	format=$char11.
		AEONGO	label="AE Ongoing?"	length=$3	format=$char3. 
		AEACN	label="AE Action"	length=$5 format=$char5.
		AEREL	label="AE Relationship to Treatment"	length=$33	format=char33. 
		RELTKI	label="Treatment was TKI?"	length=$9	format=char9.
		AEOUT	label="AE Outcome" length=$66	format=char66. 
		;
	set aedtsort;
	drop subject ecstdat_raw ecendat_raw dtxsmoyr aestmoyr AESTDATdel AEENDATdel;
run;

