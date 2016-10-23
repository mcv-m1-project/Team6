function imageres=morphoprocess(image)

    imageres=image;
    %try to reconstruct triangle
    for degress_count=40:50
        imageres=imclose(imageres,strel('line',15,90+degress_count));
        imageres=imclose(imageres,strel('line',15,degress_count));
    end
    imageres=imclose(imageres,strel('disk',8));
    
    %first try to remove noise
    imageres=imopen(imageres,strel('square',2));
    imageres=imfill(imageres);
    %cicle signals
    imageres=imclose(imageres,strel('disk',8));
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
end