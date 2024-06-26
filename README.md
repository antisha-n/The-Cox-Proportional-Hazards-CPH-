# The-Cox-Proportional-Hazards-CPH-
This project replicated the results of Card, Chetty, and Weber (2007) titled "Cash-on-Hand and Competing Models of Intertemporal Behavior: New Evidence from the Labor Market. 

# CASH-ON-HAND AND COMPETING MODELS OF INTERTEMPORAL BEHAVIOR: NEW EVIDENCE FROM THE LABOR MARKET (Card et.al. 2007)

## 1. Institutional Context

The labor market in Austria is characterized as an optimal blend of institutional regulation and flexibility. Their dynamics of job creation and job destruction are well-balanced, akin to the situation in the United States. Severance pay, a critical component of firing regulations in Austria, was first introduced in 1921 solely for white-collar workers. This provision was subsequently extended to all categories of workers in 1979. Severance payments are disbursed within one month of job termination and are not subject to social security taxes.

Eligibility for severance pay in Austria is strictly confined to individuals with at least three years of employment tenure. According to this stipulation, employees with less than 36 months of service are ineligible for this benefit. The amount of severance pay is calculated as two months of the employee’s pre-tax salary, averaging 2,300 euros across observed cases. This regulation excludes construction workers, who are subject to alternate severance pay regulation, and therefore, they are omitted from this analysis. Additional exclusions apply to employees in public sectors like schools and hospitals, owing to their fixed-term employment contracts.

The laid-off workforce is eligible for unemployment benefits if they can present evidence of sufficient work history. However, unlike severance pay, unemployment insurance can be claimed by individuals who have worked for twelve months or more in the two years preceding their job loss. Workers who are laid off by their employers are immediately eligible for benefits, while those who voluntarily leave or are fired for a reasonable cause undergo a four-week waiting period. Furthermore, there are different unemployment insurance slabs applicable depending on the duration of job tenure in the past five years to the current job loss. Individuals with less than 36 months of employment in the past five years receive twenty weeks of benefits, while those who have worked for at least 36 months of employment in the last five years receive thirty weeks of benefits. Unemployment insurance is also referred to as extended benefits. At the end, if unemployed individuals exhaust their extended benefits, they can also claim means-tested secondary benefit, known as "unemployment assistance" which amounts to euros equivalent of an average family income until they find the next job. The receipt of severance pay does not affect any of the extended employment benefits.

## 2. Internal Validity

This investigation is based on data obtained from the Austrian Social Security Registry 1980-2001. The dataset provides comprehensive daily records on employment status, unemployment and non-employment duration, annual earnings of the employees, as well as demographic characteristics of the firms and the workers. It is integrated with additional information regarding education and marital status obtained from the Austrian unemployment registers, which are available from 1987 to 1998. The authors leverage a quasi-experimental design induced by Austria’s institutional arrangements to rigorously examine the discontinuities in severance pay and unemployment benefits, enabling a sharp regression discontinuity (RD) analytic framework. From this rich dataset, the analysis excludes any job terminations followed by an unemployment claim that did not result in retirement within the same calendar year, alongside roles in the public sector, services industry, and construction sector due to their distinct regulatory frameworks.

The refined sample consists of 650,922 job losses, selectively filtering out individuals under 20 or over 49 years of age, those employed less than a year or over five years, voluntary quitters, and any instances of rehiring by the same employer. This strategic sample refinement helps ensure that the empirical findings are representative of the broader population of individuals experiencing job loss. The sample included individuals who lost their job at least once. The dataset shares 84% of single job loss, two job losses for 13%, and 3 or more job losses for the remaining 3% of individuals. The final analysis sample is slightly younger, more likely to be female, and a little less likely to hold Austrian citizenship than the overall workforce. Job losers also earn lower wages than workers as a whole. However, overall characteristics of the job losers in the paper’s analysis are fairly similar to those of the broader set of job losers (see Table 1). This suggests that the authors’ empirical results are likely to be representative of the population of job losers.

## 3. Key Results and Findings

### Severance Pay
- Figure V suggests that the nonemployment duration increases by 10 days (about one and a half weeks) at the threshold for severance pay eligibility. This observed increase, however, cannot be solely attributed to severance pay due to potential confounding effects from extended unemployment benefits.
- Subsequent analyses (see Figure VI) adjusting for these dual influences reveal a decrease in the reemployment likelihood at the severance pay eligibility threshold, quantified as a 10% reduction in the hazard rate of finding new employment.

![Figure V](figures/figure5.png)
![Figure VI](figures/figure6.png)

### Extended Benefits (EB)
- Figure VIIIa suggests that the average nonemployment duration drops by seven days around the EB discontinuity.
- There is a slight fall in the average hazard rate (see Figure VIIIb), with a sudden fall of approximately 7% in the average hazard rate at the cutoff for EB eligibility.

![Figure VIIIa](figures/figure8a.png)
![Figure VIIIb](figures/figure8b.png)

### Job Search Duration
- Figure Xa suggests that increased job search duration due to severance pay did not improve wage levels in the next job, and job leaving hazards are smooth around cut-off (see Figure Xb).

![Figure Xa](figures/figure10a.png)
![Figure Xb](figures/figure10b.png)

## 4. Discussion

Proportional hazard models are statistical tools used to conduct survival analysis and evaluate not only if an event happens, like using the logistic regression, but also when it happens. In the context of Card et al., 2007, employing the Cox proportional hazards model, the study assessed the timing and likelihood of reemployment subsequent to job loss, accounting for the duration of unemployment benefits received. This is extremely useful in public finance as it can assist in deciding for how long similar policy benefits should be financed and given to beneficiaries to smooth consumption and improve their welfare. Cox models also helped analyze the dynamic process of job searching over time by handling the time-dependent covariates, which often cause issues in time series analysis due to complex dependency structures. This model is particularly advantageous for analyzing complex, time-dependent data structures typical of longitudinal employment studies such as this.

While inspecting the validity of the RD design and evaluating main results, the Proportional hazard model also allowed censoring time-dependent factors and studying the required model specifications such as the effect of EB on nonemployment duration in the first twenty weeks. This model can be further utilized to check the robustness of findings in more refined censors.

### Negative Sides of Using Proportional Hazard Model
- The Proportional hazard model firmly stands on the assumption that the effects of the covariates are constant over time. It necessitates careful consideration to avoid bias in interpreting the results.
- Selective censoring in the proportional hazard models may sometimes bias estimates. For instance, Card et al., 2007 censor spells at 140 days to isolate the policy variables’ effects, which might lead to information loss or bias if the censoring is not random.

## 5. Appendix

### Figure References
- Appendix Figure II: Investigating the practice of selective firing mechanism by analyzing layoffs at 35 months and beyond 36 months.
- Appendix Figure IIIa & IIIb: Variation in observable characteristics around the 36-month threshold.
- Appendix Figure IV: Average predicted hazard ratios by tenure-month category using a Cox Proportional Hazard Model.
- Appendix Table I: Characteristics of job losers vs. the broader set of job losers.
- Appendix Table II: Estimated effect of SP and EB on nonemployment duration.
- Appendix Table III: Double RD specifications on job search duration.

![Appendix Figure II](figures/appendix_figure2.png)
![Appendix Figure IIIa](figures/appendix_figure3a.png)
![Appendix Figure IIIb](figures/appendix_figure3b.png)
![Appendix Figure IV](figures/appendix_figure4.png)


