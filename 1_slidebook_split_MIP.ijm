//Made with ImageJ 1.53q
//Made by Mariana Ferreira @ IGC


macro "SLD Split Max Action Tool - C000 T0b07R T6b07a Tcb07n Teb07d Thb07o" {
	
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
	img_path = File.openDialog("Choose Image");
	directory = File.getDirectory(img_path);

	//Create base variables and arrays
	// N/A
	
	//Placeholder variables
	// N/A
	
	//Get Series info from file using bioformats macro extensions
	Ext.setId(img_path);
	Ext.getSeriesCount(seriesCount);
	
	//Get file name with and W/o extension and make new save directory folder
	img_ID = File.getName(img_path);
	img_name = File.getNameWithoutExtension(img_path);
	
	save_dir_bf = directory + "/" + img_name + "_Split_BF/";
	
	save_dir_mip = directory + "/" + img_name + "_Split_MIP/";
	File.makeDirectory(save_dir_mip);
	
	setBatchMode(true);
	
	//Loop opens each series in the file and check if z-satck then does a max projection and saves in the new folder
	for(s = 1; s<= seriesCount; s++){
		//Open current series
		run("Bio-Formats Importer", "open=[" + img_path + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_" + s);
		work_img = getTitle();
		series_name = substring(work_img, lengthOf(img_ID) + 3);
		work_img = "BF_" + series_name;
		
		getDimensions(width, height, channels, slices, frames);
		
		//If image is brightfield save in bf directory
		if ( slices == 1){
			if ((File.exists(save_dir_bf)) == 0) {
				File.makeDirectory(save_dir_bf);
			}
			saveAs(".tif", save_dir_bf + work_img);		
		}
		
		//If image is Zstack do max projection and save in mip directory
		if ( slices != 1){
			run("Z Project...", "projection=[Max Intensity] all");
			work_img = "MAX_" + series_name;
			saveAs(".tif", save_dir_mip + work_img);
		}
		
		
		run("Close All");
		
	}
	
	exit("Done!");
}
		
	
	