//Made with ImageJ 1.53t
//Made by Mariana Ferreira @ IGC
//Open each individual series from a single .lif file and allow the user to crop an area of interest, then do a Difference of Gaussian and save the result as a .tif


macro "Difference of Gaussian Action Tool - C000 T0b07R T6b07a Tcb07n Teb07d Thb07o" {
	
	//Cleans work environment
	run("Close All");
	run("Clear Results");
	close("Results");
	close("ROI Manager");
	
	//Check for needed plugins	
	// N/A
	
	//Initialize and set constant parameters
	run("Bio-Formats Macro Extensions");
	
	//Select directory and macro retrieves file list
	img_path = File.openDialog("Choose Image to split");
	directory = File.getDirectory(img_path);

	//Create base variables and arrays
	max_prefix = "MAX_";
	
	//Placeholder variables
	// N/A
	
	//Get Series info from file using bioformats macro extensions
	Ext.setId(img_path);
	Ext.getSeriesCount(seriesCount);
	
	//Get file name with and W/o extension and make new save directory folder
	img_ID = File.getName(img_path);
	img_name = File.getNameWithoutExtension(img_path);
	
	save_dir = directory + "/" + img_name + "_Split_DoG/";
	File.makeDirectory(save_dir);
	
	setBatchMode(true);
	
	//Loop opens each series in the file and check if z-satck then does a max projection and saves in the new folder
	for(s = 1; s <= seriesCount; s++){
		//Resetable variables
		region_loop = 1;
		skip_img = 0;
		xpoints = newArray();
		ypoints = newArray();
		
		//Open current series and get series name
		run("Bio-Formats Importer", "open=[" + img_path + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_" + s);
		work_img = getTitle();
		series_name = substring(work_img, lengthOf(img_ID) + 3);
		rename(series_name);
		
		//Create split channel variable names
		ch_green = "C1-" + series_name;
		ch_red = "C2-" + series_name;
		ch_bf = "C3-" + series_name;
		ch_list = newArray(ch_green, ch_red);
		
		getDimensions(width, height, channels, slices, frames);
		
		//Split channels and create MIPs and remerge to check area to analyze
		run("Split Channels");
		
		selectImage(ch_green);
		run("Z Project...", "projection=[Max Intensity]");	
		selectImage(ch_red);
		run("Z Project...", "projection=[Max Intensity]");	
		
		selectImage(ch_bf);
		setBatchMode("show");
		
		//Merge the 2 fluorescence MIPs and auto B&C
		run("Merge Channels...", "c1=[" + max_prefix + ch_red + "] c2=[" + max_prefix + ch_green + "] create");
		rename("Composite - " + series_name);
				
		Stack.setDisplayMode("color");
		Stack.setChannel(1);		
		run("Enhance Contrast", "saturated=0.35");
		Stack.setChannel(2);		
		run("Enhance Contrast", "saturated=0.35");
		Stack.setDisplayMode("composite");
		setBatchMode("show");
		
		//Loop to check image 
		while ( region_loop == 1 ){
			setTool("polygon");
			waitForUser("Inspect the maximum intensity projection and draw a polygon region of interest.\n Press ok when done \n Select nothing if you want to skip this image.");
			if (selectionType() == -1){
				skip_img = getBoolean("Are you sure you want to skip this image?");
				if ( skip_img == 1){
					region_loop = 0;
				}	
			}
			if ( selectionType() == 2 ){
				region_loop = 0;
			}
		}
		if (skip_img == 1){
			run("Close All");
			continue;
		}
		
		//Save selection coordinates made by user
		getSelectionCoordinates(xpoints, ypoints);
		
		//Close no longer needed images
		close("Composite - " + series_name);
		close(ch_bf);
		
		//Start difference of gaussian loop which includes crop from region
		for (c = 0; c < lengthOf(ch_list); c++) {	
			selectImage(ch_list[c]);
			makeSelection(2, xpoints, ypoints);
			run("Crop");	
			run("Select None");		
			gauss_1 = "gauss_1_" + ch_list[c];
			gauss_2 = "gauss_2_" + ch_list[c];
			
			run("Duplicate...", "title=[" + gauss_1 + "] duplicate");
			run("Gaussian Blur...", "sigma=1 stack");
				
			selectImage(ch_list[c]);
			run("Duplicate...", "title=[" + gauss_2 + "] duplicate");
			run("Gaussian Blur...", "sigma=2 stack");
			
			imageCalculator("Subtract create stack", gauss_1 ,gauss_2);
			rename("DoG_" + ch_list[c]);
		}
		
		run("Merge Channels...", "c1=[DoG_" + ch_red + "] c2=[DoG_" + ch_green + "] create");
		rename("DoG_" + series_name);
		
		saveAs(".tif", save_dir + "DoG_" + series_name);		
		
		run("Close All");	
	}
	exit("Done!");
}
		
	
	
