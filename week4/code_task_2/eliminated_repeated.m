function cbbox= eliminated_repeated(bbox)
   
    if(size(bbox,1)>0)
         list_bbox=[bbox.area];
        [values, list_bbox_res] = sort(list_bbox, 'descend');
        cbbox=[bbox(list_bbox_res(1))];
        for countbbox=2:size(list_bbox_res,2)
            candiated=true;
            for countcbbox=1:size(cbbox,1)
                %compara si las areas se superpone
                if(RoiOverlapping(cbbox(countcbbox), bbox(list_bbox_res(countbbox))) > 0.2)
                    %elige el rectangulo mas grande como represntante de la
                    %señal
                    candiated=false;
                end
            end
            if(candiated)
                cbbox=[cbbox;bbox(list_bbox_res(countbbox))];
            end
        end
       
    end
end