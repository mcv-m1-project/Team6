function task1_w2 ()
    %Load image
    'Loading image...'
    Image=imread('./Wet-BW.jpg');
    my_se=input('Enter the matrix that represent the structuring element, format [ x x x; x (x) x; x x x ] considering the center as the middle of the matrix...\n');
    se_matlab= strel('arbitrary',my_se);

    %function handles
    f={@mydilate;@myerode;@myOpening;@myClosing;@myTopHat;@myDualTopHat; ...
        @DilateCompare;@ErodeCompare;@OpeningCompare;@ClosingCompare};
    fprintf('Available operations:\n1- Dilation\n2- Erosion\n3- Opening\n4- Closing\n5- Top Hat\n6- Dual Top Hat\n7- Compare Dilations\n8- Compare Erosions\n9- Compare Openings\n10- Compare Closings\n\n');
    %function selection
    selection=input('Select number of operation from the ones above: \n');
    if selection <= 4
        %For ops that do not show resulting image
        Out= f{selection}(Image,my_se);
        imshow(Out);
    else
        f{selection}(Image,se_matlab,my_se);
    end
    fprintf('Operation concluded\n');
end

function [Out] = mydilate(Image,SE)
    sizeSE=size(SE);
    Out=zeros(size(Image));
    for channel=1:size(Image,3)
        image = double(Image(:,:,channel));    
        imdil = zeros(size(image));
        deflecti= double((sizeSE(1)-1)/2);
        deflectj= double((sizeSE(2)-1)/2);
        imgraynorm = (image - min(min(image)))/(max(max(image)) - min(min(image)));
        imgraynorm = padarray(imgraynorm,[deflecti deflectj]);
        for i=1+deflecti:(size(imgraynorm,1)-deflecti)
            for j=1+deflectj:(size(imgraynorm,2)-deflectj)
                imdil(i-deflecti,j-deflectj) = max(max(SE.*imgraynorm(i-deflecti:i+deflecti,j-deflectj:j+deflectj)));
            end
        end
        Out(:,:,channel)=mat2gray(imdil);
    end
end

function [Out] = myerode(Image,SE)
    sizeSE=size(SE);
    Out=zeros(size(Image));
    for channel=1:size(Image,3)
        image = double(Image(:,:,channel));     
        imdil = zeros(size(image));
        deflecti= double((sizeSE(1)-1)/2);
        deflectj= double((sizeSE(2)-1)/2);
        imgraynorm = (image - min(min(image)))/(max(max(image)) - min(min(image)));
        imgraynorm = padarray(imgraynorm,[deflecti deflectj],1);
        for i=1+deflecti:(size(imgraynorm,1)-deflecti)
            for j=1+deflectj:(size(imgraynorm,2)-deflectj)
                imageres_mult=SE.*imgraynorm(i-deflecti:i+deflecti,j-deflectj:j+deflectj);
                imdil(i-deflecti,j-deflectj) = min(imageres_mult(find(SE~=0)));
            end
        end
        Out(:,:,channel)=mat2gray(imdil);
    end   
end

function [Out]=myOpening(Image,SE)
    %launch erode and then dilate for opening
    Eroded= myerode(Image,SE);
    Out= mydilate(Eroded,SE);
end

function [Out]=myClosing(Image,SE)
    %launch dilate and then erode for closing
    Dilated= mydilate(Image,SE);
    Out= myerode(Dilated,SE);  
end

function myTopHat(Image,SE)
    %launch opening op
    Opened= myOpening(Image,SE);
    %prepare Acase for subtraction by switching to double and normalizing
    Image = double(Image);
    Image = (Image - min(min(min(Image))))/(max(max(max(Image))) - min(min(min(Image))));
    %Subtract one dilated color image from the other and show on figure 4
    TopHatted= Image-Opened;
    figure(4)
    imshow(TopHatted);
    title('TopHat');
end

function myDualTopHat(Image,SE)
    %launch closing op
    Closed= myClosing(Image,SE);
    %prepare Acase for subtraction by switching to double and normalizing
    Image = double(Image);
    Image = (Image - min(min(min(Image))))/(max(max(max(Image))) - min(min(min(Image))));
    %Subtract closed color image from the other and show on figure 4
    DTopHatted= Image-Closed;
    figure(4)
    imshow(DTopHatted);
    title('DualTopHat');
end

function DilateCompare(Image,se_matlab,myse)
    %launch dilate ops
    tic
    Acase= imdilate(Image,se_matlab);
    toc
    tic
    Bcase= mydilate(Image,myse);
    toc
    %display original, matlab and homemade vers
    figure(1)
    imshow(Image);
    title('Original');
    figure(2)
    imshow(Acase);
    title('Matlab version');
    figure(3)
    imshow(Bcase);
    title('Homemade version');
    %prepare Acase for subtraction by switching to double and normalizing
    Acase = double(Acase);
    Acase = (Acase - min(min(min(Acase))))/(max(max(max(Acase))) - min(min(min(Acase))));
    %Subtract one dilated color image from the other and show on figure 4
    AB= Acase-Bcase;
    figure(4)
    imshow(AB);
    title('Matlab - homemade');
end

function ErodeCompare(Image,se_matlab,myse)    
    %launch erode ops
    tic
    Acase= imerode(Image,se_matlab);
    toc
    tic
    Bcase= myerode(Image,myse);
    toc
    %display original, matlab and homemade vers
    figure(1)
    imshow(Image);
    title('Original');
    figure(2)
    imshow(Acase);
    title('Matlab version');
    figure(3)
    imshow(Bcase);
    title('Homemade version');
    %prepare Acase for subtraction by switching to double and normalizing
    Acase = double(Acase);
    Acase = (Acase - min(min(min(Acase))))/(max(max(max(Acase))) - min(min(min(Acase))));
    %Subtract one eroded color image from the other and show on figure 4
    AB= Acase-Bcase;
    figure(4)
    imshow(AB);
    title('Matlab - homemade');
end

function OpeningCompare(Image,se_matlab,myse)
    %launch opening ops
    tic
    Acase= imopen(Image,se_matlab);
    toc
    tic
    Bcase= myOpening(Image,myse);
    toc
    %display original, matlab and homemade vers
    figure(1)
    imshow(Image);
    title('Original');
    figure(2)
    imshow(Acase);
    title('Matlab version');
    figure(3)
    imshow(Bcase);
    title('Homemade version');
    %prepare Acase for subtraction by switching to double and normalizing
    Acase = double(Acase);
    Acase = (Acase - min(min(min(Acase))))/(max(max(max(Acase))) - min(min(min(Acase))));
    %Subtract one opened color image from the other and show on figure 4
    AB= Acase-Bcase;
    figure(4)
    imshow(AB);
    title('Matlab - homemade');
end

function ClosingCompare(Image,se_matlab,myse)
    %launch closing ops
    'Launching closing ops with chronometration...'
    tic
    Acase= imclose(Image,se_matlab);
    toc
    tic
    Bcase= myClosing(Image,myse);
    toc
    %display original, matlab and homemade vers
    figure(1)
    imshow(Image);
    title('Original');
    figure(2)
    imshow(Acase);
    title('Matlab version');
    figure(3)
    imshow(Bcase);
    title('Homemade version');
    %prepare Acase for subtraction by switching to double and normalizing
    Acase = double(Acase);
    Acase = (Acase - min(min(min(Acase))))/(max(max(max(Acase))) - min(min(min(Acase))));
    %Subtract one closed color image from the other and show on figure 4
    AB= Acase-Bcase;
    figure(4)
    imshow(AB);
    title('Matlab - homemade');
end


