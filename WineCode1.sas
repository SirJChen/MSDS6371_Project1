data ww1;
infile '\\Client\C$\Users\glennoswald\datasets\wineproject\winewhite.csv' dlm=';' firstobs=2;
input fixed_acidity volatile_acidity citric_acid residual_sugar chlorides free_sulfur_dioxide total_sulfur_dioxide density pH sulphates alcohol quality;
type="white";
format type $5.;
run;

data wr1;
infile '\\Client\C$\Users\glennoswald\datasets\wineproject\winered.csv' dlm=';' firstobs=2;
input fixed_acidity volatile_acidity citric_acid residual_sugar chlorides free_sulfur_dioxide total_sulfur_dioxide density pH sulphates alcohol quality;
type="red";
format type $5.;
run;

data wb1;
set ww1 wr1;
run;

proc print data=wr1;
run;

/* Five-number summary for all variables */
/* Pretransformation */
proc means data=wr1 n min q1 median q3 max;
var quality fixed_acidity volatile_acidity citric_acid residual_sugar chlorides free_sulfur_dioxide total_sulfur_dioxide density pH sulphates alcohol;
run;

/* A few more descriptors of the variables */
/* Pretranformation */
proc means data=wr1 n mean std skew kurt;
var quality fixed_acidity volatile_acidity citric_acid residual_sugar chlorides free_sulfur_dioxide total_sulfur_dioxide density pH sulphates alcohol;
run;

/*regression with VIF*/
/* Pretransformation */
proc reg data=wr1 plots=diagnostics;
model quality = fixed_acidity volatile_acidity citric_acid residual_sugar chlorides free_sulfur_dioxide total_sulfur_dioxide density pH sulphates alcohol / VIF;
run;
quit;

/*scatterplot*/
/* Pretransformation */
proc sgscatter data=wr1;
matrix quality fixed_acidity volatile_acidity citric_acid residual_sugar chlorides free_sulfur_dioxide total_sulfur_dioxide density pH sulphates alcohol /diagonal=(histogram normal);
run;

proc freq data=wr1;
tables citric_acid total_sulfur_dioxide sulphates;
run;

/* log transformations */
data wr2;
set wr1;
logresidual_sugar=log(residual_sugar);
logchlorides=log(chlorides);
logtotal_sulfur_dioxide=log(total_sulfur_dioxide);
logdensity=log(density);
logsulphates=log(sulphates);
logalcohol=log(alcohol);
run;

/* Five-number summary for all variables */
/* Transformed vs pretransformed */
proc means data=wr2 n min q1 median q3 max;
var residual_sugar logresidual_sugar chlorides logchlorides total_sulfur_dioxide logtotal_sulfur_dioxide density logdensity sulphates logsulphates alcohol logalcohol;
run;

/* A few more descriptors of the variables */
/* Transformed vs pretransformed */
proc means data=wr2 n mean std skew kurt;
var residual_sugar logresidual_sugar chlorides logchlorides total_sulfur_dioxide density logtotal_sulphur_dioxide logdensity sulphates logsulphates alcohol logalcohol;
run;

/*regression with VIF*/
proc reg data=wr2 
	plots(label)=(CooksD RStudentByLeverage);
model quality = fixed_acidity volatile_acidity citric_acid logresidual_sugar logchlorides free_sulfur_dioxide logtotal_sulfur_dioxide logdensity pH logsulphates logalcohol / VIF;
output out=wr3 rstudent=r cookd=cd;
run;
quit;

/*scatterplot*/
proc sgscatter data=wr2;
matrix quality fixed_acidity volatile_acidity citric_acid logresidual_sugar logchlorides free_sulfur_dioxide logtotal_sulfur_dioxide logdensity pH logsulphates logalcohol /diagonal=(histogram normal);
run;

/* sort the data using cook's d descencing */
proc sort data=wr3;
by descending cd;
run;

/* view the observations where cook's d is over 0.019 */
/* the threshold of 0.019 was selected by visually looking at the cook's d plot from the prog reg above*/
proc print data=wr3;
var cd r;
where cd>.014;
run;

/* create new data set and delete high leverage points */
data wr4;
set wr3;
if cd>0.014 then delete;
run;

/*regression with VIF*/
/* Transformed high leverage points removed */
proc reg data=wr4 
	plots=(CooksD RStudentByLeverage);
model quality = fixed_acidity volatile_acidity citric_acid logresidual_sugar logchlorides free_sulfur_dioxide logtotal_sulfur_dioxide logdensity pH logsulphates logalcohol / VIF;
run;
quit;

/* Forward selection */
proc glmselect data=wr4;
model quality = fixed_acidity volatile_acidity logresidual_sugar logchlorides logtotal_sulfur_dioxide logdensity pH logsulphates logalcohol / selection=forward;
run;

/* Backward selection */
proc glmselect data=wr4;
model quality = fixed_acidity volatile_acidity logresidual_sugar logchlorides logtotal_sulfur_dioxide logdensity pH logsulphates logalcohol / selection=backward;
run;

/* Lars */
proc glmselect data=wr4;
model quality = fixed_acidity volatile_acidity logresidual_sugar logchlorides logtotal_sulfur_dioxide logdensity pH logsulphates logalcohol / selection=LAR;
run;

/* LASSO */
proc glmselect data=wr4;
model quality = fixed_acidity volatile_acidity logresidual_sugar logchlorides logtotal_sulfur_dioxide logdensity pH logsulphates logalcohol / selection=LASSO;
run;

