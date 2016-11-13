%evaluate the genrated model with a validation test
function evalmodel_with_windows_test(directory,windowSet)
    
    
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
     
       
        % Candidate Generation (window)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        windowCandidates=select_regions_candidats_edge(im,windowSet);
         % Candidate Generation (pixel) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pixelCandidates = CandidateGenerationPixel_Color_window(im, windowCandidates);
        imwrite(pixelCandidates,strcat(directory, '/mask_result/mask.', files(i).name(1:size(files(i).name,2)-3), 'png'));
        
        filename_gt_result=strcat(directory, '/gt_result/mask.', files(i).name(1:size(files(i).name,2)-3), 'mat');
        if(isempty(windowCandidates))
            save(filename_gt_result)
        else
            save(filename_gt_result,'windowCandidates');
 
        
        end
end
