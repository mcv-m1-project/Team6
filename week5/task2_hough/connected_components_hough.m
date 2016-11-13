%function load the diferents datasets
function windowCandidates=connected_components_hough(binMask,im,GlobalPath,fileName,windowSet)
    [conec, Ne] = bwlabel(binMask); %Apply a label identification on the binary image
    possibleSignals = regionprops(conec);   %Analize regions on the image (calculate center and region box)
    fields = fieldnames(windowSet);
    windowCandidates = [];
    h = figure;
    h.Visible = 'off';
    imshow(binMask);
    ContourAdd = 0.2; % % of Window added to a BoundingBox to detect lines around the signal
    minHeight = 29;
    minWidth = 29;
    minLabelArea = minHeight*minWidth;
    im = imread([GlobalPath fileName '.jpg']);
    for i=1:Ne
        if possibleSignals(i).Area > minLabelArea && possibleSignals(i).BoundingBox(3) >= minWidth...
                && possibleSignals(i).BoundingBox(4) >= minHeight
            rect = floor(possibleSignals(i).BoundingBox); %calculate box for crop the object
            rect(1) = 2.*round((rect(1)-(rect(3)*ContourAdd)/2)/2);
            rect(2) = 2.*round((rect(2)-(rect(4)*ContourAdd)/2)/2);
            rect(3) = 1+2.*round(rect(3)*(1+ContourAdd)/2); %width
            rect(4) = 1+2.*round(rect(4)*(1+ContourAdd)/2); %height
            if (rect(1) < 1)
                rect(1) = 2; 
            end
            if (rect(2) < 1)
                rect(2) = 2;
            end
            if (rect(1)+ rect(3) > size(im,2))
                rect(3) = size(im,2)-rect(1)-1; 
            end
            if (rect(2) + rect(4) > size(im,1))
                rect(4) = size(im,1)-rect(2)-1; 
            end
            imageSegment = imcrop(im,rect);
            maskSegment = imcrop(binMask,rect);
            imageSegment = rgb2gray(imageSegment);
            edgesSeg = edge(imageSegment,'Canny',[0 0.2],0.5);
%             figure, imshow(edgesSeg);
            for class_image = 1:numel(fields)
                if ~isempty(strfind(fields{class_image},'class'))
                    aspectRatio = [windowSet.(fields{class_image}).minaspectRatio windowSet.(fields{class_image}).maxaspectRatio];
                    fillRatio = windowSet.(fields{class_image}).minfillingRatio;
                    switch (fields{class_image})
                        case 'classA'
                            newBoxes = NormalTriangularSearch(edgesSeg,rect(1:2),maskSegment);
                        case 'classB'
                            newBoxes = ReverseTriangularSearch(edgesSeg,rect(1:2),maskSegment);
                        case 'classF'                            
                            newBoxes = RectangleSearch(edgesSeg,rect(1:2),maskSegment,aspectRatio);
                        case 'classCDE'
                            radrange = 2.*round([windowSet.(fields{class_image}).minwidth/2-2 max([rect(3) rect(4)])/2]/2);
                            newBoxes = CircularSearch(imageSegment,maskSegment,radrange,rect(1:2));
                    end                    
                    if ~isempty(newBoxes)
                        box = 1;
                        while (box <= length(newBoxes))
                            if ((newBoxes(box).w/newBoxes(box).h > aspectRatio(2) ||...
                                newBoxes(box).w/newBoxes(box).h < aspectRatio(1)) ||...
                                newBoxes(box).pixels/newBoxes(box).area < fillRatio)
                                newBoxes(box) = [];
                            else
                                box = box+1;
                            end
                        end
                        if ~isempty(newBoxes)
                            windowCandidates=[windowCandidates; newBoxes];
                        end
                        break;
                    end
                end
            end
        end
    end
    if(size(windowCandidates,1)>1)
        windowCandidates=eliminated_repeated(windowCandidates); % se elimina las areas que se sobre ponen
    end
    if(size(windowCandidates,1)>0)
        for elem=1:length(windowCandidates)
            Bounding(1) = windowCandidates(elem).x;
            Bounding(2) = windowCandidates(elem).y;
            Bounding(3) = windowCandidates(elem).w;
            Bounding(4) = windowCandidates(elem).h;
            rectangle('Position',Bounding,'edgecolor','y');
        end
    end
    saveas(h,[GlobalPath 'results/' fileName '.png']);
    close(h);
