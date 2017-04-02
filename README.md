# ROIextractor

## Introduction
The scripts (in an earlier version) in this repository was used in the article [Quantitative mass spectrometry imaging of small-molecule neurotransmitters in rat brain tissue sections using nanospray desorption electrospray ionization ](http://pubs.rsc.org/en/content/articlelanding/2016/an/c5an02620b#!divAbstract).

The scripts are for making images, extracting region of interest (ROI) data and summarizing the ROI data from [mass spectrometry imaging](https://en.wikipedia.org/wiki/Mass_spectrometry_imaging) (MSI) experiments using the [nanospray desorption electrospray 
ionization mass spectrometry](http://imaging.pnnl.gov/projects/posters/2013/2_2JLaskin_2013_fin.pdf) (nano-DESI) technique ([see also](https://www.emsl.pnl.gov/emslweb/news/birth-nanodesi)).

Quickly explained, nano-DESI is a technique where liquid is pumped out from one capillary (primary) and take up by another capillary (secondary) such that the liquid forms a liquid-bridge between the capillaries. When the liquid-bridge is in contact with a sample, molecules in the sample will be transferred to the liquid. In the liquid, the sample-molecules are transported (together with the liquid) through the secondary capillary to the mass spectrometer for measurement. At the mass spectrometer, the molecules are ionized (if able, here there is a bias in which molecules are ionized and how well). The mass spectrometer in its turn takes "snapshots" of the ionized molecules it gets.
The mass spectrometer will measure the intensity for each ratio of mass and charge (m/z) value to give a mass spectrum.

When using nano-DESI for MSI the two capillaries are moved over the surface (at a constant speed) collecting molecules from the sample. Due to that the mass spectrometer takes "snapshots" that take differently long to collect, the samples will not be evenly spaced and correction for that must be made later. When taking the ion image capillaries move in a straight line (x-direction) over the sample until it reach the end. There the capillaries will move to the beginning and start a new line a distance translated in y-direction, such that the measurements will be along parallel straight lines.

So, the ion image is made up of lines, where each line contains unevenly spaced "point" measurement (called scans). Each scan is a spectrum for the specific measurement and thus contains intensities for the measured m/z values.


## Files used by the scripts

The scripts use an intensity matrix file and a header file for each line in the ion image.

The matrix file contains intensities each row is for one m/z value and each column is for one combination of line number and scan number (line:scan, for example. "1:2" for line 1 and scan 2 in it).

The header files contain the (among some other things) the scan and its ion accumulation time (IT, time taken to collect ions) and cumulative retention time (RT, time from start of line until current scan).


## Definining a ROI
A ROI is defined by drawing an area in an image produced by the scripts (more precisely *1-make_images.R*). The images produced contains only the red and green channels of the image, leaving the blue channel empty. So, in any image produced an area can be drawn in blue to represent the ROI. The image cannot be re-sized since the scripts require the size to be the same. As pixels of a light blue colour might be removed, use a strong blue colour (preferred max in the blue channel).
Each ROI needs to be drawn in its own image and the ROI will be named the same as the file name of the ROI image from which it is produced.


## Targeted analysis
To quantify exact amounts of a molecule (the endogenous), an internal standard can be added to the liquid the takes up molecules from the sample. An internal standard is a molecule similar to the molecule of interest, like the same molecule with some heavier atoms, so that it is affected by ionization effect in the same way as the molecule of interest. As the internal standard is added by hand the concentration is known and the concentration of the endogenous molecule can be determined from the equation $C_{std}\frac{I_{end}}{I_{std}}$, where $C_{std}$ is the concentration of the internal standard, $I_{std}$ the intensity of the internal standard and $I_{end}$ the intensity of the endogenous molecule.


## Scripts/pipeline

The scripts are designed to be executed one after the other (in order of the starting number in the scripts file name) to form a pipeline. Any script can be executed by itself if *0-project_data.R* is executed before. In addition to the scripts that are executed there is the script *library.R* functions used by the other scripts. To run the scripts the packages *png* and *bigmemory* are required. The different script forming the pipeline are as follows:

#### 0-project_data.R
Contains the different variables (the comments in the file should be enough what the different variables mean) used by the other scripts. Executing the script will also load the intensity matrix and the header files. The script will also calculate a position matrix (a matrix that contains the line number and scan number in the position where it is in the image) used later for making images. Also, if some line:scan combinations lack measurements in the intensity matrix file (the column is missing), columns are added for each missing with the values 0 for each m/z.

#### 1-make_images.R
Makes an png image for each m/z in the intensity matrix (each named as the m/z value), except when there are too few non-zero values such that the image would be single coloured (images in this case are not produced so that one does not have to look through irrelevant images). Due to the uneven spacing of scans, an image with the scans (using one pixel per scan) lined up after each other in each line would be distorted. To remedy this the script finds the line with the most scans, then for each other line the scans with the longest IT will be elongated by one pixel until the line is as long as the longest line.

The images are coloured from black (for zero intensity) through red to yellow (max intensity). There is a problem that large outlier values for a scans m/z intensity would dominating the image and then each non-outlier pixel will be darker such that structures in the image will be harder to distinguish. This is remedied by removing (set to NA, then set equal to the max of the remaining intensities) the outliers. Outliers are detected using the *boxplot.stats* function, outliers are any values paste the extreme of the upper whisker in a box plot. It is due to this that an image with few non-zero would be mono-coloured (yellow).

##### Variables in 0-project_data.R required

The *make_experiment* function requires the *l_matrix_file*, *l_header_folder* and *l_image_height* variables to be set so the *intensity_matrix* can be loaded and the *position_matrix* (with *l_image_height* as the number pixels to extend each line) can be constructed. The *image_out_folder* variable is needed so that the ion images are written in the folder specified.


#### 2-check_roi.R
This script reads the ROI images and reads in the ROI area. As each line:scan combination takes up more than one pixel in the ion image, the true ROI takes up a larger area in the image and looks slightly different. The script draws the pixels with a line:scan combination in the ROI area in green in the ROI image and save to the folder given by *roi_check_folder*.

##### Variables in 0-project_data.R required
Again, the *make_experiment* function requires the *l_matrix_file*, *l_header_folder* and *l_image_height* variables to be set. Also, the variable *roi_image_folder* indicates where the ROI images are found and the variable *roi_check_folder* is where the "checked" images are written.


#### 3-make_roi_file.R
This script reads the ROI images and extract the line:scan combinations covered by the blue area. Also, some filtering, where pixels with a faint blue colour are removed, is performed. For each ROI image as ROI file, consisting of the intensity matrix for the line:scan combinations in the covered by the ROI, is saved in the folder specified by the *roi_csv_folder* variable.

##### Variables in 0-project_data.R required
Again, the *make_experiment* function requires the *l_matrix_file*, *l_header_folder* and *l_image_height* variables to be set as the intensities are taken from the intensity matrix. The ROI images are read from the folder specified by the *roi_image_folder* variable and the resulting ROI files are written to the folder specified by the *roi_csv_folder* variable.


#### 4-targeted_roi.R
This script does a targeted analysis where the different ROI files are read in and the concentration, norm (ratio of intensities) and the amount (mole) for each scan is calculated for each molecule of interest. Then the result for each ROI file is written to a file.

##### Variables in 0-project_data.R required
Again, the *make_experiment* function requires the *l_matrix_file*, *l_header_folder* and *l_image_height* variables to be set as the IT are taken from the header file data.
The variable *targets* is a list of data for molecules of interest. Each molecule data in the list contains the m/z of the endogenous molecule, the m/z of the internal standard, the concentration of the internal standard and the exponent that (with base 10) is multiplied with the amount (to avoid small numbers). The *roi_csv_folder* variable must be set so the script can find the ROI files, *ROI_flowrate* variable (in liter per second) is used to calculate the amount of each molecule of interest and the variable *roi_csv_targeted_folder* (set to *NULL* if not doing targeted analysis, see below) is set to the folder to put the targeted ROI files.


#### 5-mean_sd_data.R
The script does a report where for each ROI file the mean, SD, #scans in the ROI, % non-zero scans (*NA* and similar are counted as zero) in the ROI, the IT cutoff if used and if TIC normalization was used.
The IT cutoff is the value that the IT of a scan must be equal or less than to be included in the calculations (filter by IT), the use of IT cutoff can be either turned on or off (if turned off the IT cutoff value is *NA*). If TIC normalization is used each m/z intensity in a scan (column in intensity matrix) is divided by the mean of the intensity of all m/z in the scan, again this can be turned off or on by a variable. The report is saved in the folder indicated by *roi_csv_folder*

If *roi_csv_targeted_folder* the same is done for the targeted ROI files (but here TIC normalization is never used as it would not make sense).



##### Variables in 0-project_data.R required
Again, the *make_experiment* function requires the *l_matrix_file*, *l_header_folder* and *l_image_height* variables to be set as the IT are taken from the header file data. The folder where targeted ROI files are is set in the *roi_csv_targeted_folder* variable, if not using targeted set it to *NULL* and no report is made for targeted data. The folder were the report(s) are written to is given by *roi_csv_folder*. The use of filtering by high IT is regulated by the variable *remove_high_it* and the TIC normalization is regulated by the *TIC_normalization* variable.