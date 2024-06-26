/********************************************************************************
*** AUTHOR:	Antisha
*** DATE: April 4th, 2024
*** PROJECT: STATA test 

*** TITLE: CASH-ON-HAND AND COMPETING MODELS OF INTERTEMPORAL BEHAVIOR: NEW EVIDENCE FROM THE LABOR MARKET

*** COMPONENT:    Particular                                                    Code line
               1. GRAPHICAL ANALYSIS FOR RD DESIGN VALIDITY                     112 TEST                                                   
               2. MAIN RD GRAPHICAL RESULTS                                     236  
          	   3. Table II Main Parametric Hazard Model Regressions             382
			   4. LONG RUN SEARCH OUTCOMES                                      485
			   5. Table III LONG RUN SEARCH OUTCOMES                            539
********************************************************************************/

*****************************
*** Configure Environment *** 
*****************************
drop _all
clear all           
capture log close    
set more off        
set logtype text 
set linesize 100
pause on
log using data_04.txt, replace


*****************************
*** Set working directory ***
*****************************
* Principle Investigators' computer
if "`c(username)'" == "Principle Investigators" {
	cd "  "
	}
* Antisha's computer
else if "`c(username)'"== "DELL" {
	cd "D:\OneDrive - London School of Economics\STICERD DATA TASK"
}


