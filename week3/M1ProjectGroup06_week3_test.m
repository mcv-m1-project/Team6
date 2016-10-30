function week3()
    %Paths   
    GlobalPath = './';
    pathTrain = [ GlobalPath 'train\'];
    pathMasks = [GlobalPath 'mask_result\'];
    pathresult_gt= [GlobalPath 'gt_result\'];
    if (exist( pathresult_gt,'dir') == 0)
        mkdir( pathresult_gt,'s');
    end
    pathMasksAnnotation = [pathTrain 'mask\'];
    pathAnnotation = [pathTrain 'gt/'];
    masks = dir([pathMasks '*.png']); %read images path
    type_window='window_integral';%window_sum, window_integral, convolution
    windowSet=split_by_shape(GlobalPath,pathTrain);
    
    windowTP=0; windowFN=0; windowFP=0; % (Needed after Week 3)
    pixelTP=0; pixelFN=0; pixelFP=0; pixelTN=0;
    timemean=0;
    
    for nFile=1:length(masks)
        tic;
        fileName = strsplit(masks(nFile).name,'.'); % split string with '.'
        txt_name=['gt' '.' fileName{2} '.' fileName{3} '.'];
        fileName = [fileName{1} '.' fileName{2} '.' fileName{3}];   %Select part that is the name
        binMask = logical(imread([pathMasks fileName '.png']));
        windowCandidates=task1(binMask,GlobalPath,fileName,windowSet);
        %windowCandidates=task2and3(binMask,GlobalPath,fileName,type_window,windowSet);
        
%         % Accumulate pixel performance of the current image %%%%%%%%%%%%%%%%%
%          pixelAnnotation = imread([pathMasksAnnotation fileName '.png'])>0;
%          [localPixelTP, localPixelFP, localPixelFN, localPixelTN] = PerformanceAccumulationPixel(binMask, pixelAnnotation);
%          pixelTP = pixelTP + localPixelTP;
%          pixelFP = pixelFP + localPixelFP;
%          pixelFN = pixelFN + localPixelFN;
%          pixelTN = pixelTN + localPixelTN;
%          
%         %Accumulate object performance of the current image %%%%%%%%%%%%%%%%  (Needed after Week 3)
%         windowAnnotations = LoadAnnotations(strcat([pathAnnotation txt_name], 'txt'));
%         [localWindowTP, localWindowFN, localWindowFP] = PerformanceAccumulationWindow(windowCandidates, windowAnnotations);
%         windowTP = windowTP + localWindowTP;
%         windowFN = windowFN + localWindowFN;
%         windowFP = windowFP + localWindowFP;
        filename_gt_result=[pathresult_gt txt_name 'mat'];
        if(isempty(windowCandidates))
            save(filename_gt_result)
        else
            save(filename_gt_result,'windowCandidates');
        end
%         timemean=toc;
    end  
        
%      timemean=timemean/size(masks,1);
%      fid = fopen('results_w3.txt','a');
%      % Plot performance evaluation
%      
%      [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity] = PerformanceEvaluationPixel(pixelTP, pixelFP, pixelFN, pixelTN);
%      F1measure=2*(pixelPrecision*pixelSensitivity)/(pixelPrecision+pixelSensitivity);
%      sprintf('The result pixel: [f1 = %f,pixelPrecision = %f, pixelAccuracy = %f, pixelSpecificity = %f, pixelSensitivity = %f, elapse time = %f,  TP = %d FP = %d, FN = %d] \n',F1measure,pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity,timemean,pixelTP,pixelFP,pixelFN)
%      fprintf(fid,'The result pixel: [f1 = %f,pixelPrecision = %f, pixelAccuracy = %f, pixelSpecificity = %f, pixelSensitivity = %f, elapse time = %f, TP = %d FP = %d, FN = %d] \n',F1measure,pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity,timemean,pixelTP,pixelFP,pixelFN);
%         
%      [windowPrecision, windowAccuracy] = PerformanceEvaluationWindow(windowTP, windowFN, windowFP); % (Needed after Week 3)
%      windowRecall=windowTP/windowTP+windowFP;
%      windowf1=2*(windowPrecision*windowRecall)/(windowPrecision+windowRecall);
%      sprintf('The result window: [f1 = %f,windowPrecision = %f, pixelAccuracy = %f,  windowRecall = %f, elapse time = %f,  TP = %d FP = %d, FN = %d] \n',windowf1,windowPrecision, windowAccuracy, windowRecall,timemean,windowTP,windowFP,windowFN)
%      fprintf(fid,'The result window: [f1 = %f,windowPrecision = %f, windowAccuracy = %f,  windowRecall = %f, elapse time = %f, TP = %d FP = %d, FN = %d] \n',windowf1,windowPrecision, windowAccuracy, windowRecall,timemean,windowTP,windowFP,windowFN);
%      
%     fclose(fid);
end

%function load the diferents datasets
function windowCandidates=task1(binMask,GlobalPath,fileName,windowSet)
    [conec, Ne] = bwlabel(binMask); %Apply a label identification on the binary image
    possibleSignals = regionprops(conec);   %Analize regions on the image (calculate center and region box)
    fields = fieldnames(windowSet);
    windowCandidates = [];
    h = figure;
    h.Visible = 'off';
    imshow(binMask);
    minLabelArea = 29*29;
    for i=1:Ne
        if possibleSignals(i).Area > minLabelArea
            for class_image = 1:numel(fields)
                if ~isempty(strfind(fields{class_image},'class'))
                    maxfill = windowSet.(fields{class_image}).manualAdj;
                    minfill = windowSet.(fields{class_image}).minfillingRatio;
                    maxAspect = windowSet.(fields{class_image}).maxaspectRatio;
                    minAspect = windowSet.(fields{class_image}).minaspectRatio;
                    rect = floor(possibleSignals(i).BoundingBox); %calculate box for crop the object
                    rect(3) = rect(3)+1;
                    rect(4) = rect(4)+1;
                    aspectRatio = rect(3)/rect(4);
                    maxfill = maxfill*rect(3)*rect(4);
                    minfill = minfill*rect(3)*rect(4); 
                    if(possibleSignals(i).Area < maxfill+1 && possibleSignals(i).Area > minfill-1 ...
                            && aspectRatio > minAspect && aspectRatio < maxAspect)
                        Bounding = [round(rect(1))-1 round(rect(2))-1 rect(3) rect(4)];
                        rectangle('Position',Bounding,'edgecolor','y');
                        element= struct('x',double(Bounding(1)),'y',double(Bounding(2)),'w',double(Bounding(3)),...
                        'h',double(Bounding(4)),'pixels',possibleSignals(i).Area);
                        windowCandidates = [windowCandidates;element];
                    end
                end
            end
        end
    end
    if(size(windowCandidates,1)>1)
        windowCandidates=eliminated_repeated(windowCandidates,binMask); % se elimina las areas que se sobre ponen
    end
    saveas(h,[GlobalPath 'results/' fileName '.png']);
    close(h);
end

%function to split in folders the train and validation dataset
function windowCandidates=task2and3(binMask,GlobalPath,fileName,type_window,windowSet)
    windowCandidates=select_regions_candidats(binMask,windowSet,type_window);
%     h = figure;
%     h.Visible = 'on';
%     imshow(binMask);
%     for i=1:size(windowCandidates,1)
%         xBox = windowCandidates(i,:).x;
%         yBox = windowCandidates(i,:).y;
%         wBox = windowCandidates(i,:).w;
%         hBox = windowCandidates(i,:).h;
%         rectangle('Position',[xBox yBox wBox hBox],'edgecolor','y');
%     end
%     saveas(h,[GlobalPath 'results/' fileName '.png']);
%     close(h);
end

function task5(binMask,GlobalPath,fileName,type_window,windowSet)
    %obtain the maximum size side of the signal for all the class signals for create a initial
    %filter with this size
    fields = fieldnames(windowSet);
    maxW = [];
    minW = [];
    for class_image = 1:numel(fields)
        if ~isempty(strfind(fields{class_image},'class'))
            maxW=[maxW windowSet.(fields{class_image}).maxwidth windowSet.(fields{class_image}).maxheight];
            minW=[minW; windowSet.(fields{class_image}).minwidth windowSet.(fields{class_image}).minheight];
        end
    end
    maxW=round(max(maxW));
    minW=round(max(min(minW))); %choose the largest side of the smallest signal
    %Increase size to an odd number for a proper convolution in the center
    if (mod(maxW,2) == 0)
        maxW = maxW+1;
    end
    if (mod(minW,2) == 0)
        minW = minW+1;
    end
    winSize = [maxW, maxW];
    iters = 20;
    winSizeDec = (maxW-minW)/iters;
    possibleBounding = [];
    for i=1:iters+1
        filterWindow = ones(winSize(1),winSize(2));
        pixelsWindow = winSize(1)*winSize(2);
        centerWindow = ceil(size(filterWindow,1)/2);
        correlation = conv2(single(binMask),filterWindow);
        correlation = correlation(centerWindow:end-(centerWindow-1),centerWindow:end-(centerWindow-1));
        for class_image = 1:numel(fields)
            if ~isempty(strfind(fields{class_image},'class'))
                maxfill = windowSet.(fields{class_image}).meanfillingRatio+windowSet.(fields{class_image}).stdfillingRatio;
                maxfill = ceil(maxfill*pixelsWindow);
                minfill = windowSet.(fields{class_image}).meanfillingRatio-windowSet.(fields{class_image}).stdfillingRatio;
                minfill = ceil(minfill*pixelsWindow);
                [row,col] = find(correlation>minfill & correlation<maxfill);
                for j=1:length(row)                   
                    if (row(i) > 0 && col(i) >0)
                        box = [col(j)-centerWindow+1 row(j)-centerWindow+1 winSize(1) winSize(2) correlation(row(j),col(j))];
                        element= struct('x',double(box(1)),'y',double(box(2)),'w',double(box(3)),'h', ...
                        double(box(4)),'pixels',box(5));
                        possibleBounding = [possibleBounding;element];
                    end
                end
            end
        end
        winSize = round(winSize-winSizeDec);
        if (mod(winSize(1),2) == 0)
            winSize(1) = winSize(1)+1;
        end
        if (mod(winSize(2),2) == 0)
            winSize(2) = winSize(2)+1;
        end
    end
    if(size(possibleBounding,1)>1)
        windowCandidates=eliminated_repeated(possibleBounding,binMask); % se elimina las areas que se sobre ponen
        h = figure;
        h.Visible = 'on';
        imshow(binMask);
        for i=1:size(windowCandidates,1)
            xBox = windowCandidates(i,:).x;
            yBox = windowCandidates(i,:).y;
            wBox = windowCandidates(i,:).h;
            hBox = windowCandidates(i,:).w;
            rectangle('Position',[xBox yBox wBox hBox],'edgecolor','y');
        end
        saveas(h,[GlobalPath 'results/' fileName '.png']);
        close(h);
    end
end
