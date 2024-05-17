****************************************
****		Course Choice	    ****
****************************************

************
** Dimensions (generic design)

x1: ECTS (2 levels)
x2: prerequisites (3 levels)
x3: schedule (2 levels)
x4: assessments (3 levels)
x5: organization (2 levels)
x6: pre-/post graduate mixed (2 levels);


* 1. Find suitable design sizes 
	(specify the no levels of the six variables above);
%mktruns(2 3 2 3 2 2);



* 2. Construct a linear arrangement (vignettes);
%mktex(2 3 2 3 2 2, n=12, seed=32719);



* 3. Evaluate the design;

/*Have a look at the vignettes*/
proc print data=design; run;

%mkteval(data=design);



* 4. Construct the choice sets;

/*Minimal design allocating the 12 vignettes to 4 coice sets, each with 3 alternatives*/
%choiceff(data=design, 
		  model=class(x1 x2 x3 x4 x5 x6 / standorth), 
		  nsets=4, flags=3,
          seed=23843, maxiter=30, options=relative, beta=zero);

/*Allocating the 12 vignettes to 12 coice sets, each with 3 alternatives*/          
%choiceff(data=design, 
		  model=class(x1 x2 x3 x4 x5 x6 / standorth), 
		  nsets=12, flags=3,
          seed=23843, maxiter=30, options=relative, beta=zero);

* 5. Block to decks;    
    
/*Blocking the 12 choice sets to 2 decks*/
%mktblock(data=best, nalts=3, nblocks=2, factors=x1-x6, 
			out=blocked, outr=blockedr, seed=472);

/*Have a look at the choice sets*/


*6. Export for further use (in Stata, etc.);
proc print data=blocked; run;

PROC EXPORT DATA=blocked
            OUTFILE= "/home/u47334465/courses.dta" 
            DBMS=STATA REPLACE;
RUN;

