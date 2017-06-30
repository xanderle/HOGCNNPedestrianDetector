setDir = dir('data-USA/images/');
setDir(1:3) = [];
setFull = fullfile('data-USA','images',{setDir.name});

annotFull = fullfile('data-USA','annotations',{setDir.name});
counter = 0;

for i=1:5
    video = dir(imgFull{i})
    video(1:2) = [];
    videoFull = fullfile(setFull{i},{video.name});
    annotVid = fullfile(annotFull{i},{video.name});
    for j=1:numel(video)
        names = dir([annotVid{i} '/*.txt']);
        annotations = fullfile(annotVid{i},{names.name});
        names = dir([videoFull{i} '/*.jpg']);
        images = fullfile(videoFull{i},{names.name});
        for k=1:numel(annotations)
            fileID = fopen(annotations{k},'r');
            fgetl(fileID);
            line = fgetl(fileID);
            im = imread(images{k});
            %imshow(im);
            while ischar(line)
                a = textscan(line,'%s');
                if a{1}{6} == 0
                    continue
                end
                if strcmp(a{1}{1},'person')
                    bbox = [str2num(a{1}{2}),str2num(a{1}{3}),str2num(a{1}{4}),str2num(a{1}{5})];
                    %rectangle('Position',bbox,'EdgeColor','g');
                    width = bbox(3);
                    height = bbox(4);
                    ratio = 0.3; %width/height;
                    newWidth = ratio*height;
                    newX = bbox(1)+(width-newWidth)/2;
                    newBBox = [newX,bbox(2),newWidth,bbox(4)];
                    im2 = imcrop(im,newBBox);
                    savePositiveDir = strcat('myPositives/',num2str(counter),'.png');
                    imwrite(im2,savePositiveDir);
                    counter = counter + 1;
                end
                line = fgetl(fileID);
            end
            
            fclose(fileID);
        end
    end
end