** This file deals with simulated annealing
** It makes use of the results from the MC allocation from Statistics.fan 



class Optimise
{
	static const Int T := Int.maxVal
	static Void main(Str[] args)
	{
		
//		del := delProjs(Nalloc,stdList, projList, rank)
//		rotate := rotateProjs(Nalloc, stdList, projList, rank)
		//manip := manipProjs(Nalloc, stdList, projList, rank)
		
		//Optimise.simAnneal(objFn, Nalloc, rank, shift, stdList)
		/* Find best allocation using simulated annealing
		identify it's the best allocation
		test by altering the number of projList
		tests how good simulated eating is
		objective function: -takes stud-proj pairs
							-outputs a number
							-sum of ranks of projs
							-unallocated is higher ranked
							-may not be correct
							-you can't have supervisor supervising more than their max limit
							-if allocation has supervisor supervising more projList than allowed, then objective function is very large M
							-needs to be independent
							-has to be efficient subject to constraints
							-difference in value of objective functions of multiple stdList needs to be small
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
		Statistics.main([args[0], args[1], args[2]])
		echo("Done!")
		//simAnneal(10000)

	}
	
	static Void callMeMaybe(Int min, Int max, Int avg, Int:Int objFn, Int:[Project:Bool] assigned, Student:[Project:Int] rank, Int:[Project:Student] Nalloc, Student[] stdList, Project[] projList, Supervisor[] supList )
	{
		asdf := shiftProjs(Nalloc, stdList, projList, rank)
		//steepDesc(objFn, Nalloc, rank, add, stdList)
	}
	
	static Float extractObjfn(Int:[Project:Student] alloc, Student:[Project:Int] rank, Student[] stdList, Int index)
	{
		num := Statistics.calcObjFn(rank, stdList, alloc)
		return num[index].toFloat
	}
	
	static Float ps(Int k, Int:[Project:Student] alloc, Student:[Project:Int] rank, [Int:[Student:Project?]]? permute, Student[] stdList)
	{
		num := 0f
		(0..k).each { num += Float.e.pow(-T*extractObjfn(alloc, rank, stdList, 1)) }
		return num
	}
	
		static Bool validShift(Student st, Project? pr, Student:[Project:Int] rank)
	{
		valid := true
		if(pr == null || rank[st][pr] == -1) 
			valid = false 
		return valid
	}
	
	
	static Void moveStud(Student:Project? SP, Project:Student PS, Project[] projs, Student:[Project:Int] rank)
	{
		newStudProj := Student:Project?[:]
		prefs_sp := Student:Project[][:]
		prefs_ps := Project:Student[][:]
		prefs_sp_unalloc := Student:Project[][:]
		PSrw := PS.rw
		
		//Populate newStudProj with SP
		SP.each |p, s| { newStudProj[s] = p }
		
		//rank.each|pi, s| { echo("$s -> $pi") }
		//Populate the preference maps by getting all the possible preferences
		//of S->P and P->S
		rank.each |pi, s| 
		{ 
			prefs_sp[s] = [,]
			pi.each |i, p| { if(i != -1) prefs_sp[s].add(p) }
		}
		
		//Populate a map of students to unallocated projects
		//students with no projects are also mapped
		rank.each |pi, s| 
		{ 
			prefs_sp_unalloc[s] = [,]
			pi.each |i, p| { if(i != -1 && (!PS.keys.contains(p) || newStudProj[s] == null)) prefs_sp_unalloc[s].add(p) }
		}
		echo(prefs_sp_unalloc)
		projs.each |Project p| 
		{ 
			prefs_ps[p] = [,]
			prefs_sp.each |v, k| { if(v.contains(p)) prefs_ps[p].add(k)  }
		}
		echo("\n$SP")
		newStudProj.each |p, s1| 
		{   
			p1 := (Project?) newStudProj[s1]
			prefs_sp[s1].each |p3| 
			{   
				if(!PSrw.containsKey(p3))
				{
					echo("\nprefs_sp[$s1]: (p3) $p3: (p1) $p1")
					prefs_ps[p1].each |s2|
					{
						//if project not assigned yet
						echo("$s2: ${newStudProj[s2]}")
						tmp := newStudProj[s2]
						if(!newStudProj.vals.contains(p3))
						{
							newStudProj[s2] = p1
							newStudProj[s1] = p3
							PSrw[p3] = s1
							//removes the assigned project from the unallocated list
							//adds the project being shifted out into the unallocated list
							
							prefs_sp_unalloc.each |pr, st| 
							{ 
								
								if(pr.contains(p3)) 
								{
									prefs_sp_unalloc[st].remove(p3)
									prefs_sp_unalloc[st].remove(p1)
								}
								if(tmp != null && rank[st][tmp] != -1 && !prefs_sp_unalloc[st].contains(tmp))
									prefs_sp_unalloc[st].add(tmp)
								
							}
							
						}

						/*
						numAssigned := 0
						newStudProj.each { if(it==p1) ++numAssigned}
						*/
						//if(newStudProj.vals.eachWhile { p1 } == null)
						//{
						//if(numAssigned <= 1)
						//{!newStudProj.vals.contains(p3)
						//if(!prefs_sp_unalloc[s2].isEmpty)
						//{
						//newStudProj[s1] = p3
						
						//shifts p1 out of s1
						//and p3 into s1
						//newStudProj[s2] = p1
							
						//shifts p2 out of s2
						//and p1 into s2
						//what happens to p2 after? no idea
						//PSrw[p3] = s1
						//p1 = tmp
							
						//}
						//if(tmp != null) PSrw.remove(tmp)
					}
				}
			}
		}
		echo("\n$newStudProj")
		echo(prefs_sp_unalloc)
		//newStudProj.each |p, s| {  if(p != null && rank[s][p] != -1) echo("OK= $s: $p = ${rank[s][p]}"); else if(p != null) echo("not OK = $s: $p = ${rank[s][p]}"); else echo("OK: $s: $p")  }
		
		if(newStudProj.vals == SP.vals)
			echo("No change in total projList")
		else
		{
			echo("Change detected.")
			numSP := 0
			numNSP := 0
			SP.vals.each { if(it != null) ++numSP }
			newStudProj.vals.each { if(it != null) ++numNSP }
			if(numSP < numNSP)
			{
				echo("Project(s) added")
				echo("$numSP projList previously; now $numNSP projList")
			}
			else if(numSP > numNSP)
			{
				echo("Project(s) deleted")
				echo("$numSP projList previously; now $numNSP projList")
			}
			else echo("Project(s) shifted")
			/*
			echo("In newStudProj: ")
			newStudProj.each |p, s| { if(!SP.vals.contains(p)) echo("$s: $p") }
			echo("In SP: ")
			SP.each |p, s| { if(!newStudProj.vals.contains(p)) echo("$s: $p") }*/
		}
		SP.clear
		SP.addAll(newStudProj)
		/*
		switch(mode)
		{
			case 1:
				//--------------------Add--------------------
				//Attempts to add a project to the each student
				//Only valid preferences can be added.
				//Adds a project only if the student has no project
				//If it can be added to the student, it is added then removed from the prefs_sp_unalloc mapping
				prefs_sp_unalloc.each |p, s|
				{
					if(!p.isEmpty)
					{
						p.each |prj|
						{ 
							if(newStudProj[s] == null)
							{
								newStudProj[s] = prj 
								prefs_sp_unalloc.each |pr, st| { if(pr.contains(prj)) prefs_sp_unalloc[st].remove(prj) }
							}
						}
					}
				}

			case 2:
				//--------------------Delete--------------------
				//Removes a project from the last student shifted
				//Simply nulls the final student
				newStudProj[newStudProj.keys.last] = null

			case 3:
				//"--------------------Rotate--------------------"
				//newStudProj is filled. need to use a temporary variable.
				//populate it then repopulate newStudProj with those values
				tmp := Student:Project?[:]
				(0..<SP.size-1).each { tmp.add(newStudProj.keys[it], newStudProj.vals[it+1])}
				tmp.add(newStudProj.keys.last, newStudProj.vals.first)
				newStudProj.clear
				newStudProj.addAll(tmp)	

			default: echo("Incorrect mode")
		}
		echo(newStudProj)
		
		*/

	}
		
	static Int:[Student:Project?] shiftProjs(Int:[Project:Student] psMap, Student[] stdList, Project[] projList, Student:[Project:Int] rank)
	{
		newRank := Int:[Student:Project?][:]
		resRank := Student:Project?[:]
		(1..psMap.size).each { newRank[it] = [:]}
		psMap.each |ps, i|
		{
			if(newRank[i].isEmpty)
				stdList.each { newRank[i][it] = null }
			
			ps.each |Student s, Project p| { newRank[i][s] = p }
		}
		//echo(newRank)
		moveStud(newRank[1], psMap[1], projList.toImmutable, rank)
		//(1..newRank.size).each { moveStud(newRank[it], psMap[it], projList.toImmutable,  rank) }
		//echo(newRank)
		return newRank
	}
	
	
	static Int:[Student:Project?] steepDesc(Int:Int objFn, Int:[Project:Student] Nalloc, Student:[Project:Int] rank, Project[] projList, Student[] stdList)
	{
		//do it once
		permute := shiftProjs(Nalloc,stdList, projList, rank)
		permPS := Int:[Project:Student][:]
		permute.each |sp, i| { permPS[i] = [:]; sp.each |Project? p, Student s| { if(p != null) permPS[i][p] = s }  }
		permObjFn := Statistics.calcObjFn(rank, stdList, permPS)
		a1 := permObjFn.vals.min
		a := objFn.vals.min

		
		//loop each time
		while(a1 < a)
		{
			//find the set of permutes
			a = a1
			permute = shiftProjs(Nalloc,stdList, projList, rank)
			permute.each |sp, j| { permPS[j] = [:]; sp.each |Project? p, Student s| { if(p != null) permPS[j][p] = s }  }
			permObjFn = Statistics.calcObjFn(rank, stdList, permPS)
			a1 = permObjFn.vals.min
		}
		
		return permute
	}
	
	static Void simAnneal(Int:Int objFn, Int:[Project:Student] alloc, Student:[Project:Int] rank, [Int:[Student:Project?]]? permute, Student[] stdList)
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
		a := Int[,]
		objFn.each { a.add(it) }
		a.sort |i, j| { return i <=> j  }
		echo(a)
		//the below function gets the key for each of the values in the sorted array, a
		a.each |i| { k := objFn.eachWhile |v, k| { i == v ? k : null}; echo(k) }
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
    	
    	(1) calculate set of perms P of initial allocation a
        (2) for each a' in P calculate objFun(a').
        (3) Take the a' in P with minimum objFun. Call this a1. (If multiple minimum select one). If this has objFun(a1) > objFun(a) we have finished and a is the "local minimum" answer. Otherwise set a = a1 and iterate from (1).

    	*/
		newObj := Int:Int[:]
		newAlloc := Int:[Project:Student][:]
		newRank := Student:[Project:Int][:]
		newPerm := Int:[Student:Project?][:]
		alpha := 0.98f
		//T := 32767f  //some arbitrarily high value
        k := 2

    	
		//ps(k)
    	
		//e.pow is too large
        
		

		//P_i = (ps(i)-ps(i-1))/ps(alloc.size-1)
		
		echo(objFn)
		//permute.each |sp, i| { echo("$i: $sp")  }
		/*
		for(i := 0; i < 10; i++)
		{
			f := Float.random * 50f
			echo("$f.toStr")
		}
		*/
		
		RAND_MAX := 32767f
		x := 10
		L := objFn[1]
		i := 1
		//need to easily use ps() syntax..
		a_i := (ps(i, alloc, rank, permute, stdList) - ps(i-1, alloc, rank, permute, stdList))/ps(alloc.size-1, alloc, rank, permute, stdList)
		n := 0
		e := 0
		while(n < Int.maxVal && e > Int.maxVal)
		{
			//need to redo this probably
			
		}
		
		for (T := objFn[1].toFloat; T > 0.00008f; T *= alpha) //T = T * alpha which used as a cooling schedule 
        {
			num := 0f
            for (j := 0; j<200; j++) //This loop is for the process of iteration (or searching for new states)
            {
                xNew := x.toFloat + (Float.random * 2f - 1f)
                LNew := xNew.pow(4f) + 4/3*xNew.pow(3f) - 4 * xNew.pow(2f) + 5
				(0..k).each { num += Float.e.pow(-T*extractObjfn(alloc, rank, stdList, 1)) }
				
                if (LNew < L.toFloat || Float.random <= Float.e.pow(-(LNew-L)/T))
                {
                    L = LNew.toInt;
                    x = xNew.toInt;
                }
            }
     
     
        }
		
		echo("Final state = $x, total of F(x) = $L")
	}
}
