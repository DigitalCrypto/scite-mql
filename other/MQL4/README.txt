Because of added security in the later versions of windows it is not possible to compile outside of the present working directory.

To resolve this you will need to create a directory symbolic link to your MT4 Include directory.

1) Open a CMD prompt in this directory 

c:\Scite-MQL\other\MQL4  (Or wherever you installed scite-mql)


2) Run the following command:

mklink /j Include C:\MT4\mql4\include


Be sure to use the location of your MT4 installation's include directory

When you have done this you should end up with a new directory 

c:\Scite-MQL\other\MQL4\include

If you go into this folder it will take you to your MT4's include library directory.


