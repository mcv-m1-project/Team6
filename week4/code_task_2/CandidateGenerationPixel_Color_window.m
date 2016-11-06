function pixelCandidates = CandidateGenerationPixel_Color_window(im, windowCandidates)
    pixelCandidates=zeros(size(im,1),size(im,2));
    for count_bbox=1:size(windowCandidates,1)
        x=windowCandidates(count_bbox).y;
        y=windowCandidates(count_bbox).x;
        h=windowCandidates(count_bbox).w;
        w=windowCandidates(count_bbox).h;
        pixelCandidates(x:x+w,y:y+h)=im(x:x+w,y:y+h);
    end
end