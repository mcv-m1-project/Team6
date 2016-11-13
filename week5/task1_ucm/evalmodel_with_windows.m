%evaluate the genrated model with a validation test
function evalmodel_with_windows(directory,windowSet,trainingset,model,colorSpace)
    

    windowTP=0; windowFN=0; windowFP=0; % (Needed after Week 3)
    pixelTP=0; pixelFN=0; pixelFP=0; pixelTN=0;
    timemean=0;
    
    
    
    files = ListFiles(directory);
    if (exist(strcat(directory, '/mask_result/'),'dir') == 0)
        mkdir(strcat(directory, '/mask_result/'));
    end
    if (exist(strcat(directory, '/gt_result/'),'dir') == 0)
        mkdir(strcat(directory, '/gt_result/'));
    end
    'Starting test'
    for i=1:size(files,1),
        disp([num2str(i),' of ', num2str(size(files,1))])
        tic;
        % Read file
        im = imread(strcat(directory,'/',files(i).name));
     
        color_mask = CandidateGenerationPixel_Color(im, trainingset,model,colorSpace);
        color_mask=morphoprocess(color_mask);
        
        % Candidate Generation (window)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [windowCandidates,pixelCandidates]=select_regions_candidats_ucm(im,color_mask,windowSet);
         % Candidate Generation (pixel) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        imwrite(pixelCandidates,strcat(directory, '/mask_result/mask.', files(i).name(1:size(files(i).name,2)-3), 'png'));
        
        filename_gt_result=strcat(directory, '/gt_result/mask.', files(i).name(1:size(files(i).name,2)-3), 'mat');
        save(filename_gt_result,'windowCandidates');

       
        
        % Accumulate pixel performance of the current image %%%%%%%%%%%%%%%%%
         pixelAnnotation = imread(strcat(directory, '/mask/mask.', files(i).name(1:size(files(i).name,2)-3), 'png'))>0;
         [localPixelTP, localPixelFP, localPixelFN, localPixelTN] = PerformanceAccumulationPixel(pixelCandidates, pixelAnnotation);
         pixelTP = pixelTP + localPixelTP;
         pixelFP = pixelFP + localPixelFP;
         pixelFN = pixelFN + localPixelFN;
         pixelTN = pixelTN + localPixelTN;
         
        %Accumulate object performance of the current image %%%%%%%%%%%%%%%%  (Needed after Week 3)
        windowAnnotations = LoadAnnotations(strcat(directory, '/gt/gt.', files(i).name(1:size(files(i).name,2)-3), 'txt'));
        [localWindowTP, localWindowFN, localWindowFP] = PerformanceAccumulationWindow(windowCandidates, windowAnnotations);
        windowTP = windowTP + localWindowTP;
        windowFN = windowFN + localWindowFN;
        windowFP = windowFP + localWindowFP;
        timemean=timemean+toc;
    end
    
     timemean=timemean/size(files,1);
     fid = fopen('results_w5.txt','a');
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


