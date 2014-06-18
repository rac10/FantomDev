** This file deals with simulated annealing/steepest descent code
** It makes use of the results from the MC allocation from Statistics.fan
** It calls Statistics.fan from the main which in turn calls a function from this file



class Optimise
{
	static const Int T := Int.maxVal
	static Void main(Str[] args)
	{
		//this function's only job is to call statistics.fan with its parameters
		Statistics.main([args[0], args[1], args[2]])
		echo("Done!")

	}
	
	static Void callOpt(Int min, Int max, Int avg, Int:Int objFn, Int:[Project:Bool] assigned, Student:[Project:Int] rank, Int:[Project:Student] Nalloc, Student[] stdList, Project[] projList, Supervisor[] supList)
	{
		//this function gets called by statistics.fan
		//and calls other functions from this class
		result := steepDesc(objFn, Nalloc, rank, projList, stdList, supList)
		echo(result)
	}
	
	static Float extractObjfn(Int:[Project:Student] alloc, Student:[Project:Int] rank, Student[] stdList, Int index)
	{
		//takes the objective function at a particular index
		num := Statistics.calcObjFn(rank, alloc)
		return num[index].toFloat
	}
	
	static Float ps(Int k, Int:[Project:Student] alloc, Student:[Project:Int] rank, [Int:[Student:Project?]]? permute, Student[] stdList)
	{
		//used for probability bias in simulated annealing
		num := 0f
		(0..k).each { num += Float.e.pow(-T*extractObjfn(alloc, rank, stdList, 1)) }
		return num
	}
	
	static Bool validShift(Student st, Project? pr, Student:[Project:Int] rank)
	{
		//checks whether the result of a shift is valid
		valid := true
		if(pr == null || rank[st][pr] == -1) 
			valid = false 
		return valid
	}
	
	static Supervisor:Int countSup(Supervisor[] supList, Student:Project? SP)
	{
		//counts the number of projects assigned for each supervisor
		supCount := Supervisor:Int[:]
		supList.each |s, i|
		{
			supCount[s] = 0
			SP.each { if(it != null && it.sup1 == s.name) supCount[s]++	}	
		}
		return supCount
	}
	
	static Int calcObjVal(Student:[Project:Int] rank, Student:Project? SP)
	{
		//calculates the objective value of a particular map
		sum := 0
		K := 2
		SP.each |p, s|
		{
			if(p != null && rank[s][p] != -1)
				sum += rank[s][p]
			else sum += 11
		}
		return sum.pow(K)
	}
	
	static Void moveStud(Student:Project? SP, Project:Student PS, Project[] projs, Student:[Project:Int] rank, Supervisor[] supList)
	{
		//attempts to shift/moves students
		//only shifts/moves students if they produce
		//a better result than the initial allocation
		newStudProj := Student:Project?[:]
		prefs_sp := Student:Project[][:]
		prefs_ps := Project:Student[][:]
		prefs_sp_unalloc := Student:Project[][:]
		supCount := countSup(supList, SP)
		PSrw := PS.rw
		objVal := calcObjVal(rank, SP)
		

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
			pi.each |i, p| { if(i != -1 && (!PS.keys.contains(p))) prefs_sp_unalloc[s].add(p) }
		}
		//echo(prefs_sp_unalloc)
		projs.each |Project p| 
		{ 
			prefs_ps[p] = [,]
			prefs_sp.each |v, k| { if(v.contains(p)) prefs_ps[p].add(k)  }
		}
		
		//prefs_sp.each |v, k| { echo("$k: $v")}
		//prefs_ps.each |v, k| { echo("$k: $v")}
		
		//echo(supCount)
		//initial state
		//echo("\n$SP")
		curObjVal := calcObjVal(rank, newStudProj)
		newStudProj.each |p1, s1| 
		{
			//newStudProj is Student:Project?
			if(p1 != null)
			{
				prefs_sp[s1].each |p2| 
				{					
					//prefs_sp is always Student:Project[]
					//performs a shift
					if(!PSrw.containsKey(p2))
					{
						//echo("\nprefs_sp[$s1]: (p2) $p2: (p1) $p1")
						prefs_ps[p1].each |s2|
						{
							//if project not assigned yet
							//echo("$s2: ${newStudProj[s2]}")
							curSup := (Supervisor) supCount.eachWhile |i, s| { p2.sup1 == s.name ? s : null}
							if(!newStudProj.vals.contains(p2) && supCount[curSup] < curSup.max)
							{
								newStudProj[s1] = p2
								newStudProj[s2] = p1
								PSrw[p2] = s1
							}
							else
							{
								newStudProj[s1] = p2
								newStudProj[s2] = null
								PSrw[p2] = s1
							}
							supCount = countSup(supList, newStudProj)
							curObjVal = calcObjVal(rank, newStudProj)
							if(curObjVal < objVal)
							{
								//if the newly placed newStudProj is better
								//replace SP
								SP.clear
								SP.addAll(newStudProj)
							}
							else
							{
								//if it's not better, revert to original SP values
								newStudProj[s1] = SP[s1]
								newStudProj[s2] = SP[s2]
							}
							//else if(curObjVal == objVal) echo("Equal")
							//else echo("Not working")
						}
					}
				}
			}
		}
		//final state
		//echo(SP)
		//echo(newStudProj)
		
