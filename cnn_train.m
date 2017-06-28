%% Set-up and Compilation of the CNN
% load pretrained cnn
cnnModel.net = load('imagenet-vgg-f.mat');
cnnModel.net = vl_simplenn_tidy(cnnModel.net);

% Set-up MatConvNet
%run(fullfile('matconvnet','matlab','vl_setupnn.m'));

%% Create positive image data
load('var/cnnHogBoxes.mat');

% Get image location
imSetPos = dir('data/myPositives/*.png');
imSetPos = fullfile('data', 'myPositives', {imSetPos.name});

% allocate normalized image size
imageSize = cnnModel.net.meta.normalization.imageSize;

% Load and resize images
for ii=1:numel(imSetPos)
    trainingImagesPos(:,:,:,ii) = imresize(single(imread(imSetPos{ii})), imageSize(1:2)) - cnnModel.net.meta.normalization.averageImage;
end

%% Create negative image data
% Load the images locations
imSetNeg = dir('data/myNegatives/*.png');
imSetNeg = fullfile('data', 'myNegatives', {imSetNeg.name});

% Load and resize
for ii=1:numel(imSetNeg)
    trainingImagesNeg(:,:,:,ii) = imresize(single(imread(imSetNeg{ii})), imageSize(1:2)) - cnnModel.net.meta.normalization.averageImage;
end

% Combine the two training image arrays
trainingImages = cat(4, trainingImagesPos, trainingImagesNeg);

% Add negative labels for HOG hard negative mined images
[x,y,z,a] = size(cnnImages);
negHogLabels = [];
for ii = 1:a
    negHogLabels(ii) = -1;
end

% Include the mined negatives from HOG training
trainingImages = cat(4,trainingImages,cnnImages);

%% Extract the features using the pre-trained CNN
% Set the batch size
cnnModel.info.opts.batchSize = 200;

% Calculate features
[~, cnnFeatures] = cnnPredict(cnnModel, trainingImages);

% Scale the results of the cnnFeatures from -1 to 1
[x, y] = size(cnnFeatures);
max = 0;

for ii=1:x
    for jj=1:y
        if(abs(cnnFeatures(ii,jj)) > max)
            max = abs(cnnFeatures(ii,jj));
        end
    end
end

for ii=1:x
    for jj=1:y
        cnnFeatures(ii,jj) = cnnFeatures(ii,jj)/max;
    end
end

%% Train the classifier using extracted features and calculate CV accuracy
% Train and validate a linear support vector machine (SVM)
trainingLabels = [ones(1, numel(imSetPos)) -ones(1, numel(imSetNeg))];
trainingLabels = [trainingLabels negHogLabels];
classifierModel = svmtrain(trainingLabels', cnnFeatures, '-c 1 -g 0.005 -b 1');

%% validate classifier

% construct positive validation images
% Load the images
imSetValPos = dir('data/myValidation/positives/*.png');
imSetValPos = fullfile('data', 'myValidation', 'positives', {imSetValPos.name});

validationPosLabels = [];
validationNegLabels = [];
validationImagesPos = [];

% Load, resize, add positive labels
for ii=1:numel(imSetValPos)
    validationImagesPos(:,:,:,ii) = imresize(single(imread(imSetValPos{ii})), imageSize(1:2)) - cnnModel.net.meta.normalization.averageImage;
    validationPosLabels(ii) = 1;
end

% construct negative validation images
% Load the images
imSetValNeg = dir('data/myValidation/negatives/*.png');
imSetValNeg = fullfile('data', 'myValidation', 'negatives', {imSetValNeg.name});
validationImagesNeg= [];
% Load, resize, add negative labels
for ii=1:numel(imSetValNeg)
    validationImagesNeg(:,:,:,ii) = imresize(single(imread(imSetValNeg{ii})), imageSize(1:2)) - cnnModel.net.meta.normalization.averageImage;
    validationNegLabels(ii) = -1;
end

validationImages = cat(4, validationImagesPos, validationImagesNeg);
validationLabels = [validationPosLabels validationNegLabels];

% calculate features from cnn
[~, cnnFeatures] = cnnPredict(cnnModel, validationImages);

% Scale the results of the cnnFeatures from  -1 to 1
[x, y] = size(cnnFeatures);
for ii=1:x
    for jj=1:y
        cnnFeatures(ii,jj) = cnnFeatures(ii,jj)/max;
    end
end

[out a b] = svmpredict(validationLabels', cnnFeatures, classifierModel, '-b 1');

%% Save the variables that will be used for the detection process
save('var/max.mat','max');
save('var/classifier.mat','classifierModel');