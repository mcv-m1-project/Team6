function M1ProjectGroup06()
   
    %Paths
    global lengthRGB;
    lengthRGB = 10;
    
    GlobalPath = './';
    pathTrain = [ GlobalPath 'train\'];
    pathTest = [ GlobalPath 'test\'];
    if (exist([ GlobalPath '\splitDataset\'],'dir') ~= 0)
        rmdir([ GlobalPath '\splitDataset\'],'s');
    end
    
    %define the color spaces and alternative of these spaces
    colorSpace = 'HSV'; %colorspaces :  RGB_histeq, HSV, RGB, LAB,RGB_imadjust
    %method to train the model
    model='2Dhist'; % models : Kmeans, 2Dhist, gaussian,gaussian_HSV (with only HS)
    %method to test the model
    evaluation = '2Dhist'; %Threshold, centroidDistance,gaussian_mixture,hand
    
    
    
    'obtaining data ...'
    trainingSet=task1(GlobalPath,pathTrain);
    'Splitting train data in 70% train 30% test...'
    task2(GlobalPath,pathTrain,trainingSet);
    'Recalculating data with the new dataset...'

    trainingSet=task1([ GlobalPath '\splitDataset\'],[GlobalPath 'splitDataset\train\']);
    ['Obtaining colour feautures from ' colorSpace ' space colour...']
    trainingSet=task3([ GlobalPath '\splitDataset\'],[GlobalPath 'splitDataset\train\'],colorSpace,model,trainingSet);
    
    'evaluating model... '
    evalmodel([GlobalPath 'splitDataset\test\'],trainingSet,evaluation,colorSpace);
    %evalmodel(pathTest,trainingSetDone,evaluation,colorSpace);
end