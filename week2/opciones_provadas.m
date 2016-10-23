%[f1 = 0.511385,pixelPrecision = 0.697041, pixelAccuracy = 0.996911, pixelSpecificity = 0.999295, pixelSensitivity = 0.403826, elapse time = 0.016095, TP = 370814 FP = 161169, FN = 547437] 
    %open cicles
    imageres=imclose(image,strel('disk',8));
    imageres=imfill(imageres);
    
    %erase noise
    imageres=imopen(imageres,strel('square',5));
    
    %imageres=imclose(imageres,strel('disk',15));
    
    %delete post
    imageres=imclose(imageres,strel('line',15,90));
    imageres=imopen(imopen(imageres,strel('square',8)),strel('square',9));
    
    
    
%[f1 = 0.525115,pixelPrecision = 0.713463, pixelAccuracy = 0.996992, pixelSpecificity = 0.999329, pixelSensitivity = 0.415442, elapse time = 0.023380, TP = 381480 FP = 153208, FN = 536771]    
    %imageres=imopen(image,strel('square',2));
    %cicle signals
    imageres=imclose(image,strel('disk',8));
    imageres=imfill(imageres);
    
    %erase noise
    imageres=imopen(imageres,strel('square',5));
    
    %square signals
    imageres=imclose(imageres,strel('line',15,90));
    imageres=imclose(imageres,strel('line',25,0));
    
    imageres=imfill(imageres);
    
    imageres=imclose(imageres,strel('disk',15));
    imageres=imopen(imageres,strel('square',15));
        %imerode(imageres,strel('square',12))
    %delete post
    imageres=imclose(imageres,strel('line',15,90));
    imageres=imopen(imopen(imageres,strel('square',8)),strel('square',9));
   
    
    
    

