libname rawcmlae '\\bertha.celgene.com\users\RegistriesRWDC\Data\CA180653_CML\safety_aerecon';
libname analcml '\\bertha.celgene.com\users\RegistriesRWDC\Data\CA180653_CML\safety_aerecon';


libname outcmlae '\\bertha.celgene.com\users\RegistriesRWDC\Projects\CA180653_CML_AE_Recon\outdata';

%let today=02AUG2022;
%put &today;



PROC IMPORT OUT= ca180653_recon_obiee_&today. 
            DATAFILE= "\\bertha.celgene.com\users\RegistriesRWDC\Data\CA180653_CML\safety_aerecon\CA180653_Recon_OBIEE_&today._noheader.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data outcmlae.ca180653_recon_obiee_&today.;
  set ca180653_recon_obiee_&today.  (rename=(Protocol_Number=PROTNUMBER Protocol_Site_ID=SITENUMBER Protocol_Subject_ID=SUBJECTID Case_Number=CASENUMBER  
                                            Verbatim_Term=AETERMS Preferred_Term=AEPTS Term_Highlighted_by_Reporter=REPHL 
                                            Event_Onset_Date=AESTDATS_RAW Reporter_Causality=REPCAUSE Serious_Category__Event_Level_=SERCAT 
                                            Event_Outcome=AEOUTS Date_of_Death=DEATHDT));
        attrib PROTNUMBER	label = "Protocol Number"	length=$9	format=$char9.
        SITENUMBER	label = "Protocol Site ID"	length=$16	format=$char16.
		SUBJECTID	label = "Protocol Subject ID"	length=$10	format=$char10.
		CASENUMBER	label = "Case Number"	length=$15	format=$char15.
        AETERMS	label="AE Verbatim Term (Safety)"	length=$100	format=$char100.
		AEPTS	label="AE Preferred Term (Safety)"	length=$100	format=$char100.
		REPHL	label="Term Highlighted by Reporter?"	length=$1	format=$char1.
		AESTDATS	label="AE Onset Date Imputed(Safety)"	length=8	format=DATE9.
		AESTDATS_RAW	label="AE Start Date Raw (Safety)"	length=$11	format=$char11.
		REPCAUSE	label="Reporter Causality (Relationship)"	length=$14	format=$char14. 
		SERCAT	label="Serious Category (Event Level)"	length=$7	format=$char7.
		AEOUTS	label="Event Outcome (Safety)" length=$26	format=$char26. 
		DEATHDT label="Date of Death" length=$11 format=$char11.
		temp1 format=$char10.
		temp2 format=$char10.
		;

   AEPTS=upcase(AEPTS);
   AETERMS=upcase(AETERMS);
   temp1=substr(SUBJECTID,5,5);
   temp2=substr(SUBJECTID,6,5);

   if length(SUBJECTID)=9 then do;
    SUBJECTID=temp1;
  end;
  else if length(SUBJECTID)=10 then do;
    SUBJECTID=temp2;
  end;
  else SUBJECTID=SUBJECTID;
  if SUBJECTID = '-0008' then SUBJECTID='00008';
   
  if length(AESTDATS_RAW)<11 then do;
    if length(AESTDATS_RAW)=4 then tempdt='01-Jan'||AESTDATS_RAW;
     else if length(AESTDATS_RAW)=8 then tempdt='01-'||AESTDATS_RAW;
	AESTDATS=input(tempdt,date11.);
  end;
  else do;
    AESTDATS=input(AESTDATS_RAW,date11.);
  end;
  if PROTNUMBER=' ' then delete;
  drop temp:;
 run;


