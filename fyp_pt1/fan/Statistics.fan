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
		
		echo("Initialising project generation lists..")
		//this initialisation ensures that no supervisor's project limits can be exceeded
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
		shiftProjs(Nalloc,stdList, projList, assigned, rank)

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

		
		//projAlloc.each |i, s| { echo(s.toStr + " with count " + projAlloc[s])  }
		//return projAlloc
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
	
	static Void simAnneal(Project:Student proj)
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
		
	}
	
	static Void moveA(Student:Project? SP, Project[] projs, Project:Bool projAssign, Student:[Project:Int] rank, Student:Project? result)
	{
		//move each student to another project
		//last student is given an arbitrary project in his preferences (if assignable)
		newStud := Student[,]
		newProj := Project?[,]
		newStudProj := Student:Project?[:]
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
		//echo(SP)
		//echo(newStudProj)
		result.clear
		result.addAll(newStudProj)
		
	}
	
	static Void moveE(Student:Project? SP, Student stud, Student:Project? result)
	{
		//move a student with an allocated project to a null project
		newStud := Student[,]
		newProj := Project?[,]
		newStudProj := Student:Project?[:]
		SP.each |p, s| 
		{  
			newStud.add(s)
			newProj.add(p)
		}
		
		newStud.each |s, i|
		{
			if(s != stud)
				newStudProj[s] = newProj[i]
			else newStudProj[s] = null
		}
		result.clear
		result.addAll(newStudProj)
	}
	
	static Void moveF(Student:Project? SP, Student[] students, Project:Bool projAssign, Project[] projects, Student:[Project:Int] rank, Student:Project? result)
	{
		//move a student that is unallocated to another student's project
		//requires the rank of the student to be known
		newStud := Student[,]
		remProj := Project?[,]
		newProj := Project?[,]
		newStudProj := Student:Project?[:]
		SP.each |p, s| 
		{  
			newStud.add(s)
			newProj.add(p)
		}
		projects.each { remProj.add(it) }
		remProj.removeAll(newProj)
		/*
		projects.each |p|
		{ 
			if(!projects.any {it.pid == newProj[p].pid}) 
				remProj.add(p)
		}*/
		//echo(newProj)
		//echo(remProj)
		//studAssigned := 0
		//students.each |s| { if(SP[s] != null) studAssigned++ }
		//echo(studAssigned)
		//projAssign.each |b, p| { if(!b) echo(p) }
		
		//need to ensure that giving the students their projects
		//that the project being assigned doesn't exceed supervisor limit

		SP.each |p, s|
		{
			if(p != null)
    			newStudProj[s] = p
			else 
			{
    			p = remProj.random
				if(rank[s][p] != -1 && !projAssign[p])
				{
    				newStudProj[s] = p
    				remProj.remove(p)
				}
				else if (rank[s][p] == -1)
				{
					newStudProj[s] = null
				}
			}
		} 
		
		//echo(SP)
		//echo(newStudProj)
		result.clear
		result.addAll(newStudProj)
	}
	
	static Void shiftProjs(Int:[Project:Student] rankList, Student[] students, Project[] projects, Int:[Project:Bool] projAssign, Student:[Project:Int] rank)
	{
		//maybe consider using Student[], Project[] as parameters
		newRank := Int:[Student:Project?][:]
		resRank := Student:Project?[:]
		(1..rankList.size).each { newRank[it] = [:] }
		rankList.each |ps, i|
		{
			if(newRank[i].isEmpty)
				students.each { newRank[i][it] = null }
			
			/*
			//this is a rotate
			if(i+1 <= rankList.size)
				newRank[i] = rankList[i+1]
			else newRank[i] = rankList[1]
			*/
			ps.each |Student s, Project p|
			{
				newRank[i][s] = p
				
			}
		}
		echo(newRank[1])
		moveA(newRank[1], projects.toImmutable, projAssign[1], rank, resRank)
		echo(resRank)
		moveF(newRank[1], students, projAssign[1], projects, rank, resRank)
		echo(resRank)
		//rankList.each |r, i| { echo("$i: $r")  }
		//newRank.each |r, i| { echo("$i: $r")  }
	}
	
}
