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
	new make()
	{
		
	}
	
	static Void main()
	{
		//Projects
        P1 := Project(1, 1, "Bob Seger", "Jack Black", "BEng", "Project 1",  50, "Radiant")
		P2 := Project(2, 2, "Bob Seger", "Jack Black", "MEng", "Project 2",  70, "Dire")
		P3 := Project(3, 3, "Bob Seger", null, "MSc", "Project 2", 80, "Radiant")
		P4 := Project(4, 4, "Bob Seger", "Jack Black", "MSc", "Project 2", 80, "Radiant")
		
		projects := [P1, P2, P3, P4]
		//projects.each { echo(it) }
		
		others := projects.map { it.title }

		//Each supervisor has a limit to their projects
    	Jack := Supervisor(1, "Jack Black", "Single", "Microwave", "EE", "E42", 2)
		Bob := Supervisor(2, "Bob Seger", "Married", "Nuclear", "EIE", "I10", 2)
		
		supervisors := [Jack, Bob]
		
		Mwaves := Preference(5, "yolo", "Project 1", "Project 2")
		
		
		checkMax(supervisors, projects)
		echo(isValid(Mwaves, projects))
	}
	
	static Bool isValid(Preference pref, Project[] proj)
	{
        return (proj.eachWhile { (it.title != pref.pref1 && it.title != pref.pref2) ? false : null} ?: true)
	}
	
	static Void checkMax(Supervisor[] s, Project[] p)
    {
		s.each |that|
		{ 
			count := 0
			p.each { if(that.name == it.sup1 || that.name == it.sup2) count++ } 
			if(count > that.max)
				echo("Too many projects for " + that.name + ". Limit is " + that.max + " but number of projects assigned is $count")
			else echo("No issues detected for " + that.name)
		}		
    }
}