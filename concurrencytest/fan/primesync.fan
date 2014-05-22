using concurrent

class primesync
{
	Int startNumber := 100000000000
	Int numberToTest := 1000
	Str checkInterval := " 0.3 sec"
	
	Void main ()
	{
		p := primesync()
		p.test(10)
	}
	
	static Bool isPrime (Int primeCandidate)
	{
		for (i := 2; i < (primeCandidate.toFloat).sqrt.ceil.toInt+1; i++)
		{
			if (primeCandidate%i == 0) return false
		}
		return true
	}
	
	Void test(Int numOfThreads)
	{
		apool := ActorPool { maxThreads = numOfThreads }
		[Int:Actor] actors := [:]
		[Int:Future] futures := [:]
		primes := Int[,]
		asdaf := 0
		primes.add(5)
		echo ("creating Actors ... ")
		for (pc := startNumber ; pc < startNumber + numberToTest ; pc ++)
		{
			actors[pc] = Actor (apool, |Int i-> Bool| {isPrime(i)})
		}
		t1 := Duration.nowTicks
		actors.each |a, pc| {futures [pc] = a.send(pc)}
		num := 0
		apool.stop // no new messages allowed to actors , allows pool to be done
		while (!apool.isDone )
		{
			num = 0
			futures.each {if(it.isDone)num++ }
			echo("$num actors finished")
			try
				apool.join(Duration.fromStr(checkInterval))
			catch (TimeoutErr e) {}
		}
		elapsedMs := (Duration.nowTicks - t1)/1000000
		num = 0
		
		futures.each {if(it.get) {num++}}
		echo("Finished in ${elapsedMs}ms using $numOfThreads threads ")
		echo("$num primes found in $numberToTest numbers tested")
		echo("Primes: " + primes)
	}
}
