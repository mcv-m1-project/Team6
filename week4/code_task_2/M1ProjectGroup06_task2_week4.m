function M1ProjectGroup06()
   
    %Paths
    global lengthRGB;
    lengthRGB = 10;
    
    GlobalPath = './';
    pathTrain = [ GlobalPath 'train\'];
    pathTest = [ GlobalPath 'test\'];
    path_templates=[GlobalPath 'mascara/'];

    windowSet=split_by_shape(GlobalPath,'splitDataset\train\',path_templates,0);
    save('window_set.mat','windowSet');
    'evaluating model... '
    load 'window_set.mat'
    evalmodel_with_windows([GlobalPath 'splitDataset\test\'],windowSet);
end