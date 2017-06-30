names = dir('data-USA/annotations/set00/V000/*.txt') ;
annotations = fullfile('data-USA','annotations','set00','V000',{names.name});

names = dir('data-USA/images/set00/V000/*.jpg');
images = fullfile('data-USA','images','set00','V000',{names.name});
counter = 0
for i=1:numel(annotations)
    fileID = fopen(annotations{i},'r');
    fgetl(fileID);
    line = fgetl(fileID);
    im = imread(images{i});
    imshow(im);
    while ischar(line)
        a = textscan(line,'%s');
        if a{1}{6} == 0
            continue
        end
        if strcmp(a{1}{1},'person')
                bbox = [str2num(a{1}{2}),str2num(a{1}{3}),str2num(a{1}{4}),str2num(a{1}{5})]
                rectangle('Position',bbox,'EdgeColor','g');
        end
        line = fgetl(fileID);
    end
    pause(0.5)
    fclose(fileID);
end