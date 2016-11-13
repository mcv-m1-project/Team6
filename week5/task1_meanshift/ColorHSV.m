
function values = ColorHSV(section, boundingBox,bandwidth)
%-------------------------------------------------------------------------
%   Parameters |    Value
%--------------------------------------------------------------------------
%   section         pixels from signals in training lot images masked.
%   boundingBox     bounding box or window where signal is
%   bandwidth       parameter to fine tune the mean shift segmentation of
%                   the signal colours.
%--------------------------------------------------------------------------
%NOTE: function to filter the black points in the resulting image after 
%applying the mask to an hsv image and the bounding box.

    values=[];
    cropimage = imcrop(section,boundingBox);
    
    %Use mean shift to segment colors in training signal sample 
    [cropimage, ~] = Ms(cropimage,bandwidth);
    
    for counti=1:size(cropimage,1)
        for countj=1:size(cropimage,2)
            if (cropimage(counti,countj,1)>0 || cropimage(counti,countj,2)>0) %values with some significace diferents to brightness
                values=[values [double(cropimage(counti,countj,1)) double(cropimage(counti,countj,2))]];%only take these values the other one is brightness
            end
        end
    end  
end