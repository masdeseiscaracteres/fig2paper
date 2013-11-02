clc;
clear;
close all;

addpath ..

x = -pi:pi/10:pi;
y = tan(sin(x)) - sin(tan(x));
plot(x,y,'--rs','LineWidth',2,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',10);

fig2paper('figure','width','8cm','height','5cm');
  
pause;

%Now delete file, compiling main.tex should rebuild it
delete('figure.pdf');