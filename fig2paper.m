function fig2paper(filename,varargin)

tex=@(x) [x '.tex'];

% Parse optional key-value pair input arguments
p=inputParser;
p.addOptional('width','\textwidth');
p.addOptional('height','0.618\textwidth');
p.parse(varargin{:});
res=p.Results;

if not(exist('filename','var'))
    filename= ['fig-' datestr(now,30)];
end

struct2vars(res);

% Check if "matlab2tikz" exists, if not download last version 
if exist('matlab2tikz','file')~=2
    fprintf('matlab2tikz not found, downloading it... ');
    folder=fileparts(mfilename('fullpath'));
    matlab2tikz_folder=fullfile(folder,'matlab2tikz');
    unzip('http://www.mathworks.com/matlabcentral/fileexchange/22022-matlab2tikz?download=true',matlab2tikz_folder)
    addpath(genpath(matlab2tikz_folder));
    fprintf('Done!\n');
end

matlab2tikz(tex(filename),...
    'standalone',true,...
    'parseStrings',false,...
    'showInfo',false,...
    'width',width,...
    'height',height);

[notfound,~] = system(sprintf('"%s" --help', 'pdflatex'));
if notfound
    error('Could not find "pdflatex" in system path. Please add pdflatex location to the system path.');
end

[status,result]=system(sprintf('pdflatex -quiet --job-name=%s %s',filename,tex(filename)));
if status==0
    open(sprintf('%s.pdf',filename));
    delete(sprintf('%s.log',filename),sprintf('%s.aux',filename));
else
    error(result);
end
end

%% struct2vars
function struct2vars(s)
fieldNames=fieldnames(s);
for iField=1:length(fieldNames)
    assignin('caller',fieldNames{iField},s.(fieldNames{iField}));
end
end

%% Helper function for future use
function template_text=template_tikz
stck=dbstack;
begin_line=stck(1).line+3;
%% BEGIN: TIKZ TEMPLATE
%{
\documentclass{standalone}
\usepackage{tikz,pgfplots}
\usetikzlibrary{plotmarks}
%\pgfplotsset{plot coordinates/math parser=false}
\pgfplotsset{compat=newest}
\usepackage[active,tightpage]{preview}  %generates a tightly fitting border around the work
\PreviewEnvironment{tikzpicture}
\setlength\PreviewBorder{0mm}
\begin{document}
\pagestyle{empty}
TIKZ_CODE_HERE
\end{document}
%}
%% END: TIKZ TEMPLATE
stck=dbstack;
end_line=stck(1).line-4;
num_lines_template=end_line-begin_line+1;
template_text=[];
fid = fopen([mfilename('fullpath') '.m'],'rt');
for nline=1:begin_line
    fgets(fid);
end
for nline=1:num_lines_template
    template_text=[template_text fgets(fid)];
end
fclose(fid);
end