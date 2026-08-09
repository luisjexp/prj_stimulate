%% METHOD TO OPTIMIZE AND STANDARDIZE CLUSTERING PROCEDURE
%% LOAD DATA
clear;

% Sparse Noise Experiments in V1
% % % 'gn7_007_001.sparsenoisekernels' cells with 2 sig subfields : [17 31 56 63 66 71 75 77 90 103 119 137 139 140 157 158 165 178 187 201 206 212 219 221 222]
% % % 'gn8_000_003_rigid.sparsenoiseK'
% % % 'gn8_001_001_rigid.sparsenoiseK'
% % % 'gn8_002_001_rigid.sparsenoiseK'
% % % 'gn8_003_001_rigid.sparsenoiseK'
% % % 'gn9_000_003_rigid.sparsenoiseK'
% % % 'gn9_001_001_rigid.sparsenoiseK'

clear;
if ismac
    dataPath = '/Users/luis/Box/boxEXPER/Toolbox/2pdata/';
elseif ispc
    dataPath = 'C:\Users\Luis\Box Sync\boxEXPER\Tuning Bias' ;
end

mouseName = 'gn7';
expId = '007_001';
kerneFileExtention = '.sparsenoise';
kernFileName    = [dataPath, mouseName,'/', mouseName '_', expId, '_rigid', kerneFileExtention];
sigFileName     = [dataPath, mouseName,'/', mouseName '_', expId, '_rigid.signals'];
runFileName     = [dataPath, mouseName,'/', mouseName '_', expId, '_quadrature.mat'];
logFileName     = [dataPath, mouseName,'/', mouseName '_', expId];

S = sbxreadsparsenoiselog(logFileName); % read log
R = load(sigFileName, '-mat');
R = R.spks;
L = load(runFileName, '-mat');
L = L.quad_data;

%%

K = load('/Users/luis/Box/boxEXPER/Toolbox/2pdata/gn7/gn7_007_001_rigid.snKernelsRun', '-mat');
K = K.K;

%%
numUnits = numel(K);
numTimeDelays = size(K(1).off_run,3);
kurt_off_run = nan(numUnits, numTimeDelays);
kurt_off_stat= nan(numUnits, numTimeDelays);
kurt_on_run= nan(numUnits, numTimeDelays);
kurt_on_stat= nan(numUnits, numTimeDelays);

Kopt_off_run = zeros(270,480,numUnits);
Kopt_off_stat = zeros(270,480,numUnits);
Kopt_on_run = zeros(270,480,numUnits);
Kopt_on_stat = zeros(270,480,numUnits);

kurtThresh = 6;
for i = 1:numUnits
    
    kurt_off_run(i,:)    = kurtosis( reshape( K(i).off_run(:) , [], numTimeDelays) );
    kurt_off_stat(i,:)   = kurtosis( reshape( K(i).off_stat(:), [], numTimeDelays) );
    kurt_on_run(i,:)     = kurtosis( reshape( K(i).on_run(:),   [], numTimeDelays) );
    kurt_on_stat(i,:)    = kurtosis( reshape( K(i).on_stat(:) , [], numTimeDelays) );
    
    Kopt_off_run(:,:,i) = mean( K(i).off_run(:,:, kurt_off_run(i,:)     == max(kurt_off_run(i,:)) ),3);
    Kopt_off_stat(:,:,i)= mean( K(i).off_run(:,:, kurt_off_stat(i,:)    == max(kurt_off_stat(i,:)) ),3);
    Kopt_on_run(:,:,i)  = mean( K(i).off_run(:,:, kurt_on_run(i,:)      == max(kurt_on_run(i,:)) ),3);
    Kopt_on_stat(:,:,i) = mean( K(i).off_run(:,:, kurt_on_stat(i,:)     == max(kurt_on_stat(i,:)) ),3);
    
%     clf;
%     figure(gcf);
%     subplot(2,2,1)
%         h1 = imagesc(    Kopt_off_run(:,:,i) ); axis equal off
%         title('off_stat')
%     subplot(2,2,2)
%         h2 = imagesc( Kopt_off_stat(:,:,i) ); axis equal off
%         title('off_run')
%     subplot(2,2,3)
%         h3 = imagesc( Kopt_on_run(:,:,i) ); axis equal off
%         title('on_stat')
%     subplot(2,2,4)
%         h4 = imagesc( Kopt_on_stat(:,:,i)  ); axis equal off
%         title('on_run')    
%         
%         drawnow;
%         pause;
    
end


%%

% Max(Off)/Max(On) in Running Vs Stationary


max_OffvsOn_run = log(max(reshape(Kopt_off_run(:), [], 29))./max(reshape(Kopt_on_run(:), [], 29)));
max_OffvsOn_stat = log(max(reshape(Kopt_off_stat(:), [], 29))./max(reshape(Kopt_on_run(:), [], 29)));

clf
histogram(max_OffvsOn_run); hold on;
histogram(max_OffvsOn_stat);
line(mean(max_OffvsOn_run)*[1 1], ylim, 'color', 'b')
line(mean(max_OffvsOn_stat)*[1 1], ylim, 'color', 'm')

figure(gcf)


