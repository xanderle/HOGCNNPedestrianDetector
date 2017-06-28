baseDir = '';
annotDir = [baseDir 'PennFudanPed/Annotation/'];
% Construct positive data
files = dir(annotDir); 
files(1:2) = [];
close all;
counter = 0;
for ii = 1 : length(files)
    fileName = [annotDir files(ii).name];
    record = PASreadrecord(fileName);
    im = imread(record.imgname);
    for jj = 1 : length(record.objects)
        bbox = record.objects(jj).bbox;
        bbox(3:4) = bbox(3:4) - bbox(1:2);
        width = bbox(3);
        height = bbox(4);
        ratio = 0.3; %width/height;
        newWidth = ratio*height;
        newX = bbox(1)+(width-newWidth)/2;
        newBBox = [newX,bbox(2),newWidth,bbox(4)];
        im2 = imcrop(im,newBBox);
        savePositiveDir = strcat(baseDir,'data/myPositives/',num2str(counter),'.png');
        imwrite(im2,savePositiveDir);
        counter = counter + 1;
    end

end

