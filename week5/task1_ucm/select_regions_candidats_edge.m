function bbox=select_regions_candidats_edge(image_input,windowSet)

    
    bbox = [];
    step_sizes=20;
    step_window=[30 30];
%     edge_image=bwdist(edge(rgb2gray(image),'Canny'));
    edge_image=bwdist(edge(image_input,'canny',0.35));
    size_image=size(image_input);
    fields = fieldnames(windowSet);
    tol=0.40;

    for class_image = 1:numel(fields)
%             fields{class_image}
            if ~isempty(strfind(fields{class_image},'class'))
                    minh=windowSet.(fields{class_image}).minheight;
                    maxh=windowSet.(fields{class_image}).maxheight;
                    step_iter=(maxh-minh)/step_sizes;
                    count_step=minh;
                    
                    while(count_step>=minh && count_step<=maxh)
                        window_size=[round(count_step*windowSet.(fields{class_image}).meanaspectRatio) round(count_step)];
                        %step_window=[round(window_size(1)*0.25) round(window_size(2)*0.25)];
                        template_image=imresize(windowSet.(fields{class_image}).template,window_size)>0;
                        %div_num=window_size(1)*window_size(2);
                        templ=single(rot90(template_image,2));
                        conv_image= conv2(edge_image,single(templ),'same');
                        result=conv_image./(window_size(1)*window_size(2));
                        [x y]=find(result<tol);
                       
                        for count_rect=1:size(x,1)
                            if((x(count_rect)-window_size(1)/2)<0 && (y(count_rect)-window_size(2)/2)<0)
                                x_insert=round(x(count_rect));
                                y_insert=round(y(count_rect));
                            elseif((x(count_rect)-window_size(1)/2)<0)
                                x_insert=round(x(count_rect));
                                y_insert=round(y(count_rect)-window_size(2)/2);
                            elseif((y(count_rect)-window_size(2)/2)<0)
                                x_insert=round(x(count_rect)-window_size(1)/2);
                                y_insert=round(y(count_rect));
                            else
                                x_insert=round(x(count_rect)-window_size(1)/2);
                                y_insert=round(y(count_rect)-window_size(2)/2);
                            end
                            %don't add margins
                            if((x(count_rect)+window_size(1))<size_image(1) && (y(count_rect)+window_size(2))<size_image(2) && x_insert>0 && y_insert >0 )
                                area=window_size(1)*window_size(2);
                                element= struct('x',double(y_insert),'y',double(x_insert),'w',double(window_size(2)),'h',double(window_size(1)),'area',area);
                                bbox = [bbox;element];
                            end
                        end
                        count_step=count_step+step_iter;
                    end
             end
    end
    if(size(bbox,1)>1)
        bbox=eliminated_repeated(bbox); % se elimina las areas que se sobre ponen
    end
end