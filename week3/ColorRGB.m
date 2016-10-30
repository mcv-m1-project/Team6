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