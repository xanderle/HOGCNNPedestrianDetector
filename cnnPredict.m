function [classLabel, scores, batchTime] = cnnPredict(cnnModel,predImage,varargin)
% Get batch size and number of images

batchSize = cnnModel.info.opts.batchSize;
n_obs = size(predImage,4);

cnnModel.net.layers{end} = struct('type', 'softmax');

% Preallocate scores
resTemp = vl_simplenn(cnnModel.net, cnnPreprocess(predImage(:,:,:,1)));
scores = zeros([size(resTemp(end-1).x), n_obs]);

for ii = 1:batchSize:n_obs
    idx = ii:min(ii+batchSize-1,n_obs);
	batchImages = predImage(:,:,:,idx);
    im = cnnPreprocess(batchImages);
    train_res = vl_simplenn(cnnModel.net, im, [], []);
    scores(:,:,:,idx) = squeeze(gather(train_res(end-1).x)); 
end

scores = squeeze(gather(scores))';
[~, labelId] = max(scores,[],2);
classLabel = cnnModel.net.meta.classes.description(labelId)';

function im = cnnPreprocess(batchImages)
    % Preprocess images
    im = single(batchImages);
    im = imresize(im, cnnModel.net.meta.normalization.imageSize(1:2)) - cnnModel.net.meta.normalization.averageImage;
end

end
