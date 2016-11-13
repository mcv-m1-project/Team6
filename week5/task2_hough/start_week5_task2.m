function start_week5()
    global trainingSet;
    GlobalPath = './splitDataset/';
    %method='CCL+Hough';%Types: CCL, CCL+conv, CCL+Hough
    pathTrain = [ GlobalPath 'train\'];
    pathTest = [ GlobalPath 'test\'];
    trainingSet=model_creation(GlobalPath,pathTrain);
    template_matching_shape(pathTrain);
    mask_signal_detection(pathTest);
    evalmodel_with_windows(GlobalPath,pathTest);
end

function template_matching_shape(pathTrain)
    global trainingSet;
    mean_shape(pathTrain);
end

function mean_shape(pathTrain)
    global trainingSet;
    format = '.jpg';
    shapes = [];
    fields = fieldnames(trainingSet);
    for class = 1:numel(fields)
        if ~isempty(strfind(fields{class},'class'))
            base_size = [];
            base_size(1) = round(trainingSet.(fields{class}).meanheight);
            base_size(2) = round(trainingSet.(fields{class}).meanwidth);
            signalImageSet = [];
            for n=1:trainingSet.(fields{class}).number
                imageName = trainingSet.(fields{class}).signal(n).imageName;              
                im = imread([pathTrain imageName format]);
                maskImage = logical(imread([pathTrain 'mask/mask.' imageName '.png']));
                im = imcrop(im,trainingSet.(fields{class}).signal(n).boundingBox);
                maskImage = imcrop(maskImage,trainingSet.(fields{class}).signal(n).boundingBox);
                im = rgb2gray(im);
                im = im.*uint8(maskImage);
                im = imresize(im,base_size);
                signalImageSet(:,:,n) = im;
            end
            meanIm = mean(signalImageSet,3);
            trainingSet.(fields{class}).meanImage = meanIm;
            if (strfind(fields{class},'classF'))
                trainingSet.(fields{class}).minCorrelation = 0.1; %manually correlation for class F
            else
                for n=1:trainingSet.(fields{class}).number
                    trainingSet.(fields{class}).signal(n).correlation = corr2(signalImageSet(:,:,n),meanIm);
                end
                trainingSet.(fields{class}).minCorrelation = min([trainingSet.(fields{class}).signal.correlation]);
            end
        end
    end
end

function mask_signal_detection(GlobalPath)
    global trainingSet;
    masks = [GlobalPath 'masks\'];
    pathMasks = [GlobalPath 'mask_result\'];
    pathresult_gt = [GlobalPath 'gt_result\'];
    pathFigures = [GlobalPath 'results\'];
    if (exist( pathresult_gt,'dir') == 0)
        mkdir( pathresult_gt,'s');
    end
    if (exist( pathMasks,'dir') == 0)
        mkdir( pathMasks,'s');
    end
    if (exist( pathFigures,'dir') == 0)
        mkdir( pathFigures,'s');
    end
    masksFiles = dir([masks '*.png']); %read images path
    timemean=0;
    for nFile=43:length(masksFiles)
        tic;
        disp([num2str(nFile),' of ', num2str(size(masksFiles,1))])
        fileName = strsplit(masksFiles(nFile).name,'.'); % split string with '.'
        txt_name=['gt' '.' fileName{1} '.' fileName{2}];
        fileName = [ fileName{1} '.' fileName{2}];   %Select part that is the name
        binMask = logical(imread([masks fileName '.png']));
        im = imread([GlobalPath fileName '.jpg']);
        windowCandidates=connected_components_hough(binMask,im,GlobalPath,fileName,trainingSet);         
        filename_gt_result=[pathresult_gt txt_name '.mat'];
        if(isempty(windowCandidates))
            imwrite(zeros(size(binMask)),[pathMasks 'mask.' fileName '.png']);
            save(filename_gt_result,'windowCandidates')
        else
            binMask = CandidateGenerationPixel_Color_window(binMask,windowCandidates);
            imwrite(binMask,[pathMasks 'mask.' fileName '.png']);
            save(filename_gt_result,'windowCandidates');
        end
        timemean=timemean+toc;
    end
    timemean=timemean/length(masksFiles)
end