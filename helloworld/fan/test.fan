//
// Copyright (c) 2011 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Alex 31 Mar 2014 - Initial Contribution
//


**
**
**
** 
** 
class test
{
  static Void main()
  {
    a := "This is letter a"
    b := "This is letter b"
    if(a==b)
      echo("$a > $b")
    else
      echo("$a < $b")
    
    Me := Person
    { 
      name = "Telecom"
      age = 100
    }
    echo("$Me.name is $Me.age years old")
    
    list := ["orange", "blue", "yellow", "green"]
    list.each  { echo(it) }
    
    
    MJ := Person
    {
      name = "Michael Jackson"
      age = 68
    }
    echo("$MJ.name was an amazing singer who died at $MJ.age")
    sum := |Int i, Int j->Int| { return i + j }
    d := sum(4, 5)
    f := |Int x, Int y->Int| { return x*2+y }
    e := f(3, 5)
    if(e > d)
      echo("$e > $d")
    else
      echo("$d > $e")
    
    Window
    {
      Button {text = "1"; command = |->| echo("first")},
      Button {text = "2"; command = |->| echo("second")}, //the final "," can be omitted
    }.open

  }
}

class Person
{
   /* new make(Str name, Int age)
    {
      this.name = name;
      this.age = age;
    }*/
    Str? name
    Int age
}