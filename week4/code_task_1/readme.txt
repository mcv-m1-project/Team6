To perform CCL and CCL+correlation method of this week 4, you need to run start_week4_task() and in the variable method especify
if you want to perfom Connected Component Labeling (CCL) or CCL plus correlation region (CCL+conv), also you need to be sure that
the variables pathTrain, pathTest and GlobalPath, containt the path of the train dataset, test dataset and current folder of the 
files respectively.
When you execute start_week4_tesk1() automatically some folders will be created on the test path according to result for masks and 
annotation files and the evaluation also will display on the console the evaluation of the system. Actually is prepared to run with
the split dataset.
Files created
	- start_week4_task1.m
	- model_creation.m (prepare the parameters and values from the train)
	- connected_components.m (perform CCL)
	- connected_components_corr.m (performs CCL+correlation region)
	- evalmodel_with_windows.m (modified for read .mat bounding boxes but actually don't work properly)