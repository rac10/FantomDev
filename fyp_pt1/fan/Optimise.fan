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
		//simAnneal(10000)

	}
	
	static Float R(Int a,  Int:[Project:Student] alloc) //THIS NEEDS TO PASS THE ALLOCATION
	{
		return 1f
	}
	
	static Float p(Int a, Int:[Project:Student] alloc)
	{
		T := Int.maxVal.toFloat //some arbitrarily high value
		num := Float.e.pow(-T*R(a, alloc))
		return num
	}
	
	static Float ps(Int k, Int:[Project:Student] alloc)
	{
		num := 0f
		(0..k).each { num += it * p(it, alloc)*it  }
		return num
	}
	
	static Void simAnneal(Int:Int objFn, Int:[Project:Student] alloc, Student:[Project:Int] rank, [Int:[Student:Project?]]? permute, Student[] students)
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
    	
    	For a given allocation a you have objective function R(a) - objFn
    
        for allocation a, and permutation set S, you have permuted allocation set:
        A' = {s(a) | s in S}
        for elements a' in A' you evaluate R(a'). These are the neighbouring values. 
        For SD you choose the minimum. 
        For SA you choose an element at random, biased towards lower values according to exponential based on temperature.
        */
        R_a := objFn[1].toFloat
		
		/*
        >How do you do this bias properly?
        
        Calculate the relative probabilities if each a in A':
        	p(a) = exp(-T*R(a))
        order the a values by R (objFn), so that a(0) is the lowest R(a) of a in A', a(N-1) is the highest R(a)
        generate the relative probability partial sums:
        ps(k) = sum(i = 0 to k) { p(a(i))} (you can do this quite efficiently)
        so that  the probability of choosing a(i) is (ps(i)-ps(i-1))/ps(N-1)
        
        Now make the choice using a uniform random number in range 0 - ps(N-1). You can do a binary search lookup to determine which "bin" the random number falls into.
        
        there are maybe ways to optimise this - e.g. incorporate the exponential in the random number and calculate p(a) without an exponential - but I would not worry too much about this. SA will be pretty inefficient because we have to calculate all the neighbours but then choose only one of them.
        
        SD is not as bad because the total number of steps in SD is necessarily small!
        
        Note also that you should get SD working first - it is simpler than SA and much easier to test.
    	*/
		newObj := Int:Int[:]
		newAlloc := Int:[Project:Student][:]
		newRank := Student:[Project:Int][:]
		newPerm := Int:[Student:Project?][:]
		alpha := 0.98f
		
		echo(ps(4, alloc))
		//P_i = (ps(i)-ps(i-1))/ps(alloc.size-1)
		
		echo(objFn)
		permute.each |sp, i| { echo("$i: $sp")  }
		/*
		for(i := 0; i < 10; i++)
		{
			f := Float.random * 50f
			echo("$f.toStr")
		}
		*/
		
		/*RAND_MAX := 32767f
		x := 10
		L := objFn
		for (T := 80f; T > 0.00008f; T *= alpha) //T = T * alpha which used as a cooling schedule 
        {
            for (i := 0; i<200; i++) //This loop is for the process of iteration (or searching for new states)
            {
                xNew := x.toFloat + (Float.random * 2f - 1f)
                LNew := xNew.pow(4f) + 4/3*xNew.pow(3f) - 4 * xNew.pow(2f) + 5
     
                if (LNew < L.toFloat || Float.random <= Float.e.pow(-(LNew-L)/T))
                {
                    L = LNew.toInt;
                    x = xNew.toInt;
                }
            }
     
     
        }
		
		echo("Final state = $x, total of F(x) = $L")*/
	}
}
