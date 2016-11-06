week 4:
	This week every one has work in differents aproach to solve inconsistencies like the ones in the past week so the code is splited for every task.
	How to use for the Task 1:
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
		
	How to use for the Task 2:
		All the code is in the folder code_task_2.
		The main files are M1ProjectGroup06_task2_week4(use to make the test) and M1ProjectGroup06_task2_week4_test(used to comuted the imatge of test). In the main it expect to path_templates to indicate 
		where are the mask with the names triangle.png,triangle_inv.png,circle.png,rectangle.png. In [GlobalPath '/splitDataset/train/'] needs to be the training split of the previous weeks and in [GlobalPath '/splitDataset/test/'] 
		needs to be the  binary mask of the test split (validation) of the previous weeks. In the split_by_shape expects the path to train, the path to the tempaltes and if we want a artificial mask(previous parameter) or a mask calculated.
		In  evalmodel_with_windows(directory,windowSet) we compute all the necessary to make the resulting mask.The first param is the directori where are the binary mask and the second one is the struct with our model. 
		With windowCandidates=select_regions_candidats_edge(im,windowSet);  we test for every image al the mask in windowSet and scalars of them computing the canny version of the im and then it's distance matrix.
		This function will have has a oput the bbox candidates for this images. 
		Then CandidateGenerationPixel_Color_window will select only the segments of the image that appear in the bboxs and generats the resulting mask for the given images then we computed the stadistics.
		
		In Documentos in the server there are the necessary folders M1ProjectGroup06_task2_week4 and M1ProjectGroup06_task2_week4_test
