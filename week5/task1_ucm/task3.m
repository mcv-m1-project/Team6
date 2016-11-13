%function to generate the models fro every class
function trainingSet=task3(GlobalPath,pathTrain,colorSpace,model,trainingSet)
    subtrainPath = [GlobalPath 'train/']; 
    fields = fieldnames(trainingSet);
    for countfieldsi = 1:numel(fields)
            if ~isempty(strfind(fields{countfieldsi},'class'))
                for signal=1:trainingSet.(fields{countfieldsi}).number
                    fileName = trainingSet.(fields{countfieldsi}).signal(signal).imageName;
                    boundingBox = trainingSet.(fields{countfieldsi}).signal(signal).boundingBox;
                    values = CalculateValuesFromColorSpace(subtrainPath,colorSpace,fileName,boundingBox);
                    trainingSet.(fields{countfieldsi}).signal(signal).values = values;
                end
                arraysamples = [trainingSet.(fields{countfieldsi}).signal.values];    
                trainingSet.(fields{countfieldsi}).model=CalculateModel(arraysamples,model,2);
            end
    end
end