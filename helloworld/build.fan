using build
class Build : build::BuildPod
{
  new make()
  {
    podName = "helloworld"
    summary = ""
    srcDirs = [`fan/`]
    depends = ["sys 1.0", "fwt", "gfx"]
  }
}
