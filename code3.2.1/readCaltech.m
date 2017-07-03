setDir = dir('data-USA/images/');
setDir(1:3) = [];
setFull = fullfile('data-USA','images',{setDir.name});

annotFull = fullfile('data-USA','annotations',{setDir.name});
counter = 0;
countNeg = 0;
for i=1:6
    video = dir(setFull{i});
    
    if video(1).name == '.'
        video(1) = [];
    end
    if video(1).name == '..'
        video(1) = [];
    end
    if strcmp(video(1).name,'.DS_Store')
        video(1) = [];
    end
    videoFull = fullfile(setFull{i},{video.name});
    annotVid = fullfile(annotFull{i},{video.name});
    for j=1:numel(video)
        names = dir([annotVid{j} '/*.txt']);
        annotations = fullfile(annotVid{j},{names.name});
        names = dir([videoFull{j} '/*.jpg']);
        images = fullfile(videoFull{j},{names.name});
        for k=1:numel(annotations)
            fileID = fopen(annotations{k},'r');
            fgetl(fileID);
            line = fgetl(fileID);
            
            im = imread(images{k});
            imshow(im);
            while ischar(line)
                a = textscan(line,'%s');
                if a{1}{6} == 0
                    continue
                end
                if strcmp(a{1}{1},'person')
                    bbox = [str2num(a{1}{2}),str2num(a{1}{3}),str2num(a{1}{4}),str2num(a{1}{5})];
                    rectangle('Position',bbox,'EdgeColor','g');
                    width = bbox(3);
                    height = bbox(4);
                    ratio = 0.3; %width/height;
                    newWidth = ratio*height;
                    newX = bbox(1)+(width-newWidth)/2;
                    newBBox = [newX,bbox(2),newWidth,bbox(4)];
                    im2 = imcrop(im,newBBox);
                    savePositiveDir = strcat('myPositives/',num2str(counter),'.png');
                    rectangle('Position', bbox, 'FaceColor','k','LineWidth',2);
                    imwrite(im2,savePositiveDir);
                    counter = counter + 1;
                end
                line = fgetl(fileID);
            end
            f = getframe(gca);
            [X,map] = frame2im(f);
            negativeDir = strcat('myNegatives/',num2str(countNeg),'.png');
            countNeg=countNeg+1;
            imwrite(X,negativeDir);
            fclose(fileID);
        end
    end
end

