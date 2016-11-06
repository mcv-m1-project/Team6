function cbbox= eliminated_repeated(bbox,pixelCandidates)
    if(size(bbox,1)>1)
        cbbox=[bbox(1)];
        for countbbox=1:size(bbox,1)
            candiated=true;
            area_change=false;
            for countcbbox=1:size(cbbox,1)
                %compara si las areas se superpone
                if(RoiOverlapping(cbbox(countcbbox), bbox(countbbox)) > 0.2)
                    candiated=false;
                    %elige el rectangulo mas grande como represntante de la
                    %señal
                    if(bbox(countbbox).pixels>cbbox(countcbbox).pixels)% to avoid points of the same figure for example parts of a triangel
                        cbbox(countcbbox)=bbox(countbbox);
                        area_change=true;
                    end
%                 else
%                     RoiOverlapping(cbbox(countcbbox), bbox(countbbox))
                end
            end
            if(candiated)
                cbbox=[cbbox;bbox(countbbox)];
            end
            if(area_change)
               cbbox=eliminated_repeated(cbbox,pixelCandidates);
            end
        end
    else
        cbbox=[bbox(1)];
    end
end