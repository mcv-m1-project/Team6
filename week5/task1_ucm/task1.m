%function load the diferents datasets
function trainingSet=task1(GlobalPath,pathTrain)
    pathGt = [ pathTrain 'gt/'];
    pathMask = [ pathTrain 'mask/'];
    images = dir([pathTrain '*.jpg']); %read images path
    % for every annotation file
    trainingSet=struct;
    trainingSet.samples = length(images);
    trainingSet.classABC.number = 0;
    trainingSet.classDF.number = 0;
    trainingSet.classE.number = 0;

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
                    case 'ABC'
                        trainingSet.classABC.number = trainingSet.classABC.number+1;
                        trainingSet.classABC.signal(trainingSet.classABC.number).boundingBox = boundingBox;
                        trainingSet.classABC.signal(trainingSet.classABC.number).imageName = trainingSet.image(nFile).name;
                    case 'DF'
                        trainingSet.classDF.number = trainingSet.classDF.number+1;
                        trainingSet.classDF.signal(trainingSet.classDF.number).boundingBox = boundingBox;
                        trainingSet.classDF.signal(trainingSet.classDF.number).imageName = trainingSet.image(nFile).name;                        
                    case 'E'
                        trainingSet.classE.number = trainingSet.classE.number+1;
                        trainingSet.classE.signal(trainingSet.classE.number).boundingBox = boundingBox;
                        trainingSet.classE.signal(trainingSet.classE.number).imageName = trainingSet.image(nFile).name;                
                end
            end
        end
        fclose(fid);
    end
end

function signal_class=convert_class_signal(org_class)
    switch (org_class)
        case 'A'
            signal_class='ABC';
        case 'B'
            signal_class='ABC';
        case 'C'
            signal_class='ABC';         
        case 'D'
            signal_class='DF';                       
        case 'E'
            signal_class='E';
        case 'F'
            signal_class='DF';
    end

end