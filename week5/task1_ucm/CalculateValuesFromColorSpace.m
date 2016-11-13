%giveng a colorspaces we select our interesting points in the mask
function values = CalculateValuesFromColorSpace(path,colorSpace,fileName,boundingBox)
    maskImage = logical(imread([path 'mask/mask.' fileName '.png']));
    colorImage = imread([path fileName '.jpg']);
    
    switch (colorSpace)
        case 'RGB_imadjust'
            colorImage(:,:,1)=imadjust(colorImage(:,:,1));
            colorImage(:,:,2)=imadjust(colorImage(:,:,2));
            colorImage(:,:,3)=imadjust(colorImage(:,:,3));
            section(:,:,1)= colorImage(:,:,1) .* uint8(maskImage);
            section(:,:,2)= colorImage(:,:,2) .* uint8(maskImage);
            section(:,:,3)= colorImage(:,:,3) .* uint8(maskImage);
            values = ColorRGB(section, boundingBox(:));
        case 'RGB_histeq'
            colorImage(:,:,1)=histeq(colorImage(:,:,1));
            colorImage(:,:,2)=histeq(colorImage(:,:,2));
            colorImage(:,:,3)=histeq(colorImage(:,:,3));
            section(:,:,1)= colorImage(:,:,1) .* uint8(maskImage);
            section(:,:,2)= colorImage(:,:,2) .* uint8(maskImage);
            section(:,:,3)= colorImage(:,:,3) .* uint8(maskImage);
            values = ColorRGB(section, boundingBox(:));
        case 'RGB'
            section(:,:,1)= colorImage(:,:,1) .* uint8(maskImage);
            section(:,:,2)= colorImage(:,:,2) .* uint8(maskImage);
            section(:,:,3)= colorImage(:,:,3) .* uint8(maskImage);
            values = ColorRGB(section, boundingBox(:));
        case 'Gray'
            %TODO
            section(:,:,1)= colorImage(:,:,1) .* uint8(maskImage);
            section(:,:,2)= colorImage(:,:,2) .* uint8(maskImage);
            section(:,:,3)= colorImage(:,:,3) .* uint8(maskImage);
            values = ColorRGBMinMax(section, boundingBox(:));
        case 'LAB'
            section(:,:,1)= colorImage(:,:,1) .* uint8(maskImage);
            section(:,:,2)= colorImage(:,:,2) .* uint8(maskImage);
            section(:,:,3)= colorImage(:,:,3) .* uint8(maskImage);
            [amean, bmean, avar, bvar]=ColorRatio(section, boundingBox(:)); %color information
            values = [amean bmean avar bvar];
        case 'HSV'
            colorImage= rgb2hsv(colorImage);
            section(:,:,1)= colorImage(:,:,1) .* double(maskImage);
            section(:,:,2)= colorImage(:,:,2) .* double(maskImage);
            section(:,:,3)= colorImage(:,:,3) .* double(maskImage);
            values = ColorHSV(section, boundingBox(:));
    end
end