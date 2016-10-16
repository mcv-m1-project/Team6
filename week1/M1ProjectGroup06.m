function M1ProjectGroup06()
    %Paths
    global trainingSet;
    trainingSet = struct;
    
    global lengthRGB;
    lengthRGB = 10;
    
    GlobalPath = './';
    pathTrain = [ GlobalPath 'train\'];
    pathTest = [ GlobalPath 'test\'];
    
    %define the color spaces and alternative of these spaces
    colorSpace = 'HSV'; %colorspaces :  RGB_histeq, HSV, RGB, LAB,RGB_imadjust
    %method to train the model
    model='gaussian_HSV'; % models : Kmeans, 3Dhist, gaussian,gaussian_HSV (with only HS)
    %method to test the model
    evaluation = 'gaussian_mixture'; %Threshold, centroidDistance,gaussian_mixture,hand
    'obtaining data ...'
    task1(GlobalPath,pathTrain);
    'Splitting train data in 70% train 30% test...'
    task2(GlobalPath,pathTrain);
    'Recalculating data with the new dataset...'
    trainingSet = struct;
    task1([ GlobalPath '\splitDataset\'],[GlobalPath 'splitDataset\train\']);
    ['Obtaining colour feautures from ' colorSpace ' space colour...']
    task3([ GlobalPath '\splitDataset\'],[GlobalPath 'splitDataset\train\'],colorSpace,model);
    trainingSetDone=trainingSet;
    trainingSet=struct;
    task1([ GlobalPath '\splitDataset\'],[GlobalPath 'splitDataset\test\']);
    'evaluating model... '
    %evalmodel([GlobalPath 'splitDataset\test\'],trainingSetDone,evaluation,colorSpace);
    evalmodel(pathTest,trainingSetDone,evaluation,colorSpace);
end
%function load the diferents datasets
function task1(GlobalPath,pathTrain)
    pathGt = [ pathTrain 'gt\'];
    pathMask = [ pathTrain 'mask\'];
    images = dir([pathTrain '*.jpg']); %read images path
    % for every annotation file
    global trainingSet;
    trainingSet.samples = length(images);
    trainingSet.classA.number = 0;
    trainingSet.classB.number = 0;
    trainingSet.classC.number = 0;
    trainingSet.classD.number = 0;
    trainingSet.classE.number = 0;
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
                trainingSet.image(nFile).signal(n).class = class(n);    % signal class
                width = boundingBoxes(n,4) - boundingBoxes(n,2); 
                height = boundingBoxes(n,3) - boundingBoxes(n,1);
                boundingBox = [boundingBoxes(n,2) boundingBoxes(n,1) width height]; %new convention for easy crops
                trainingSet.image(nFile).signal(n).aspectRatio = width/height; %aspect ratio
                pixels = sum(sum(maskImage(boundingBoxes(n,1):...
                    boundingBoxes(n,3),boundingBoxes(n,2):boundingBoxes(n,4))));
                trainingSet.image(nFile).signal(n).fillingRatio = pixels/(width*height); % filling ratio
                % class counter
                switch (trainingSet.image(nFile).signal(n).class)
                    case 'A'
                        trainingSet.classA.number = trainingSet.classA.number+1;
                        trainingSet.classA.signal(trainingSet.classA.number).boundingBox = boundingBox;
                        trainingSet.classA.signal(trainingSet.classA.number).imageName = trainingSet.image(nFile).name;
                    case 'B'
                        trainingSet.classB.number = trainingSet.classB.number+1;
                        trainingSet.classB.signal(trainingSet.classB.number).boundingBox = boundingBox;
                        trainingSet.classB.signal(trainingSet.classB.number).imageName = trainingSet.image(nFile).name;
                    case 'C'
                        trainingSet.classC.number = trainingSet.classC.number+1;
                        trainingSet.classC.signal(trainingSet.classC.number).boundingBox = boundingBox;
                        trainingSet.classC.signal(trainingSet.classC.number).imageName = trainingSet.image(nFile).name;                        
                    case 'D'
                        trainingSet.classD.number = trainingSet.classD.number+1;
                        trainingSet.classD.signal(trainingSet.classD.number).boundingBox = boundingBox;
                        trainingSet.classD.signal(trainingSet.classD.number).imageName = trainingSet.image(nFile).name;                        
                    case 'E'
                        trainingSet.classE.number = trainingSet.classE.number+1;
                        trainingSet.classE.signal(trainingSet.classE.number).boundingBox = boundingBox;
                        trainingSet.classE.signal(trainingSet.classE.number).imageName = trainingSet.image(nFile).name;
                    case 'F'
                        trainingSet.classF.number = trainingSet.classF.number+1;
                        trainingSet.classF.signal(trainingSet.classF.number).boundingBox = boundingBox;
                        trainingSet.classF.signal(trainingSet.classF.number).imageName = trainingSet.image(nFile).name;                       
                end
            end
        end
        fclose(fid);
    end
end
%function to split in folders the train and validation dataset
function task2(GlobalPath,pathTrain)
    global trainingSet;
    splitFactor = 0.3; %split factor for test
    %create folders and subfolders
    pathTrainSplit = [GlobalPath 'splitDataset\train\'];
    pathTrainSplitGt = [pathTrainSplit 'gt\'];
    pathTrainSplitMask = [pathTrainSplit 'mask\'];
    %Create folders if not exist
    if (exist(pathTrainSplit,'dir') == 0)
        mkdir(pathTrainSplit);
        if (exist(pathTrainSplitGt,'dir') == 0)
            mkdir(pathTrainSplitGt);
        end
        if (exist(pathTrainSplitMask,'dir') == 0)
            mkdir(pathTrainSplitMask);
        end
    end
    pathTestSplit = [GlobalPath 'splitDataset\test\'];
    pathTestSplitGt = [pathTestSplit 'gt\'];
    pathTestSplitMask = [pathTestSplit 'mask\'];
    if (exist(pathTestSplit,'dir') == 0)
        mkdir(pathTestSplit);
        if (exist(pathTestSplitGt,'dir') == 0)
            mkdir(pathTestSplitGt);
        end
        if (exist(pathTestSplitMask,'dir') == 0)
            mkdir(pathTestSplitMask);
        end
    end
    %calculate number of images to a certain split factor
    keySet =   {'A', 'B', 'C', 'D', 'E', 'F'};
    classAtest = round(splitFactor*trainingSet.classA.number);
    classBtest = round(splitFactor*trainingSet.classB.number);
    classCtest = round(splitFactor*trainingSet.classC.number);
    classDtest = round(splitFactor*trainingSet.classD.number);
    classEtest = round(splitFactor*trainingSet.classE.number);
    classFtest = round(splitFactor*trainingSet.classF.number);
    valueSet = [classAtest,classBtest,classCtest,classDtest,classEtest,classFtest];
    mapObj = containers.Map(keySet,valueSet); %container working as a dictionary
    %For every image the split dataset its progressively filled until the
    %number of images needed for every class is reached
    for nFile=1:trainingSet.samples
        validate = 1;
        newValueSet = cell2mat(values(mapObj));
        auxMapObj = containers.Map(keySet,newValueSet); %auxiliar container for update after checking
        for nSignal=1:trainingSet.image(nFile).numSignals
            %checking for every signal in a image determinate if adding this image
            %the number images frecuencies for every class will be correct
            classNum = mapObj(trainingSet.image(nFile).signal(nSignal).class);
            if (classNum - 1 == 0)
                validate = 0; 
            end
            auxMapObj(trainingSet.image(nFile).signal(nSignal).class) = classNum - 1;
        end
        %Copy training files in the new split validation or train folders
        if (validate)
            newValueSet = cell2mat(values(auxMapObj));
            mapObj = containers.Map(keySet,newValueSet);
            copyfile([pathTrain trainingSet.image(nFile).name '.jpg'],pathTestSplit);
            copyfile([pathTrain 'gt\gt.' trainingSet.image(nFile).name '.txt'],pathTestSplitGt);
            copyfile([pathTrain 'mask\mask.' trainingSet.image(nFile).name '.png'],pathTestSplitMask);
        else
            copyfile([pathTrain trainingSet.image(nFile).name '.jpg'],pathTrainSplit);
            copyfile([pathTrain 'gt\gt.' trainingSet.image(nFile).name '.txt'],pathTrainSplitGt);
            copyfile([pathTrain 'mask\mask.' trainingSet.image(nFile).name '.png'],pathTrainSplitMask);
        end
    end
end
%function to generate the models fro every class
function task3(GlobalPath,pathTrain,colorSpace,model)
    global trainingSet;
    subtrainPath = [GlobalPath '/train/']; 
    %Signal class analysis to obtain colour values for masks depending the
    %colour space used
    for signal=1:trainingSet.classA.number
        fileName = trainingSet.classA.signal(signal).imageName;
        boundingBox = trainingSet.classA.signal(signal).boundingBox;
        values = CalculateValuesFromColorSpace(subtrainPath,colorSpace,fileName,boundingBox);
        trainingSet.classA.signal(signal).values = values;
    end
    arraysamples = [trainingSet.classA.signal.values];    
    trainingSet.classA.model=CalculateModel(arraysamples,model,2);
    
    for signal=1:trainingSet.classB.number
        fileName = trainingSet.classB.signal(signal).imageName;
        boundingBox = trainingSet.classB.signal(signal).boundingBox;
        values = CalculateValuesFromColorSpace(subtrainPath,colorSpace,fileName,boundingBox);
        trainingSet.classB.signal(signal).values = values;
    end
    arraysamples=[trainingSet.classB.signal.values];
    trainingSet.classB.model=CalculateModel(arraysamples,model,2);
    
    for signal=1:trainingSet.classC.number
        fileName = trainingSet.classC.signal(signal).imageName;
        boundingBox = trainingSet.classC.signal(signal).boundingBox;
        values = CalculateValuesFromColorSpace(subtrainPath,colorSpace,fileName,boundingBox);
        trainingSet.classC.signal(signal).values = values;
    end
    arraysamples=[trainingSet.classC.signal.values];
    trainingSet.classC.model=CalculateModel(arraysamples,model,2);
    
    for signal=1:trainingSet.classD.number
        fileName = trainingSet.classD.signal(signal).imageName;
        boundingBox = trainingSet.classD.signal(signal).boundingBox;
        values = CalculateValuesFromColorSpace(subtrainPath,colorSpace,fileName,boundingBox);
        trainingSet.classD.signal(signal).values = values;
    end
    arraysamples=[trainingSet.classD.signal.values];
    trainingSet.classD.model=CalculateModel(arraysamples,model,2);
    
    for signal=1:trainingSet.classE.number
        fileName = trainingSet.classE.signal(signal).imageName;
        boundingBox = trainingSet.classE.signal(signal).boundingBox;
        values = CalculateValuesFromColorSpace(subtrainPath,colorSpace,fileName,boundingBox);
        trainingSet.classE.signal(signal).values = values;
    end
    arraysamples=[trainingSet.classE.signal.values];
    trainingSet.classE.model=CalculateModel(arraysamples,model,2);
    
    for signal=1:trainingSet.classF.number
        fileName = trainingSet.classF.signal(signal).imageName;
        boundingBox = trainingSet.classF.signal(signal).boundingBox;
        values = CalculateValuesFromColorSpace(subtrainPath,colorSpace,fileName,boundingBox);
        trainingSet.classF.signal(signal).values = values;
    end
    arraysamples=[trainingSet.classF.signal.values];
    trainingSet.classF.model=CalculateModel(arraysamples,model,2);
end
%depending of the model we use diferents method to generate the information
function genmodel=CalculateModel(sample,model,dim)
    switch (model)
        case 'kmeans' % compute the kmeans with dim number of clusters
            sample = vec2mat(sample,3);
            [points,genmodel] = kmeans(sample,dim);
        case '3Dhist' %compute a kind of histogram from RGB space and a tolerance range for simplify          
            global lengthRGB;
            sample = vec2mat(sample,3);
            histogram = [sample(1,1) sample(1,2) sample(1,3) 1];
            for pixel=2:length(sample(:,1))
                row = find(histogram(:,1) <  sample(pixel,1)+lengthRGB & histogram(:,1) >  sample(pixel,1)-lengthRGB);
                if isempty(row)
                    histogram = [histogram; sample(pixel,1) sample(pixel,2) sample(pixel,3) 1];
                else
                    for i=1:length(row)
                        addPixel = 1;
                        if (histogram(row(i),2) < sample(pixel,2)+lengthRGB && histogram(row(i),2) > sample(pixel,2)-lengthRGB...
                            && histogram(row(i),3) < sample(pixel,3)+lengthRGB && histogram(row(i),3) > sample(pixel,3)-lengthRGB)    
                            histogram(row(i),4) = histogram(row(i),4)+1;
                            addPixel = 0;
                            break                          
                        end
                    end
                    if (addPixel)
                        histogram = [histogram; sample(pixel,1) sample(pixel,2) sample(pixel,3) 1];
                    end
                end
            end
            histogram = sortrows(histogram,-4);
            genmodel = histogram(1:20,:);
        case 'gaussian' %fit a gaussian mixture with dim number of gaussians
            sample = vec2mat(sample,3);
            genmodel = gmdistribution.fit(sample,dim);
        case 'gaussian_HSV' % the same as the previous one but for the two relevant dimensions of the HSV spaces
            sample = vec2mat(sample,2);
            genmodel = gmdistribution.fit(sample,dim);
        otherwise
            genmodel= [];
    end
end
%giveng a colorspaces we select our interesting points in the mask
function values = CalculateValuesFromColorSpace(path,colorSpace,fileName,boundingBox)
    maskImage = logical(imread([path 'mask/mask.' fileName '.png']));
    colorImage = imread([path fileName '.jpg']);
    
    switch (colorSpace)
        case 'RGB_imadjust'
            colorImage(:,:,1)=imadjust(colorImage(:,:,1));
            colorImage(:,:,2)=imadjust(colorImage(:,:,2));
            colorImage(:,:,3)=imadjust(colorImage(:,:,3));
            section(:,:,1)= colorImage(:,:,1) .* uint8(maskImage);
            section(:,:,2)= colorImage(:,:,2) .* uint8(maskImage);
            section(:,:,3)= colorImage(:,:,3) .* uint8(maskImage);
            values = ColorRGB(section, boundingBox(:));
        case 'RGB_histeq'
            colorImage(:,:,1)=histeq(colorImage(:,:,1));
            colorImage(:,:,2)=histeq(colorImage(:,:,2));
            colorImage(:,:,3)=histeq(colorImage(:,:,3));
            section(:,:,1)= colorImage(:,:,1) .* uint8(maskImage);
            section(:,:,2)= colorImage(:,:,2) .* uint8(maskImage);
            section(:,:,3)= colorImage(:,:,3) .* uint8(maskImage);
            values = ColorRGB(section, boundingBox(:));
        case 'RGB'
            section(:,:,1)= colorImage(:,:,1) .* uint8(maskImage);
            section(:,:,2)= colorImage(:,:,2) .* uint8(maskImage);
            section(:,:,3)= colorImage(:,:,3) .* uint8(maskImage);
            values = ColorRGB(section, boundingBox(:));
        case 'Gray'
            %TODO
            section(:,:,1)= colorImage(:,:,1) .* uint8(maskImage);
            section(:,:,2)= colorImage(:,:,2) .* uint8(maskImage);
            section(:,:,3)= colorImage(:,:,3) .* uint8(maskImage);
            values = ColorRGBMinMax(section, boundingBox(:));
        case 'LAB'
            section(:,:,1)= colorImage(:,:,1) .* uint8(maskImage);
            section(:,:,2)= colorImage(:,:,2) .* uint8(maskImage);
            section(:,:,3)= colorImage(:,:,3) .* uint8(maskImage);
            [amean, bmean, avar, bvar]=ColorRatio(section, boundingBox(:)); %color information
            values = [amean bmean avar bvar];
        case 'HSV'
            colorImage= rgb2hsv(colorImage);
            section(:,:,1)= colorImage(:,:,1) .* double(maskImage);
            section(:,:,2)= colorImage(:,:,2) .* double(maskImage);
            section(:,:,3)= colorImage(:,:,3) .* double(maskImage);
            values = ColorHSV(section, boundingBox(:));
    end
end
%function to filter the black points in the resulting image after appling
%the mask to a rgb image and the boundarings
function values = ColorRGB(section, boundingBox)
    values=[];
    cropimage = imcrop(section,boundingBox);
    for counti=1:size(cropimage,1)
        for countj=1:size(cropimage,2)
            if (cropimage(counti,countj,1)>1 && cropimage(counti,countj,2)>1 && cropimage(counti,countj,3)>1)
                values=[values [double(cropimage(counti,countj,1)) double(cropimage(counti,countj,2)) double(cropimage(counti,countj,3))]];
            end
        end
    end  
end
%function to filter the black points in the resulting image after appling
%the mask to a hsv image and the boundarings
function values = ColorHSV(section, boundingBox)
    values=[];
    cropimage = imcrop(section,boundingBox);
    for counti=1:size(cropimage,1)
        for countj=1:size(cropimage,2)
            if (cropimage(counti,countj,1)>0 || cropimage(counti,countj,2)>0) %values with some significace diferents to brightness
                values=[values [double(cropimage(counti,countj,1)) double(cropimage(counti,countj,2))]];%only take these values the other one is brightness
            end
        end
    end  
end
%function to filter the black points in the resulting image after appling
%the mask to a hsv image and the boundarings, searching for the min max
function values = ColorRGBMinMax(section, boundingBox)
    crop = imcrop(section,boundingBox);
    red = crop(:,:,1);
    green = crop(:,:,2);
    blue = crop(:,:,3);
    values = [min(min(red(red>0))) max(max(red))]; %min max red component
    values = [values min(min(green(green>0))) max(max(green))]; %min max green component
    values = [values min(min(blue(blue>0))) max(max(blue))]; %min max blue component
end

function [amean,bmean, avar, bvar] = ColorRatio(section, boundingBox)

    %Paso a CIE Lab
    Labver= rgb2lab(section);
              
    %Crop image with bounding box
    sectioncrop = imcrop(Labver,boundingBox);
    
    %Get amean, bmean, and respectives spread for signal tracking  
    a= sectioncrop(:,:,2);
    b= sectioncrop(:,:,3);
    
    amean = mean(mean(a));
    bmean = mean(mean(b));
    
    avar= mad(mad(a));
    bvar= mad(mad(b));
    
end
%evaluate the genrated model with a validation test
function evalmodel(directory,trainingset,model,colorSpace)
     pixelTP=0; pixelFN=0; pixelFP=0; pixelTN=0;
     timemean=0;
    files = ListFiles(directory);
    if (exist(strcat(directory, '/mask/'),'dir') == 0)
        mkdir(strcat(directory, '/mask/'));
    end
    for i=1:size(files,1),
        tic;
        % Read file
        im = imread(strcat(directory,'/',files(i).name));
     
        % Candidate Generation (pixel) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pixelCandidates = CandidateGenerationPixel_Color(im, trainingset,model,colorSpace);

        imwrite(pixelCandidates,strcat(directory, '/mask/mask.', files(i).name(1:size(files(i).name,2)-3), 'png'));
        % Candidate Generation (window)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % windowCandidates = CandidateGenerationWindow_Example(im, pixelCandidates, window_method); %%'SegmentationCCL' or 'SlidingWindow'  (Needed after Week 3)
        
        % Accumulate pixel performance of the current image %%%%%%%%%%%%%%%%%
%         pixelAnnotation = imread(strcat(directory, '/mask/mask.', files(i).name(1:size(files(i).name,2)-3), 'png'))>0;
%         [localPixelTP, localPixelFP, localPixelFN, localPixelTN] = PerformanceAccumulationPixel(pixelCandidates, pixelAnnotation);
%         pixelTP = pixelTP + localPixelTP;
%         pixelFP = pixelFP + localPixelFP;
%         pixelFN = pixelFN + localPixelFN;
%         pixelTN = pixelTN + localPixelTN;
%         timemean=toc;
    end
    
%     timemean=timemean/size(files,1);
%     fid = fopen('results.txt','a');
%     % Plot performance evaluation
%     F1measure=2*pixelTP/(2*pixelTP+pixelFP+pixelFN);
%     [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity] = PerformanceEvaluationPixel(pixelTP, pixelFP, pixelFN, pixelTN);
%     [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity]
%     %required information to do the studying of the differents methods
%     fprintf(fid,'The result for model %s and space %s: [pixelPrecision = %f, pixelAccuracy = %f, pixelSpecificity = %f, pixelSensitivity = %f, elapse time = %f, f1 = %f, TP = %d FP = %d, FN = %d] \n',model,colorSpace,pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity,timemean,F1measure,pixelTP,pixelFP,pixelFN);
%     fclose(fid);
end

%make the necessary transform to the validation image to aplied the model
function [pixelCandidates] = CandidateGenerationPixel_Color(im, trainingset,model,colorSpace)

    im=double(im);

    switch colorSpace
        case 'RGB_histeq' %applied the histogram equalitation to all the channels
            im(:,:,1)=histeq(im(:,:,1));
            im(:,:,2)=histeq(im(:,:,2));
            im(:,:,3)=histeq(im(:,:,3));
            pixelCandidates = CandidateGenerationPixel_Model(im, trainingset,model);
        case 'RGB_imadjust'%applied the transform to all the channels, in this method the supotition is that only 1% of the image have the maximun vaule and minmun
            im(:,:,1)=imadjust(im(:,:,1));
            im(:,:,2)=imadjust(im(:,:,2));
            im(:,:,3)=imadjust(im(:,:,3));
            pixelCandidates = CandidateGenerationPixel_Model(im, trainingset,model);
        case 'RGB'
            pixelCandidates = CandidateGenerationPixel_Model(im, trainingset,model);
            
        case 'HSV' %transform to the hsv spaces an take the relevants channels (Hue and Saturation)
             im= rgb2hsv(im);
             im=im(:,:,1:2);
             pixelCandidates = CandidateGenerationPixel_Model(im, trainingset,model);
        otherwise
            error('Incorrect color space defined');
            return
    end
end 

%applied the model and some condition to get the pixels which are considere
%traffic signals
function [pixelCandidates] = CandidateGenerationPixel_Model(im, trainingset,evaluation)
    pixelCandidates=zeros(size(im,1),size(im,2));
     switch evaluation
        case 'centroidDistance' %distance of every pixel to a centroid of the kmeans if one pixel is less than 20 units of the centroid we considered it has a signal 
            fields = fieldnames(trainingset);
            for countfieldsi = 1:numel(fields)
                if ~isempty(strfind(fields{countfieldsi},'class'))
                    for countclusters =1:size(trainingset.(fields{countfieldsi}).model,1)
                        for counti=1:size(im,1)
                            for countj=1:size(im,2)
                                if(norm([im(counti,countj,1) im(counti,countj,2) im(counti,countj,3)]-trainingset.(fields{countfieldsi}).model(countclusters,:))<20)
                                    pixelCandidates(counti,countj)=1;
                                end
                            end
                        end
                    end
                end
            end
          case 'Threshold' %Threshold using the diferent values obtained from the frequencies of RGB
            global lengthRGB;
            fields = fieldnames(trainingset);
            for class = 1:numel(fields)
                if ~isempty(strfind(fields{class},'class'))
                    for row =1:3 % using the first 3 row values of every model array
                       mask = im(:,:,1)<trainingset.(fields{class}).model(row,1) + lengthRGB &...
                              im(:,:,1)>trainingset.(fields{class}).model(row,1) - lengthRGB &...
                              im(:,:,2)<trainingset.(fields{class}).model(row,2) + lengthRGB &...
                              im(:,:,2)>trainingset.(fields{class}).model(row,2) - lengthRGB &...
                              im(:,:,3)<trainingset.(fields{class}).model(row,3) + lengthRGB &...
                              im(:,:,3)>trainingset.(fields{class}).model(row,3) - lengthRGB;
                       pixelCandidates = pixelCandidates | mask;
                    end
                end
            end
         case 'hand' % a hand estimation of all the posible colors
             red=im(:,:,1)>170&im(:,:,2)<40&im(:,:,3)<40;
             blue=im(:,:,1)<40&im(:,:,2)<40&im(:,:,3)>170;
             white=im(:,:,1)>170&im(:,:,2)>170&im(:,:,3)>170;
             pixelCandidates=red+white+blue;
         case 'gaussian_mixture'  % applied the  gaussian mixture model and get the points that are with a probability of more than the 75% of the maximus probability
            fields = fieldnames(trainingset);
            for countfieldsi = 1:numel(fields)
                if ~isempty(strfind(fields{countfieldsi},'class'))                   
                    ImgVector = reshape(im,size(im,1)*size(im,2), size(im,3));
                    imres=zeros(size(ImgVector,1),1);
                    y = pdf(trainingset.(fields{countfieldsi}).model,ImgVector);
                    imres(find(y>max(y)*0.75))=1;
                    im_restaurada=reshape(imres,size(im,1),size(im,2),1);
                    pixelCandidates=pixelCandidates+im_restaurada;
                end
            end
     end
   
end