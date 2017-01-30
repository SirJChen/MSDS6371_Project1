data ww1;
infile '\\Client\C$\Users\glennoswald\datasets\wineproject\winewhite.csv' dlm=';' firstobs=2;
input fixed_acidity volatile_acidity citric_acid residual_sugar chlorides free_sulfur_dioxide density pH sulphates alcohol quality;
type="white";
format type $5.;
run;

data wr1;
infile '\\Client\C$\Users\glennoswald\datasets\wineproject\winered.csv' dlm=';' firstobs=2;
input fixed_acidity volatile_acidity citric_acid residual_sugar chlorides free_sulfur_dioxide density pH sulphates alcohol quality;
type="red";
format type $5.;
run;

data wb1;
set ww1 wr1;
run;


/*regression with VIF*/
proc reg data=wr1 plots=diagnostics;
model quality = fixed_acidity volatile_acidity citric_acid residual_sugar chlorides free_sulfur_dioxide density pH sulphates alcohol / VIF;
run;
quit;

/*scatterplot*/
proc sgscatter data=wr1;
matrix quality fixed_acidity volatile_acidity citric_acid residual_sugar chlorides free_sulfur_dioxide density pH sulphates alcohol /diagonal=(histogram normal);
run;

data wr2;
set wr1;
logresidual_sugar=log(residual_sugar);
logchlorides=log(chlorides);
logdensity=log(density);
logalcohol=log(alcohol);
run;

/*regression with VIF*/
proc reg data=wr2 plots=diagnostics;
model quality = fixed_acidity volatile_acidity citric_acid logresidual_sugar logchlorides free_sulfur_dioxide logdensity pH sulphates logalcohol / VIF;
output out=wr3 rstudent=r cookd=cd;
run;
quit;

/*regression with VIF sulf diox taken out*/
proc reg data=wr2 plots=diagnostics;
model quality = fixed_acidity volatile_acidity citric_acid logresidual_sugar logchlorides logdensity pH sulphates logalcohol / VIF;
output out=wr3 rstudent=r cookd=cd;
run;
quit;

/*scatterplot*/
proc sgscatter data=wr2;
matrix quality fixed_acidity volatile_acidity citric_acid logresidual_sugar logchlorides free_sulfur_dioxide logdensity pH sulphates logalcohol /diagonal=(histogram normal);
run;


/* the expend and public variables have outliers so we will run proc univarite to find the outliers in the extreme observations table */
proc univariate data=wr2;
var fixed_acidity volatile_acidity citric_acid logresidual_sugar logchlorides free_sulfur_dioxide logdensity pH sulphates logalcohol;
histogram;
run;

proc sort data=wr3;
by descending cd;
run;

proc print data=wr3;
var cd r;
where cd>.015;
run;

data wr4;
set wr3;
if cd>0.15 then delete;
run;

proc print data=wr4;
var cd r;
where cd>.015;
run;
