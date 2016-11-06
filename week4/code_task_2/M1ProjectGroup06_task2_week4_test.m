function M1ProjectGroup06_test()
   
    %Paths
    global lengthRGB;
    lengthRGB = 10;
    
    GlobalPath = './';
    pathTrain = [ GlobalPath 'train\'];
    pathTest = [ GlobalPath 'test\'];
    path_templates=[GlobalPath 'mascara/'];
    windowSet=split_by_shape(GlobalPath,'splitDataset\train\',path_templates);
    save('window_set.mat','windowSet');
    'evaluating model... '
    load 'window_set.mat'
    trainingSet=struct;
    evalmodel_with_windows_test([GlobalPath 'mask_result_test\'],windowSet);
end