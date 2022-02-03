# Installing Git for Windows Using Silent Installer
1. Download the latest version from [Git-SCM.com](https://git-scm.com/download/win)
1. Download Setup Response File from [https://raw.githubusercontent.com/mdzi/cis25x_lss/main/Git/gitinf.inf](https://raw.githubusercontent.com/mdzi/cis25x_lss/main/Git/gitinf.inf), saving the file in the same directory as the Git-{Version}.exe
1. In a Command-Prompt, change directory to the location of the saved files
1. Run Git-{Version}.exe /LOADINF=gitinf.inf /SILENT