****************************
** configurations for graphs
****************************
pwd
global directory `c(pwd)'
global graphs "$directory/Output"

set scheme meta
grstyle init
grstyle graphsize x 3.575
grstyle graphsize y 2.6
grstyle color background white
grstyle anglestyle vertical_tick horizontal


** LOAD< RESTRICT< AND MERGE SAMPLE
use "work_history.dta", clear
sort penr
save "work_history.dta", replace


use "sample_75_02.dta", clear
** RESTRICTING THE DATASET FOR ANALYSIS
		//Sanity check if the given files exclude people younger than twenty years of age and older than fifty years of age at the time of job termination
		tab age 
		** Test successful 
		
		gen not_in_sample = .
		tab endy
		//capturing years when severance pay standards weren't applicable to everybody
		replace not_in_sample = 1 if endy<=1980 | endy>=2002     
		//capturing those who volunatarily quit
		replace not_in_sample = 1 if volquit==1    
		//capturing those recalled to their prior firms
		replace not_in_sample = 1 if recall==1   
		//capturing construction workers
		//replace not_in_sample = 1 if iconstruction== 1   
		drop if not_in_sample == 1
		** count  939,950
		
		** FURTHER RESTRICTING THE DATASET FOR FIGURES
		keep if duration>=365 & duration<5*365 & dempl5>=365 & dempl5<5*365
		** count  650,922


// MERGE THE DATASET WITH THE WORK HISTORY DATASET
cap drop _merge 
merge 1:1 penr file using "work_history.dta", force keep(master match)


//RECENTERING BANDWIDTH AROUND THRESHOLD
gen tenure_sp = int(cond((duration- 1096) >=0, (duration- 1096)/31 +36, (((duration-1096)+1)/31)+35))
gen tenure_eb = int(cond((dempl5- 1096 ) >=0, (dempl5- 1096/31)+36, ((dempl5- 1096)+1/31)+35 ))

/* 
For all the figures, the authors define month as a period of 31 days and months starting from the discontinuity (three years = 1096 days), counting 31-day intervals on the left and the right (see Footnote 15 of the paper), Further, the month groups 12 and 59 have been dropped due to having less than 10 days. Therefore all plots are from month 13 to 58. 

Mathematical Alignment: It helps in aligning the division process to the nearest whole number for negative values, ensuring consistency in how fractional parts are handled across positive and negative durations. When durations are negative and close to zero, adding 1 before division slightly reduces the magnitude of negativity in the result, potentially correcting for an inherent downward bias in how durations are calculated or recorded. 

Adjusting for seasonal patterns associated with integer years of tenusre does not change the estimated coefficients significantly (See page 1542)
*/

** USEFUL FOR LATER
bysort tenure_sp: gen index_tenure_sp = _n
bysort tenure_eb: gen index_tenure_eb = _n

BREAK 


************************************************
//GRAPHICAL ANALYSIS FOR RD DESIGN VALIDITY TEST 
************************************************

*Figure II: Frequency of Layoffs by Job Tenure considering SP
preserve 
		bysort tenure_sp: gen layoffs = _n
		collapse (count) layoffs, by(tenure_sp)
		keep if tenure_sp>=13 & tenure_sp<= 58

		twoway scatter layoffs tenure_sp, connect(l color(black)) mcolor(black) msize(small) ///
		xline(35.5, lcolor(black)) ///
		xlabel(12(6)60) ylabel(0 0(10000)40000) ///
		title(Figure II) subtitle(Frequency of Layoffs by Job Tenure) ///
		xtitle(Previous Job Tenure (Months)) ytitle(Number of Layoffs) ///
		graphregion(fcolor(white) margin(large)) legend(off) ///
		note("Note: The graph neither witness a jump in the layoffs around the 35-month threshold of job tenure, nor a shortfall in the number of people laid off immediately after the threshold. This is suggestive of the claim that firms do not engage in selective firing in order to evade severance payments", span)  
		
		graph export "$graphs/FigureII.png", replace
restore 


** Figure IIIa: Number of Jobs Held by Job Tenure
preserve 
		bysort tenure_sp: egen count_jobs = sum(last_job)
		keep if tenure_sp>=13 & tenure_sp<= 58

		twoway scatter count_jobs tenure_sp if index_tenure_sp==1, msize(small) ///
		|| lfit count_jobs tenure_sp if tenure_sp<35.5, lcolor(black) ///
		|| lfit count_jobs tenure_sp if tenure_sp>35.5, lcolor(black) ///
		,xline(35.5, lcolor(black)) ///
		title("Figure IIIa") subtitle("Number of Jobs Held by Job Tenure") ///
		ytitle("Mean Number of Jobs") xtitle("Previous Job Tenure (Months)") ///
		ylabel(4 4(0.5)5.5)  xlabel(12(6)60)  ///	
		graphregion(fcolor(white) margin(large)) legend(off) ///
		note("Note: The aeverage number of jobs witness no discontinuity at 36-months of tenure indicating that prior work histories are similar for individuals laid off just before and after the cutff", span)

		graph export "graphs/FigureIIIa.png", replace
restore 


**Figure IIIb: Wage by Tenure
//I understand wage0 as the monthly wage in the final year of the job from which the inidvidual has been laid off
preserve
		gen annual_wages = wage0*14 
		**Workers in Austria recieve 14 "monthly" salaries per year (Appendix Page 1557)
		
		collapse (mean) annual_wages, by(tenure_sp)
		replace annual_wages = annual_wages/1000       
		**Coverting wage units into Euro

		keep if  tenure_sp> 12 & tenure_sp<59
		
		twoway scatter annual_wages tenure_sp, msize(small) mcolor(black) ///
		|| lfit annual_wages tenure_sp if tenure_sp<35.5, lcolor(black) ///
		|| lfit annual_wages tenure_sp if tenure_sp>35.5, lcolor(black) ///
		,xline(35.5, lcolor(black)) ///
		title("Figure III b") subtitle("Wage by Tenure") ///
		ytitle("Mean Annual Wage (Euro x 1000)") xtitle("Previous Job Tenure (Months)") ///
		ylabel(16 16(0.5)18.5) xlabel(12 12(6)60)  ///		
		graphregion(fcolor(white) margin(large)) legend(off)	///
		note("This figure plots the average annual wage in the final year of the job from which the individual was laid off. While there is a statistically significant jump observed in this graph, the authors emphasize the distinction between economic and statistical significance in a dataset of this size. They argue that unless there is a large correlation between wages and nonemployment duration, such a small jump in wages or any other observable characteristics do not have potential to cause bias in the estimates of severance pay on the search durations", span)
		
		graph export "$graphs/FigureIIIb.png", replace
restore 
	

*Figure IV: Selection on Observables

** SET UP **
//GENERATING COVARIATES FOR COX MODEL 

gen age2 = age^2
gen lnwage = ln(wage0)
gen lnwage2 = lnwage^2                           
tab endmo, gen(endmo_dum)                   //dummies for month of job termination
tab endy, gen(endy_dum)                     //dummies for year of job termination
gen experience_years = (experience + duration)/365
gen experience_years2 = experience_years^2

codebook pr_etyp                            //bluecollar at job prior to the one just lost
gen pr_bluecollar = 1 if pr_etyp == 2

tab education, gen(edu_dum)                 //dummies for education
tab industry, gen(ind_dum)                  //dummies for industry
tab region, gen(reg_dum)                    //dummies for region of job loss


preserve
keep if not_in_sample==.
		gen censor = noneduration>=140 
		** Censor the spell at 140 days in order to isolate the effects of the policy variables in the first twenty weeks of the job search, pior to the point at which extended ebenfits become available. 
		**DECLARE THE DATASET FOR SURVIVAL TIME ANALYSIS
		stset noneduration, failure(censor==0)

		** Attempt to center covariates around zero, and improve numeric stability
		foreach var of varlist female married austrian bluecollar age age2 lnwage lnwage2 high_ed   firms  experience exper2 last_job last_recall pr_bluecollar last_breaks last_noneduration {	
		egen mean_`var' = mean(`var')
		gen demean_`var' = `var'-mean_`var'
		}
		
		** Running the Cox model and predicting the coefficients
		stcox demean* reg_dum2-reg_dum6 ind_dum2-ind_dum6 edu_dum2-edu_dum6 endy_dum2-endy_dum21 endmo_dum2-endmo_dum12, nohr 
		predict pred_hr

        ** Calculating the average predicted hazard rate
		collapse (mean) pred_hr, by(tenure_sp)
		
		** Plotting the average predicted hazard rate by Severance Pay Tenure Category
		twoway scatter pred_hr tenure_sp, mcolor(black) msize(very_small) /// 
		|| lfit pred_hr tenure_sp if tenure_sp<35.5, lcolor(black)  /// 
		|| lfit pred_hr tenure_sp if tenure_sp>35.5, lcolor(black) ///
		title(Figure IV) subtitle(Selection on Observables)  ///
		ytitle(Mean Predicted Hazard Ratios) xtitle(Previous Job Tenure (Months))  ///
		xlabel(12(6)60) xline(35.5, lcolor(black)) ///
		graphregion(fcolor(white) margin(large)) legend(off)   /// 
		note("Note: This figure analysis how endogenous outcomes, such as number of previous jobs, the duration of the most recent spell, and wages are affected by the unobserved attributes. This would in turn affect the duration of job search which is likely to be correlated with these observed variables. However, there is no jump in the predicted hazard rates at the threshold of 36 months of job tenure. This conclued that individuals are near randomized around the cut-off, implying that any discontinuity in the search behavior at the cut-off can be reasoned as the causal effect of severance pay of other extended benfits", span)
		
		graph export "$graphs/figureIV.png", replace
