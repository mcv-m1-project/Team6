%function to filter the black points in the resulting image after appling
%the mask to a hsv image and the boundarings, searching for the min max
function values = ColorRGBMinMax(section, boundingBox)
    crop = imcrop(section,boundingBox);
    red = crop(:,:,1);
    green = crop(:,:,2);
    blue = crop(:,:,3);
    values = [min(min(red(red>0))) max(max(red))]; %min max red component
    values = [values min(min(green(green>0))) max(max(green))]; %min max green component
    values = [values min(min(blue(blue>0))) max(max(blue))]; %min max blue component
end
