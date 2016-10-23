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