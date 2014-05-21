** Statistics.fan
** Deals with the MC allocation
class Statistics
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
		haiworld := MCNtimes(stdList, projList, rank, 3)
		echo(haiworld)
	}
	
	static Project:Student MC(Student[] students, Project[] projects, Student:[Project:Int] rank)
	{
		/** Performs Monte-Carlo simulation
		* * Allocates randomly. Allocation is not guaranteed for all students
		* * 
		* * 
		*  */
		//look at each student in a random order
		//allocate student, highest ranked remaining project
		//after all students have been considered, the final allocation is remembered.
		//simulated allocation is repeated many times using random shuffles of student order & allocation stats are collected
		//need Project:Student map
		//need Supervisor:Int map and count how many projects have been allocated to each supervisor
		//the map of the assigned projects
		projAssign := Project:Student[:]
		projAssigned := Project:Bool[:]
		studAssigned := Student:Bool[:]

		//need a map of rank:list of projects
		rankProj := Int:Project[][:]
		
		//temp vars
		rankTmp := rank
		projTmp := projects
		studTmp := students
		
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
				
				projTmp.each 
				{
					r := rankTmp[s][it]
					rankProj[r].add(it)
				}
				

				//use rankProj to determine the project assignments
				p := rankProj.eachWhile |proj| { proj.random }
				projAssign[p] = s
				projAssigned[p] = true
				studAssigned[s] = true
				
				studTmp.each  { rankTmp[it].remove(p) }
				projTmp.remove(p)
				
				//clear rankProj. using clear removes all pointers; don't do that
				(1..10).each { rankProj[it] = [,] }
			}
			catch(Err e)
			{
				echo(e.msg)
			}	
		}
		//echo(projAssign)

		return projAssign
	}
	
	static Int:[Project:Student] MCNtimes(Student[] students, Project[] projects, Student:[Project:Int] rank, Int N)
	{
		projAssign := Int:[Project:Student][:]
		studImm := students
		projImm := projects
		rankImm := rank
		
		(1..N).each |n|
		{
			echo(rank)
			projAssign[n] = [:]
			tmp := MC(studImm, projImm, rankImm)
			tmp.each |s, p| { projAssign[n][p] = s }
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
		projAlloc := Supervisor:Int[:]
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
	}
}
