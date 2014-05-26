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
		
		*/

	}
}
