function K = extractSpatialKernels()

%% Load
dataPath = '/Users/luis/Box/boxEXPER/Toolbox/2pdata/';

mouseName = 'gn7';
expId = '007_001';
kerneFileExtention = '.sparsenoise';
sigFileName     = [dataPath, mouseName,'/', mouseName '_', expId, '_rigid.signals'];
runFileName     = [dataPath, mouseName,'/', mouseName '_', expId, '_quadrature.mat'];
logFileName     = [dataPath, mouseName,'/', mouseName '_', expId];

%% Variables
unitIds         = [17 31 56 63 17 31 56 63 66 71 75 77 90 103 119 137 139 140 157 158 165 178 187 201 206 212 219 221 222];
numUnits        = numel(unitIds); 
numTimeDelays   = 12;

L = load(runFileName, '-mat');
L = L.quad_data;

S = sbxreadsparsenoiselog(logFileName); 
S.isRunning = zeros(height(S),1);
S.isRunning( ismember(S.sbxborn, find(abs(diff(L))>5)) ) = 1;
X       = S.xpos;
Y       = S.ypos;
T       = S.sbxborn;
numStim = size(S,1);

R = load(sigFileName, '-mat');
R = R.spks;

G = fspecial('gauss',250,30);
imsize = [270 480];
K = struct('off_stat', nan(imsize), 'off_run', nan(imsize), 'on_stat', nan(imsize), 'on_run', nan(imsize));
K = repmat(K, numUnits, 1);



%% Now Extract Kernels

%  Create Processing Blocks
unitsPerBlock = 3;
[blkIds, blkIdx] = createblocks(unitsPerBlock, unitIds);

for b = 1:numel(blkIds)
    units = blkIds{b};
    n = numel(units);
    M  = zeros(max(Y),max(X),numTimeDelays,2,2, n);
    
    for i=1:numStim
        
        if S.isRunning(i) 
            runIdx = 2;
        else
            runIdx = 1;
        end

        if (S.mean(i)==0)
            fieldIdx = 1;
        else
            fieldIdx = 2;
        end

        M(Y(i),X(i),:,runIdx,fieldIdx,:)  = squeeze(M(Y(i),X(i),:,runIdx,fieldIdx,:)) + ...
            R(T(i):T(i)+numTimeDelays-1,units);
        i
    end
    
    for uidx = 1:size(M,6)
        u       = blkIdx{b}(uidx);
        K(u)    = getKernels(M,uidx, G); 
    end    

end
%%
fname = [dataPath, mouseName,'/', mouseName, '_', expId, '_rigid.snKernelsRun'];
save(fname,'K', '-v7.3');

end


%% A. Create Processing Blocks
function [blkIds, blkIdx] = createblocks(unitsPerBlock, unitIds)


    blkIds = cell(0);
    blkIdx = cell(0);
    numUnits=numel(unitIds);
    idx = 1:numUnits;
    
    k = 1;
    while(~isempty(idx))
        j = ((k-1)*unitsPerBlock+1): min( ((k-1)*unitsPerBlock+1)+unitsPerBlock-1, numUnits);
        blkIds{k} = unitIds(j);
        blkIdx{k} = j;
        k = k+1;
        idx = setdiff(idx,j);
    end

end

%% D. Get ON and OFF Maps
function K = getKernels(krn,unitIdx, gausskern )

    imsize = [270 480];
    % Find Kernels
    ntau        = size(krn,3);
    K.off_stat  = zeros([imsize ntau]);
    K.off_run   = zeros([imsize ntau]);
    K.on_stat   = zeros([imsize ntau]);
    K.on_run    = zeros([imsize ntau]);
    
    clf;
    figure(gcf);
    subplot(2,2,1)
        h1 = imagesc(nan(imsize)); axis equal off
        title('off_stat')
    subplot(2,2,2)
        h2 = imagesc(nan(imsize)); axis equal off
        title('off_run')
    subplot(2,2,3)
        h3 = imagesc(nan(imsize)); axis equal off
        title('on_stat')
    subplot(2,2,4)
        h4 = imagesc(nan(imsize)); axis equal off
        title('on_run')        
       
    for w=1:ntau
        K.off_stat(:,:,w)   = imresize(filter2(gausskern,krn(:,:,w,1,1,unitIdx),'same'),0.25);
        K.off_run(:,:,w)    = imresize(filter2(gausskern,krn(:,:,w,2,1,unitIdx),'same'),0.25);
        K.on_stat(:,:,w)    = imresize(filter2(gausskern,krn(:,:,w,1,2,unitIdx),'same'),0.25);
        K.on_run(:,:,w)     = imresize(filter2(gausskern,krn(:,:,w,2,2,unitIdx),'same'),0.25);
        
        h1.CData = K.off_stat(:,:,w);
        h2.CData = K.off_run(:,:,w);
        h3.CData = K.on_stat(:,:,w);
        h4.CData = K.on_run(:,:,w);        
        drawnow;
        

    end

    
    
end


