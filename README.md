Fig2Paper
=================

Fig2Paper is a Matlab(R)/Octave script that takes the current figure and converts it to a PDF file which is ready to be inserted in a LaTeX file. An standalone .tex with the TikZ code is also returned in case one needs to manually modify/compile it. This script is basically a wrapper of the Matlab2TikZ <https://github.com/nschloe/matlab2tikz> script by Nico Schlömer. 

###### Requirements:
  - A LaTeX distribution including TikZ-related packages
  - pdflatex added to the system path
  - Matlab2TikZ added to the Matlab(R)/Octave path (if not found, it will downloaded automatically)

This is work in progress and new functionalities will be added sporadically.

Usage
--------------

Convert the current figure to a PDF file named fig-[*timestamp*].pdf
```m
fig2paper
```
 If you prefer to specify a name for the output use:
 ```m
fig2paper('figure_name')
```
Desired width and height can be also specified (using LaTeX length specifiers):
 ```m
fig2paper('figure_name','width','8 cm','height','6 cm')
```
By default, the returned figure has divine proportions with ``width`` equal to ``\textwidth``