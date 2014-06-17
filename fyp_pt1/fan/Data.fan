//
// Copyright (c) 2011 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Alex 5 Apr 2014 - Initial Contribution
//   Part 1 of the FYP

 
** This file contains the basic representation of all the classes that can be used
** It can also parse information from .txt files and create a class out of that

class Data
{
	static Void main(Str[] args)
	{
		//readFile
		//All local students
		Alpha := Student(1, "Alex", 2010, "rac10")		
		Beta := Student(2, "Bob", 2009, "bob11")
		Charlie := Student(3, "Charlie", 2011, "cl101")
		Delta := Student(4, "Delta", 2012, "del10")
		Eagle := Student(5, "Eagle", 2008, "ea2011")
		
		students := [Alpha, Beta, Charlie]
		stdList := (1..10).map { Student (it, "Stud" + it.toStr, 2050-it, "stud"+ (08..14).random.toStr)}
		echo(stdList)
		try
		{
			echo(stdList[13])
		}
		catch(Err e)
		{
			echo(e.msg)
		}
		
		P1 := Project(1, 1, "Mr Bob", null, "BEng", "Project 1")
		P2 := Project(2, 2, "Mr Jack", null, "MEng", "Project 2")
		P3 := Project(3, 3, "Mr James", "Mr Shane", "MSc", "Project 3")
		
		projects := [P1, P2, P3]
		projList := (1..10).map { Project(it, it, "Prof" + it.toStr, [null, "Dr " + it.toStr].random, ["BEng", "MEng", "MSc"].random, "Project" + it.toStr )}
		echo(projList)
		//Each supervisor has a limit to their projects
		Jack := Supervisor(5, "Jack Black", "EE", "E42", 3)
		
		supList := (1..10).map { Supervisor(it, "Prof" + it.toStr, ["E", "I"].random, ["E", "I"].random + (10..20).random.toStr, 1+(1..5).random) }
		echo(supList)
//	  Help := StudProj(Alpha, P1)
//		Assist := StudProj(Beta, P1)
		
		//need to declare a map of type Student:Project first
		rank := Student:Project[:]
		//randomise the students and projects list
		students.shuffle
		projects.shuffle
		//populate rank
		students.each |s, i| { rank[s] = projects[i] }

		echo(rank)
		echo(ProcessData.mapValid(rank))
		
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
		//reads from input file
		tmp := File(`input.txt`)
		tmp.open("r")
		lines := tmp.readAllLines
		thistest := lines.map { Student(it) }
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
		return ("$this.sid - $this.name")
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
		return ("$this.pid - $this.title")
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
	new make(Student s, Project p, Str comment, Float value)
	{
		try
		{
			this.sid = s.sid
			this.pid = p.pid
			this.title = p.title
			this.comment = comment
			this.value = value
		}
		catch(Err e)
		{
			echo(e.msg)
		}
	}
	override Str toStr()
	{
		//used for debugging
		return ("$this.sid, $this.pid - $this.title")
	}
	
	const Int sid
	const Int pid
	const Str? title
	const Str? comment
	const Float value
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
		return ("$this.supid - $this.name")
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