		//echo("$curObjVal, $objVal")
		//echo(prefs_sp)
		//echo("\n$newStudProj")
		//echo(supCount)
		//supCount.each |i, s| {   echo("$s.name: $s.max")}
		//newStudProj.each |p, s| {  if(p != null && rank[s][p] != -1) echo("OK= $s: $p = ${rank[s][p]}"); else if(p != null) echo("not OK = $s: $p = ${rank[s][p]}"); else echo("OK: $s: $p")  }
		/*
		if(SP.vals.containsAll(newStudProj.vals))
			echo("Project(s) rotated")
		else
		{
			//echo("Change detected.")
			numSP := 0
			numNSP := 0
			SP.vals.each { if(it != null) ++numSP }
			newStudProj.vals.each { if(it != null) ++numNSP }
			if(numSP < numNSP)
			{
				echo("Project(s) added")
				echo("$numSP projects previously; now $numNSP projects")
			}
			else if(numSP > numNSP)
			{
				echo("Project(s) deleted")
				echo("$numSP projects previously; now $numNSP projects")
			}
			else echo("Project(s) shifted")
			/*
			echo("In newStudProj: ")
			newStudProj.each |p, s| { if(!SP.vals.contains(p)) echo("$s: $p") }
			echo("In SP: ")
			SP.each |p, s| { if(!newStudProj.vals.contains(p)) echo("$s: $p") }*/
		}*/
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
		
	static Int:[Student:Project?] shiftProjs(Int:[Project:Student] psMap, Student[] stdList, Project[] projList, Student:[Project:Int] rank, Supervisor[] supList)
	{
		//deals with the project shifting
		//creates local variables that are returned after being processed
		
		newRank := Int:[Student:Project?][:]
		resRank := Student:Project?[:]
		(1..psMap.size).each { newRank[it] = [:]}
		psMap.each |ps, i|
		{
			if(newRank[i].isEmpty)
				stdList.each { newRank[i][it] = null }
			
			ps.each |Student s, Project p| { newRank[i][s] = p }
		}
		//newRank.each |a, b| { echo("$b: $a") }
		//moveStud(newRank[1], psMap[1], projList.toImmutable, rank)
		(1..newRank.size).each { moveStud(newRank[it], psMap[it], projList.toImmutable,  rank, supList) }
		//echo(newRank)
		return newRank
	}
	
	
	static Int:[Project:Student] steepDesc(Int:Int objFn, Int:[Project:Student] Nalloc, Student:[Project:Int] rank, Project[] projList, Student[] stdList, Supervisor[] supList)
	{
		//calculates the set of permutations
		//do it once first
		permute := shiftProjs(Nalloc, stdList, projList, rank, supList)
		permPS := Int:[Project:Student][:]
		permute.each |sp, i| { permPS[i] = [:]; sp.each |Project? p, Student s| { if(p != null) permPS[i][p] = s }  }
		echo(Nalloc)
		//echo(permPS)
		//permute.each |v, k| { echo("$k: $v")}
		permObjFn := Statistics.calcObjFn(rank, permPS)
		a1 := permObjFn.vals.min
		a := objFn.vals.min

		
		//loop to recalculating the permutations
		while(a1 < a)
		{
			//find the set of permutes
			echo("Looping..")
			a = a1
			permute = shiftProjs(permPS, stdList, projList, rank, supList)
			permute.each |sp, j| { permPS[j] = [:]; sp.each |Project? p, Student s| { if(p != null) permPS[j][p] = s }  }
			permObjFn = Statistics.calcObjFn(rank, permPS)
			a1 = permObjFn.vals.min

		}
		//Nalloc.each |v, k| {echo("$k: $v") }
		//permute.each |v, k| { echo("$k: $v")}
		return permPS
	}
	
	static Void simAnneal(Int:Int objFn, Int:[Project:Student] alloc, Student:[Project:Int] rank, [Int:[Student:Project?]]? permute, Student[] stdList)
	{
		//performs simulated annealing on the initial allocation
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
        a.sort
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
		
		//echo(objFn)
		
		RAND_MAX := 32767f
		x := 10
		L := objFn[1]
		i := 1
		//probability bias
		a_i := (ps(i, alloc, rank, permute, stdList) - ps(i-1, alloc, rank, permute, stdList))/ps(alloc.size-1, alloc, rank, permute, stdList)
		n := 0
		e := 0
		
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
