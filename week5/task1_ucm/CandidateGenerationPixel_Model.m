%applied the model and some condition to get the pixels which are considere
%traffic signals
function [pixelCandidates] = CandidateGenerationPixel_Model(im, trainingset,evaluation)
     pixelCandidates=zeros(size(im,1),size(im,2));
     switch evaluation
        case 'centroidDistance' %distance of every pixel to a centroid of the kmeans if one pixel is less than 20 units of the centroid we considered it has a signal 
            fields = fieldnames(trainingset);
            for countfieldsi = 1:numel(fields)
                if ~isempty(strfind(fields{countfieldsi},'class'))
                    for countclusters =1:size(trainingset.(fields{countfieldsi}).model,1)
                        for counti=1:size(im,1)
                            for countj=1:size(im,2)
                                if(norm([im(counti,countj,1) im(counti,countj,2) im(counti,countj,3)]-trainingset.(fields{countfieldsi}).model(countclusters,:))<20)
                                    pixelCandidates(counti,countj)=1;
                                end
                            end
                        end
                    end
                end
            end
         case '2Dhist' %Threshold using the 2D histogram as a gaussian model of probabilities
            fields = fieldnames(trainingset);
            thresholdVec = [5.5 2.5 3];
            thr = 1;
            for class = 1:numel(fields)
                if ~isempty(strfind(fields{class},'class'))
                    histogram = trainingset.(fields{class}).model;
                    threshold = thresholdVec(thr);
                    for i=1:size(im,1)
                        for j=1:size(im,2)
                            row = round(im(i,j,1)/histogram(2,1,1))+1;
                            col = round(im(i,j,2)/histogram(2,1,1))+1;
                            if (histogram(row,col,3) > threshold)
                                pixelCandidates(i,j)=1;
                            end
                        end
                    end
                    thr = thr+1;
                end
            end
         case 'hand' % a hand estimation of all the posible colors
             red=im(:,:,1)>170&im(:,:,2)<40&im(:,:,3)<40;
             blue=im(:,:,1)<40&im(:,:,2)<40&im(:,:,3)>170;
             white=im(:,:,1)>170&im(:,:,2)>170&im(:,:,3)>170;
             pixelCandidates=red+white+blue;
         case 'gaussian_mixture'  % applied the  gaussian mixture model and get the points that are with a probability of more than the 75% of the maximus probability
            fields = fieldnames(trainingset);
            for countfieldsi = 1:numel(fields)
                if ~isempty(strfind(fields{countfieldsi},'class'))                   
                    ImgVector = reshape(im,size(im,1)*size(im,2), size(im,3));
                    imres=zeros(size(ImgVector,1),1);
                    y = pdf(trainingset.(fields{countfieldsi}).model,ImgVector);
                    imres(find(y>max(y)*0.75))=1;
                    im_restaurada=reshape(imres,size(im,1),size(im,2),1);
                    pixelCandidates=pixelCandidates+im_restaurada;
                end
            end
     end
   
end