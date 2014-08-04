%% Alternative implementation of simplifyFigure

clc;
clear;
close all;

%%
figure
x=linspace(0,2*pi,1000);
for kk=1:3000
    y=sin(x)+0.1*randn(1);
    plot(x,y);
    hold on;
end
pause

%%
h=gcf;
ah=gca;
%% Parameters
resolution=100; % resolution in dpi
%% Original figure

fig1 = hardcopy(h, '-dzbuffer', sprintf('-r%d',resolution));
% figure(1000);
% subplot(1,2,1);
% imshow(fig1);
%% Simplified figure
List=get(ah,'Children');
nObjects=length(List);

%Define filters
filter=@(x) norm(get(x,'Color')-[0.7 0.7 0.7])<1e-3; %grey objects

%Filter-in some objects
temp=false(1,nObjects);
for kk=1:nObjects
    if filter(List(kk))
        temp(kk)=true;
    end
end
List=List(temp);
nObjects=length(List);

fprintf('Detected %d objects\n',nObjects');

nHide=5;
Votes=zeros(1,nObjects);

VOTINGS=1000;
for iVoting=1:VOTINGS
    fprintf('Voting %d / %d\n',iVoting,VOTINGS);
    sel=randperm(nObjects);
    sel=sel(1:nHide);
    
    % Hide objects
    for kk=sel
        set(List(kk),'Visible', 'off');
    end
    
    fig2 = hardcopy(h, '-dzbuffer', sprintf('-r%d',resolution));
    %     figure(1000);
    %     subplot(1,2,2);
    %     imshow(fig2);
    %     drawnow;
    
    %restore visibility
    for kk=sel
        set(List(kk),'Visible', 'on');
    end
    
    d=sum(fig1(:)~=fig2(:));
    fprintf('Found %d different pixels\n',d);
    if d~=0
        Votes(sel)=Votes(sel)+1;
        figure(1000);
        stem(1:nObjects,Votes);
        drawnow;
    end
end

%% The most voted objects need to be kept
[srtVotes,idx]=sort(Votes,'ascend');

for kk=1:nObjects
    set(List(kk),'Visible', 'on');
end

NUMDELETE=4000; %choose a threshold by looking at ecdf(Votes)
deleteList=idx(1:NUMDELETE);
for kk=deleteList
    %     set(List(kk),'Visible', 'off');
    delete(List(kk));
end
%% Plot results
% figure(1000)
% subplot(1,2,1);
% imshow(fig1);
% drawnow;
% subplot(1,2,2);
% imshow(final);
% drawnow;
