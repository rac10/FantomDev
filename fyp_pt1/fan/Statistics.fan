using concurrent

** Statistics.fan
** Deals with the MC allocation
** 
const class Statistics
{	
	static Void main(Str[] args)
	{
		//random initailisation of data
		Student[] stdList := [,]
		Project[] projList := [,]
		Supervisor[] supList := [,]
		
		//this initialisation ensures that no supervisor's project limits can be exceeded
		echo("Initialising project generation lists..")
		allocOK := false
		while(!allocOK)
		{
    		stdList = (1..args[0].toInt).map { Student (it, "Stud" + it.toStr, 2050-it, "stud"+ (08..14).random.toStr) }
    		projList = (1..args[1].toInt).map { Project(it, it, "Prof" + (1..args[2].toInt).random.toStr, [null, "Dr " + it.toStr].random, ["BEng", "MEng", "MSc"].random, "Project" + it.toStr) }
    		supList = (1..args[2].toInt).map { Supervisor(it, "Prof" + it.toStr, ["E", "I"].random, ["E", "I"].random + (10..20).random.toStr, (2..5).random) }
			allocOK = checkSup(supList, projList)
		}
		echo("Lists generated successfully!\n")
		
		
		//prefList := (1..stdList.size).map { Preference(stdList.getSafe(it), projList.getSafe(it), "Comment" + it.toStr, (1..projList.size).random.toFloat) }
		rank := Student:[Project:Int]?[:]
		//uses random probability to decide whether a student
		//has made a preference or not
		pS := 40
		
		stdList.shuffle
		projList.shuffle
		
		//randomly assigns a value to each student:project to indicate rank
		//low rank(1) indicates high preference
		//high rank(10) indicates low preference
		stdList.each |s|
		{    			
			try
			{
				rank[s] = [:]
				projList.each 
				{ 
					
					if((0..100).random <= pS)
						rank[s][it] = (1..10).random
					else rank[s][it] = -1
				}
				
			}
			catch(Err e)
			{
				echo(e.msg)
			}	
		}
		
		
		//rank.each |r, i| { echo(i.toStr + " " +  r)  }
		//hi := MC(stdList, projList, supList, rank)
		//echo(hi))
		Nalloc := MCNtimes(stdList, projList, supList, rank, 3)
		//Nalloc.each |r, i| { echo(i.toStr + ": " + r) }
		assigned := findAssigned(Nalloc, projList)
		projProb := calcProjProb(Nalloc, projList)
		studProb := calcStudProb(Nalloc, stdList)
		objFn := calcObjFn(rank, stdList, Nalloc)
		//objFn.each |b, a| { echo("Iteration $a: objective function $b") }
		min := Int.maxVal
		max := Int.minVal
		avg := 0
		objFn.each { if(min > it) min = it; if(max < it) max = it; avg += it }
		avg /= objFn.size
		//echo("Minimum value obtained is: $min")
		//echo("Max value obtained is: $max")
		//echo("Average value is: $avg")
		shift := shiftProjs(Nalloc,stdList, projList, assigned, rank)
		rotate := rotateProjs(Nalloc, stdList, projList, assigned, rank)
		Optimise.simAnneal(objFn, Nalloc, rank, shift, stdList)

	}
	
	static Project:Student MC(Student[] students, Project[] projects, Supervisor[] supervisors, Student:[Project:Int] rank)
	{
		/** Performs Monte-Carlo simulation
		* * Allocates randomly. Allocation is not guaranteed for all students
		*  */
		projAssign := Project:Student[:]
		projAssigned := Project:Bool[:]

		//need a map of rank:list of projects
		rankProj := Int:Project[][:]
		
		//temp vars
		rankTmp :=  Student:[Project:Int][:]
		rank.each |pi, s| { rankTmp[s] = [:]; pi.each |i, p| { rankTmp[s][p] = i }  }
		projTmp := projects.map { it }
		studTmp := students.map { it }
		
		//randomise the students and projects list
		projTmp.shuffle
		studTmp.shuffle

		//create a set that is non-empty and non-null
		projTmp.each { projAssigned[it] = false }

		//initialise rankProj
		(1..10).each { rankProj[it] = [,] }
		
		//initial project allocation
		studTmp.each |s, i|
		{    			
			try
			{
				allAssigned := projAssigned.all { it == true }
				
				if(!allAssigned)
				{
    				projTmp.each 
    				{
    					r := rankTmp[s][it]
						if(r !=- 1)
							rankProj[r].add(it)
    				}
					
    				//use rankProj to determine the project assignments
    				p := (Project?) rankProj.eachWhile |proj| { proj.random }
					if(p != null)
					{
        				projAssign[p] = s
        				projAssigned[p] = true
						
						//removes the allocated project
        				studTmp.each { rankTmp[it].remove(p) }
        				projTmp.remove(p)
					}
					
					//clear rankProj. using .clear removes all pointers; don't do that
    				(1..10).each { rankProj[it] = [,] }
				}
			}
			catch(Err e)
			{
				echo(e.msg)
			}	
		}
		return projAssign
	}
	
	static Int:[Project:Student] MCNtimes(Student[] students, Project[] projects, Supervisor[] supervisors, Student:[Project:Int] rank, Int N)
	{
		/** Performs MC simulation N times
		* * Uses the MC() function originally implemented
		* * Uses actors to perform concurrency and returns a list of maps.
		*/
		
		projAssign := Int:[Project:Student][:]		
		
		//synchronised concurrency
		aPool := ActorPool { maxThreads = N }
		actor := [Int:Actor][:]
		future := [Int:Future][:]
		
		//Creating actors
		for(i := 1; i <= N; i++)
		{
			actor[i] = Actor(aPool, |->Project:Student| { MC(students, projects, supervisors, rank).toImmutable })
		}
		actor.each|a, i| { future[i] = a.send(i) }	
		
		aPool.stop
		while (!aPool.isDone )
		{
			try
				aPool.join(Duration.fromStr("0.1sec"))
			catch (TimeoutErr e) {}
		}
		//completed processing
		future.each |f, i| { projAssign[i] = f.get }

		return projAssign
	}
	
	static Int:[Project:Bool] findAssigned(Int:[Project:Student] MCres, Project[] projects)
	{
		//counts how many projects are assigned
		//unassigned projects are inferred
		projAssign := Int:[Project:Bool][:]
		projCount := Int:Int[:]
		(1..MCres.size).each |n| 
		{ 
			projAssign[n] = [:]
			projCount[n] = 0
			projects.each |p| { projAssign[n][p] = false } 
		}
		MCres.each |ps, i| { ps.each |s, p| { if(projects.any { it == p}) projAssign[i][p] = true }  }
		projAssign.each |pb, i| { pb.each |b, p| { if(b) projCount[i]++  }  }
		//projCount.each |j, i| { echo("Run $i: $j projects assigned of $projects.size projects")  }
		return projAssign
	}
	
	static Student:Int findMin(Student:[Project:Int] rank)
	{
		//find minimum rank of each student
		//no longer used. used in previous iteration of MC() function
		tmp := Student:Int[:]
		rank.each |pf, s| 
		{   
			rankVals := Int[,]
			pf.each |f, p| 
			{   
				rankVals.add(f)
			}
			tmp.add(s, rankVals.min)

		}
		return tmp
	}
	
	static Bool checkSup(Supervisor[] supervisors, Project[] projects)
	{
		//counts how many projects has been allocated
		//only counts mandatory supervisor
		projAlloc := Supervisor:Int[:]
		supervisors.each { projAlloc[it] = 0 }
		OK := true
		

		projAlloc.each |i, s|
		{ 
			projects.each 
			{ 
				if(s.name == it.sup1)
					projAlloc[s]++
			}
			
			//too many projects for current supervisor
			if(projAlloc[s] > s.max)
			{
				//echo("Max limit of " + s.max + " for " + s.name + " surpassed. Currently assigned " + projAlloc[s] + " projects.")
				OK = false
			}
			//else echo("No problems for " + s.name + " with " + s.max + " limit but currently has " + projAlloc[s] + " projects")
		}
		return OK
	}
	
	static Project:Float calcProjProb(Int:[Project:Student] rankList,  Project[] projects)
	{
		//calculates probability of each project being assigned
		projProb := Project:Float[:]
		
		//initialising
		projects.each { projProb[it] = 0f }
		
		//adding and calculation
		rankList.each |ps, i| 
		{ 
			ps.each |Student? s, Project? p| 
			{ 	
				if(projects.any { p.pid == it.pid })
					projProb[p]++
			}
		}
		projects.each { projProb[it] *= 100f/rankList.size.toFloat }
		//projProb.each |i, p| { echo("Probability for $p.title being assigned is $i%") }
		return projProb
	}
	
	static Student:Float calcStudProb(Int:[Project:Student] rankList, Student[] students)
	{
		//calculates probability of each student being assigned
		studProb := Student:Float[:]
		
		//initialising
		students.each { studProb[it] = 0f }
		
		//adding and calculation
		rankList.each |ps, i| 
		{ 
			ps.each |Student? s, Project? p| 
			{ 
				if(students.any { s.name == it.name }) 
					studProb[s]++

			}
		}
		students.each { studProb[it] *= 100f/rankList.size.toFloat }
		//studProb.each |i, s| { echo("Probability for $s.name being assigned is $i%") }
		return studProb
	}
	
	static Int:Int calcObjFn(Student:[Project:Int] rank, Student[] students, Int:[Project:Student] rankList)
	{
		//need to do sum of all ranks of EACH STUDENT
		//if unallocated, then rank is set to 11
		//all ranks eventually raised to power K
		
		//rankList shows the allocation of project:student for each iteration
		//rank shows the Students' preferences per student. rank[s][p] = -1 indicates that there is no preference
		sum := Int:Int[:]
		K := 2
		(1..rankList.size).each { sum[it] = 0 }
		rankList.each |ps, i|
		{
			ps.each |s, p|
			{
				if(rank[s][p] != -1)
					sum[i] += rank[s][p]
				else sum[i] += 11
			}
			sum[i] = sum[i].pow(K)
		}
		return sum
	}
	
	static Void moveStud(Student:Project? SP, Project:Student PS, Project[] projs, Project:Bool projAssign, Student:[Project:Int] rank, Int mode)
	{
		//move each student to another project
		//last student is given an arbitrary project in his preferences (if assignable)
		//if no project preference is available, student is not given a project
		
		//maybe do this recursively
		//scan through list of allocated students
		//for each possible student S1, for each project in the prefs of S1,
		//if S1 is not allocated to project P2 whilst P2 is already allocated to S2,
		//allocate S1 to P2. do this recursively.
		newStudProj := Student:Project?[:]
		
		switch (mode)
		{
			//shift
			case 1:
				echo("Shift")
				SP.each |p, s| 
				{   
					if(PS[p] == s)
						return
				}
			//add
			case 2:
				echo("Add")
			//delete
			case 3:
				echo("Delete")
			//rotate
			case 4:
				echo("Rotate")
			default:
				echo("Invalid selection")
				
		}
		
		/*
		newStud := Student[,]
		newProj := Project?[,]
		
		remProj := Project?[,]
		SP.each |p, s| 
		{  
			newStud.add(s)
			newProj.add(p)
		}
		projs.each { remProj.add(it) }
		remProj.removeAll(newProj)
		
		
		newStud.each |s, i| 
		{ 
			if(!rotate)
    			{
    			if(i+1 < newProj.size)
    			{
    				newStudProj[s] = newProj[i+1]
    				if(i == 0 && newProj[i] != null)
    					projAssign[newProj[i]] = false
    			}
    			else
    			{
    				assigned := false
    				projs.each 
    				{
            			if(rank[s][it] != -1 && !projAssign[it])
            			{
            				newStudProj[s] = it
            				projAssign[it] = true
    						assigned = true
            			}
    				}
    				if(!assigned)
    					newStudProj[s] = null
    
    			}
			}
			else
			{
				if(i+1 < SP.size)
					newStudProj[s] = newProj[i+1]
                else newStudProj[s] = newProj.first
			}
		}*/
		SP.clear
		SP.addAll(newStudProj)	
	}

	
	static Int:[Student:Project?] shiftProjs(Int:[Project:Student] psList, Student[] students, Project[] projects, Int:[Project:Bool] projAssign, Student:[Project:Int] rank)
	{
		newRank := Int:[Student:Project?][:]
		resRank := Student:Project?[:]
		(1..psList.size).each { newRank[it] = [:] }
		psList.each |ps, i|
		{
			if(newRank[i].isEmpty)
				students.each { newRank[i][it] = null }
			
			ps.each |Student s, Project p| { newRank[i][s] = p }
		}

		//(1..newRank.size).each { moveStud(newRank[it], psList[it], projects.toImmutable, projAssign[it], rank, false) }
		
		return newRank
	}

	static Int:[Student:Project?] rotateProjs(Int:[Project:Student] psList, Student[] students, Project[] projects, Int:[Project:Bool] projAssign, Student:[Project:Int] rank)
	{
		newRank := Int:[Student:Project?][:]
		resRank := Student:Project?[:]
		(1..psList.size).each { newRank[it] = [:] }
		psList.each |ps, i|
		{
			if(newRank[i].isEmpty)
				students.each { newRank[i][it] = null }
			
			ps.each |Student s, Project p| { newRank[i][s] = p }
		}
		
		
		//(1..newRank.size).each { moveStud(newRank[it], psList[it], projects.toImmutable, projAssign[it], rank, true) }
		
		return newRank
	}
}
