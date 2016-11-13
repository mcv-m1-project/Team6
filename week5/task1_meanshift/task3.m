%function to generate the models fro every class
function trainingSet=task3(GlobalPath,subtrainPath,colorSpace,model,trainingSet,bandwidth)
    
%     subtrainPath = [GlobalPath '/train/']; 
    fields = fieldnames(trainingSet);
    
    for countfieldsi = 1:numel(fields) %for the fields within the trining structure
            if ~isempty(strfind(fields{countfieldsi},'class'))
                %cycle through every signal of the given class
                for signal=1:trainingSet.(fields{countfieldsi}).number
                    fileName = trainingSet.(fields{countfieldsi}).signal(signal).imageName;
                    boundingBox = trainingSet.(fields{countfieldsi}).signal(signal).boundingBox;
                    values = CalculateValuesFromColorSpace(subtrainPath,colorSpace,fileName,boundingBox,bandwidth);
                    trainingSet.(fields{countfieldsi}).signal(signal).values = values;
                end
                %with the color values for each class, construct a model
                %(in this case color histogram)
                arraysamples = [trainingSet.(fields{countfieldsi}).signal.values];
                trainingSet.(fields{countfieldsi}).model=CalculateModel(arraysamples);
            end
    end
end