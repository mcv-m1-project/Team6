%function load the diferents datasets
function trainingSet=split_by_shape(GlobalPath,pathTrain)
    pathGt = [ pathTrain 'gt\'];
    pathMask = [ pathTrain 'mask\'];
    images = dir([pathTrain '*.jpg']); %read images path
    % for every annotation file
    trainingSet=struct;
    trainingSet.samples = length(images);
    trainingSet.classAB.number = 0;
    trainingSet.classCDE.number = 0;
    trainingSet.classF.number = 0;


    for nFile=1:trainingSet.samples
        fileName = strsplit(images(nFile).name,'.'); % split string with '.'
        fileName = [fileName{1} '.' fileName{2}];   %Select part that is the name
        fid = fopen([pathGt 'gt.' fileName '.txt'], 'r' );
        size = [5 Inf];
        file = fscanf(fid,'%f %f %f %f %c',size); %read the annotation file
        if ~isempty(file)
            maskImage = logical(imread([pathMask 'mask.' fileName '.png']));
            file = file';
            trainingSet.image(nFile).name = fileName;
            trainingSet.image(nFile).numSignals = length(file(:,1));
            boundingBoxes = [round(file(:,1)) round(file(:,2)) round(file(:,3)) round(file(:,4))];
            class = char(file(:,5)); %convert to char the column that correspond to signal class
            for n=1:trainingSet.image(nFile).numSignals %for every signal in the image
                trainingSet.image(nFile).signal(n).boundingBox = boundingBoxes(n,:); %save the bpunding box
                trainingSet.image(nFile).signal(n).class = convert_class_signal(class(n));    % signal class
                trainingSet.image(nFile).signal(n).realclass = class(n);
                width = boundingBoxes(n,4) - boundingBoxes(n,2); 
                height = boundingBoxes(n,3) - boundingBoxes(n,1);
                boundingBox = [boundingBoxes(n,2) boundingBoxes(n,1) width height]; %new convention for easy crops
                trainingSet.image(nFile).signal(n).aspectRatio = width/height; %aspect ratio
                pixels = sum(sum(maskImage(boundingBoxes(n,1):...
                    boundingBoxes(n,3),boundingBoxes(n,2):boundingBoxes(n,4))));
                trainingSet.image(nFile).signal(n).fillingRatio = pixels/(width*height); % filling ratio
                % class counter
                switch (trainingSet.image(nFile).signal(n).class)
                    case 'AB'
                        trainingSet.classAB.number = trainingSet.classAB.number+1;
                        trainingSet.classAB.signal(trainingSet.classAB.number).boundingBox = boundingBox;
                        trainingSet.classAB.signal(trainingSet.classAB.number).imageName = trainingSet.image(nFile).name;
                        
                        trainingSet.classAB.signal(trainingSet.classAB.number).width = width;
                        trainingSet.classAB.signal(trainingSet.classAB.number).height = height;
                        trainingSet.classAB.signal(trainingSet.classAB.number).aspectRatio = trainingSet.image(nFile).signal(n).aspectRatio;
                        trainingSet.classAB.signal(trainingSet.classAB.number).fillingRatio = trainingSet.image(nFile).signal(n).fillingRatio ;
                        trainingSet.classAB.signal(trainingSet.classAB.number).pixels = pixels;
                        trainingSet.classAB.manualAdj = 0.9;
                    case 'CDE'
                        trainingSet.classCDE.number = trainingSet.classCDE.number+1;
                        trainingSet.classCDE.signal(trainingSet.classCDE.number).boundingBox = boundingBox;
                        trainingSet.classCDE.signal(trainingSet.classCDE.number).imageName = trainingSet.image(nFile).name;   
                        
                        trainingSet.classCDE.signal(trainingSet.classCDE.number).width = width;
                        trainingSet.classCDE.signal(trainingSet.classCDE.number).height = height;
                        trainingSet.classCDE.signal(trainingSet.classCDE.number).aspectRatio = trainingSet.image(nFile).signal(n).aspectRatio;
                        trainingSet.classCDE.signal(trainingSet.classCDE.number).fillingRatio = trainingSet.image(nFile).signal(n).fillingRatio ;
                        trainingSet.classCDE.signal(trainingSet.classCDE.number).pixels = pixels;
                        trainingSet.classCDE.manualAdj = 0.9;
                    case 'F'
                        trainingSet.classF.number = trainingSet.classF.number+1;
                        trainingSet.classF.signal(trainingSet.classF.number).boundingBox = boundingBox;
                        trainingSet.classF.signal(trainingSet.classF.number).imageName = trainingSet.image(nFile).name;      
                        
                        trainingSet.classF.signal(trainingSet.classF.number).width = width;
                        trainingSet.classF.signal(trainingSet.classF.number).height = height;
                        trainingSet.classF.signal(trainingSet.classF.number).aspectRatio = trainingSet.image(nFile).signal(n).aspectRatio;
                        trainingSet.classF.signal(trainingSet.classF.number).fillingRatio = trainingSet.image(nFile).signal(n).fillingRatio ;
                        trainingSet.classF.signal(trainingSet.classF.number).pixels = pixels;
                        trainingSet.classF.manualAdj = 1;
                end
            end
        end
        fclose(fid);
    end
    fields = fieldnames(trainingSet);
    for class = 1:numel(fields)
        if ~isempty(strfind(fields{class},'class'))
            trainingSet.(fields{class}).meanaspectRatio = mean([trainingSet.(fields{class}).signal.aspectRatio]);
            trainingSet.(fields{class}).stdaspectRatio = std([trainingSet.(fields{class}).signal.aspectRatio]);
            
            trainingSet.(fields{class}).maxaspectRatio = max([trainingSet.(fields{class}).signal.aspectRatio]);
            trainingSet.(fields{class}).minaspectRatio = min([trainingSet.(fields{class}).signal.aspectRatio]);
            
            trainingSet.(fields{class}).meanfillingRatio = mean([trainingSet.(fields{class}).signal.fillingRatio]);
            trainingSet.(fields{class}).stdfillingRatio = std([trainingSet.(fields{class}).signal.fillingRatio]);
            
            trainingSet.(fields{class}).maxfillingRatio = max([trainingSet.(fields{class}).signal.fillingRatio]);
            trainingSet.(fields{class}).minfillingRatio = min([trainingSet.(fields{class}).signal.fillingRatio]);
            
            trainingSet.(fields{class}).maxwidth = max([trainingSet.(fields{class}).signal.width]);
            trainingSet.(fields{class}).minwidth = min([trainingSet.(fields{class}).signal.width]);
            
            trainingSet.(fields{class}).maxheight = max([trainingSet.(fields{class}).signal.height]);
            trainingSet.(fields{class}).minheight = min([trainingSet.(fields{class}).signal.height]);
            trainingSet.(fields{class}) = rmfield(trainingSet.(fields{class}),'signal');
        else
            trainingSet= rmfield(trainingSet,fields{class});
        end
    end
end

function signal_class=convert_class_signal(org_class)
    switch (org_class)
        case 'A'
            signal_class='AB';
        case 'B'
            signal_class='AB';
        case 'C'
            signal_class='CDE';         
        case 'D'
            signal_class='CDE';                       
        case 'E'
            signal_class='CDE';
        case 'F'
            signal_class='F';
    end

end