end

function windowCandidates=NormalTriangularSearch(edgesSeg,windowXY,maskSegment)
    horitLineTheta = [80 -80];
    leftLineTheta = [-40 -20];
    rightLineTheta = [20 40];
    triangles = [];
    distThres = 0.05*min(size(edgesSeg)); %dist max Euclidean
    leftLineCand = [];
    rightLineCand = [];
    upperLineCand = [];
    windowCandidates = [];
    [HoughMatrix,Theta,Rho] = hough(edgesSeg);
    Peaks = houghpeaks(HoughMatrix,8,'Threshold',0.2*max(HoughMatrix(:)));
    lines = houghlines(edgesSeg,Theta,Rho,Peaks,'FillGap',5,'MinLength',28);
%     PlotHough(lines,edgesSeg);
    for line=1:length(lines)
        if (lines(line).theta >= horitLineTheta(1) || lines(line).theta <= horitLineTheta(2))
            upperLineCand = [upperLineCand; lines(line)];
        elseif (lines(line).theta >= leftLineTheta(1) && lines(line).theta <= leftLineTheta(2))
            leftLineCand = [leftLineCand; lines(line)];
        elseif (lines(line).theta >= rightLineTheta(1) && lines(line).theta <= rightLineTheta(2))
            rightLineCand = [rightLineCand; lines(line)];
        end
    end
    distUp2Left = [];
    distRight2Up = [];
    distLeft2Right = [];
    if (~isempty(rightLineCand) && ~isempty(leftLineCand))
        distUp2Left = distanceLinesP1toP2(upperLineCand, leftLineCand);
        distUp2Left = EliminateLowerRows(distUp2Left, distThres);
    end
    if (~isempty(upperLineCand) && ~isempty(rightLineCand))
        distRight2Up = distanceLinesP2toP2(rightLineCand, upperLineCand);
        distRight2Up = EliminateLowerRows(distRight2Up, distThres);
    end
    if (~isempty(leftLineCand) && ~isempty(rightLineCand))
        distLeft2Right = distanceLinesP1toP1(leftLineCand, rightLineCand);
        distLeft2Right = EliminateLowerRows(distLeft2Right, distThres);
    end
    if (~isempty(distUp2Left) && ~isempty(distRight2Up) && ~isempty(distLeft2Right))
        for line=1:size(distUp2Left,1)
            indListUL = find(distLeft2Right(:,1) == distUp2Left(line,2));
            if (~isempty(indListUL))
                for ind=1:size(indListUL,1)
                    indListLR = find(distRight2Up(:,1) == distLeft2Right(ind,2));
                    if (~isempty(indListLR))
                        triangles = [triangles; [upperLineCand(distRight2Up(indListLR(1),2))
                                     leftLineCand(distLeft2Right(indListUL(ind),1))
                                     rightLineCand(distRight2Up(indListLR(1),1))]];
                    end
                end
            end
        end
    else
        if ~isempty(distUp2Left)
            triangles = [triangles;upperLineCand(distUp2Left(1,1)) 
                        leftLineCand(distUp2Left(1,2))];
        end
        if ~isempty(distRight2Up)
            triangles = [triangles;upperLineCand(distRight2Up(1,2)) 
                        rightLineCand(distRight2Up(1,1))];
        end
        if ~isempty(distLeft2Right)
            triangles = [triangles;leftLineCand(distLeft2Right(1,1)) 
                        rightLineCand(distLeft2Right(1,2))];            
        end
    end
%     PlotHough(triangles,edgesSeg);
    if (~isempty(triangles))
        triangle = struct2table(triangles);
        x = min([triangle.point1(:,1); triangle.point2(:,1)]);
        y = min(triangle.point1(:,2));
        w = max(triangle.point2(:,1))-x;
        h = max([triangle.point1(:,2); triangle.point2(:,2)])-y;
        margin = round(distThres);
        bBox = ([x-margin y-margin w+margin h+margin]);
        pixels = sum(sum(imcrop(maskSegment,bBox)));
        bBox(1) = windowXY(1)+bBox(1);
        bBox(2) = windowXY(2)+bBox(2);
        if (bBox(1) < 1)
            bBox(1) = 1; 
        end
        if (bBox(2) < 1)
            bBox(2) = 1;
        end
        element= struct('x',bBox(1),'y',bBox(2),'w',bBox(3),'h',bBox(4),'area',bBox(3)*bBox(4),'pixels',pixels);
        windowCandidates = [windowCandidates;element];
    end
