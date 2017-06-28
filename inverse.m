%% 
baseDir = '';
annotDir = [baseDir 'PennFudanPed/Annotation/'];

files = dir(annotDir) ;
files(1:2) = [];
close all;
for ii = 1 : length(files)
    fileName = [annotDir files(ii).name];
    record = PASreadrecord(fileName);
    imshow([baseDir record.imgname]);
    hold on;
    for jj = 1 : length(record.objects)
        bbox = record.objects(jj).bbox;
        bbox(3:4) = bbox(3:4) - bbox(1:2);
        rectangle('Position', bbox, 'FaceColor','k','LineWidth',2);
        
    end
    f = getframe(gca);
    [X,map] = frame2im(f);
    negativeDir = strcat('data/myNegatives/','PennFudan',num2str(ii),'.png');
    imwrite(X,negativeDir);    
    hold off;    
   
end
