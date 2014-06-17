using gfx
using fwt

** GUI.fan
** This is the GUI interface of the program
** This shows that GUI can be easily implemented and be used to set parameters for the program.

class GUI
{
	static Void main(Str[] args)
	{
		//main class. contains the window.
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
						Button { text = "Data"; onAction.add |Event e| { Dialog.openInfo(e.window, "Executing Data.fan...") }; onAction.add { callData(defargs) } },
						Button { text = "ProcessData"; onAction.add |Event e| { Dialog.openInfo(e.window, "Executing ProcessData.fan...") }; onAction.add { callProcData }},
						Button { text = "Statistics"; onAction.add |Event e| { Dialog.openInfo(e.window, "Executing Statistics.fan...") }; onAction.add { callStats(defargs) }},
						Button { text = "Optimise"; onAction.add |Event e| { Dialog.openInfo(e.window, "Executing Optimise.fan...") }; onAction.add { callOpt(defargs) }},
						Button { text = "Testing.."; onAction.add { echo(defargs)} },
					}
				}
			},;
						
			
		}.open
	}
	
	static Menu callMenuBar(Str?[] values)
	{
		//the menu bars
		return Menu
		{
			Menu
			{
				text = "File"
				MenuItem { text = "Use default args.."; onAction.add |Event e| { Dialog.openInfo(e.window, "Resetting to default values..."); values[0] = "10"; values[1] = "10"; values[2] = "5"}},
				MenuItem { text = "Exit"; onAction.add { Env.cur.exit } },
			},
			
			Menu
			{
				text = "Arguments"
				MenuItem { text = "Change student size"; onAction.add |Event e| { Dialog.openPromptStr(e.window, "Number of students",  values[0]) { if(it!= null) values[0] = it } } },
				MenuItem { text = "Change project size"; onAction.add |Event e| { Dialog.openPromptStr(e.window, "Number of projects",  values[1]) { if(it!= null) values[1] = it } } },
				MenuItem { text = "Change supervisor size"; onAction.add |Event e| { Dialog.openPromptStr(e.window, "Number of supervisors", values[2]) { if(it != null) values[2] = it } } },
			},
			
			Menu
			{
				text = "Help"
				MenuItem { text = "About me"; onAction.add |Event e| { Dialog.openInfo(e.window, "This project was done by Reginald Alexander Carson of EIE3, with (A LOT of) assistance from Dr. Tom Clarke") } },
				MenuItem { text = "Version"; onAction.add |Event e| { Dialog.openInfo(e.window, "Not even alpha dude") } },
			},
		}
	}
	
	//functions for calling other functions
	static Void callData(Str[] args)
	{
		Data.main(args)
	}
	
	static Void callProcData()
	{
		ProcessData.main
	}
	
	static Void callStats(Str[] args)
	{
		Statistics.main(args)
	}
	
	static Void callOpt(Str[] args)
	{
		Optimise.main(args)
	}
}




