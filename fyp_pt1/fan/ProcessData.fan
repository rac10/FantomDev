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
    	Jack := Supervisor(1, "Jack Black", "Single", "Microwave", "EE", "E42", 4)
		Bob := Supervisor(2, "Bob Seger", "Married", "Nuclear", "EIE", "I10", 2)
		
		supervisors := [Jack, Bob]
		
		Mwaves := Preference(5, "yolo", "Project 1", "Project 2")
		
		
		//checkMax(supervisors, projects)
		echo(isValid(Mwaves, projects))
	}
	
	static Bool isValid(Preference pref, Project[] proj)
	{
        return (proj.eachWhile { (it.title != pref.pref1 && it.title != pref.pref2) ? false : null} ?: true)

		//return true
        /*
		for(i :=0; i < proj.size; i++)
		{
			//checks that project title matches either preference
			//no match returns false
			if(proj[i].title != pref.pref1 && proj[i].title != pref.pref2)
				return false
		}
		return true
		
        if(proj.each {it} != pref.pref1 && proj.each != pref.pref2)
            return false
        return true*/
		
	}
	
	static Void checkMax(Supervisor[] s, Project[] p)
    {
		//count := 0
    	for(i := 0; i < s.size; i++)
		{
			//checks supervisor name in list of supervisors
			//counts how many times his name is mentioned
			//excessive matching returns prematurely
			count := 0
			for(j := 0; j < p.size; j++)
			{
    			if(s[i].name == p[j].sup1 || s[i].name == p[j].sup2)
    			{
    				count++
    				
					
    			}
			}
			if(count > s[i].max)
				echo("Too many projects for " + s[i].name +". Limit is " + s[i].max + " but number of projects assigned is $count")
			else
				echo ("No issues for " + s[i].name)
		}
		
    }
}