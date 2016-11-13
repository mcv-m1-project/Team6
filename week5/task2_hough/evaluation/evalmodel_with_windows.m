%evaluate the genrated model with a validation test
function evalmodel_with_windows(directory,pathTest)
    
    maskResultsPath = [pathTest 'mask_result/'];
    maskPath = [pathTest 'mask/'];
    gtResultPath = [pathTest 'gt_result/'];
    gtPath = [pathTest 'gt/'];
    windowTP=0; windowFN=0; windowFP=0; % (Needed after Week 3)
    pixelTP=0; pixelFN=0; pixelFP=0; pixelTN=0;
    timemean=0;

    files = ListFiles(pathTest);
    'Starting test'
    for i=1:size(files,1),
        disp([num2str(i),' of ', num2str(size(files,1))])
        tic;
        % Read file
        pixelCandidates = imread(strcat(maskResultsPath,'mask.',files(i).name(1:size(files(i).name,2)-3), 'png'))>0;
        gt_annotation = load(strcat(gtResultPath, 'gt.', files(i).name(1:size(files(i).name,2)-3), 'mat'));
        windowCandidates = gt_annotation.windowCandidates;
        if isempty(windowCandidates)
            windowCandidates = [];
        end
        % Accumulate pixel performance of the current image %%%%%%%%%%%%%%%%%
         pixelAnnotation = imread(strcat(maskPath, '/mask.', files(i).name(1:size(files(i).name,2)-3), 'png'))>0;
         [localPixelTP, localPixelFP, localPixelFN, localPixelTN] = PerformanceAccumulationPixel(pixelCandidates, pixelAnnotation);
         pixelTP = pixelTP + localPixelTP;
         pixelFP = pixelFP + localPixelFP;
         pixelFN = pixelFN + localPixelFN;
         pixelTN = pixelTN + localPixelTN;
         
        %Accumulate object performance of the current image %%%%%%%%%%%%%%%%  (Needed after Week 3)
        windowAnnotations = LoadAnnotations(strcat(gtPath, 'gt.', files(i).name(1:size(files(i).name,2)-3), 'txt'));
        [localWindowTP, localWindowFN, localWindowFP] = PerformanceAccumulationWindow(windowCandidates, windowAnnotations);
        windowTP = windowTP + localWindowTP;
        windowFN = windowFN + localWindowFN;
        windowFP = windowFP + localWindowFP;
        timemean=timemean+toc;
    end
    
     timemean=timemean/size(files,1);
     fid = fopen('results_w3.txt','a');
     % Plot performance evaluation
     
     [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity] = PerformanceEvaluationPixel(pixelTP, pixelFP, pixelFN, pixelTN);
     F1measure=2*(pixelPrecision*pixelSensitivity)/(pixelPrecision+pixelSensitivity);
     sprintf('The result pixel: [f1 = %f,pixelPrecision = %f, pixelAccuracy = %f, pixelSpecificity = %f, pixelSensitivity = %f, elapse time = %f,  TP = %d FP = %d, FN = %d] \n',F1measure,pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity,timemean,pixelTP,pixelFP,pixelFN)
     fprintf(fid,'The result pixel: [f1 = %f,pixelPrecision = %f, pixelAccuracy = %f, pixelSpecificity = %f, pixelSensitivity = %f, elapse time = %f, TP = %d FP = %d, FN = %d] \n',F1measure,pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity,timemean,pixelTP,pixelFP,pixelFN);
     
     
     [windowPrecision, windowAccuracy] = PerformanceEvaluationWindow(windowTP, windowFN, windowFP); % (Needed after Week 3)
     windowRecall=windowTP/(windowTP+windowFN);
     windowf1=2*(windowPrecision*windowRecall)/(windowPrecision+windowRecall);
     sprintf('The result window: [f1 = %f,windowPrecision = %f, windowAccuracy = %f,  windowRecall = %f, elapse time = %f,  TP = %d FP = %d, FN = %d] \n',windowf1,windowPrecision, windowAccuracy, windowRecall,timemean,windowTP,windowFP,windowFN)
     fprintf(fid,'The result window: [f1 = %f,windowPrecision = %f, windowAccuracy = %f,  windowRecall = %f, elapse time = %f, TP = %d FP = %d, FN = %d] \n',windowf1,windowPrecision, windowAccuracy, windowRecall,timemean,windowTP,windowFP,windowFN);
     
    fclose(fid);
end
