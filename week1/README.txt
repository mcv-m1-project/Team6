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
