function [bbox,result_image]=select_regions_candidats_ucm(image_input,color_mask,windowSet)
    fields = fieldnames(windowSet);
    result_image=zeros(size(image_input,1),size(image_input,2));
    bbox=[];
    [candidates_struct, ucm_image] = im2mcg(image_input,'fast');
%     edges = imdilate(ucm_image,strel(ones(3)));
%     edges = edges>0.55;
%     edges=imresize(edges,0.5);
    for id1=1:size(candidates_struct.scores,1)
            x = candidates_struct.bboxes(id1,1);
            y = candidates_struct.bboxes(id1,2);
            w = candidates_struct.bboxes(id1,3)-x;
            h = candidates_struct.bboxes(id1,4)-y;
%             imshow(color_mask);
%             rectangle('Position',[y,x,h,w],'EdgeColor','r');
    
%             mask_id = ismember(candidates_struct.superpixels, candidates_struct.labels{id1});
            fillingratio=sum(sum(color_mask(x:x+w,y:y+h)))/(w*h);
            aspectratio=w/h;
            for class_image = 1:numel(fields)
                if ~isempty(strfind(fields{class_image},'class'))
                    %remove big regions
                    if(w<windowSet.(fields{class_image}).maxwidth && w>windowSet.(fields{class_image}).minwidth && h<windowSet.(fields{class_image}).maxheight && h>windowSet.(fields{class_image}).minheight)
                        %filter by shape in the color mask
                        if(windowSet.(fields{class_image}).minfillingRatio<fillingratio && windowSet.(fields{class_image}).maxfillingRatio>fillingratio && windowSet.(fields{class_image}).minaspectRatio<aspectratio && windowSet.(fields{class_image}).maxaspectRatio>aspectratio)
                            element=struct('x',double(y),'y',double(x),'w',double(h+1),'h',double(w+1),'area',w*h);
                            bbox = [bbox; element];
                            result_image(x:x+w,y:y+h)=color_mask(x:x+w,y:y+h);
                        end
                    end
                end
            end
    end
    if(size(bbox,1)>1)
        bbox=eliminated_repeated(bbox); % se elimina las areas que se sobre ponen
    end
end