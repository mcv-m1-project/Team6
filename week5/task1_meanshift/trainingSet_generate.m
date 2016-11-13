function trainingSet_generate()
%-------------------------------------------------------------------------
%   Parameters |    Value
%--------------------------------------------------------------------------
%   No input. Paths automatically added on start.
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%   Output: 
%   -spliDataset directory with images, masks and gt files sorted
%   out.
%   (Currently unused) -trainingSet.mat file for latter use in ColorSegmentationbyshift
%   function.
%--------------------------------------------------------------------------
%NOTE: Run this function to generate the trainingSet structure with the
%training and test images that end stored in splitDataset folder. The
%structure trainingSet is stored as .mat file for latter use in
%ColorSegmentationbyshift function.

    clearvars
    %Paths
    global lengthRGB;
    lengthRGB = 10;
    
    GlobalPath = './';
    pathTrain = [ GlobalPath 'train\'];
    pathTest = [ GlobalPath 'test\'];
    if (exist([ GlobalPath '\splitDataset\'],'dir') ~= 0)
        rmdir([ GlobalPath '\splitDataset\'],'s');
    end

    
    %Check if there is al old file in directory and delete
    filename = 'trainingSet';
    if exist(filename, 'file')==2
        delete('trainingSet');
    end
    
    global trainingSet
    trainingSet = struct();
    trainingSet.samples = 0;
    trainingSet.classABC.number = 0;
    trainingSet.classDF.number = 0;
    trainingSet.classE.number = 0;
    
    
    trainingSet = task1(GlobalPath,pathTrain,trainingSet);
    task2(GlobalPath,pathTrain,trainingSet);
    
%     save(filename,'trainingSet');
    'trainingSet created...'
end