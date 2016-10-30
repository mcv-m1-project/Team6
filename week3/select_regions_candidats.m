function bbox=select_regions_candidats(pixelCandidates,windowSet,type)
%El sistema es recorre la iamgen escalada sin cambiar el tamaño de la
%ventana la cual es del tamaño de la señal mas pequeña encontrada con esto
%se reduce el numero de iteracioens.
    
    bbox = [];
    scale_imaget=0.8;% reducion de la imagen en cada iteracion
    step_window=15;%espacio entre cuadrados
    count_iterations=1;
    factor=1;
    aux_image=pixelCandidates;
    size_image=size(aux_image);
    fields = fieldnames(windowSet);
    minw=[];
    minh=[];
    maxw=[];
    maxh=[];
    
    
    %Por tal de comprovar que la iamgen encontrada sive se busca el minimo de todas las clase
    for class_image = 1:numel(fields)
        if ~isempty(strfind(fields{class_image},'class'))
            minw=[minw windowSet.(fields{class_image}).minwidth];
            minh=[minh windowSet.(fields{class_image}).minheight];
        end
    end
    minw=min(minw);
    minh=min(minh);
    %odd sizes in the window for a proper convolution in the center
    if strcmp(type,'convolution')
        if (mod(minw,2) == 0)
            minw = minw+1;
        end
        if (mod(minh,2) == 0)
            minh = minh+1;
        end
    end
    %comprovacion de llegar a la imagen considerada mas peqña donde
    %encontrar una señal (posiblemente se deva cmabiar respecto al factor de escalado)
    while((minw+step_window)*4<size_image(1)&&(minh+step_window)*4<size_image(2))%to reduce number of iterations
        %tarea 3
        if strcmp(type,'window_integral')
            integral_aux=cumsum(cumsum(aux_image,1),2); %se suma tanto por filas como por columnas la imagen
        elseif strcmp(type,'convolution')
            filterWindow = ones(minw,minh);
            centerWindow = ceil(size(filterWindow,1)/2);
            correlation = conv2(single(aux_image),filterWindow);
            correlation = correlation(centerWindow:end-(centerWindow-1),centerWindow:end-(centerWindow-1));
        end
        for class_image = 1:numel(fields)
            if ~isempty(strfind(fields{class_image},'class'))
                %se elige como ventana la señal mas pequeña encontrada de
                %la clase
                window_size=[round(windowSet.(fields{class_image}).minheight*windowSet.(fields{class_image}).meanaspectRatio) round(windowSet.(fields{class_image}).minheight)];
                step_window_x=round(window_size(1)/2);
                step_window_y=round(window_size(2)/2);
                %calculo del tamaño real de la ventana
                w=round(window_size(2)/factor); 
                h=round(window_size(1)/factor);
                %Comprovacion de que no vamos ha encontrado objetos grandes
                if(w<windowSet.(fields{class_image}).maxwidth && h<windowSet.(fields{class_image}).maxheight)
%                     imshow(aux_image);
%                     hold on;
                    for counti=1:step_window_x:size_image(1)-window_size(1)
                        for countj=1:step_window_y:size_image(2)-window_size(2)
%                             rectangle('Position',[round(countj/factor) round(counti/factor) h w],'edgecolor','y')
                            if strcmp(type,'window_sum')
                                %tarea2
                                pixels=sum(sum(aux_image(counti:counti+window_size(1),countj:countj+window_size(2))));
                            elseif strcmp(type,'window_integral')
                                %tarea 3
                                %sum=A-B-C+D
                                if(countj>1 && counti>1)
                                    pixels=integral_aux(counti+window_size(1),countj+window_size(2))-integral_aux(counti+window_size(1),countj-1)-integral_aux(counti-1,countj+window_size(2))+integral_aux(counti-1,countj-1);
                                elseif(countj>1 && counti==1)
                                    pixels=integral_aux(counti+window_size(1),countj+window_size(2))-integral_aux(counti+window_size(1),countj-1);
                                elseif(countj==1 && counti>1)
                                    pixels=integral_aux(counti+window_size(1),countj+window_size(2))-integral_aux(counti-1,countj+window_size(2));
                                elseif(countj==1 && counti==1)
                                    pixels=integral_aux(counti+window_size(1),countj+window_size(2));
                                end
                            elseif strcmp(type,'convolution')
                                pixels = correlation(counti+centerWindow-1,countj+centerWindow-1);
                            end
                            %La comprovacion se hace con el filling ratio
                            fillingratio=pixels/(window_size(1)*window_size(2));
                            if(fillingratio>windowSet.(fields{class_image}).meanfillingRatio-windowSet.(fields{class_image}).stdfillingRatio && fillingratio<windowSet.(fields{class_image}).meanfillingRatio+windowSet.(fields{class_image}).stdfillingRatio)
                                %cordendas reales del punto superio
                                %izquierdo con las coordenadas giradas
                                x=round(counti/factor);
                                y=round(countj/factor);

                                %imshow(pixelCandidates);
                                %rectangle('Position',[y x h w],'edgecolor','y')
                                element= struct('x',double(y),'y',double(x),'w',double(w),'h',double(h),'pixels',pixels);
                                bbox = [bbox;element];
                            end
                           
                        end
                    end
%                  hold off
                    
                end
            end 
        end
        %CAMBIAR TAMAÑO DE LA IMAGEN Y ADAPTAR EL count_iterations PARA QUE
        %SE ADAPTE A LA IMAGEN TY PUEDA RECUPERAR LOS INDICES
        %aux_image=impyramid(aux_image, 'reduce'); % ejemplo con pyramid de
        %matlab
        aux_image=imresize(aux_image,scale_imaget);
        size_image=size(aux_image);
        count_iterations=count_iterations+1;
        factor=scale_imaget^(count_iterations-1); %scalation factor error in the flotant point
    end
    if(size(bbox,1)>1)
        bbox=eliminated_repeated(bbox,pixelCandidates); % se elimina las areas que se sobre ponen
    end
end