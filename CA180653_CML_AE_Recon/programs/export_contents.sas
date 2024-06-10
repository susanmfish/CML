
  title1 "PROC CONTENTS ODS Output";

options nodate nonumber nocenter formdlim='-';


ods output attributes=atr
           variables=var
           enginehost=eng;
ods listing close;

proc contents data=fiout.pat_30day;
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
  outfile="\\bertha\users\RegistriesRWDC\Projects\FlatironNSCLC_Explore\output\Pat_30day_Variables.xlsx" 
  replace;
run;

**** LOTPD_30day;

ods output attributes=atr2
           variables=var2
           enginehost=eng2;
ods listing close;

proc contents data=fiout.lotpd_30day;
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
  dbms=xlsx 
  outfile="\\bertha\users\RegistriesRWDC\Projects\FlatironNSCLC_Explore\output\LOTPD_30day_Variables.xlsx" 
  replace;
run;


