%function to split in folders the train and validation dataset
function task2(GlobalPath,pathTrain,trainingSet)

    splitFactor = 0.3; %split factor for test
    %create folders and subfolders
    pathTrainSplit = [GlobalPath 'splitDataset/train/'];
    pathTrainSplitGt = [pathTrainSplit 'gt/'];
    pathTrainSplitMask = [pathTrainSplit 'mask/'];
    %Create folders if not exist
    if (exist(pathTrainSplit,'dir') == 0)
        mkdir(pathTrainSplit);
        if (exist(pathTrainSplitGt,'dir') == 0)
            mkdir(pathTrainSplitGt);
        end
        if (exist(pathTrainSplitMask,'dir') == 0)
            mkdir(pathTrainSplitMask);
        end
    end
    pathTestSplit = [GlobalPath 'splitDataset/test/'];
    pathTestSplitGt = [pathTestSplit 'gt/'];
    pathTestSplitMask = [pathTestSplit 'mask/'];
    if (exist(pathTestSplit,'dir') == 0)
        mkdir(pathTestSplit);
        if (exist(pathTestSplitGt,'dir') == 0)
            mkdir(pathTestSplitGt);
        end
        if (exist(pathTestSplitMask,'dir') == 0)
            mkdir(pathTestSplitMask);
        end
    end
    %calculate number of images to a certain split factor
    keySet =   {'ABC', 'DF', 'E'};
    classABCtest = round(splitFactor*trainingSet.classABC.number);
    classDFtest = round(splitFactor*trainingSet.classDF.number);
    classEtest = round(splitFactor*trainingSet.classE.number);
    valueSet = [classABCtest,classDFtest,classEtest];
    mapObj = containers.Map(keySet,valueSet); %container working as a dictionary
    %For every image the split dataset its progressively filled until the
    %number of images needed for every class is reached
    for nFile=1:trainingSet.samples
        validate = 1;
        newValueSet = cell2mat(values(mapObj));
        auxMapObj = containers.Map(keySet,newValueSet); %auxiliar container for update after checking
        for nSignal=1:trainingSet.image(nFile).numSignals
            %checking for every signal in a image determinate if adding this image
            %the number images frecuencies for every class will be correct
            classNum = mapObj(trainingSet.image(nFile).signal(nSignal).class);
            if (classNum - 1 == 0)
                validate = 0; 
            end
            auxMapObj(trainingSet.image(nFile).signal(nSignal).class) = classNum - 1;
        end
        %Copy training files in the new split validation or train folders
        if (validate)
            newValueSet = cell2mat(values(auxMapObj));
            mapObj = containers.Map(keySet,newValueSet);
            copyfile([pathTrain trainingSet.image(nFile).name '.jpg'],pathTestSplit);
            copyfile([pathTrain 'gt/gt.' trainingSet.image(nFile).name '.txt'],pathTestSplitGt);
            copyfile([pathTrain 'mask/mask.' trainingSet.image(nFile).name '.png'],pathTestSplitMask);
        else
            copyfile([pathTrain trainingSet.image(nFile).name '.jpg'],pathTrainSplit);
            copyfile([pathTrain 'gt/gt.' trainingSet.image(nFile).name '.txt'],pathTrainSplitGt);
            copyfile([pathTrain 'mask/mask.' trainingSet.image(nFile).name '.png'],pathTrainSplitMask);
        end
    end
end