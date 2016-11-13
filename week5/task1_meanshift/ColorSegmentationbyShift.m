function mainW5_meanShift()
%-------------------------------------------------------------------------
%   Parameters |    Value
%--------------------------------------------------------------------------
%   No input. Paths automatically added on start.
%   bandwidth       Shall be set for mean shift
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%   Output: 
%   -Histogram model for Hue and Saturation in HSV colorspace for each  
%   signal class stored within trainingSet structure.
%   -trainingSet2.mat file for latter use in ColorUsingMeanShift06w5
%   function.
%--------------------------------------------------------------------------
%NOTE: Run 'dataSet_generate' prior to this.  

    
%Paths    
    GlobalPath = './';
    pathTrain = [ GlobalPath 'train\'];
    pathTest = [ GlobalPath 'test\'];

    %Check if there is al old file in directory and delete
    filename = 'trainingSet2.mat';
    if exist(filename, 'file')==2
        delete('trainingSet2.mat');
    end
       
    bandwidth = 0.125;
    
    %define the color spaces and alternative of these spaces
    colorSpace = 'HSV'; %colorspaces :  RGB_histeq, HSV, RGB, LAB,RGB_imadjust
    %method to train the model
    model='2Dhist'; % models : Kmeans, 2Dhist, gaussian,gaussian_HSV (with only HS)
    %method to test the model
    evaluation = '2Dhist'; %Threshold, centroidDistance,gaussian_mixture,hand
    
    'Recalculating data with the new dataset...'

    trainingSet=task1([ GlobalPath '\splitDataset\'],[GlobalPath 'splitDataset\train\']);
    ['Obtaining colour feautures from ' colorSpace ' space colour...']
    trainingSet=task3([ GlobalPath '\splitDataset\'],[GlobalPath 'splitDataset\train\'],colorSpace,model,trainingSet,bandwidth);
    
    save(filename);
    'saved...'
    
    MeanShiftLaunch(trainingSet, bandwidth);

end