end

function windowCandidates=ReverseTriangularSearch(edgesSeg,windowXY,maskSegment)
    horitLineTheta = [80 -80];
    rightLineTheta = [-40 -20];
    leftLineTheta = [20 40];
    triangles = [];
    distThres = 0.05*min(size(edgesSeg)); %dist max Euclidean
    leftLineCand = [];
    rightLineCand = [];
    upperLineCand = [];
    windowCandidates = [];
    [HoughMatrix,Theta,Rho] = hough(edgesSeg);
    Peaks = houghpeaks(HoughMatrix,8,'Threshold',0.2*max(HoughMatrix(:)));
    lines = houghlines(edgesSeg,Theta,Rho,Peaks,'FillGap',5,'MinLength',28);
%     PlotHough(lines,edgesSeg);
    for line=1:length(lines)
        if (lines(line).theta >= horitLineTheta(1) || lines(line).theta <= horitLineTheta(2))
            upperLineCand = [upperLineCand; lines(line)];
        elseif (lines(line).theta >= leftLineTheta(1) && lines(line).theta <= leftLineTheta(2))
            leftLineCand = [leftLineCand; lines(line)];
        elseif (lines(line).theta >= rightLineTheta(1) && lines(line).theta <= rightLineTheta(2))
            rightLineCand = [rightLineCand; lines(line)];
        end
    end
    distUp2Left = [];
    distRight2Up = [];
    distLeft2Right = [];
    if (~isempty(upperLineCand) && ~isempty(leftLineCand))
        distUp2Left = distanceLinesP1toP1(upperLineCand, leftLineCand);
        distUp2Left = EliminateLowerRows(distUp2Left, distThres);
    end
    if (~isempty(upperLineCand) && ~isempty(rightLineCand))
        distRight2Up = distanceLinesP1toP2(rightLineCand, upperLineCand);
        distRight2Up = EliminateLowerRows(distRight2Up, distThres);
    end
    if (~isempty(leftLineCand) && ~isempty(rightLineCand))
        distLeft2Right = distanceLinesP2toP2(leftLineCand, rightLineCand);
        distLeft2Right = EliminateLowerRows(distLeft2Right, distThres);
    end
    if (~isempty(distUp2Left) && ~isempty(distRight2Up) && ~isempty(distLeft2Right))
        for line=1:size(distUp2Left,1)
            indListUL = find(distLeft2Right(:,1) == distUp2Left(line,2));
            if (~isempty(indListUL))
                for ind=1:size(indListUL,1)
                    indListLR = find(distRight2Up(:,1) == distLeft2Right(ind,2));
                    if (~isempty(indListLR))
                        triangles = [triangles; [upperLineCand(distRight2Up(indListLR(1),2))
                                     leftLineCand(distLeft2Right(indListUL(ind),1))
                                     rightLineCand(distRight2Up(indListLR(1),1))]];
                    end
                end
            end
        end
    else
        if ~isempty(distUp2Left)
            triangles = [triangles;upperLineCand(distUp2Left(1,1)) 
                        leftLineCand(distUp2Left(1,2))];
        end
        if ~isempty(distRight2Up)
            triangles = [triangles;upperLineCand(distRight2Up(1,2)) 
                        rightLineCand(distRight2Up(1,1))];
        end
        if ~isempty(distLeft2Right)
            triangles = [triangles;leftLineCand(distLeft2Right(1,1)) 
                        rightLineCand(distLeft2Right(1,2))];            
        end
    end
