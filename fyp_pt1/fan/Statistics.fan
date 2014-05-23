using concurrent

** Statistics.fan
** Deals with the MC allocation
** 
const class Statistics
{	
	static Void main(Str[] args)
	{
		stdList := (1..args[0].toInt).map { Student (it, "Stud" + it.toStr, 2050-it, "stud"+ (08..14).random.toStr) }
		projList := (1..args[1].toInt).map { Project(it, it, "Prof" + (1..10).random.toStr, [null, "Dr " + it.toStr].random, ["BEng", "MEng", "MSc"].random, "Project" + it.toStr) }
		supList := (1..args[2].toInt).map { Supervisor(it, "Prof" + it.toStr, ["E", "I"].random, ["E", "I"].random + (10..20).random.toStr, (1..5).random) }
		//prefList := (1..stdList.size).map { Preference(stdList.getSafe(it), projList.getSafe(it), "Comment" + it.toStr, (1..projList.size).random.toFloat) }
		rank := Student:[Project:Int][:]
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
				projList.each { rank[s][it] = (1..10).random }
			}
			catch(Err e)
			{
				echo(e.msg)
			}	
		}
		
		
		//rank.each |r, i| { echo(i.toStr + " " +  r)  }
		//hi := MC(stdList, projList, rank)
		//countSup(supList, projList)
		haiworld := MCNtimes(stdList, projList, rank, 6)
		haiworld.each |r, i| { echo(i.toStr + ": " + r) }
	}
	
	static Int:[Project:Student] MCNtimes(Student[] students, Project[] projects, Student:[Project:Int] rank, Int N)
	{
		projAssign := Int:[Project:Student][:]
		
		/* Any info from an actor should be sent as a message to another actor.
		A "result" actor can store stuff in its actor.locals
		(which can contain a Map etc) and read out stored data at the end.
		It can be polled for the end point.

		The work you do is the receive function of the Actor.
		This would do one - or more than one - MC alloc and return the
		allocations. The receive function can therefore have no parameters.
		For efficiency the allocations should be immutable.

		You need to have multiple actor instances (at least one per hardware
		thread) to make use of concurrent execution.

		In your case you can do what the primes example does and 
		get data back from futures of the actors.
		*/
		
		/*
		//? i'm not sure if this is concurrent LOL
		for(i := 0; i < N; i++)
		{
			Actor.locals["project"] = projAssign[i] = MC(students, projects, rank)
				
		}
		echo(Actor.locals)	
		*/
		
		/*
		//asynchronised concurrency
		(1..N).each { projAssign[it] = [:] }
		aPool := ActorPool { maxThreads = 2 }
		aReply := Actor(aPool, |Obj o->Obj?| {printFunc(o)})
		aProj := Actor(aPool, |->|{findProjs(students, projects, rank, N, aReply)})
		projAssign[0] = MC(students, projects, rank)
		aProj.send(projAssign[1].toImmutable) //start async

		

		while(!aPool.isDone)
		{
			echo("waiting..")
		}
		echo("Done!")
		
		i := 0
		while(i < N)
		{
			s := aReply.sendLater (0.1sec,"").get
			Env.cur.out.writeChars("$s")
			if(s.toStr.size > 0) i++
		}
		*/
		
		
		/*
		//some example from the net..
		pool := ActorPool()
        a := Actor(pool) |->Project:Student|
        {
            data := MC(students, projects, rank)
			//echo(data)
            Actor.locals["proj"] = data
			echo(Actor.locals["proj"])
            return data
        }
           

        
		N.times { a.send(null) }
        echo("Project is now " +  a.send("proj").get.toStr)
		*/
		
		
		//synchronised concurrency
		aPool := ActorPool { maxThreads = N }
		actor := [Int:Actor][:]
		future := [Int:Future][:]
		
		echo("Creating actors...")
		for(i := 1; i <= N; i++)
		{
			actor[i] = Actor(aPool, |->Project:Student| { MC(students, projects, rank).toImmutable })
		}
		t1 := Duration.nowTicks
		actor.each|a, i| { future[i] = a.send(i) }	
		
		aPool.stop
		num := 0
		while (!aPool.isDone )
		{
			try
				aPool.join(Duration.fromStr("0.1sec"))
			catch (TimeoutErr e) {}
		}
		
		elapsedMs := (Duration.nowTicks - t1)/1000000
		future.each |f, i| { projAssign[i] = f.get }
		echo("Finished in ${elapsedMs}ms using $N threads")
		
		
		/*
		(1..N).each |n|
		{
			projAssign[n] = MC(students, projects, rank)
		}
		*/
		return projAssign
	}
	
	static Str? printFunc (Obj s)
	{
		h := Actor.locals.get("printFuncState","").toStr
		if (s is Project:Student)
		{
			Actor.locals["printFuncState"] = "$h$s.toStr\n"
			return (null)
		}
		else
		{
			Actor.locals["printFuncState"] = ""
			return h
		}	
		
	}
	
	static Void findProjs (Student[] students, Project[] projects, Student:[Project:Int] rank, Int max, Actor printFuncActor)
	{
		i := 1
		while(i != max)
		{
			printFuncActor.send(MC(students, projects, rank).toImmutable)
			i++
		}
		/*
		for (i := 1; i <= max; i++)
		{
			printFuncActor.send(MC(students, projects, rank))
		}*/
	}
	
	static Project:Student MC(Student[] students, Project[] projects, Student:[Project:Int] rank)
	{
		/** Performs Monte-Carlo simulation
		* * Allocates randomly. Allocation is not guaranteed for all students
		*  */
		projAssign := Project:Student[:]
		projAssigned := Project:Bool[:]
		studAssigned := Student:Bool[:]

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
		studTmp.each { studAssigned[it] = false }
		//echo(projects)
		//echo(students)

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
    					rankProj[r].add(it)
    				}
    				//if all students already assigned, need to deal with unassigned students
    				//use rankProj to determine the project assignments
    				p := rankProj.eachWhile |proj| { proj.random }
    				projAssign[p] = s
    				projAssigned[p] = true
    				studAssigned[s] = true
    				
    				studTmp.each  { rankTmp[it].remove(p) }
    				projTmp.remove(p)
    				
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
	
	static Student:Int findMin(Student:[Project:Int] rank)
	{
		tmp := Student:Int[:]
		//find minimum rank of each student
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
	
	static Void countSup(Supervisor[] supervisors, Project[] projects)
	{
		//counts how many projects has been allocated
		//only counts mandatory supervisor
		projAlloc := Supervisor:Int[:]
		supervisors.each { projAlloc.getOrAdd(it) { 0 }}
		
		projAlloc.each |i, s|
		{ 
			projects.each 
			{ 
				if(s.name == it.sup1)
					projAlloc[s]++
			}
			if(projAlloc[s] > s.max)
			{
				echo("Max limit of " + s.max + " for " + s.name + " surpassed. Currently assigned " + projAlloc[s] + " projects. Resetting to infinity..")
				projAlloc[s] = 999
			}
			else echo("No problems for " + s.name + " with " + s.max + " limit but currently has " + projAlloc[s] + " projects")
		}
		//projects.each { echo(it.sup1 + " " + it.sup2)  }
		projAlloc.each |i, s| { echo(s.toStr + " with count " + projAlloc[s])  }
	}
}
