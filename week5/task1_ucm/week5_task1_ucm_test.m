function week5_task1_ucm_test()
   
    %Paths
    global lengthRGB;
    lengthRGB = 10;
    
    GlobalPath = './';
    pathTrain = [ GlobalPath 'train/'];
    pathTest = [ GlobalPath 'test/'];
    path_templates=[GlobalPath 'mascara/'];
    
    %define the color spaces and alternative of these spaces
    colorSpace = 'HSV'; %colorspaces :  RGB_histeq, HSV, RGB, LAB,RGB_imadjust
    %method to train the model
    model='2Dhist'; % models : Kmeans, 2Dhist, gaussian,gaussian_HSV (with only HS)
    %method to test the model
    evaluation = '2Dhist'; %Threshold, centroidDistance,gaussian_mixture,hand
    
 
     trainingSet=task1([ GlobalPath ''],[GlobalPath 'train/']);
     ['Obtaining colour feautures from ' colorSpace ' space colour...']
     trainingSet=task3(GlobalPath,[GlobalPath 'train/'],colorSpace,model,trainingSet);
     save('trainingSet_test.mat','trainingSet');
     'evaluating model... '
        
     
     windowSet=split_by_shape_week3(GlobalPath,'train/');
     save('window_set_test.mat','windowSet');
    'evaluating model... '
    load 'window_set_test.mat'
    load 'trainingSet_test.mat'
    evalmodel_with_windows_test([GlobalPath 'test/'],windowSet,trainingSet,evaluation,colorSpace);
end