restore 


** ANALYSIS **

************************************
*EFFECT OF SP AND EB ON NONEDURATION
************************************

//Figure V 
//Effect of Severance Pay on Nonemployment Durations 

preserve
		//Capturing observations with nonduration of more than two years
		gen nonedur_2years = noneduration <= 2*365  
		collapse (mean) noneduration, by(tenure_sp nonedur_2years)
		keep if  tenure_sp>= 13 & tenure_sp<=58	
			
		twoway scatter noneduration tenure_sp if nonedur_2years==1, msize(small) mcolor(black)  ///
		|| qfit noneduration tenure_sp if tenure_sp<35.5 & nonedur_2years==1, lcolor(black)    /// 
		|| qfit noneduration tenure_sp if tenure_sp>35.5 & nonedur_2years==1, lcolor(black)    /// 
		title(Figure V) subtitle(Effect of Severance Pay on Nonemployment Durations, size(small) margin(small)) xtitle(Previous Job Tenure (Months)) ytitle(Mean Nonemployment Duration (days), size(small) margin(-8)) ///
		xlabel(12(6)60) ylabel(145 145(5)165) xline(35.5, lcolor(black)) graphregion(fcolor(white) margin(large)) legend(off) ///	
		note("Note: The figure shows a jump of 10 days in the average nonemployment duration at the threshold for severance pay eligibility. We cannot attribute the entire jump to the effects of severance pay due to double discontinuity; the fraction of people receiving EB also jumps at the cutoff as the authors claimed. Figure VI adjusts for this double discontinuity and corrects for the censoringof nonemployment spells by examining how the hazard rate changes at the severance pay threshold.", span) 

        graph export "$graphs/figureV.png", replace
