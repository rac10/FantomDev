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
		Alpha := Student(1, "Alex", 2010, 70, 800, "rac10")		
		Beta := Student(2, "Bob", 2009, 80, 1000, "bob11")
		Charlie := Student(3, "Charlie", 2011, 90, 900, "cl101")
		Delta := Student(4, "Delta", 2012, 50, 700, "del10")
		Eagle := Student(5, "Eagle", 2008, 70, 950, "ea2011")
		students := [	Student(1, "Alex", 2010, 70, 800, "rac10"),
						Student(2, "Bob", 2009, 80, 1000, "bob11") 
					]

		echo(students[0].toStr + " " + students[1].toStr)
		if(students[0].name == "Alex")
			echo(students[0].name + " for sure")
		else echo("not " + students[1].name)

		
		//tied to alpha
        P1 := Project(1, students[0].sid, "Mr Bob", null, "BEng", "Project 1",  50, "Radiant")
		//tied to beta
		P2 := Project(2, 2, "Mr Jack", null, "MEng", "Project 2",  70, "Dire")
		
		projects := [P1, P2]
		
		//Each supervisor has a limit to their projects
    	Jack := Supervisor(5, "Jack Black", "Single", "Microwave", "EE", "E42", 3)
		
		Mwaves := Preference(5, "yolo", "Project 1", "Project 2")
		//valid = ProcessData::isValid(Mwaves, projects)
        Help := Sp(Alpha, P1)
		Assist := Sp(Beta, P1)
        echo("$Alpha.name started in $Alpha.regYr")
        echo("$P1.sup1 is dealing with $P1.title")
      //  echo("$Help.student.name has supervisor $Help.project.sup")
    	echo("$Jack.name is the supervisor of project $P1.title")
        a := (0..360).random
		if(Help == Sp(Alpha, P1))
			echo("Equals")
		else echo("Nope")
		/* projs = pid -> Project
		studs = sid -> Student
		sups = supid -> Supervisor
		deletes = Sp -> Deletion
		constraints = Sp -> Constraint
		prefs = sid -> Preference
		suplimits = supid -> limit
		ownprojs = sid -> pid
		*/
		
		
    	//projs := [Alpha.sid:P1, Beta.sid:P1]
		//studs := [Alpha.sid:Alpha, Beta.sid:Beta]
		//sups := [Jack.eeid:Jack]
		//deletes := [Help:Alpha, Assist:Beta]


		
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
		something := tmp.readAllLines
		//echo(something)
		//yay this works now!
		//EVEN FUCKIN SIMPLER HOLY SHIT
		thistest := something.map { Student(it) }
		//something.each { thistest.add(it) }
		/*
		thistest.size = something.size
		for(i := 0; i < something.size; i++)
		{
			thistest[i] = Student(something[i])
			i++
		}*/
		echo(thistest[0].toStr + " " + thistest[1].toStr + " " + thistest[2].toStr)
	}
	
	
}

const class Student
{
    new make(Int sid, Str name, Int regYr, Int marks, Int marks_tot, Str email)
    {
		try
		{
            this.sid = sid
            this.name = name
            this.regYr = regYr
            this.marks = marks
            this.marks_tot = marks_tot
            this.email = email
		}
		catch
		{
			echo("Formatting error")
		}
    }
	
	new makeStr(Str BigString)
	{
		try
		{
			Str[] SubStrings := BigString.split
    		this.sid = SubStrings[0].toInt
    		this.name = SubStrings[1]
    		this.regYr = SubStrings[2].toInt
    		this.marks = SubStrings[3].toInt
    		this.marks_tot = SubStrings[4].toInt
    		this.email = SubStrings[5]
		}
		catch
		{
			echo("Misleading text size")
		}
	}
	override Str toStr()
	{
		//used for debugging
		return (this.sid.toStr + " " + this.name)
	}
    const Int sid
    const Str? name
    const Int regYr
    const Int marks
    const Int marks_tot
    const Str? email
}

const class Project
{
    new make(Int pid, Int studid, Str? sup1, Str? sup2, Str? tstream, Str? title, Int mark2, Str? team)
    {
		try
		{
            this.pid = pid
    		this.studid = studid
            this.sup1 = sup1
    		this.sup2 = sup2
            this.tstream = tstream
            this.title = title
            this.mark2 = mark2
            this.team = team	
		}
		catch
		{
			echo("Formatting error")
		}
    }
	override Str toStr()
	{
		//used for debugging
		return (this.pid.toStr)
	}
	
    const Int pid
    const Str? sup1
	const Str? sup2
    const Int studid
    const Str? tstream
    const Str? title
    const Int mark2
    const Str? team
}

const class Preference
{
    new make(Int eeid, Str? comments, Str? pref1, Str? pref2)
    {
		try
		{
            this.eeid = eeid
            this.comments = comments
            this.pref1 = pref1
    		this.pref2 = pref2
		}
		catch
		{
			echo("Formatting error")
		}
    }
	override Str toStr()
	{
		//used for debugging
		return (this.eeid.toStr)
	}
	
    const Int eeid
    const Str? comments
    const Str? pref1
    const Str? pref2
}

const class Supervisor
{
	new make(Int eeid, Str? name, Str? status, Str? categ, Str? dept, Str? group, Int max)
	{
		try
		{
    		this.eeid = eeid
    		this.name = name
    		this.status = status
    		this.categ = categ
    		this.dept = dept
    		this.group = group
    		this.max = max
		}
		catch
		{
			echo("Formatting error")
		}
	}
	override Str toStr()
	{
		//used for debugging
		return (this.eeid.toStr + " " + this.name)
	}
    const Int eeid
    const Str? name
    const Str? status
    const Str? categ
    const Str? dept
    const Str? group
	const Int max
}

const class Sp
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
        y:= x as Sp
        return (student == y?.student && project == y?.project)
    
    }

    override Int hash()
    {
        return (student.hash()*7907 + project.hash()*7919);
    }
}

mixin Constraint
{
	abstract Str? check_preference(Sp sp, [Sp:Int] allpr)

}

