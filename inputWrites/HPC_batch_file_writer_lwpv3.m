clearvars
fclose all;

savepath = 'C:\hcburch\Research\Dissertation\Prelminary_work\Scripts\';

hprime = 68:.1:87;
beta = 0.3:0.002:0.66;


% txnames = {'NAA';'NLM';'NLK';'NPM'};
txnames = {'NAA'};
rxnames = {'EG';'CN';'CB'};

% fid = fopen([savepath 'run_four_parameter_LWPC_NPM.sh'],'w');
% fid = fopen([savepath 'run_four_parameter_LWPC_NLM.sh'],'w+');
% fid = fopen([savepath 'run_four_parameter_LWPC_NLK.sh'],'w+');
% fid = fopen([savepath 'run_test_case_03.sh'],'w+');
fid = fopen([savepath 'run_chapman_lwpv3.sh'],'w+');


% fprintf(fid, 'test');
% fprintf(fid, '#!/bin/sh\n');
% fprintf(fid, '#SBATCH --job-name=four_parameter_submission_script # Job name\n');
% fprintf(fid, '#SBATCH --mail-type=ALL # Mail events (NONE, BEGIN, END, FAIL, ALL)\n');
% fprintf(fid, '#SBATCH --mail-user=hcburch@ufl.edu # Where to send mail	\n');
% fprintf(fid, '#SBATCH --nodes=1 # Use one node\n');
% fprintf(fid, '#SBATCH --ntasks=1 # Run a single task\n');
% fprintf(fid, '#SBATCH --mem=2gb # Memory limit\n');
% fprintf(fid, '#SBATCH --time=24:00:00 # Time limit hrs:min:sec\n');
% fprintf(fid, '#SBATCH --output=four_parameter_submission_script_%%j.out # Standard output and error log\n');
% fprintf(fid, 'pwd; hostname; date\n');
% fprintf(fid, 'cd /blue/moore/hcburch/lwpv3/test/\n');

% nmax = length(hprime);
% mmax =length(beta);
% nnmax =length(coefnu);
% mmmax = length(expnu);
% tmax = length(txnames);

%     fid = fopen([savepath 'run_four_parameter_LWPC_' txname '.sh'],'w+');
%     fid = fopen([savepath 'run_test_case_new' txname '.sh'],'w+');
    fprintf(fid, '#!/bin/sh\n');
fprintf(fid, '#SBATCH --job-name=hprime_beta_lwpv3_script # Job name\n');
fprintf(fid, '#SBATCH --mail-type=ALL # Mail events (NONE, BEGIN, END, FAIL, ALL)\n');
fprintf(fid, '#SBATCH --mail-user=hcburch@ufl.edu # Where to send mail	\n');
fprintf(fid, '#SBATCH --nodes=1 # Use one node\n');
fprintf(fid, '#SBATCH --ntasks=1 # Run a single task\n');
fprintf(fid, '#SBATCH --mem=2gb # Memory limit\n');
fprintf(fid, '#SBATCH --time=24:00:00 # Time limit hrs:min:sec\n');
fprintf(fid, '#SBATCH --output=hprime_beta_lwpv3_script%%j.out # Standard output and error log\n');
fprintf(fid, 'pwd; hostname; date\n');
fprintf(fid, 'cd /blue/moore/hcburch/lwpv3/test/\n');
runcounter = 0;
txname = txnames{1};
for r = 1:length(rxnames)
    rxname = rxnames{r};
    for n=1:nmax
        for m=1:mmax
            runcounter = runcounter +1;
%             basename = sprintf('%1$03.fb%2$02.f_%3$s-%4$s',hprime(n)*10,beta(m)*1000,txname,rxname);
            basename = sprintf('%03.fn%02.fs%02.f_%s-%s',h_0(hh),logno(nn),H(ss),txname,rxname);
            fprintf(fid, '\necho "Beginning LWPC run %i"\n',runcounter);
            fprintf(fid, 'cp /blue/moore/hcburch/lwpv3/test/inputs/chapman/%s/%s.inp /blue/moore/hcburch/lwpv3/test/\n',rxname,basename);
            fprintf(fid, '/blue/moore/hcburch/lwpv3/test/lwpm %s\n', basename);
            fprintf(fid, 'cp /blue/moore/hcburch/lwpv3/test/%s.log  /blue/moore/hcburch/lwpv3/test/outputs/chapman/%s/\n',basename,rxname);
            fprintf(fid, 'rm /blue/moore/hcburch/lwpv3/test/%s.inp\n',basename);
            fprintf(fid, 'rm /blue/moore/hcburch/lwpv3/test/%s.log\n',basename);
            fprintf(fid, 'rm /blue/moore/hcburch/lwpv3/test/%s.lwf\n',basename);
            fprintf(fid, 'rm /blue/moore/hcburch/lwpv3/test/%s.mds\n',basename);
            
        end
    end
end

fclose all