%     PlotHough(triangles,edgesSeg);
    if (~isempty(triangles))
        triangle = struct2table(triangles);
        x = min(triangle.point1(:,1));
        y = min([triangle.point1(:,2); triangle.point2(:,2)]);
        w = max([triangle.point1(:,1); triangle.point2(:,1)])-x;
        h = max(triangle.point2(:,2))-y;
        margin = round(distThres);
        bBox = ([x-margin y-margin w+margin h+margin]);
        pixels = sum(sum(imcrop(maskSegment,bBox)));
        bBox(1) = windowXY(1)+bBox(1);
        bBox(2) = windowXY(2)+bBox(2);
        if (bBox(1) < 1)
            bBox(1) = 1; 
        end
        if (bBox(2) < 1)
            bBox(2) = 1;
        end
        element= struct('x',bBox(1),'y',bBox(2),'w',bBox(3),'h',bBox(4),'area',bBox(3)*bBox(4),'pixels',pixels);
        windowCandidates = [windowCandidates;element];
    end
end

function windowCandidates=RectangleSearch(edgesSeg,windowXY,maskSegment,aspectRatio)
    horitLineTheta = [75 -75];
    vertLineTheta = [-15 15];
    rectangles = [];
    distThres = 0.1*min(size(edgesSeg)); %dist max Euclidean
    vertLineCand = [];
    horitLineCand = [];
    windowCandidates = [];
    thresParalel = 5;
    [HoughMatrix,Theta,Rho] = hough(edgesSeg);
    Peaks = houghpeaks(HoughMatrix,6,'Threshold',0.2*max(HoughMatrix(:)));
    lines = houghlines(edgesSeg,Theta,Rho,Peaks,'FillGap',80,'MinLength',28);
%     PlotHough(lines,edgesSeg);
    for line=1:length(lines)
        if (lines(line).theta >= vertLineTheta(1) && lines(line).theta <= vertLineTheta(2))
            vertLineCand = [vertLineCand; lines(line)];
        elseif (lines(line).theta >= horitLineTheta(1) || lines(line).theta <= horitLineTheta(2))
            horitLineCand = [horitLineCand; lines(line)];
        end
    end
    minTheta = 100;
    maxRho = 0;
    for line1=1:length(vertLineCand)
        line1Heigth = pdist([vertLineCand(line1).point1; vertLineCand(line1).point2]);
        for line2=line1+1:length(vertLineCand)
            line2Heigth = pdist([vertLineCand(line2).point1; vertLineCand(line2).point2]);
            upperDist = pdist([vertLineCand(line1).point1; vertLineCand(line2).point1]);
            aspectRatioLine1 = upperDist/line1Heigth;
            aspectRatioLine2 = upperDist/line2Heigth;
            auxTheta = abs(abs(vertLineCand(line1).theta)-abs(vertLineCand(line2).theta));
            auxRho = abs(abs(vertLineCand(line1).rho)-abs(vertLineCand(line2).rho));
            if (((aspectRatioLine1 > aspectRatio(1) && aspectRatioLine1 < aspectRatio(2))...
              || (aspectRatioLine2 > aspectRatio(1) && aspectRatioLine2 < aspectRatio(2)))...
              && (auxTheta <= minTheta) && (auxRho >= maxRho))
                minTheta = auxTheta;
                maxRho = auxRho;
                if(vertLineCand(line1).point1(1) < vertLineCand(line2).point1(1))
                    rectangles = [vertLineCand(line1) vertLineCand(line2)];
                else
                    rectangles = [vertLineCand(line2) vertLineCand(line1)];
                end
            end
        end
    end
    if (~isempty(rectangles))
        for line1=1:length(horitLineCand)
            lineDistRU = pdist([horitLineCand(line1).point2; rectangles(2).point1]);
            lineDistRD = pdist([horitLineCand(line1).point2; rectangles(1).point2]);
            lineDistLU = pdist([horitLineCand(line1).point1; rectangles(1).point1]);
            lineDistLD = pdist([horitLineCand(line1).point1; rectangles(1).point2]);
            if (lineDistRU <= distThres || lineDistRD <= distThres || lineDistLU <= distThres || lineDistLD <= distThres)
                rectangles = [rectangles horitLineCand(line1)];
                if (length(rectangles) == 4)
                    break;
                end
            end
        end
