%giveng a colorspaces we select our interesting points in the mask
function values = CalculateValuesFromColorSpace(path,colorSpace,fileName,boundingBox,bandwidth)
    maskImage = logical(imread([path 'mask/mask.' fileName '.png']));
    colorImage = imread([path fileName '.jpg']);

% 'HSV'
    colorImage= rgb2hsv(colorImage);
    section(:,:,1)= colorImage(:,:,1) .* double(maskImage);
    section(:,:,2)= colorImage(:,:,2) .* double(maskImage);
    section(:,:,3)= colorImage(:,:,3) .* double(maskImage);
    values = ColorHSV(section, boundingBox(:),bandwidth);
end