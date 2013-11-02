function figure_exporter(format)
% figure_exporter(format)
% where 'format' must be:
%   'fig','eps','eps2pdf','tikz','pgf'

%Change line width
linewidth=2;
markersize=10;
lineobj = findobj('type', 'line');
set(lineobj, 'linewidth', linewidth);
set(lineobj, 'MarkerSize', markersize);

%Change font size
fontsize=20;
textobj = findobj('type', 'text');
set(textobj, 'fontunits', 'points');
set(textobj, 'fontsize', fontsize);
set(gca,'FontSize',fontsize)

%Resize figure
set(gca,'plotboxaspectratio',[2 1.5 1])
drawnow;

%TODO: allow other filename for PGF format
filename=sprintf('output-%s',datestr(now,30));

switch format
    case 'fig'
        %Save as .fig
        saveas(gca,sprintf('%s.fig',filename));
    case 'eps'
        %Save as .eps
        print('-depsc2',sprintf('%s.eps',filename));
    case 'eps2pdf'
        print('-depsc2',sprintf('%s.eps',filename));
        system(sprintf('ps2epsi %s.eps %s_epi.eps',filename,filename));
        system(sprintf('ps2pdf -dEPSCrop %s_epi.eps %s_eps.pdf',filename,filename));
        open(sprintf('%s_eps.pdf',filename));
    case 'tikz'
        %TODO:
        %sizes, widths, etc
        %Change line width, no math
        linewidth=1.5;
        markersize=4;
        lineobj = findobj('type', 'line');
        set(lineobj, 'linewidth', linewidth);
        set(lineobj, 'MarkerSize', markersize);
        
        %Build template_tikz.tex
        template_tikz_str=[];
        template_tikz_str=[template_tikz_str  '\documentclass{article}' 10]; %10 is LF character
        template_tikz_str=[template_tikz_str  '\usepackage{tikz,pgfplots}' 10];
        template_tikz_str=[template_tikz_str  '\usetikzlibrary{plotmarks}' 10];
        template_tikz_str=[template_tikz_str  '%\pgfplotsset{plot coordinates/math parser=false}' 10];
        template_tikz_str=[template_tikz_str  '\pgfplotsset{compat=newest}' 10];
        template_tikz_str=[template_tikz_str  '\usepackage[active,tightpage]{preview}  %generates a tightly fitting border around the work' 10];
        template_tikz_str=[template_tikz_str  '\PreviewEnvironment{tikzpicture}' 10];
        template_tikz_str=[template_tikz_str  '\setlength\PreviewBorder{0mm}' 10];
        template_tikz_str=[template_tikz_str  '\begin{document}' 10];
        template_tikz_str=[template_tikz_str  '\pagestyle{empty}' 10];
        template_tikz_str=[template_tikz_str  sprintf('\\input{%s.tikz}',filename) 10];
        template_tikz_str=[template_tikz_str  '\end{document}' 10];
        
        fid = fopen('template_tikz.tex','w');
        fprintf(fid,'%s',template_tikz_str);
        fclose(fid);
        
        %Save as tikz
        matlab2tikz(sprintf('%s.tikz',filename), 'height', '9cm', 'width', '12cm' );
        [status,result]=system(sprintf('/usr/texbin/pdflatex -quiet --job-name=%s_tikz template_tikz.tex',filename));
        if status==0
            open(sprintf('%s_tikz.pdf',filename));
            delete('*.log','*.aux')
        else
            error(result);
        end
    case 'pgf'
        %Save as pgf
        %TODO:
        %Never tested
        linewidth=1.5;
        markersize=4;
        lineobj = findobj('type', 'line');
        set(lineobj, 'linewidth', linewidth);
        set(lineobj, 'MarkerSize', markersize);
        
        %Build template_pgf.tex
        
        template_pgf_str=['\documentclass{article}',10, ...%10 is LF character
            '\usepackage{pgf}',10,...
            '\usepackage{pgffor}',10,...
            '\usepgflibrary{plothandlers}',10,...
            '\%\usepackage{tikz}',10,...
            '\%\usepackage{3dplot}',10,...
            '\%\usetikzlibrary{positioning,decorations.pathmorphing,patterns}',10,...
            '\%\usetikzlibrary{calc,3d}',10,...
            '\usepackage[active,tightpage]{preview}  \%generates a tightly fitting border around the work',10,...
            '\%\PreviewEnvironment{figure}',10,...
            '\setlength\PreviewBorder{2mm}',10,...
            '\begin{document}',10,...
            '\pagestyle{empty}',10,...
            '\begin{preview}',10,...
            '\Huge',10,...
            sprintf('\\input{%s.pgf}',filename), 10,...
            '\end{preview}',10,...
            '\end{document}']
        
        fid = fopen('template_pgf.tex','w');
        fprintf(fid,'%s',template_pgf_str);
        fclose(fid);
        
        matfig2pgf('filename', filename, 'fignr', 0, 'fontsize',fontsize,'figwidth',0);
        system(sprintf('pdflatex --job-name=%s_pgf -quiet template_pgf.tex',filename));
        open(sprintf('%s_pgf.pdf',filename));
        delete('*.log','*.aux')
    otherwise
        disp('Invalid format');
end

return
%example
plot(rand(5));
legend(datestr(now));
figure_exporter('eps2pdf');