%         PlotHough(rectangles,edgesSeg);
        rectangles = struct2table(rectangles);
        x = min([rectangles.point1(:,1); rectangles.point2(:,1)]);
        y = min([rectangles.point1(:,2); rectangles.point2(:,2)]);
        w = max([rectangles.point1(:,1); rectangles.point2(:,1)])-x;
        h = max([rectangles.point1(:,2); rectangles.point2(:,2)])-y;
        margin = round(distThres);
        bBox = ([x-margin y-margin w+margin h+margin]);
        pixels = sum(sum(imcrop(maskSegment,bBox)));
        bBox(1) = windowXY(1)+bBox(1);
        bBox(2) = windowXY(2)+bBox(2);
        if (bBox(1) < 1)
            bBox(1) = 1; 
        end
        if (bBox(2) < 1)
            bBox(2) = 1;
        end
        element= struct('x',bBox(1),'y',bBox(2),'w',bBox(3),'h',bBox(4),'area',bBox(3)*bBox(4),'pixels',pixels);
        windowCandidates = [windowCandidates;element];
    end
end

function windowCandidates=CircularSearch(image,maskSegment,radrange,windowXY)
    fltr4LM_R = [5 10 16 30];
    windowCandidates = [];
    distThres = 0.1*min(size(maskSegment));
    imSize = size(image);
%     figure, imshow(image), hold on
    bestRadius = 15;
    for fltr=1:length(fltr4LM_R)
        if ~((fltr == 3 && (size(image,1) < 60 || size(image,2) < 60)) ||... 
            (fltr == 4 && (size(image,1) < 200 || size(image,2) < 200)))
            [accum, circen, cirrad] = CircularHough_Grd(image, radrange,10,fltr4LM_R(fltr));            
            for i=1:length(cirrad)            
%                 DrawCircle(circen(i,1), circen(i,2), cirrad(i), 20, 'yellow');
                if (cirrad(i) > bestRadius && imSize(1) >= circen(i,1)+cirrad(i) && 0 <= circen(i,1)-cirrad(i)...
                        && imSize(2) >= circen(i,2)+cirrad(i) && 0 <= circen(i,2)-cirrad(i))
                    bBox = round([circen(i,1)-cirrad(i)-distThres circen(i,2)-cirrad(i)-distThres cirrad(i)*2+distThres cirrad(i)*2+distThres]);
                    pixels = sum(sum(imcrop(maskSegment,bBox)));
                    bestRadius = cirrad(i);
                    bBox(1) = windowXY(1)+bBox(1);
                    bBox(2) = windowXY(2)+bBox(2);
                    if (bBox(1) < 1)
                        bBox(1) = 1; 
                    end
                    if (bBox(2) < 1)
                        bBox(2) = 1;
                    end
%                     DrawCircle(circen(i,1), circen(i,2), cirrad(i), 20, 'green');
                    element= struct('x',bBox(1),'y',bBox(2),'w',bBox(3),'h',bBox(4),'area',bBox(3)*bBox(4),'pixels',pixels);
                    windowCandidates = [windowCandidates;element];
                end
            end
        end
    end
end

function PlotHough(lines,edgesSeg)
    figure, imshow(edgesSeg), hold on
    for k = 1:length(lines)
       xy = [lines(k).point1; lines(k).point2];
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

       % Plot beginnings and ends of lines
       plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
       plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    end
end

function distP1toP1=distanceLinesP1toP1(lines1, lines2)
    distP1toP1 = [];
    for i=1:length(lines1)
        for j=1:length(lines2)
            points = [lines1(i).point1 ;lines2(j).point1];
            distAux = pdist(points);
            distP1toP1 = [distP1toP1; i j distAux];
        end
    end
end

function distP1toP2=distanceLinesP1toP2(lines1, lines2)
    distP1toP2 = [];
    for i=1:length(lines1)
        for j=1:length(lines2)
            points = [lines1(i).point1 ;lines2(j).point2];
            distAux = pdist(points);
            distP1toP2 = [distP1toP2; i j distAux];
        end
    end
end

function distP2toP2=distanceLinesP2toP2(lines1, lines2)
    distP2toP2 = [];
    for i=1:length(lines1)
        for j=1:length(lines2)
            points = [lines1(i).point2 ;lines2(j).point2];
            distAux = pdist(points);
            distP2toP2 = [distP2toP2; i j distAux];
        end
    end
end

function matrix=EliminateLowerRows(matrix, thres)
    i = 1;
    while (i <= size(matrix,1))
        if (matrix(i,3) > thres)
            matrix(i,:) = [];
        else
            i = i+1;
        end
    end
end