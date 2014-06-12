

using gfx
using fwt

class GUI
{
	static Void main(Str[] args)
	{
		Window
        {
			title = "Main menu"
			size = Size(500,100)
			defargs := Str["0", "0", "0"]
			menuBar = callMenuBar(defargs)
			EdgePane
			{
				top = InsetPane
				{
        			content = GridPane
        			{
        				
            			it.hgap = 30
            			it.vgap = 30
            			it.numCols = 5
            			it.halignCells = Halign.center
            			it.valignCells = Valign.center
        				Button { text = "Data"; onAction.add { callData } },
            			Button { text = "ProcessData"; onAction.add { callProcData }},
            			Button { text = "Statistics"; onAction.add { callStats }},
            			Button { text = "Optimise"; onAction.add { callOpt }},
						Button { text = "Testing.."; onAction.add { echo(defargs)} },
        			}
				}
			},;
						
			
        }.open
	}
	
	static Menu callMenuBar(Str?[] values)
    {
    	return Menu
    	{
    		Menu
    		{
    			text = "Arguments"
				MenuItem { text = "Change student size"; onAction.add |Event e| { Dialog.openPromptStr(e.window, "Number of students",  values[0]) { if(it!= null) values.set(0, it) } } },
				MenuItem { text = "Change project size"; onAction.add |Event e| { Dialog.openPromptStr(e.window, "Number of projects",  values[1]) { if(it!= null) values.set(1, it) } } },
				MenuItem { text = "Change supervisor size"; onAction.add |Event e| { Dialog.openPromptStr(e.window, "Number of supervisors", values[2]) { if(it != null) values.set(2, it) } } },
    		},
    	}
    }
	
	static Void callData()
    {
		echo("Calling Data...")
    	Data.main(["5", "5", "5"])
    }
	
	static Void callProcData()
    {
		echo("Calling ProcessData...")
    	ProcessData.main
    }
	
	static Void callStats()
    {
    	echo("Calling Statistics...")
    	Statistics.main(["5", "5", "5"])
    }
	
	static Void callOpt()
    {
		echo("Calling Optimise...")
    	//Optimise.main()
    }
}




