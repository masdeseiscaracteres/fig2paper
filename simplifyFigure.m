function simplifyFigure(h,varargin)
% Example:
%{
  figure
  x=linspace(0,2*pi,1000);
  for kk=1:3000
      y=sin(x)+0.1*randn(1);
      plot(x,y);
      hold on;
  end
  simplifyFigure()
%}

% Filter example
% filter=@(x) norm(get(x,'Color')-[0.7 0.7 0.7])<1e-3; %grey objects

p=inputParser;
p.addOptional('Resolution',100); % resolution in dpi
p.addOptional('Verbose',false);
p.addOptional('CanBeDeleted',@(handler)true);
p.parse(varargin{:});
res=p.Results;

if not(exist('h','var')) || isempty(h) || not(ishghandle(h))
    h=gcf;
end

struct2vars(res);

%% Original figure
fig1 = hardcopy(h, '-dzbuffer', sprintf('-r%d',Resolution));

if Verbose
    vh=figure;
    subplot(1,2,1);
    imshow(fig1);
end

%% Register onCleanUp function
global CTRLC_args;
cleanupFun=@() CTRLC_function();
cleanupObj = onCleanup(cleanupFun);

%% Simplified figure
List=findobj(h,'Type','line');
nObjects=length(List);

%Filter-in some objects
temp=false(1,nObjects);
for kk=1:nObjects
    if CanBeDeleted(List(kk))
        temp(kk)=true;
    end
end
List=List(temp);
nObjects=length(List);

fprintf('Detected %d objects\n',nObjects');

final=fig1;
nHide=100:100:nObjects;
HiddenObjectsVector=false(1,nObjects);
CTRLC_args=struct('List',List,'HiddenObjectsVector',HiddenObjectsVector,'h',h);
%% Simplification loop
for iHide=1:length(nHide)
    nh=nHide(iHide);
    
    while 1
        fprintf('Trying to remove %d / %d objects (CTRL+C applies the result)\n',nh,nObjects);
        
        % Choose "nh" objects to hide among those not hidden yet
        allowedIndices=find(~HiddenObjectsVector);
        sel=randperm(length(allowedIndices));
        candidates=allowedIndices(sel(1:(nh-sum(HiddenObjectsVector))));
        hiddenIndices=find(HiddenObjectsVector);
        
        % Hide objects
        for kk=[hiddenIndices candidates]
            set(List(kk),'Visible', 'off');
        end
        
        fig2 = hardcopy(h, '-dzbuffer', sprintf('-r%d',Resolution));
        if Verbose
            figure(vh);
            subplot(1,2,2);
            imshow(fig2);
            drawnow;
        end
        
        %restore visibility
        for kk=[hiddenIndices candidates]
            set(List(kk),'Visible', 'on');
        end
        
        d=sum(fig1(:)~=fig2(:));
        fprintf('Found %d different pixels:',d);
        if d==0
            fprintf(' DELETING\n',d);
            HiddenObjectsVector(candidates)=true;
            final=fig2;
            CTRLC_args=struct('List',List,'HiddenObjectsVector',HiddenObjectsVector,'h',h);
            break;
        else
            fprintf(' TRYING AGAIN\n',d);
        end
    end
end

%% Final result
sel=find(HiddenObjectsVector);
for kk=sel
    delete(List(kk));
    %     set(List(kk),'Visible', 'off');
end

%% Plot results
if Verbose
    figure(vh)
    subplot(1,2,1);
    imshow(fig1);
    title('Original figure');
    drawnow;
    subplot(1,2,2);
    imshow(final);
    title('Simplified figure');
end

end

%% struct2vars
function struct2vars(s)
fieldNames=fieldnames(s);
for iField=1:length(fieldNames)
    assignin('caller',fieldNames{iField},s.(fieldNames{iField}));
end
end

%% cleanUp function
function CTRLC_function()
global CTRLC_args;

sel=find(CTRLC_args.HiddenObjectsVector);
for kk=sel
    delete(CTRLC_args.List(kk));
    %     set(CTRLC_args.List(kk),'Visible', 'off');
end
% hgsave(CTRLC_args.h,'simplified.fig')
% openfig('simplified.fig');
end