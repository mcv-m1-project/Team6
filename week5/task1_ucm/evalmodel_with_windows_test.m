%evaluate the genrated model with a validation test
function evalmodel_with_windows_test(directory,windowSet,trainingset,model,colorSpace)
    
    dir_mask_color=[directory '/mask_color/'];
    files = ListFiles(directory);
    if (exist(strcat(directory, '/mask_result/'),'dir') == 0)
        mkdir(strcat(directory, '/mask_result/'));
    end
    if (exist(strcat(directory, '/gt_result/'),'dir') == 0)
        mkdir(strcat(directory, '/gt_result/'));
    end
    'Starting test'
    for i=1:size(files,1),
        disp([num2str(i),' of ', num2str(size(files,1))])
        % Read file
        im = imread(strcat(directory,'/',files(i).name));
        color_mask = CandidateGenerationPixel_Color(im, trainingset,model,colorSpace);
        color_mask=morphoprocess(color_mask);
        %color_mask=imread(strcat(dir_mask_color,'mask.', files(i).name(1:size(files(i).name,2)-3), 'png'));
        % Candidate Generation (window)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [windowCandidates,pixelCandidates]=select_regions_candidats_ucm(im,color_mask,windowSet);
         % Candidate Generation (pixel) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         pixelCandidates = CandidateGenerationPixel_Color_window(mask_edges, windowCandidates);
        imwrite(pixelCandidates,strcat(directory, '/mask_result/mask.', files(i).name(1:size(files(i).name,2)-3), 'png'));
        
        filename_gt_result=strcat(directory, '/gt_result/mask.', files(i).name(1:size(files(i).name,2)-3), 'mat');

        save(filename_gt_result,'windowCandidates');
 
        end
end
