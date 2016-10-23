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