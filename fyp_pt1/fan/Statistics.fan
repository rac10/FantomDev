
class Statistics
{
	static Void main()
	{
		stdList := (1..10).map { Student (it, "Stud" + it.toStr, 2050-it, "stud"+ (08..14).random.toStr)}
		projList := (1..10).map { Project(it, it, "Prof" + it.toStr, [null, "Dr " + it.toStr].random, ["BEng", "MEng", "MSc"].random, "Project" + it.toStr )}
		supList := (1..10).map { Supervisor(it, "Prof" + it.toStr, ["E", "I"].random, ["E", "I"].random + (10..20).random.toStr, (1..5).random) }
		MC(stdList, projList, supList)
	}
	
	static Void MC(Student[] students, Project[] projects, Supervisor[] supervisors)
	{
		//look at each student in a random order
		//allocate student, highest ranked remaining project
		//after all students have been considered, the final allocation is remembered.
		//simulated allocation is repeated many times using random shuffles of student order & allocation stats are collected
		//need Project:Student map
		//need Supervisor:Int map and count how many projects have been allocated to each supervisor
		projAssign := Project:Student[:]
		//counts how many projects has been assigned
		projAlloc := Supervisor:Int[:]
		maxSize := projects.size
		//randomise the students and projects list
		projects.shuffle
		students.shuffle
		//populate assigned projects
		projects.each |p, i| { projAssign[p] = students[i] }
		supervisors.each { projAlloc[it] = 0  } //initialisation
		
		echo(projects.getSafe(50))
		//need to initialise p if it does not exist
		if(projects.getSafe(50) == null)
		{
			projAssign[projects.random] = students.random
		//	projAssign.add([p.random:s.random])
		}
		projAlloc.each |i, s| { if(true) i++  }
		echo(projects)
		
	}
}
