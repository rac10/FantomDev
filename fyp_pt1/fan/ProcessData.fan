/*
*  Copyright (c) 2011 xored software, Inc.
** Licensed under Eclipse Public License version 1.0
**
** History:
** rac10 1 May 2014 - Initial Contribution
** This will be the module of Fantom
** that deals with all the data manipulation
**/

class ProcessData
{
	static Void main()
	{
		//students
		Alpha := Student(1, "Alex", 2010, "rac10")		
		Beta := Student(2, "Bob", 2009, "bob11")
		Charlie := Student(3, "Charlie", 2011, "cl101")
		Delta := Student(4, "Delta", 2012, "del10")
		Eagle := Student(5, "Eagle", 2008, "ea2011")
		
		students := [Alpha, Beta, Charlie]
		
		//Projects
        P1 := Project(1, 1, "Bob Seger", "Jack Black", "BEng", "Project 1")
		P2 := Project(2, 2, "Bob Seger", "Jack Black", "MEng", "Project 2")
		P3 := Project(3, 3, "Bob Seger", null, "MSc", "Project 2")
		P4 := Project(4, 4, "Bob Seger", "Jack Black", "MSc", "Project 2")
		
		projects := [P1, P2, P3, P4]
		//projects.each { echo(it) }
		
		//list of valid projects
		projList := (1..10).map { Project(it, it, "Prof" + it.toStr, [null, "Dr " + it.toStr].random, ["BEng", "MEng", "MSc"].random, "Project" + it.toStr )}
		
		others := projects.map { it.title }

		//Each supervisor has a limit to their projects
    	Jack := Supervisor(1, "Jack Black", "EE", "E42", (1..5).random)
		Bob := Supervisor(2, "Bob Seger", "EIE", "I10", (1..5).random)
		
		supervisors := [Jack, Bob]
		
		prefs := Preference(Alpha, P1, "Seems interesting", 1f)
		
		
		//supposed to deal with ranks or something
		
		checkMax(supervisors, projects)
		echo(prefs.title)
		echo(isValid(prefs, projList))
	}
	
	static Bool isValid(Preference pref, Project[] proj)
	{
		//makes sure that the project titles match
        proj.any { it.title == pref.title }
	}
	
	static Bool mapValid(Student:Project sp)
	{
		//makes sure a mapping is valid
		sp.any |p, s| { p.studid == s.sid  }
	}
	
	static Void checkMax(Supervisor[] s, Project[] p)
	{
		//checks whether a supervisor has been assigned too many projects
		s.each |that|
		{ 
			count := 0
			p.each { if(that.name == it.sup1 || that.name == it.sup2) count++} 
			if(count > that.max)
				echo("Too many projects for " + that.name + ". Limit is " + that.max + " but number of projects assigned is $count")
			else echo("No issues detected for " + that.name)
		}		
	}
	
	static Void removePrefs(Preference[] p, Student:Project rank)
	{
		//go through list of constraints individually
		//remove prefs
		//no of proj for each supervisor = no. of projs supervisor can allocate +/- small random number
	}
}