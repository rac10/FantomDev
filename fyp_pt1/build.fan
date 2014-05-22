using build
class Build : build::BuildPod
{
    new make()
    {
        podName = "fyp_pt1"
        summary = ""
        srcDirs = [`fan/`]
        depends = ["sys 1.0", "fwt 1.0+", "gfx 1.0+", "concurrent 1.0+"]
    }
	
	@Target{help = "Delete target and recompile"}
	override Void compile()
	{
		outPodDir.plusName("${podName}.pod").toFile.delete
		super.compile
	}
}
