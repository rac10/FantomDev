//
// Copyright (c) 2011 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   rac10 22 May 2014 - Initial Contribution
//

using concurrent

class PrintPrimesAsync
{
	Int startNumber := 10000000000000
	static const Int numberToTest := 10
	
	Void main()
	{
		apool := ActorPool {maxThreads = 2}
		areply := Actor (apool, |Obj o->Obj?| {printFunc(o)})
		acalc := Actor (apool, |Int pc->Void| {findPrimes (pc, numberToTest, areply)})
		acalc.send (startNumber) // start asynch program
		
		i := 0
		while(i < numberToTest)
		{
			s := areply.sendLater (Duration.fromStr("0.1sec"),"").get
			Env.cur.out.writeChars("$s")
			if(s.toStr.size > 0) i++
		}
	}
	
	static Str? printFunc (Obj s)
	{
		h := Actor.locals.get("printFuncState","") as Str
		if (s is Int)
		{
			Actor.locals["printFuncState"] = "$h$s.toStr\n"
			return ( null )
		}
		else
		{
			Actor.locals["printFuncState"] = ""
			return h
		}	
		
	}
	
	static Void findPrimes (Int start, Int numToPrint, Actor printFuncActor )
	{
		pr := start
		i := 0
		while (i < numToPrint)
		{
			pr++
			while (!isPrime(pr)) pr++
			printFuncActor.send(pr)
			i++
		}
	}
	
	static Bool isPrime ( Int pc)
	{
		for (i := 2; i < (pc.toFloat).sqrt.ceil.toInt+1; i ++)
		{
			if (pc % i == 0) return false
		}
		return true
	}
}
