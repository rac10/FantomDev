using concurrent
using fwt
using gfx

const class Clock : Actor
{
    static const Str updateMsg := ""
    const Str handle := Uuid().toStr
    
    new make(Label label) : super(ActorPool())
    {
        Actor.locals[handle] = label
		//send(updateMsg)
        sendLater(1sec, "")
    }
    
    override Obj? receive(Obj? msg)
    {
        //if(msg == updateMsg)
        //{
            Desktop.callAsync |->| { update }
            //send(updateMsg)
            sendLater(0.1sec, "")
        //}
        return null
    }
    
    Void update()
    {
        label := Actor.locals[handle] as Label
        if(label != null)
        {
            time := Time.now.toLocale("hh:mm:ss")
            label.text = "It is now $time"
            
        }
    }
    

    static Void main()
    {
        display := Label
        {
            text := "Does anybody know what time it is?"
            halign = Halign.center
        }

        clock := Clock(display)
        
        Window
        {
            size = Size(300, 150)
            title = "Your mother"
            display,
        }.open
    }
}
