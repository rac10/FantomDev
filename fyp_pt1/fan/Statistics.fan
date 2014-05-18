** Statistics.fan
** Deals with the MC allocation
class Statistics
{
	static Void main()
	{
		stdList := (1..5).map { Student (it, "Stud" + it.toStr, 2050-it, "stud"+ (08..14).random.toStr) }
		projList := (1..5).map { Project(it, it, "Prof" + (1..10).random.toStr, [null, "Dr " + it.toStr].random, ["BEng", "MEng", "MSc"].random, "Project" + it.toStr) }
		supList := (1..5).map { Supervisor(it, "Prof" + it.toStr, ["E", "I"].random, ["E", "I"].random + (10..20).random.toStr, (1..5).random) }
		//prefList := (1..stdList.size).map { Preference(stdList.getSafe(it), projList.getSafe(it), "Comment" + it.toStr, (1..projList.size).random.toFloat) }
		rank := Student:[Project:Float][:]
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
				projList.each { rank[s][it] = (1..10).random.toFloat }
			}
			catch(Err e)
			{
				echo(e.msg)
			}	
		}
		rank.each |r, i| { echo(i.toStr + " " +  r)  }
		hi := MC(stdList, projList, supList, rank)
		echo(hi)
	}
	
	static Student:Project MC(Student[] students, Project[] projects, Supervisor[] supervisors, Student:[Project:Float] rank)
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
		studAssign := Student:Project[:]
		studAssigned := Student:Bool[:]
		//counts how many projects has been allocated
		projAlloc := Supervisor:Int[:]
		//need an array of float to determine minimum
		rankMin := Student:Float[:]
		//randomise the students and projects list
		projects.shuffle
		students.shuffle

		//create a set that is non-empty and non-null
		projects.each { projAssigned[it] = false }
		students.each { studAssigned[it] = false }
		
		echo(students)
		//initial project allocation
		students.each |s| 
		{   
			rankMin = findMin(rank)
			//initial project allocation
			projects.each |p|
			{
				try
				{
					//find best allocation that is unassigned for both projects and students
					if(rankMin[s] >= rank[s][p] && !studAssigned[s] && !projAssigned[p])
					{
						projAssign[p] = s
						studAssign[s] = p
						projAssigned[p] = true
						studAssigned[s] = true
					}
					//removes already assigned projects
					if(projAssigned[p]) {students.each  { rank[it].remove(p)} }
				}
				catch(Err e)
				{
					echo(e.msg)
				}	
			}
		}
		echo(projAssign)
		//echo(studAssigned)
		//echo(projAssigned)
		/*
		projects.each |p| 
		{ 
			//populate projAssign
			try
			{
				students.each |s, j| 
				{   
					echo(rank[s])
					if(rank[s][p] == rankMin[j] && !projAssigned[p])
					{
						projAssign[p] = s
        				projAssigned[p] = true
					}
					//else projAssigned[p] = false
				}
			}
			catch(Err e)
			{
				echo(e.msg)
			}	
		} 
		
		*/
		//projAssign.each |s, p| { if(projAssign[p] == null) break }
		
		/*
		projAssigned.each |b, p|
		{ 
			if(!projAssigned[p])  
				rank.each |s|
				{ 
					projAssign   
					
				}
		}*/
		/*
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
		*/
		//need to initialise p if it does not exist
		/*
		if(projects.getSafe(50) == null)
		{
			projAssign[projects.random] = students.random
		//	projAssign.add([p.random:s.random])
		}*/
		//echo(projects)
		return studAssign
	}
	
	static Student:Float findMin(Student:[Project:Float] rank)
	{
		tmp := Student:Float[:]
		//find minimum rank of each student
		rank.each |pf, s| 
		{   
			rankVals := Float[,]
			pf.each |f, p| 
			{   
				rankVals.add(f)
			}
			tmp.add(s, rankVals.min)

		}
		return tmp
	}
}
