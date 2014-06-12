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
		//add := addProjs(Nalloc,stdList, projList, rank)
//		del := delProjs(Nalloc,stdList, projList, rank)
//		rotate := rotateProjs(Nalloc, stdList, projList, rank)
		//manip := manipProjs(Nalloc, stdList, projList, rank)
		Optimise.callMeMaybe(min, max, avg, objFn, assigned, rank, Nalloc, stdList, projList, supList)
		//Optimise.simAnneal(objFn, Nalloc, rank, shift, stdList)

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
	
	static Bool validShift(Student st, Project? pr, Student:[Project:Int] rank)
	{
		valid := true
		if(pr == null || rank[st][pr] == -1) 
			valid = false 
		return valid
	}
	
	
	static Void moveStud(Student:Project? SP, Project:Student PS, Project[] projs, Student:[Project:Int] rank, Int mode)
	{
		newStudProj := Student:Project?[:]
		remProj := Project?[,]
		//--------------------Shift--------------------
		//Shifts all projects forward by one student
		try
		{
			if(newStudProj.isEmpty)
			{
				i := 1
				while((i < SP.size-1) && !validShift(SP.keys[0], SP.vals[i], rank)) { ++i }
				
				if(i < SP.size-1)
				{
					(0..<SP.size-1).each {newStudProj.add(SP.keys[it%SP.size],SP.vals[(it+i)%SP.size]) }
					//remProj adds all the projects that have not yet been assigned to a student for usage later on
					projs.each |p| { if(newStudProj.vals.find { p == it } == null) remProj.add(p)}
				}
				else echo("Couldn't find a suitable shift for ${SP.keys[0]}")
    			//(0..<SP.size-1).each { newStudProj.add(SP.keys[it],SP.vals[it+i]) }
			}
			else
			{	
				tmp := Student:Project?[:]
				(0..<SP.size-1).each  { tmp.add(newStudProj.keys[it], SP.vals[it+1]) }
				newStudProj.clear
				newStudProj.addAll(tmp)
			}
		}
		catch(Err e)
		{
			echo("$e.cause, $e.msg")
		}
		
		if(!newStudProj.isEmpty)
		{
			switch (mode)
			{
				case 1:
				//--------------------Add--------------------
				//Adds a project to the last student shifted
				//Only valid preferences can be added.
				try
				{
					//remProj is then iterated through and each project is checked to see if it can be added to the student
					//If it can be added to the student, it is added then removed from the remProj list
					//Otherwise, a null project is assigned meaning the add was invalid
					assigned := false
					if(newStudProj.containsKey(SP.keys[SP.size-1]))
					{
						//adds a project only if the last student is null
						//uses overwrite instead of .add
						if(newStudProj[SP.keys[SP.size-1]] == null)
						{
							remProj.each 
							{
								if(it != null && !assigned && rank[SP.keys[SP.size-1]][it] != -1)
								{
									newStudProj[SP.keys[SP.size-1]] = it
									remProj.remove(it)
									assigned = true								
								}
							}
						}
					}
					else
					{
						//use .add command since student does not exist in new map yet
						remProj.each 
						{
							if(it != null && !assigned && rank[SP.keys[SP.size-1]][it] != -1)
							{
								newStudProj.add(SP.keys[SP.size-1], it)
								remProj.remove(it)
								assigned = true
							}
						}
						if(!assigned)
							newStudProj.add(SP.keys[SP.size-1], null)
					}
				}
				catch(Err e)
					echo("$e.cause, $e.msg")
				case 2:
            	//--------------------Delete--------------------
            	//Removes a project from the last student shifted
            	//Simply nulls the final student
				try
            	{
            		if(newStudProj.containsKey(SP.keys[SP.size-1]))
            		{
            			newStudProj[SP.keys[SP.size-1]] = null
            		}
            		else
            		{
            			newStudProj.add(SP.keys[SP.size-1], null)
            		}
            	}
            	catch(Err e)
            		echo("$e.cause, $e.msg")
            case 3:
            	//"--------------------Rotate--------------------"
            	//Ensures that the last student is given the first student's project
            	//Keeps project consistency throughout
            	try
            	{
            		if(newStudProj.containsKey(SP.keys[SP.size-1]))
            		{
            			//newStudProj is filled. need special rotate case
            			//use a temporary variable, populate it then repopulate newStudProj with those values
            			tmp := Student:Project?[:]
            			(0..<SP.size-1).each { tmp.add(newStudProj.keys[it], newStudProj.vals[it+1])}
            			tmp.add(newStudProj.keys[SP.size-1], newStudProj.vals[0])
            			newStudProj.clear
            			newStudProj.addAll(tmp)
            			
            		}
            		else
            			newStudProj.add(SP.keys[SP.size-1], SP.vals[0])
            	}
            	catch(Err e)
            		echo("$e.cause, $e.msg")
            	
            default:
            	echo("Invalid selection")
    				
    		}
    	
			SP.clear
			SP.addAll(newStudProj)	
		}
	}
	
	static Int:[Int:[Student:Project?]] manipProjs(Int:[Project:Student] psMap, Student[] students, Project[] projects, Student:[Project:Int] rank)
	{
		//each newRank is a map of psMap with nulls and the index for newRank, e.g. newRank[i] dictates the actions that occur to the map, psMap
		//1 for add, 2 for delete, and 3 for rotate
		//thus newRank is a map of psMap which stores its add, delete and rotate in a single map
		newRank := Int:[Int:[Student:Project?]][:]
		resRank := Student:Project?[:]
		(1..3).each |k|
		{
			newRank[k] = [:]
    		psMap.each |ps, i|
    		{
				newRank[k][i] = [:]
    			if(newRank[k][i].isEmpty)
    				students.each { newRank[k][i][it] = null }
    			
    			ps.each |Student s, Project p| { newRank[k][i][s] = p }
    		}
		}
		(1..3).each |i| { (1..newRank.size).each { moveStud(newRank[i][it], psMap[it], projects.toImmutable,  rank, i) } }
		return newRank
	}

	
	static Int:[Student:Project?] addProjs(Int:[Project:Student] psMap, Student[] students, Project[] projects, Student:[Project:Int] rank)
	{
		newRank := Int:[Student:Project?][:]
		resRank := Student:Project?[:]
		(1..psMap.size).each { newRank[it] = [:]}
		psMap.each |ps, i|
		{
			if(newRank[i].isEmpty)
				students.each { newRank[i][it] = null }
			
			ps.each |Student s, Project p| { newRank[i][s] = p }
		}
		//echo(newRank[1])
		//moveStud(newRank[1], psMap[1], projects.toImmutable, rank, 1)
		(1..newRank.size).each { moveStud(newRank[it], psMap[it], projects.toImmutable,  rank, 1) }
		//echo(newRank[1])
		return newRank
	}
	
	static Int:[Student:Project?] delProjs(Int:[Project:Student] psMap, Student[] students, Project[] projects, Student:[Project:Int] rank)
	{
		newRank := Int:[Student:Project?][:]
		resRank := Student:Project?[:]
		(1..psMap.size).each { newRank[it] = [:] }
		psMap.each |ps, i|
		{
			if(newRank[i].isEmpty)
				students.each { newRank[i][it] = null }
			
			ps.each |Student s, Project p| { newRank[i][s] = p }
		}
		echo(newRank)
		//moveStud(newRank[1], psMap[1], projects.toImmutable, rank, 3)
		(1..newRank.size).each { moveStud(newRank[it], psMap[it], projects.toImmutable, rank, 2) }
		echo(newRank)
		return newRank
	}

	static Int:[Student:Project?] rotateProjs(Int:[Project:Student] psMap, Student[] students, Project[] projects, Student:[Project:Int] rank)
	{
		newRank := Int:[Student:Project?][:]
		resRank := Student:Project?[:]
		(1..psMap.size).each { newRank[it] = [:] }
		psMap.each |ps, i|
		{
			if(newRank[i].isEmpty)
				students.each { newRank[i][it] = null }
			
			ps.each |Student s, Project p| { newRank[i][s] = p }
		}
		echo(newRank)
		//moveStud(newRank[1], psMap[1], projects.toImmutable, rank, 3)
		(1..newRank.size).each { moveStud(newRank[it], psMap[it], projects.toImmutable, rank, 3) }
		echo(newRank)
		return newRank
	}
	
	
}