restore 


** EFFECT OF SEVERANCE PAY ON JOB FINDING HAZARD RATES 
** Focusing on reemployment hazard in the first 20 weeks to include only the time before the benefit extension

** SET UP **
** Generating high order polynomials of the SP and EB tenure
gen centering_sp = duration- 1096
gen p1_tenure_sp = centering_sp/365         //defining in yearly terms
gen p2_tenure_sp = p1_tenure_sp^2
gen p3_tenure_sp = p1_tenure_sp^3

gen centering_eb = dempl5- 1096
gen p1_tenure_eb = centering_eb/365         //defining in yearly terms
gen p2_tenure_eb = p1_tenure_eb^2
gen p3_tenure_eb = p1_tenure_eb^3

** Gen indicator for those eligible to receive severance payments
gen severance_pay = duration >= 1096

** Interact indicators for SP and EB with their higher order polynomials
gen interact_sp1 = severance_pay * p1_tenure_sp
gen interact_sp2 = severance_pay * p2_tenure_eb
gen interact_sp3 = severance_pay * p3_tenure_sp

gen interact_eb1 = eligible30 * p1_tenure_eb
gen interact_eb2 = eligible30 * p2_tenure_eb
gen interact_eb3 = eligible30 * p3_tenure_eb

tab tenure_sp, gen(tenure_sp_dum)


// Figure VI: Effect of Severance Pay on the Job Finding Hazards
        ** Declaring the dataset
		capture drop censor
		gen censor = noneduration < 140
		stset noneduration, failure(censor==1)

