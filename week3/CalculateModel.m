%depending of the model we use diferents method to generate the information
function genmodel=CalculateModel(sample,model,dim)
    switch (model)
        case 'kmeans' % compute the kmeans with dim number of clusters
            sample = vec2mat(sample,3);
            [points,genmodel] = kmeans(sample,dim);
        case '2Dhist' %compute a 2D histogram preinizialized with a predefined size
            segments = 0.05;
            numDivisions = 1/segments+1;
            histogram = zeros(numDivisions,numDivisions,3);
            %preinizialize histogram with the segment size especified
            for i=1:numDivisions
                for j=1:numDivisions
                    histogram(i,j,1:2) = [segments*(i-1) segments*(j-1)];
                end
            end
            %convert sample array in a 2 point matrix
            sample = vec2mat(sample,2);
            %compute histogram
            for pixel=1:length(sample(:,1))
                row = round(sample(pixel,1)/segments)+1;
                col = round(sample(pixel,2)/segments)+1;
                histogram(row,col,3) = histogram(row,col,3)+1;
            end
            %calculate model with % of pixels for every HS values
            genmodel = histogram;
            genmodel(:,:,3) = 100*histogram(:,:,3)./length(sample(:,1));
        case 'gaussian' %fit a gaussian mixture with dim number of gaussians
            sample = vec2mat(sample,3);
            genmodel = gmdistribution.fit(sample,dim);
        case 'gaussian_HSV' % the same as the previous one but for the two relevant dimensions of the HSV spaces
            sample = vec2mat(sample,2);
            genmodel = gmdistribution.fit(sample,dim);
        otherwise
            genmodel= [];
    end
end