function M1ProjectGroup06_test()
   
    %Paths
    global lengthRGB;
    lengthRGB = 10;
    
    GlobalPath = './';
    pathTrain = [ GlobalPath 'train\'];
    pathTest = [ GlobalPath 'test\'];
    
    %define the color spaces and alternative of these spaces
    colorSpace = 'HSV'; %colorspaces :  RGB_histeq, HSV, RGB, LAB,RGB_imadjust
    %method to train the model
    model='2Dhist'; % models : Kmeans, 2Dhist, gaussian,gaussian_HSV (with only HS)
    %method to test the model
    evaluation = '2Dhist'; %Threshold, centroidDistance,gaussian_mixture,hand,2Dhist
    
    'obtaining data ...'
    trainingSet=task1(GlobalPath,pathTrain);
    trainingSet=task3(GlobalPath,pathTrain,colorSpace,model,trainingSet);
    
    'evaluating model... '
    evalmodel_test(pathTest,trainingSet,evaluation,colorSpace);
end