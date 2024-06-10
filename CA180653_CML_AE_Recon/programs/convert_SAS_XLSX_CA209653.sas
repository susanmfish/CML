libname rawchl '\\bertha\users\RegistriesRWDC\Data\CA209655_cHL\RawData';
libname analchl '\\bertha\users\RegistriesRWDC\Data\CA209655_cHL\AnalysisDatasets';

libname outdata '\\bertha\users\RegistriesRWDC\Projects\CA209655_cHL_DataEval\outdata';

options mprint;
%global dsin;
%global dsout;

%macro exportsas(dsin= ,dsout=);
proc export 
  data=rawchl.&dsin. (drop=projectid project studyid environmentName subjectId StudySiteId SiteGroup instanceId InstanceName InstanceRepeatNumber folderid Folder FolderName
                           FolderSeq TargetDays DataPageId RecordDate RecordId RecordPosition MinCreated MaxUpdated SaveTS StudyEnvSiteNumber SDVTier siteid Site)
  dbms=xlsx 
  outfile="\\bertha\users\RegistriesRWDC\Projects\CA209655_cHL_DataEval\outdata\&dsin..xlsx" 
  replace;
run;


%mend exportsas;


 
%exportsas(dsin=DM);
%exportsas(dsin=SUBJECT);
%exportsas(dsin=ECOG);
%exportsas(dsin=HLINF);
%exportsas(dsin=PTSTAT);
%exportsas(dsin=SITELIST);
%exportsas(dsin=BIOTESTS);
%exportsas(dsin=PSMT);
%exportsas(dsin=PRAD);
%exportsas(dsin=PSURG);
%exportsas(dsin=PPHL);
%exportsas(dsin=CMB);
%exportsas(dsin=TBSS);
%exportsas(dsin=HEMA);
%exportsas(dsin=SURG);
%exportsas(dsin=RADST);
%exportsas(dsin=MCHEMO);
%exportsas(dsin=IMMUNO);
%exportsas(dsin=MCTT);
%exportsas(dsin=AE);
%exportsas(dsin=CP);
%exportsas(dsin=CM);
%exportsas(dsin=IV);
%exportsas(dsin=HCVISIT);
%exportsas(dsin=PETSCL);
%exportsas(dsin=SURFU);
%exportsas(dsin=STEIMM);
%exportsas(dsin=ALLO);
%exportsas(dsin=FACTM);












