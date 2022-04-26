## DANY Data Dashboard

This is the base folder for the R+Shiny web application.

`Dockerfile` contains the build instructions for the image to run the application.
  - `.dockerignore` lists files/directories that do not go into the image
  - `.onbuild` is part of the build process and contains some extra commands to run at the end

`Makefile` contains commands for the `make` program to automate running common command sequences.

