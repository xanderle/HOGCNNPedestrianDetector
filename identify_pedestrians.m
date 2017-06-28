function [t] = identify_pedestrians(file,classifierModel,w,mx)

cnnModel.net = load('imagenet-vgg-f.mat');
cnnModel.net = vl_simplenn_tidy(cnnModel.net);
cnnModel.info.opts.batchSize = 10;

% create scale of bounding boxes
hogCellSize = 8 ;
minScale = -1 ;
maxScale = 3 ;
numOctaveSubdivisions = 3 ;
scales = 2.^linspace(minScale,maxScale,numOctaveSubdivisions*(maxScale-minScale+1)) ;

im = im2single(file);
tstart = tic;
% Compute hog detections
[detections, scores] = detect(im, w, hogCellSize, scales) ;
keep = boxsuppress(detections, scores, 0.25) ;
detections = detections(:, keep(1:100)) ;
scores = scores(keep(1:100)) ;

[x,y] = size(detections);

boxImages = [];
validationLabels = [];

im = file;

for i=1:y
  bbox = detections(:,i);
  bbox(3:4) = bbox(3:4) - bbox(1:2);
  box = imcrop(im,bbox);
  boxImages(:,:,:,i) = imresize(single(box),cnnModel.net.meta.normalization.imageSize(1:2))- cnnModel.net.meta.normalization.averageImage;
  validationLabels(i) = - 1;
end

[~, cnnFeatures] = cnnPredict(cnnModel, boxImages);

[x, y] = size(cnnFeatures);

for ii=1:x
    for jj=1:y
        cnnFeatures(ii,jj) = cnnFeatures(ii,jj)/mx;
    end
end

[scores a prob] = svmpredict(validationLabels', cnnFeatures, classifierModel,'-b 1 -q');

[x,y,z,j] = size(boxImages);

boundingBoxes = [];
probabilityScore = [];
finalImage = im;
t = toc(tstart);
for i=1:j
    bbox = detections(:,i);
    bbox(3:4) = bbox(3:4) - bbox(1:2);
    textPositionX = bbox(1);
    textPositionY = bbox(2) - 15;
    personLikelihood = round(prob(i,1), 4) * 100;
    if scores(i) == 1
        boundingBoxes(:,:,:,:,i) = bbox;
        probabilityScore(i) = personLikelihood;
        probability = text(textPositionX, textPositionY, num2str(personLikelihood));
        set(probability, 'FontSize', 12, 'Color', 'g');
      rectangle('Position',bbox,'EdgeColor','g');
    else
        % optional for plotting negative hogs
        %rectangle('Position',bbox,'EdgeColor','r');
    end
end

end
