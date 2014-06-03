** This file deals with simulated annealing
** It makes use of the results from the MC allocation from Statistics.fan 


class Optimise
{
	static Void main(Str[] args)
	{
		/* Find best allocation using simulated annealing
		identify it's the best allocation
		test by altering the number of projects
		tests how good simulated eating is
		objective function: -takes stud-proj pairs
							-outputs a number
							-sum of ranks of projs
							-unallocated is higher ranked
							-may not be correct
							-you can't have supervisor supervising more than their max limit
							-if allocation has supervisor supervising more projects than allowed, then objective function is very large M
							-needs to be independent
							-has to be efficient subject to constraints
							-difference in value of objective functions of multiple students needs to be small
							-differential objective function
							-function needs to be given existing allocation
							-for efficiency, need to have the stats for each supervisor (because of limit of each supervisor)
							-takes info from current allocation
							-how many choices for project + rank for each project, gather stats for each project
		
		
		1) Select an initial value
    2) Obtain the objective function
    3) Select the reduction factor
    4) Randomly select a value neighbouring the initial value
    5) Calculate the difference between the neighbouring value and the initial value
    	a. If the difference is less than zero, then use the neighbouring value as the new initial value for the next iteration
    b. Otherwise, generate a random number such that if this random number is less a defined factor, then the neighbouring value is assigned as the new initial value for the following iteration
    6) Repeat the iterations as needed
    7) Scale the objective function by the reduction factor
    8) Repeat until the halting condition is met
		*/
		reduc := 0.4f
		simAnneal(5)

	}
	
	static Void simAnneal(Int objFn)
	{
		/*	1) Select an initial value
            2) Obtain the objective function
            3) Select the reduction factor
            4) Randomly select a value neighbouring the initial value
            5) Calculate the difference between the neighbouring value and the initial value
            	a. If the difference is less than zero, then use the neighbouring value as the new initial value for the next iteration
            b. Otherwise, generate a random number such that if this random number is less a defined factor, then the neighbouring value is assigned as the new initial value for the following iteration
            6) Repeat the iterations as needed
            7) Scale the objective function by the reduction factor
            8) Repeat until the halting condition is met */
	/*	
		 double first_run, second_run, third_run;        //(first, second and third run) are defined for the purpose of comparing the resulting
    time_t systime;                                // solutions of the three runs will be chosen as the final solution
    time(&systime);
    srand((unsigned int)systime);
    double  alpha = 0.9;                         //alpha is used for the cooling schedule of the temperature            
    const double e = 2.718281828;
 
 
 
 
 
 
    double x = 10; //setting an initial value of x (state)
 
    cout << "Initial State = " << x << "\t, and F(x)= " << f(x) << endl;
 
    double L = f(x);
 
    for (double T = 80; T > 0.00008; T *= alpha) //T = T * alpha which used as a cooling schedule 
    {
 
 
        for (int i = 0; i<200; i++) //This loop is for the process of iteration (or searching for new states)
        {
            double xNew = x + ((rand() / (double)RAND_MAX) * 2 - 1);
            double LNew = f(xNew);
 
            if (LNew < L || (rand() / (double)RAND_MAX) <= pow(e, -(LNew - L) / T))
            {
                L = LNew;
                x = xNew;
            }
        }
 
 
    }
 
    cout << "Final state = " << x << "\t, total of F(x) = " << f(x) << endl << endl;
	
	For a given allocation a you have objective function R(a)

    for allocation a, and permutation set S, you have permuted allocation set:
    A' = {s(a) | s in S}
    for elements a' in A' you evaluate R(a'). These are the neighbouring values. For SD you choose the minimum. For SA you choose an element at random,
    biased towards lower values according to exponential based on temperature.
    
    >How do you do this bias properly?
    
    calculate the relative probabilities if each a in A':
    	p(a) = exp(-T*R(a))
    order the a values by R, so that a(0) is the lowest R(a) of a in A', a(N-1) is the highest R(a)
    generate the relative probability partial sums:
    ps(k) = sum(i = 0 to k) { p(a(i))} (you can do this quite efficiently)
    so that  the probability of choosing a(i) is (ps(i)-ps(i-1))/ps(N-1)
    
    Now make the choice using a uniform random number in range 0 - ps(N-1). You can do a binary search lookup to determine which "bin" the random number falls into.
    
    there are maybe ways to optimise this - e.g. incorporate the exponential in the random number and calculate p(a) without an exponential - but I would not worry too much about this. SA will be pretty inefficient because we have to calculate all the neighbours but then choose only one of them.
    
    SD is not as bad because the total number of steps in SD is necessarily small!
    
    Note also that you should get SD working first - it is simpler than SA and much easier to test.
	*/
		alpha := 0.98f
		newstuff := Int.random/Int.maxVal
		//T := 5f
		R_a := objFn
		//p_a := Float.e.pow(-T*R_a)
		RAND_MAX := Int.maxVal.toFloat
		x := 10
		L := x.pow(4) + (4 / 3) * x.pow(3) - 4 * x.pow(2) + 5
		for (T := 80f; T > 0.00008f; T *= alpha) //T = T * alpha which used as a cooling schedule 
        {
     
     
            for (i := 0; i<200; i++) //This loop is for the process of iteration (or searching for new states)
            {
                xNew := x.toFloat + ((Float.random / RAND_MAX) * 2f - 1f);
                LNew := xNew.pow(4f) + (4 / 3).toFloat * xNew.pow(3f) - 4 * xNew.pow(2f) + 5;
     
                if (LNew < L.toFloat || (Float.random / (Float) RAND_MAX) <= Float.e.pow(-(LNew - L) / T))
                {
                    L = LNew.toInt;
                    x = xNew.toInt;
                }
            }
     
     
        }
		
		echo("$L: $x")
	}
}
