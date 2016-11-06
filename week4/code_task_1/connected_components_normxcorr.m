%function load the diferents datasets
function windowCandidates=connected_components_normxcorr(binMask,GlobalPath,fileName,windowSet)
    [conec, Ne] = bwlabel(binMask); %Apply a label identification on the binary image
    possibleSignals = regionprops(conec);   %Analize regions on the image (calculate center and region box)
    fields = fieldnames(windowSet);
    windowCandidates = [];
    h = figure;
    h.Visible = 'off';
    imshow(binMask);
    steps = 20;
    minLabelArea = 29*29;
    im = imread([GlobalPath fileName '.jpg']);
    for i=1:Ne
        if possibleSignals(i).Area > minLabelArea
            for class_image = 1:numel(fields)
                if ~isempty(strfind(fields{class_image},'class'))
                    %Shape Model didn't apply to class F 
                    if (strfind(fields{class_image},'classF'))
                        maxfill = 1;
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
                            if (Bounding(1) < 1)
                                Bounding(1) = 1; 
                            end
                            if (Bounding(2) < 1)
                                Bounding(2) = 1;
                            end
                            element= struct('x',double(Bounding(1)),'y',double(Bounding(2)),'w',double(Bounding(3)),...
                            'h',double(Bounding(4)),'pixels',possibleSignals(i).Area);
                            windowCandidates = [windowCandidates;element];                
                            rectangle('Position',Bounding,'edgecolor','y');
                        end
                    %every other class signal
                    else
                        meanIm = windowSet.(fields{class_image}).meanImage;
                        minWidth = windowSet.(fields{class_image}).minwidth;
                        rect = floor(possibleSignals(i).BoundingBox); %calculate box for crop the object
                        rect(3) = rect(3)+1; %width
                        rect(4) = rect(4)+1; %height
                        widthDiff = rect(3)-minWidth;
                        widthDec = widthDiff/steps;
                        actualWidth = rect(3);

                        imageSegment = imcrop(im,rect);
                        maskSegment = imcrop(binMask,rect);
                        imageSegment = rgb2gray(imageSegment);
                        imageSegment = single(imageSegment).*single(maskSegment);

                        for j=1:steps+1
                            resizeFactor = actualWidth/size(meanIm,2);
                            meanSegment = imresize(meanIm,resizeFactor);
                            szMeanSeg = size(meanSegment);
                            halfSzMeanSeg = round(size(meanSegment)/2);
                            if (szMeanSeg(1) <= size(imageSegment,1) && szMeanSeg(2) <= size(imageSegment,2))
                                correlation = normxcorr2(meanSegment,imageSegment);
                                szMean = round(size(meanSegment));
                                correlation_resized = correlation(szMean(1):end-szMean(1),szMean(2):end-szMean(2));
                                correlation = correlation(halfSzMeanSeg(1):end-halfSzMeanSeg(1),halfSzMeanSeg(2):end-halfSzMeanSeg(2));
                                maxCorr = max(max(correlation_resized));
                                if(maxCorr >= windowSet.(fields{class_image}).minCorrelation)
                                    [row, col] = find(correlation == maxCorr,1);
                                    Bounding = [rect(1)+col-halfSzMeanSeg(1) rect(2)+row-halfSzMeanSeg(2) szMeanSeg(1) szMeanSeg(2)];
                                    if (Bounding(1) < 1)
                                        Bounding(1) = 1; 
                                    end
                                    if (Bounding(2) < 1)
                                        Bounding(2) = 1;
                                    end
                                    element= struct('x',double(Bounding(1)),'y',double(Bounding(2)),'w',double(Bounding(3)),...
                                    'h',double(Bounding(4)),'pixels',possibleSignals(i).Area);
                                    windowCandidates = [windowCandidates;element];                
                                    rectangle('Position',Bounding,'edgecolor','y');
                                    break;
                                end
                            end
                            actualWidth = round(rect(3)-widthDec*j);
                        end
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