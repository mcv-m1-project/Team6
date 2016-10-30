week1:
	In order to use the code you have to open M1ProjectGroup06.m. 
	The main function(M1ProjectGroup06) define the params to execute the algorithms.
	Explanation of the vars:

	lengthRGB: define the area in rgb used to consider a pixel as good.

	GlobalPath: path to the folder of image could be set with absolute path or relative
	pathTrain = [ GlobalPath 'train\']; : path to train
	pathTest = [ GlobalPath 'test\']; : path to test only used to generate the mask

	colorSpace: define the colorspces used the possible ones are  RGB_histeq, HSV, RGB, LAB, RGB_imadjust
	model: define the method used to generate our model of data, the possible ones are kmeans, 3Dhist, gaussian, gaussian_HSV (with only HS),hand
	evaluation: define the evaluation method. These are related to the model var. The possible ones are Threshold, centroidDistance, gaussian_mixture, hand




	Only some combinations are possible:

	All three RGB colorspace (RGB,RGB_histeq,RGB_imadjust) could be used with kmeans, 3Dhist, gaussian, hand.
	The HSV colorspace could only be used in gaussian_HSV because we limited the number of features to two and
	the other models expect 3 features or RGB values.
	The hand model and evaluation method are the human estimation, they are some RGB values that we have estimated.
	The model doesn't do anything to the dataset, is only to follow the structure of conditions.
	 And in the evaluation part is where we make the filetring of pixels.

	the models and evaluation relations are the following:
	-----------------------------------------------
		model		evaluation
	--------------------------------------------------	
		kmeans		centroidDistance
		3Dhist		Threshold	
		gaussian	gaussian_mixture
		gaussian_HSV	gaussian_mixture
		hand		hand
week2:
	The first task is in task1w2.m the configuration is done in the command window, you could define a matrix of 0s and 1s which represent the estructural element and the method to use.
	There are also some comparative between the matlab method and the ones that we develop.
	We add the option 2Dhist to do the histogram back-projection.
	Also there is a morphoprocess which do the morpholical operation.
	
	There are to method to execute the script, M1ProjectGroup06.m would use the train images to do the split and test the alghoritm.
	M1ProjectGroup06_test.m is a copy of M1ProjectGroup06.m but configured to use the eval_test method to eval the testset and all the trainset to produce the models for each class.
	
week3:
	First the mask_result is generated with the code of the previous week, is required to execute the M1ProjectGroup06_week12.m or M1ProjectGroup06_week12_test.m and put
	the resolting mask in a folder call mask_result in the same path as the code. For M1ProjectGroup06_week3.m it's also required the folders gt and mask in a folder call train 
	(it's a folder where we put all the images for train without split). We have try to adapt the code of week 2 to obtain better results in the test set.
	
	The main file is M1ProjectGroup06_week3.m in this file there are some varible to config the differents path example:
	GlobalPath = './'; % the main path
    pathTrain = [ GlobalPath 'train\']; %path to all the images, mask and gt. Needed to do the measure for the diferent shapes of images.
    pathMasks = [GlobalPath 'mask_result\']; % path to the mask that we want to test
    pathresult_gt= [GlobalPath 'gt_result\']; % path where it will be same the .mat files
    if (exist( pathresult_gt,'dir') == 0) %if it doesn't exist we will created it
        mkdir( pathresult_gt,'s');
    end
    pathMasksAnnotation = [pathTrain 'mask\']; %path to the mask images to comapre
    pathAnnotation = [pathTrain 'gt/'];%path to the gt txt files of the images to comapre
    masks = dir([pathMasks '*.png']); %read all mask images path
	
	There is also the var type_window which could have the following values:ccl,window_sum, window_integral, convolution. It's computed the results for one of the methods corresponding for every task.
	
		
		
