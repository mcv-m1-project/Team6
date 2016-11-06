%function load the diferents datasets
function trainingSet=split_by_shape(GlobalPath,pathTrain,path_templates,auto_template)
    pathGt = [ pathTrain 'gt\'];
    pathMask = [ pathTrain 'mask\'];
    images = dir([pathTrain '*.jpg']); %read images path
    windows_shape=[50 50];
    % for every annotation file
    trainingSet=struct;
    trainingSet.samples = length(images);
    trainingSet.classA.number = 0;
    trainingSet.classB.number = 0;
    trainingSet.classCDE.number = 0;
    trainingSet.classF.number = 0;
    
    if(auto_template==0)
        trainingSet.classA.template = imread([path_templates 'triangle.png']);
        trainingSet.classB.template = imread([path_templates 'triangle_inv.png']);
        trainingSet.classCDE.template = imread([path_templates 'circle.png']);
        trainingSet.classF.template = imread([path_templates 'rectangle.png']);
    end
    
    trainingSet.classA.template = imresize(trainingSet.classA.template(:,:,1),windows_shape);
    trainingSet.classB.template =  imresize(trainingSet.classB.template(:,:,1),windows_shape);
    trainingSet.classCDE.template =  imresize(trainingSet.classCDE.template(:,:,1),windows_shape);
    trainingSet.classF.template =  imresize(trainingSet.classF.template(:,:,1),windows_shape);

    for nFile=1:trainingSet.samples
        fileName = strsplit(images(nFile).name,'.'); % split string with '.'
        fileName = [fileName{1} '.' fileName{2}];   %Select part that is the name
        fid = fopen([pathGt 'gt.' fileName '.txt'], 'r' );
        size = [5 Inf];
        file = fscanf(fid,'%f %f %f %f %c',size); %read the annotation file
        if ~isempty(file)
            maskImage = logical(imread([pathMask 'mask.' fileName '.png']));
            file = file';
            trainingSet.image(nFile).name = fileName;
            trainingSet.image(nFile).numSignals = length(file(:,1));
            boundingBoxes = [round(file(:,1)) round(file(:,2)) round(file(:,3)) round(file(:,4))];
            class = char(file(:,5)); %convert to char the column that correspond to signal class
            for n=1:trainingSet.image(nFile).numSignals %for every signal in the image
                trainingSet.image(nFile).signal(n).boundingBox = boundingBoxes(n,:); %save the bpunding box
                trainingSet.image(nFile).signal(n).class = convert_class_signal(class(n));    % signal class
                trainingSet.image(nFile).signal(n).realclass = class(n);
                width = boundingBoxes(n,4) - boundingBoxes(n,2); 
                height = boundingBoxes(n,3) - boundingBoxes(n,1);
                boundingBox = [boundingBoxes(n,2) boundingBoxes(n,1) width height]; %new convention for easy crops
                trainingSet.image(nFile).signal(n).aspectRatio = width/height; %aspect ratio
                
                pixels = sum(sum(maskImage(boundingBoxes(n,1):...
                    boundingBoxes(n,3),boundingBoxes(n,2):boundingBoxes(n,4))));
                trainingSet.image(nFile).signal(n).fillingRatio = pixels/(width*height); % filling ratio
                if(auto_template==1)
					image_orginal=rgb2gray(imread([pathTrain images(nFile).name]));
					image_edge=edge(image_orginal,'canny',0.99);
					image_edge=immultiply(image_edge,maskImage);
					template_edge=image_edge(boundingBoxes(n,1):...
					boundingBoxes(n,3),boundingBoxes(n,2):boundingBoxes(n,4));
					resizeimage=imresize(template_edge,windows_shape);
				end
                % class counter
                switch (trainingSet.image(nFile).signal(n).class)
                    case 'A'
                        trainingSet.classA.number = trainingSet.classA.number+1;
                        trainingSet.classA.signal(trainingSet.classA.number).boundingBox = boundingBox;
                        trainingSet.classA.signal(trainingSet.classA.number).imageName = trainingSet.image(nFile).name;
                        
                        trainingSet.classA.signal(trainingSet.classA.number).width = width;
                        trainingSet.classA.signal(trainingSet.classA.number).height = height;
                        trainingSet.classA.signal(trainingSet.classA.number).aspectRatio = trainingSet.image(nFile).signal(n).aspectRatio;
                        trainingSet.classA.signal(trainingSet.classA.number).fillingRatio = trainingSet.image(nFile).signal(n).fillingRatio ;
                        trainingSet.classA.signal(trainingSet.classA.number).pixels = pixels;
                        trainingSet.classA.manualAdj = 0.9;
                        if(auto_template==1)
                            trainingSet.classA.template=trainingSet.classA.template+resizeimage;
                        end
                    case 'B'
                        trainingSet.classB.number = trainingSet.classB.number+1;
                        trainingSet.classB.signal(trainingSet.classB.number).boundingBox = boundingBox;
                        trainingSet.classB.signal(trainingSet.classB.number).imageName = trainingSet.image(nFile).name;
                        
                        trainingSet.classB.signal(trainingSet.classB.number).width = width;
                        trainingSet.classB.signal(trainingSet.classB.number).height = height;
                        trainingSet.classB.signal(trainingSet.classB.number).aspectRatio = trainingSet.image(nFile).signal(n).aspectRatio;
                        trainingSet.classB.signal(trainingSet.classB.number).fillingRatio = trainingSet.image(nFile).signal(n).fillingRatio ;
                        trainingSet.classB.signal(trainingSet.classB.number).pixels = pixels;
                        trainingSet.classB.manualAdj = 0.9;
                        if(auto_template==1)
                             trainingSet.classB.template=trainingSet.classB.template+resizeimage;
                        end
                    case 'CDE'
                        trainingSet.classCDE.number = trainingSet.classCDE.number+1;
                        trainingSet.classCDE.signal(trainingSet.classCDE.number).boundingBox = boundingBox;
                        trainingSet.classCDE.signal(trainingSet.classCDE.number).imageName = trainingSet.image(nFile).name;   
                        
                        trainingSet.classCDE.signal(trainingSet.classCDE.number).width = width;
                        trainingSet.classCDE.signal(trainingSet.classCDE.number).height = height;
                        trainingSet.classCDE.signal(trainingSet.classCDE.number).aspectRatio = trainingSet.image(nFile).signal(n).aspectRatio;
                        trainingSet.classCDE.signal(trainingSet.classCDE.number).fillingRatio = trainingSet.image(nFile).signal(n).fillingRatio ;
                        trainingSet.classCDE.signal(trainingSet.classCDE.number).pixels = pixels;
                        trainingSet.classCDE.manualAdj = 0.9;
                        if(auto_template==1)
                            trainingSet.classCDE.template=trainingSet.classCDE.template+resizeimage;
                        end
                    case 'F'
                        trainingSet.classF.number = trainingSet.classF.number+1;
                        trainingSet.classF.signal(trainingSet.classF.number).boundingBox = boundingBox;
                        trainingSet.classF.signal(trainingSet.classF.number).imageName = trainingSet.image(nFile).name;      
                        
                        trainingSet.classF.signal(trainingSet.classF.number).width = width;
                        trainingSet.classF.signal(trainingSet.classF.number).height = height;
                        trainingSet.classF.signal(trainingSet.classF.number).aspectRatio = trainingSet.image(nFile).signal(n).aspectRatio;
                        trainingSet.classF.signal(trainingSet.classF.number).fillingRatio = trainingSet.image(nFile).signal(n).fillingRatio ;
                        trainingSet.classF.signal(trainingSet.classF.number).pixels = pixels;
                        trainingSet.classF.manualAdj = 1;
                        if(auto_template==1)
                            trainingSet.classF.template=trainingSet.classF.template+resizeimage;
                        end
                end
            end
        end
        fclose(fid);
    end
    fields = fieldnames(trainingSet);
    for class = 1:numel(fields)
        if ~isempty(strfind(fields{class},'class'))
            trainingSet.(fields{class}).meanaspectRatio = mean([trainingSet.(fields{class}).signal.aspectRatio]);
            trainingSet.(fields{class}).stdaspectRatio = std([trainingSet.(fields{class}).signal.aspectRatio]);
            
            trainingSet.(fields{class}).maxaspectRatio = max([trainingSet.(fields{class}).signal.aspectRatio]);
            trainingSet.(fields{class}).minaspectRatio = min([trainingSet.(fields{class}).signal.aspectRatio]);
            
            trainingSet.(fields{class}).meanfillingRatio = mean([trainingSet.(fields{class}).signal.fillingRatio]);
            trainingSet.(fields{class}).stdfillingRatio = std([trainingSet.(fields{class}).signal.fillingRatio]);
            
            trainingSet.(fields{class}).maxfillingRatio = max([trainingSet.(fields{class}).signal.fillingRatio]);
            trainingSet.(fields{class}).minfillingRatio = min([trainingSet.(fields{class}).signal.fillingRatio]);
            
            trainingSet.(fields{class}).maxwidth = max([trainingSet.(fields{class}).signal.width]);
            trainingSet.(fields{class}).minwidth = min([trainingSet.(fields{class}).signal.width]);
            
            trainingSet.(fields{class}).maxheight = max([trainingSet.(fields{class}).signal.height]);
            trainingSet.(fields{class}).minheight = min([trainingSet.(fields{class}).signal.height]);
            if(auto_template==1)
             trainingSet.(fields{class}).template=trainingSet.(fields{class}).template./trainingSet.(fields{class}).number;%clean the template
             trainingSet.(fields{class}).template= edge(trainingSet.(fields{class}).template,'canny',0.35);
            end
            trainingSet.(fields{class}) = rmfield(trainingSet.(fields{class}),'signal');
            
        else
            trainingSet= rmfield(trainingSet,fields{class});
        end
    end
end

function signal_class=convert_class_signal(org_class)
    switch (org_class)
        case 'A'
            signal_class='A';
        case 'B'
            signal_class='B';
        case 'C'
            signal_class='CDE';         
        case 'D'
            signal_class='CDE';                       
        case 'E'
            signal_class='CDE';
        case 'F'
            signal_class='F';
    end

end