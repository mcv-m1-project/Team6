
function genmodel=CalculateModel(sample)
%-------------------------------------------------------------------------
%   Parameters |    Value
%--------------------------------------------------------------------------
%   sample          pixels from signals in training lot, without background
%                   or mask pixels
%   model           name of mathematic model (currently unused)
%   dim             parameter for unused models
%   bandwidth       parameter unused
%--------------------------------------------------------------------------
%NOTE: Run 'task3.m' to launch the sequence which locates the signal
%values, places them within trainingSet structure, and finally launches
%CalculateModel.

%compute a 2D histogram preinizialized with a predefined size
            binHeight = 1/20;
            binWidth = 1/10;
            numRows = 1/binHeight+1; %divisions for hue
            numCols = 1/binWidth+1; %divisions for saturation
            histogram = zeros(numRows,numCols,3);
            
            %preinizialize histogram with the segment size especified
            for i=1:numRows 
                for j=1:numCols
                    histogram(i,j,1:2) = [binHeight*(i-1), binWidth*(j-1)];
                end
            end
            
            %convert sample array in a 2 point matrix
            %sample = vec2mat(sample,2);
            
            %compute histogram
            for pixel=1:length(sample(:,1))
                row = round(sample(pixel,1)/binHeight)+1;
                col = round(sample(pixel,2)/binWidth)+1;
                histogram(row,col,3) = histogram(row,col,3)+1;
            end
            
            [x y] = find(histogram(:,:,3) > (0.2 * (mean(mean(histogram(:,:,3))))));
            
            h_param = (x-1).*binHeight;
            s_param = (y-1).*binWidth;
           
            %calculate model with % of pixels for every HS values
            %genmodel = histogram;
            %genmodel(:,:,3) = 100*histogram(:,:,3)./length(sample(:,1));
            genmodel = [h_param, s_param];
end