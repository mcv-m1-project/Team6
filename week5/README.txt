Task 1 meanshift(folder task1_meanshift):
	IMPLEMENTATION OF MEAN SHIFT APPROACH FOR REPLACING COLOR SEGMENTATION

	This implementation takes the split data directories, and applies mean shift
	segmentation with colour and spatial features instead of colour histograms.
	The colour space is HSV and only hue and saturation channels are computed.
	First, signal samples from training set are segmented. This way, colour palette 
	to contrast with is reduced. 
	On the other hand, the same process of colour and spatial mean shift segmentation  
	is applied to each image before searching for pixel candidates. Therefore, only
	the cluster center hue and saturation values are compared to samples through 
	euclidean distance. In case that this distance is beneath a manually set threshold,
	all pixels from the given cluster are considered as signal candidates.
	 
	The process is as follows:
	- Run function traininSet_generate() in order to create the split dataset working 
	directories.
	- Then run ColorSegmentationbyShift (), to process the images. 

	No inputs for these functions are requiered. Just make sure that you have the dataset
	images, gt folder and mask folder within  a folder named 'train'.



	Main function: 

	function ColorSegmentationbyShift ()
	%-------------------------------------------------------------------------
	%   Parameters   |    Value
	%--------------------------------------------------------------------------
	%   No input. 	      Paths automatically added on start.
	%   bandwidth         Shall be set for mean shift
	%--------------------------------------------------------------------------
	%--------------------------------------------------------------------------
	%   Output: 
	%   -Histogram model for Hue and Saturation in HSV colorspace for each  
	%   signal class stored within trainingSet structure.
	%   -.png files for masks results stored in './mask_result' directory
	%--------------------------------------------------------------------------

Task 1 UCM (folder task1_ucm):
	This task use the week5_task1_ucm_train and week5_task1_ucm_test as main files. It use the color segmentation 
	from the previous weeks so it accept the same parameters(but only have been test with the colorSpace = 'HSV';
	model='2Dhist'; evaluation = '2Dhist';). The other params are the global path and the relative path use by each
	function.
	
	As requiremnts it's needs the software packet "segment-ucm" because we use the im2mcg function in 
	select_regions_candidats_ucm. The select_regions_candidats_ucm(image_input,color_mask,windowSet) 
	compute the ucm of the image_input. It use color_mask and the stadistics in windowSet to detect the signals 
	in the regions of the ucm image.
	
Task 2 Hough (folder task2_hough):
	For execute week 5 task 2, using CCL + Hough you only need to open start_week5_task2.m, add to the current
	path the next folders: 'circular_hough' and 'evaluation' in order to execute the inner fuctions located there.
	Remember to define properly the paths for train and test in the variables pathTrain and pathTest if they aren't
	in the main path of the mat files.
	Evaluation function is commented to avoid a evaluation on test if gt is not there.
	When you execute start_week5_task2.m the folders for results will be created automatically if they don't exist
	Files created
		- start_week5_task2.m
		- model_creation.m (prepare the parameters and values from the train)
		- connected_components_hough.m (perform Hough in CCL regions)
		- evalmodel_with_windows.m (modified for read .mat bounding boxes but actually don't work properly)

