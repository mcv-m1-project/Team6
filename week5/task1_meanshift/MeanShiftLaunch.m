function  MeanShiftLaunch(trainingSet, bandwidth)
%-------------------------------------------------------------------------
%   Parameters |    Value
%--------------------------------------------------------------------------
%   traininSet      trained dataset of images.
%   
%   bandwidth       parameter for mean shift windowing
%--------------------------------------------------------------------------
%NOTE: Needs traininSet structure to be already created.

for i=1:size(files,1),
        disp([num2str(i),' of ', num2str(size(files,1))])
        tic;
        % Read file
        im = imread(strcat(directory,'/',files(i).name));
        
        %Candidate generation
        CandidateRegion = RegionCandidatesMS(image,trainingSet,bandwidth);
        pixelCandidates=morphoprocess(pixelCandidates);
        %File store for result masks
        imwrite(pixelCandidates,strcat(directory, '/mask_result/mask.', files(i).name(1:size(files(i).name,2)-3), 'png'));
        toc;
end
end

function CandidateRegion = RegionCandidatesMS(image,trainingset,bandwidth)

im    = image(:,:,1:2);

[im, Kms, point2cluster] = Ms2(im, bandwidth);

CandidateRegion = CandidateGenerationPixel_Model(im, Kms, point2cluster, trainingset);

end

function [pixelCandidates] = CandidateGenerationPixel_Model(im, Kms, point2cluster, trainingset)
     
pixelCandidates = zeros(size(im,1),size(im,2));
eudist = ones(size(im));     
fields = fieldnames(trainingset);

%On each cluster
for region = 1:(Kms-1)
    sector = logical(point2cluster == region);
    sectorvals(:,:,1) = im(:,:,1) .* sector;
    sectorvals(:,:,2) = im(:,:,2) .* sector;
    if ( ((sum(sum(sectorvals(:,:,1))))~= 0 )&& ((sum(sum(sectorvals(:,:,2))))~= 0 ) )
        [~, ~, valsh] = find(sectorvals(:,:,1));
        [~, ~, valss] = find(sectorvals(:,:,2));

        %Cluster centroid
        centroid = [valsh(1), valss(1)];

        %Release memory
        sectorvals = [];

        %For each signal class 
        for class = 1:numel(fields)
            if ~isempty(strfind(fields{class},'class'))
                model0 = trainingset.(fields{class}).model;
                eudist = sqrt( (centroid(1) - model0(1))^2 + (centroid(2) - model0(2))^2 );

                %difference between image cluster pixels and parameter signal pixel
                %colours bin size
                if ( eudist <= sqrt( (0.05^2) + (0.1^2) ))
                    pixelCandidates = pixelCandidates + sector;
                end     
            end
        end
    end     
end
end