
class Statistics
{
	static Void main()
	{
		stdList := (1..15).map { Student (it, "Stud" + it.toStr, 2050-it, "stud"+ (08..14).random.toStr) }
		projList := (1..10).map { Project(it, it, "Prof" + (1..10).random.toStr, [null, "Dr " + it.toStr].random, ["BEng", "MEng", "MSc"].random, "Project" + it.toStr) }
		supList := (1..10).map { Supervisor(it, "Prof" + it.toStr, ["E", "I"].random, ["E", "I"].random + (10..20).random.toStr, (1..5).random) }
		prefList := (1..stdList.size).map { Preference(stdList.getSafe(it), projList.getSafe(it), "Comment" + it.toStr, (1..projList.size).random.toFloat) }
		rank := Student:Project[:]
		stdList.shuffle
		projList.shuffle
		//prefList.sort |Student:Project sp| { rank.  }
		stdList.each |s, i|
		{ 
			try
			{
				//assign normally
    			if(projList.getSafe(i) != null)
    				rank[s] = projList[i]
    			else //if no more projects available, randomly assign project to student
    				rank[s] = projList.random
			}
			catch(Err e)
			{
				echo(e.msg)
			}
		}
		MC(stdList, projList, supList, rank)
	}
	
	/*	•	You can use random numbers to generate simulated preferences as follows:
        •	Assign each supervisor a probability Ps
        •	Assign each project a probability Pp
        •	Use Ps to determine which supervisors students will select. If any students selects <2 supervisors top up selection randomly to 2.
        •	Use Pp to determine which projects (of selected supervisors) students will select
        •	Order selections of each student, trim to < 10, if < 4 select extra lower ranked projects from selected supervisors if possible up to 4.
	*/
	
	static Void MC(Student[] students, Project[] projects, Supervisor[] supervisors, Student:Project rank)
	{
		//look at each student in a random order
		//allocate student, highest ranked remaining project
		//after all students have been considered, the final allocation is remembered.
		//simulated allocation is repeated many times using random shuffles of student order & allocation stats are collected
		//need Project:Student map
		//need Supervisor:Int map and count how many projects have been allocated to each supervisor
		
		//the map of the assigned projects
		projAssign := Project:Student[:]
		projAssigned := Project:Bool[:]
		pS := 0.3f	//probability of each supervisor being assigned
		pP := 0.4f	//prob of each project being assigned
		//counts how many projects has been allocated
		projAlloc := Supervisor:Int[:]
		maxSize := projects.size
		//randomise the students and projects list
		projects.shuffle
		students.shuffle
		//populate assigned projects
		projects.each |p, i| 
		{ 
			//populate projAssign
			//if null then randomly choose student
			try
			{
    			if(students.getSafe(i) != null)
				{
    				projAssign[p] = students[i]
    				projAssigned[p] = true
				}
    			else
				{
    				//projAssign[p] = students.random
    				projAssigned[p] = false
				}
			}
			catch(Err e)
			{
				echo(e.msg)
			}	
		} 
		//projAssign.each |s, p| { if(projAssign[p] == null) break }
		//initialisation
		supervisors.each { projAlloc.getOrAdd(it) { 0 }}
		//for each supervisor
		//count how many times each supervisor has been allocated a project
		//only counts mandatory supervisor
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

		//need to initialise p if it does not exist
		/*
		if(projects.getSafe(50) == null)
		{
			projAssign[projects.random] = students.random
		//	projAssign.add([p.random:s.random])
		}*/
		//echo(projects)
		
	}
}
