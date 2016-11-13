%make the necessary transform to the validation image to aplied the model
function [pixelCandidates] = CandidateGenerationPixel_Color(im, trainingset,model,colorSpace)

    im=double(im);

    switch colorSpace
        case 'RGB_histeq' %applied the histogram equalitation to all the channels
            im(:,:,1)=histeq(im(:,:,1));
            im(:,:,2)=histeq(im(:,:,2));
            im(:,:,3)=histeq(im(:,:,3));
            pixelCandidates = CandidateGenerationPixel_Model(im, trainingset,model);
        case 'RGB_imadjust'%applied the transform to all the channels, in this method the supotition is that only 1% of the image have the maximun vaule and minmun
            im(:,:,1)=imadjust(im(:,:,1));
            im(:,:,2)=imadjust(im(:,:,2));
            im(:,:,3)=imadjust(im(:,:,3));
            pixelCandidates = CandidateGenerationPixel_Model(im, trainingset,model);
        case 'RGB'
            pixelCandidates = CandidateGenerationPixel_Model(im, trainingset,model);
            
        case 'HSV' %transform to the hsv spaces an take the relevants channels (Hue and Saturation)
             im= rgb2hsv(im);
             im=im(:,:,1:2);
             pixelCandidates = CandidateGenerationPixel_Model(im, trainingset,model);
        otherwise
            error('Incorrect color space defined');
            return
    end
end