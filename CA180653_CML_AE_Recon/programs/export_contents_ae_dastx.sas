libname rawcmlae '\\bertha\users\RegistriesRWDC\Data\CA180653_CML\RawData';

libname outcmlae '\\bertha\users\RegistriesRWDC\Projects\CA180653_CML_AE_Recon\outdata';

title1 "PROC CONTENTS ODS Output";

options nodate nonumber nocenter formdlim='-';

**** DT;

data dt; 
  set rawcmlae.dt (keep=subject datapagename ec:);
run;

ods output attributes=atr
           variables=var
           enginehost=eng;
ods listing close;

proc contents data=dt;
run;
ods listing;

proc sort data=var out=varspec (drop=member pos informat num);
  by num;
run;

data varspec;
  retain variable label type len format; 
set varspec;
run;


proc export 
  data=work.varspec 
  dbms=xlsx 
  outfile="\\bertha\users\RegistriesRWDC\Projects\CA180653_CML_AE_Recon\output\CA180-653_Dasatinib_Tx_Variables.xlsx" 
  replace;
run;

**** AE;
data ae (drop=projectid project studyid environmentName subjectId StudySiteId SDVTier siteid Site SiteNumber SiteGroup instanceId InstanceName InstanceRepeatNumber folderid Folder FolderName
                           FolderSeq TargetDays DataPageId PageRepeatNumber RecordDate RecordId RecordPosition MinCreated MaxUpdated SaveTS StudyEnvSiteNumber );
  set rawcmlae.ae;
run;

ods output attributes=atr2
           variables=var2
           enginehost=eng2;
ods listing close;

proc contents data=ae;
run;
ods listing;

proc sort data=var2 out=varspec2 (drop=member pos informat num);
  by num;
run;

data varspec2;
  retain variable label type len format; 
set varspec2;
run;


proc export 
  data=work.varspec2 
  dbms= EXCEL
  outfile="\\bertha\users\RegistriesRWDC\Projects\CA180653_CML_AE_Recon\output\CA180-653_AE_Variables.xlsx" 
  replace;
run;


