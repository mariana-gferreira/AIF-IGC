//Made with ImageJ 1.53q
//Made by Mariana Ferreira @ IGC

macro "Randomizer Action Tool - C000 T0b07R T6b07a Tcb07n Teb07d Thb07o" {
	
	//Cleans work environment
	run("Close All");
	run("Clear Results");
	close("Results");
	close("ROI Manager");
	
	//Check for needed plugins	
	//N/A
	
	//Initialize and set constant parameters
	// N/A
	
	//Select directory and macro retrieves file list
	directory = getDirectory("Choose Directory with the Images");
	list = getFileList(directory);

	//Create base variables and arrays
	prefix = "MAX_";
	suffix = ".tif";
	min_samples = 5;
	percentage_samples = 10;
	
	//Placeholder variables
	folder_count = 1;
	sample_count = 0;
	trainer_count = 1;
	
	//Create user interaction dialog
	Dialog.create("Information - Images");
	Dialog.addString("File Name Prefix:", prefix);
	Dialog.addString("File type:", suffix);
	Dialog.addNumber("Minimum number of samples per images", min_samples);
	Dialog.addNumber("% of total for samples", percentage_samples);
	Dialog.show();
	
	//Get information from dialog
	prefix = Dialog.getString();
	suffix = Dialog.getString();
	min_samples = Dialog.getNumber();
	percentage_samples = Dialog.getNumber();
	
	//Check if a save directory already exists, if yes create a new one
	save_dir = directory + "/Training_Dataset_1/";
	
	while ((File.exists(save_dir)) == 1) {
		save_dir = directory + "/Training_Dataset_"+ folder_count + "/";
		folder_count++;
	}
	
	File.makeDirectory(save_dir);
	
	//Batchmode for faster and no flickering
	setBatchMode(true);
	
	//Loop over file list	
	for(i = 0; i < lengthOf(list); i++){
		filename = list[i];
		
		//Check if file matches prefix and file type of interest
		if( (startsWith(filename, prefix)) && (endsWith(filename, suffix)) ){
			open(directory + filename);
			getDimensions(width, height, channels, slices, frames);
			
			//Get percentage calculation -- only runs on first open image
			if (sample_count == 0) {
				sample_percent_number = Math.abs(percentage_samples / 100 * frames);
				sample_count = maxOf(min_samples, sample_percent_number);				
			}
			
			//Repeat loop to randomly extract a frame and save it until number extracted matches percentage calculation
			for(s = 0; s < sample_count; s++){
				get_frame = Math.ceil((frames * random)); //Math ceiling to round up any floats
				save_name = toString(trainer_count, 0) + "_traning_image_" + filename;
				
				selectImage(filename);
				setSlice(get_frame);
				run("Duplicate...", "title=" + save_name);
				
				saveAs(".tif", save_dir + save_name);
				close(save_name);
				
				trainer_count++;
				
			}
		close(filename);			
			
		}
		
	}
	exit("Done!");
}	
