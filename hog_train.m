setup ;

% Training cofiguration
targetClass = 1 ;
numHardNegativeMiningIterations = 5 ;
schedule = [1 2 5 5 5] ;

% Scale space configuration
hogCellSize = 8 ;
minScale = -1 ;
maxScale = 3 ;
numOctaveSubdivisions = 3 ;
scales = 2.^linspace(...
  minScale,...
  maxScale,...
  numOctaveSubdivisions*(maxScale-minScale+1)) ;


%% Construct training data
trainImages = {} ;
trainBoxes = [] ;
trainBoxPatches = {} ;
trainBoxImages = {} ;
trainBoxLabels = [] ;

% Create negative data
names = dir('data/myNegatives/*.png') ;
trainImages = fullfile('data', 'myNegatives', {names.name}) ;
annotNames = dir('data/myNegatives/annotations/*.txt');
trainAnnotations = fullfile('data','myNegatives','annotations',{annotNames.name});

% Create positive data
names = dir('data/myPositives/*.png') ;
names = fullfile('data', 'myPositives', {names.name}) ;
for i=1:numel(names)
  im = imread(names{i}) ;
  im = imresize(im, [128 42.67]) ;
  trainBoxes(:,i) = [0 ; 0 ; 42.67 ; 128] ;
  trainBoxPatches{i} = im2single(im) ;
  trainBoxImages{i} = names{i} ;
  trainBoxLabels(i) = 1 ;
  
end
trainBoxPatches = cat(4, trainBoxPatches{:}) ;

% Calculate HOG features
trainBoxHog = {} ;
for i = 1:size(trainBoxPatches,4)
  trainBoxHog{i} = vl_hog(trainBoxPatches(:,:,:,i), hogCellSize);
end
trainBoxHog = cat(4, trainBoxHog{:}) ;
modelWidth = size(trainBoxHog,2) ;
modelHeight = size(trainBoxHog,1) ;

%% Hard Negative mining
% Initial positive and negative data
pos = trainBoxHog(:,:,:,ismember(trainBoxLabels,targetClass)) ;
neg = zeros(size(pos,1),size(pos,2),size(pos,3),0) ;
cnnImages = [];
for t=1:numHardNegativeMiningIterations
  numPos = size(pos,4) ;
  numNeg = size(neg,4) ;
  C = 1 ;
  lambda = 1 / (C * (numPos + numNeg)) ;

  fprintf('Hard negative mining iteration %d: pos %d, neg %d\n', ...
    t, numPos, numNeg) ;

  % Train SVM
  x = cat(4, pos, neg) ;
  x = reshape(x, [], numPos + numNeg) ;
  y = [ones(1, size(pos,4)) -ones(1, size(neg,4))] ;
  w = vl_svmtrain(x,y,lambda,'epsilon',0.01,'verbose') ;
  w = single(reshape(w, modelHeight, modelWidth, [])) ;

  % On the last iteration, Save the negatives for use in the cnn training

   if t == 5
       [matches, moreNeg, moreCnnImages] = ...
        evaluateModel(...
        vl_colsubset(trainImages', schedule(t), 'beginning'), ...
        trainBoxes, trainBoxImages, ...
        w, hogCellSize, scales,1) ;
   else
       [matches, moreNeg, moreCnnImages] = ...
        evaluateModel(...
        vl_colsubset(trainImages', schedule(t), 'beginning'), ...
        trainBoxes, trainBoxImages, ...
        w, hogCellSize, scales,0) ;
   end
  % Add negatives
  cnnImages = moreCnnImages;
  neg = cat(4, neg, moreNeg) ;

  % Remove duplicates
  z = reshape(neg, [], size(neg,4)) ;
  [~,keep] = unique(z','stable','rows') ;
  neg = neg(:,:,:,keep) ;
end
%% Save the final Variables
save('var/cnnHogBoxes.mat','cnnImages','-v7.3');
save('var/w.mat','w')
save('var/scales.mat','scales')
save('var/hogCellSize.mat','hogCellSize')