preserve 
		drop if tenure_sp ==. 
		bysort tenure_sp: gen temp = _n
		
		** Cox model 
		#delimit;
		stcox eligible30
		tenure_sp_dum2-tenure_sp_dum48 
		p1_tenure_eb-p3_tenure_eb 
		interact_eb1 
		interact_eb2 
		interact_eb3
		, nohr;
        #delimit cr

		//generating mean hazard rate across each tenure-month category
		gen mean_hazrate=.
		foreach var of numlist 2/48 {
		replace mean_hazrate = _b[tenure_sp_dum`var'] if temp==1&tenure_sp_dum`var'==1
		}

		keep if tenure_sp>= 13 & tenure_sp<=58	
		
		twoway scatter mean_hazrate tenure_sp if temp==1, msize(medsmall) mcolor(black) ///
		|| qfit mean_hazrate tenure_sp if tenure_sp<35.5&temp==1, lcolor(black)      /// 
		|| qfit mean_hazrate tenure_sp if tenure_sp>35.5&temp==1, lcolor(black)   /// 
		, xline(35.5, lcolor(black)) xlabel(12(6)60) graphregion(fcolor(white) margin(large)) legend(off) /// 
		title(Figure VI) subtitle(Effect of Severance Pay on Job Finding Hazards) xtitle(Previous Job Tenure (Months)) ytitle(Average Daily Job Finding Hazard in First 20 Weeks)   /// 	
		note("Note: The values in this plot can be interpreted as the percentage difference in the average job-finding hazard during the first twenty weeks after job loss between each tenure-month group and the group with 35 months of job tenure", span)

		graph export "$graphs/FigureVI.png", replace
restore


// Figure VIIIa: Effect of Benefit Extension on Nonemployment Durations
preserve 
		gen nonedur_2years = noneduration <= 365*2
		collapse (mean) noneduration, by(tenure_eb nonedur_2years)
		keep if tenure_eb>= 13 & tenure_eb<=58

		twoway scatter noneduration tenure_eb if nonedur_2years == 1, msize(small) mcolor(black)  ///
		|| qfit noneduration tenure_eb if tenure_eb<35.5 & nonedur_2years == 1, lcolor(black)      ///
		|| qfit noneduration tenure_eb if tenure_eb>35.5 & nonedur_2years == 1, lcolor(black)    /// 
		xlabel(12(6)60) xline(35.5, lcolor(black)) graphregion(fcolor(white) margin(large)) legend(off) ylabel(135(5)165)    /// 
		title(Figure VIIIa) subtitle(Effect of Benefit Extension on Nonemployment Durations) ///
	    ytitle(Mean Nonemployment Duration (days)) xtitle(Months Employed in Past Five Years)  ///
		note("Note: While analyzing the effect of EB, the plot exclude the observations with a nonemployment duration of more than two years", span)

		graph export "$graphs/FigureVIIIa,png" replace
restore


// Figure VIIIb: Extended Benefit RD and Job Finding Hazards
cap drop tenure_eb_dum* 
tab tenure_eb, gen(tenure_eb_dum)

preserve 
        ** Cox model 
		#delimit;
		stcox severance_pay
		tenure_eb_dum2-tenure_eb_dum48 
		p1_tenure_eb-p3_tenure_eb 
		interact_sp1 
		interact_sp2 
		interact_sp3 if tenure_eb!= . , nohr
        #delimit cr
        
		** gen mean hazard rate 
		bysort tenure_eb: gen temp = _n
		gen mean_hazrate=.
		foreach var of numlist 2/48 {
			replace mean_hazrate = _b[tenure_eb_dum`var'] if tenure_eb_dum`var'==1 & temp==1 
		}
		replace mean_hazrate = 0 if temp==1&tenure_eb~=.&mean_hazrate==.

		twoway scatter mean_hazrate tenure_eb if temp==1, msize(medsmall) mcolor(black) ///
		|| qfit mean_hazrate tenure_eb if tenure_eb<35.5&temp==1, lcolor(black)     /// 
		|| qfit mean_hazrate tenure_eb if tenure_eb>35.5&temp==1, lcolor(black)   /// 
		xline(35.5, lcolor(black)) xlabel(12 12(6)60) graphregion(fcolor(white) margin(large)) legend(off)  /// 
		title(Figure VIIIb) subtitle(Effect of Extended Benefits on Job-Finding Hazards) xtitle(Months Employed in Past Five Years) ytitle(Average Daily Job Finding Hazard in First 20 Weeks)  ///
		note("Note: This figure plots coefficients from the Cox model examining how the average hazard rate over the first twenty weeks of the spell vary around the EB discontinuity", span)

        graph export "$graphs/FigureVIIIb.png", replace
restore 


**************************************************
*Table II Main Parametric Hazard Model Regressions
**************************************************

cap drop censor
//Constructing the failure variable for survival time analysis
** Ensuring that the earnings are censured at the Social Security contribution limit
gen censor = ne_cens_w0|noneduration>= 140
//Declaring the datset for survival-time analysis
stset noneduration, failure(censor==0)


*Table II- (1) Estimating the effect of severance_pay and EB without controls
#delimit;
		stcox severance_pay eligible30 
			  p1_tenure_sp-p3_tenure_sp interact_sp1-interact_sp3 
			  p1_tenure_eb-p3_tenure_eb interact_eb1-interact_eb3
			  , nohr;
#delimit cr

outreg2 using Result_TableII.doc, replace
// To switch the output display from hazard ratios to the regression coefficients (beta values). Coefficients (Beta): Directly indicate the effect on the log hazard rate; a one-unit increase in the variable increases the log hazard by the coefficient value. Negative values indicate a protective effect. Hazard Ratios: Provide an intuitive measure of risk; values greater than one suggest increased risk, and values less than one suggest decreased risk per unit increase in the variable.

*Table II- (2) Basic Controls
#delimit;
		stcox severance_pay eligible30 
			  p1_tenure_sp-p3_tenure_sp interact_sp1-interact_sp3 
			  p1_tenure_eb-p3_tenure_eb interact_eb1-interact_eb3 
			  female                       //begin basic controls
			  married 
			  austrian 
			  bluecollar 
			  age 
			  age2 
			  lnwage 
			  lnwage2 
			  endmo_dum2-endmo_dum12 
			  endy_dum2-endy_dum21 
			  , nohr;
#delimit cr

outreg2 using Result_TableII.doc, append

*Table II- (3) Full controls
#delimit;
		stcox severance_pay eligible30 
			  p1_tenure_sp-p3_tenure_sp interact_sp1-interact_sp3         //begin basic controls      
			  p1_tenure_eb-p3_tenure_eb interact_eb1-interact_eb3 
			  female 
			  married 
			  austrian 
			  bluecollar 
			  age 
			  age2 
			  lnwage
			  lnwage2
			  endmo_dum2-endmo_dum12 
			  endy_dum2-endy_dum21     
			  firms                      //remaining controls
			  experience_years 
			  experience_years2 
			  last_job
			  last_duration
			  pr_bluecollar
			  last_recall 
			  indnempl
			  pr_noneduration
			  last_noneduration
			  last_breaks
			  edu_dum2-edu_dum6        //education dummy
			  ind_dum2-ind_dum6        //industry dummy
			  reg_dum2-reg_dum6        //region of job loss dummy
			  , nohr;
#delimit cr

outreg2 using Result_TableII.doc, append

*Table II- (4) FULL SAMPLE REWEIGHTED SPECIFICATION

*Table II- (5) Effect on subsample of individuals who were laid off from a firm that laid off four or more workers within one month
cap drop amonth_layoffs
by benr endy endmo: gen amonth_layoffs = _N

#delimit;
		stcox severance_pay eligible30 
			  p1_tenure_sp-p3_tenure_sp interact_sp1-interact_sp3 
			  p1_tenure_eb-p3_tenure_eb interact_eb1-interact_eb3 
			  female                       //begin basic controls
			  married 
			  austrian 
			  bluecollar 
			  age 
			  age2 
			  lnwage 
			  lnwage2 
			  endmo_dum2-endmo_dum12 
			  endy_dum2-endy_dum21 if amonth_layoffs>=4
			  , nohr;
#delimit cr

outreg2 using Result_TableII.doc, append


******************************
** LONG RUN SEARCH OUTCOMES **
******************************

// Figure Xa: Effect of Severance Pay on Subsequent Wages
preserve 
		gen wage_change = log(ne_wage0)-log(wage0)
		collapse (mean) wage_change, by(tenure_sp)
		keep if tenure_sp>=13 & tenure_sp<=58

		twoway scatter wage_change tenure_sp, msize(small) mcolor(black)  ///
		|| lfit wage_change tenure_sp if tenure_sp<35.5, lcolor(black)  /// 
		|| lfit wage_change tenure_sp if tenure_sp>35.5, lcolor(black) ///
		xline(35.5, lcolor(black)) graphregion(fcolor(white) margin(large)) legend(off) xlabel(12(6)60) yscale(range(-.1 0.01)) ylabel(-.1(.02)0) ///
		title(Figure Xa) subtitle(Effect of Severance Pay on Subsequent Wages) xtitle(Previous Job Tenure (Months)) ytitle(Wage Growth)  ///

		graph export "$graphs/FigureXa.png", replace
restore


// Figure Xb Effect of Severance Pay on Subsequent Job Duration
preserve 
		keep if tenure_sp != .
		cap drop tenure_sp_dum*
		tab tenure_sp, gen(tenure_sp_dum)
        
		** Gen duration of next job in month unit
        gen ne_durationm = ne_duration/31

		** Declaring the dataset for hazard model estimates
		stset ne_durationm if indnemp==1, failure(ne_cens_w0==0)
		
		** Cox model
		stcox tenure_sp_dum2-tenure_sp_dum48, nohr
		
		** Gen mean hazard rate
		bysort tenure_sp: gen temp = _n
		gen mean_hazrate=.
		foreach X of numlist 2/48 {
		replace mean_hazrate = _b[tenure_sp_dum`X'] if temp==1&tenure_sp_dum`X'==1
		}
         replace mean_hazrate = 0 if temp==1&tenure_sp~=.&mean_hazrate==.
		 
		** Plot 
		twoway scatter mean_hazrate tenure_sp if temp==1,  msize(small) mcolor(black)  ///
		|| qfit mean_hazrate tenure_sp if tenure_sp<35.5&temp==1, lcolor(black)   /// 
		|| qfit mean_hazrate tenure_sp if tenure_sp>35.5&temp==1, lcolor(black)   /// 
		title(Figure Xb) subtitle(Effect of Severance Pay on Subsequent Job Duration) xtitle(Previous Job Tenure (Months)) ytitle(Average Monthly Job Ending Hazard in Next Job) ///
		xline(35.5, lcolor(black))xlabel(12(6)60) graphregion(fcolor(white) margin(large)) legend(off)
		
	    graph export "$graphs/FigureXb.png", replace
restore


**************************************
*** Table III LONG RUN SEARCH OUTCOMES
**************************************

*Table III- (1) Wage Growth, No Controls
		gen wage_change = log(ne_wage0)-log(wage0)

		** Run OLS
		reg wage_change severance_pay eligible30 p1_tenure_sp-p3_tenure_sp interact_sp1-interact_sp3 p1_tenure_eb-p3_tenure_eb interact_eb1-interact_eb3, robust

		outreg2 using Result_TableIII.doc, replace

*Table III- (2) Wage Growth, Full Controls
#delimit;
reg wage_change severance_pay eligible30 
		p1_tenure_sp-p3_tenure_sp interact_sp1-interact_sp3 
		p1_tenure_eb-p3_tenure_eb interact_eb1-interact_eb3 
		female 
		married 
		austrian 
		bluecollar 
		age 
		age2 
		lnwage
		lnwage2
		endmo_dum2-endmo_dum12 
		endy_dum2-endy_dum21     
		firms                      //remaining controls
		experience_years 
		experience_years2
		last_job
		last_duration
		pr_bluecollar
		last_recall 
		indnempl
		pr_noneduration
		last_noneduration
		last_breaks
		edu_dum2-edu_dum6        //education dummy
		ind_dum2-ind_dum6        //industry dummy
		reg_dum2-reg_dum6        //region of job loss dummy
		;
#delimit cr

outreg2 using Result_TableIII.doc, append

*Table III- (3) Duration of Next Job, No Controls
		gen ne_durationm = ne_duration/31
		stset ne_durationm if indnemp==1
#delimit;	
stcox severance_pay eligible30 
		p1_tenure_sp-p3_tenure_sp 
		interact_sp1
		interact_sp2 
		interact_sp3 
		p1_tenure_eb-p3_tenure_eb 
		interact_eb1-interact_eb3, nohr
		;
#delimit cr

outreg2 using Result_TableIII.doc, append


*Table III- (4) Duration of Next Job, With Controls
#delimit;
stcox severance_pay eligible30 
		p1_tenure_sp-p3_tenure_sp interact_sp1-interact_sp3 
		p1_tenure_eb-p3_tenure_eb interact_eb1-interact_eb3 
		female 
		married 
		austrian 
		bluecollar 
		age 
		age2 
		lnwage
		lnwage2
		endmo_dum2-endmo_dum12 
		endy_dum2-endy_dum21     
		firms                      //remaining controls
		experience_years 
		experience_years2 
		last_job
		last_duration
		pr_bluecollar
		last_recall 
		indnempl
		pr_noneduration
		last_noneduration
		last_breaks
		edu_dum2-edu_dum6        //education dummy
		ind_dum2-ind_dum6        //industry dummy
		reg_dum2-reg_dum6        //region of job loss dummy
		;
#delimit cr
outreg2 using Result_TableIII.doc, append






**************
* SAVE DATASET

save "Cash-on-hand.dta", replace
log close