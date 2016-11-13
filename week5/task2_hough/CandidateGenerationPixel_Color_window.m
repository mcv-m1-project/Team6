function pixelCandidates = CandidateGenerationPixel_Color_window(im, windowCandidates)
    pixelCandidates=zeros(size(im,1),size(im,2));
    for count_bbox=1:size(windowCandidates,1)
        x=windowCandidates(count_bbox).y;
        y=windowCandidates(count_bbox).x;
        h=windowCandidates(count_bbox).w;
        w=windowCandidates(count_bbox).h;
        height = x+w;
        width = y+h; 
        if (height > size(im,1))
            height = size(im,1);
        end
        if (width > size(im,2))
            width = size(im,2);
        end
        pixelCandidates(x:height,y:width)=im(x:height,y:width);
    end
end