function xwritelagfiles(lagStep,lagMax)
% XWRITELAGFILES - create lag files for multiple detector and site
% combinations.
%
% usage: xwritelagfiles(lagStep,lagMax)
%
%  lagStep                double. Size of smallest time lag in seconds.
%  lagMax                 double. Size of largest time lag in seconds.

% ---- Checks.
error(nargchk(2,2,nargin));

vplus = [lagStep:lagStep:lagMax];
v1 = [sort(-vplus), vplus]';
v2 = flipud(v1);
v0 = zeros(size(v1));
	
fprintf(1,'Writing lag files to working dir... ')
dlmwrite('lags_2det1site.txt', [v0,v1], ' ');
dlmwrite('lags_2det2site.txt', [v0,v2], ' ');
dlmwrite('lags_3det2site.txt', [v0,v0,v2], ' ');
dlmwrite('lags_3det3site.txt', [v0,v2,v1], ' ');
dlmwrite('lags_4det3site.txt', [v0,v0,v2,v1], ' ');
fprintf(1,'Done! \n')

% Michal: For the 3det3site case it generates a lot of
% time slides where the delay between two detectors is kept constant and
% only the third detector is moved. So you increase the number of time
% slides, but you don't necessarily improve your background estimation,
% glitches that happen to be coincident with a given time lag between two
% detectors will be counted multiple times.
%
%vplus = [lagStep:lagStep:lagMax];
%
%v1 = [];
%v2 = [];
%
%% ---- Lag vectors for 1 or 2 site networks.
%vv1 = [vplus, sort(-vplus)]';
%vv0 = zeros(size(vv1));
%
%% ---- Create lag vectors for 3 site networks.
%for ilag1 = 1:length(vv1)
%   % ---- Create a copy of vv1 but remove the current value, vv1(ilag)=[].
%   vtemp = vv1;
%   vtemp(find(vtemp==vtemp(ilag1)))=[];
%    
%   v1 = [v1; vv1(ilag1)*ones(size(vtemp))];
%   v2 = [v2;vtemp];
%end % -- Loop over vv1.
%v0 = zeros(size(v1)); 
%
%fprintf(1,'Writing lag files to working dir... ')
%dlmwrite('lags_2det1site.txt', [vv0,vv1], ' ');
%dlmwrite('lags_2det2site.txt', [vv0,vv1], ' ');
%dlmwrite('lags_3det2site.txt', [vv0,vv0,vv1], ' ');
%dlmwrite('lags_3det3site.txt', [v0,v1,v2], ' ');
%dlmwrite('lags_4det3site.txt', [v0,v0,v1,v2], ' ');
%fprintf(1,'Done! \n')

% ---- Done.
return

