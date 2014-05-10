//
// Copyright (c) 2011 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Alex 5 Apr 2014 - Initial Contribution
//   Part 1 of the FYP

 
**
**
**
** 
class Data
{
    static Void main(Str[] args)
    {
		
		readFile
		//All local students
		Alpha := Student(1, "Alex", 2010, "rac10")		
		Beta := Student(2, "Bob", 2009, "bob11")
		Charlie := Student(3, "Charlie", 2011, "cl101")
		Delta := Student(4, "Delta", 2012, "del10")
		Eagle := Student(5, "Eagle", 2008, "ea2011")
		
		students := [Alpha, Beta, Charlie].toImmutable
			
		//alpha
        P1 := Project(1, 1, "Mr Bob", null, "BEng", "Project 1")
		//beta
		P2 := Project(2, 2, "Mr Jack", null, "MEng", "Project 2")
		//charlie
		P3 := Project(3, 3, "Mr James", "Mr Shane", "MSc", "Project 3")
		
		projects := [P1, P2, P3].toImmutable
		
		//Each supervisor has a limit to their projects
    	Jack := Supervisor(5, "Jack Black", "EE", "E42", 3)
		
		Mwaves := Preference(5, "yolo", "Project 1", "Project 2")
		//valid = ProcessData::isValid(Mwaves, projects)
        Help := StudProj(Alpha, P1)
		Assist := StudProj(Beta, P1)
		
		/* projs = pid -> Project
		studs = sid -> Student
		sups = supid -> Supervisor
		deletes = Sp -> Deletion
		constraints = Sp -> Constraint
		prefs = sid -> Preference
		suplimits = supid -> limit
		ownprojs = sid -> pid
		*/

		//need to declare a map of type Student:Project first
		rank := Student:Project[:]

		for(i := 0; i < students.size; i++)
		{
			rank.add(students[i], projects[i])
		}
//		echo(rank)
//		rank.remove(Beta)
//		echo(rank)
		
		echo(ProcessData.mapValid(rank))
		//rank.each |p, s| { rank[s as students] = p as projects  }
		/*
		students.each |that|
		{
			projects.each { rank[that] = it }
		}*/
		/*
		rank := [students:projects]
		echo(rank)
		rank.remove(students)
		echo(rank)*/


		
        /*
        need to generate initial set of test data
        randomly allocate the test data
        optimise the allocations
        students -> prefs(mutable)
        id -> students
        id -> projects
        id -> supervisor 
        cyclic graph
        need to lookup from stud->stud.prefs
        
        */
    
    }
	
	static Void readFile()
	{
		tmp := File(`input.txt`)
		tmp.open("r")
		lines := tmp.readAllLines
		thistest := lines.map { Student(it) }
//		echo(thistest[0].toStr + " " + thistest[1].toStr + " " + thistest[2].toStr)
//		Alpha := Student(1, "Alex", 2010, "rac10")	
//		thistest.remove([1, "Alex", 2010, "rac10"])
//		echo(thistest[0].toStr + " " + thistest[1].toStr)
	}
	
	
}

const class Student
{
    new make(Int sid, Str name, Int regYr, Str email)
    {
		try
		{
            this.sid = sid
            this.name = name
            this.regYr = regYr
            this.email = email
		}
		catch(Err e)
		{
			echo(e.msg)
		}
    }
	
	new makeStr(Str BigString)
	{
		try
		{
			SubStrings := BigString.split.map { toInt(10, false) ?: it }
    		this.sid = SubStrings[0]
    		this.name = SubStrings[1]
    		this.regYr = SubStrings[2]
    		this.email = SubStrings[3]
		}
		catch(Err e)
		{
			echo(e.msg)
		}
	}
    
    new makeSpecial(|This|? f := null)
	{ 
		if (f != null) 
			f(this)
	}
       
	override Str toStr()
	{
		//used for debugging
		return (this.sid.toStr + " " + this.name + " " + this.email)
	}
    const Int sid
    const Str? name
    const Int regYr
    const Str? email
}

const class Project
{
    new make(Int pid, Int studid, Str? sup1, Str? sup2, Str? tstream, Str? title)
    {
		try
		{
            this.pid = pid
    		this.studid = studid
            this.sup1 = sup1
    		this.sup2 = sup2
            this.tstream = tstream
            this.title = title
		}
		catch(Err e)
		{
			echo(e.msg)
		}
    }
	override Str toStr()
	{
		//used for debugging
		return (this.pid.toStr + " " + this.title)
	}
	
    const Int pid
    const Int studid
    const Str? sup1
	const Str? sup2
    const Str? tstream
    const Str? title
}

const class Preference
{
    new make(Int id, Str? comments, Str? pref1, Str? pref2)
    {
		try
		{
            this.id = id
            this.comments = comments
            this.pref1 = pref1
    		this.pref2 = pref2
		}
		catch(Err e)
		{
			echo(e.msg)
		}
    }
	override Str toStr()
	{
		//used for debugging
		return (this.id.toStr)
	}
	
    const Int id
    const Str? comments
    const Str? pref1
    const Str? pref2
}

const class Supervisor
{
	new make(Int supid, Str? name, Str? dept, Str? group, Int max)
	{
		try
		{
    		this.supid = supid
    		this.name = name

    		this.dept = dept
    		this.group = group
    		this.max = max
		}
		catch(Err e)
		{
			echo(e.msg)
		}
	}
	override Str toStr()
	{
		//used for debugging
		return (this.supid.toStr + " " + this.name)
	}
    const Int supid
    const Str? name
    const Str? dept
    const Str? group
	const Int max
}

const class StudProj
{
    new make(Student s, Project p)
    {
        this.student = s
        this.project = p
    }
    
    const Student student
    const Project project
    
    override Bool equals(Obj? x)
    {
        y:= x as StudProj
        return (student == y?.student && project == y?.project)
    
    }

    override Int hash()
    {
        return (student.hash()*7907 + project.hash()*7919);
    }
}

mixin Constraint
{
	abstract Str? check_preference(StudProj sp, [StudProj:Int] allpr)

}