# ROIextractor

## Introduction
The scripts in this repository was used in the article [Quantitative mass spectrometry imaging of small-molecule neurotransmitters in rat brain tissue sections using nanospray desorption electrospray ionization ](http://pubs.rsc.org/en/content/articlelanding/2016/an/c5an02620b#!divAbstract).

The scripts are for making images, extracting region of interest (ROI) data and summarizing the ROI data from [mass spectrometry imaging](https://en.wikipedia.org/wiki/Mass_spectrometry_imaging) (MSI) experiments using the [nanospray desorption electrospray 
ionization mass spectrometry](http://imaging.pnnl.gov/projects/posters/2013/2_2JLaskin_2013_fin.pdf) (nano-DESI) technique ([see also](https://www.emsl.pnl.gov/emslweb/news/birth-nanodesi)).

Quickly explained, nano-DESI is a technique where liquid is pumped out from one capillary (primary) and take up by another capillary (secondary) such that the liquid forms a liquid-bridge between the capillaries. When the liquid-bridge is in contact with a sample molecules in the sample will be transferred to the liquid. In the liquid, the sample-molecules are transported (together with the liquid) through the secondary capillary to the mass spectrometer for measurement. At the mass spectrometer, the molecules are ionized (if able, here there is a bias in which molecules are ionized and how well). The mass spectrometer in its turn takes "snapshots" of the ionized molecules it gets. The mass spectrometer will measure the ratio of mass and charge (m/z) of the molecules, presented the intensity for different m/z values (mass spectrum).

When using nano-DESI for MSI the two capillaries are moved over the surface (at a constant speed) collecting molecules from the sample. Due to that the mass spectrometer takes "snapshots" that take differently long to collect, the samples will not be evenly spaced and correction for that must be made later. When taking the ion image capillaries move in a straight line (x-direction) over the sample until it reach the end. There the capillaries will move to the beginning and start a new line a distance translated in y-direction, such that the measurements will be along parallel straight lines.

So now the ion image is made up of lines, where each line contains unevenly spaced "point" measurement (called scans). Each scan is a spectrum for the specific measurement and thus contains intensities for the measured m/z values.


## Files used by the scripts

The scripts take an intensity matrix file and a header file per line.

The matrix file contains intensities with the columns containing the line number and scan number (line:scan, for example. "1:2" for line 1 and scan 2 in it) and the m/z values on the rows.

The header files contain the (among some other things) the scan and its ion accumulation time (IT, time taken to collect ions) and cumulative retention time (RT, time from start of line until current scan).


## Definining a ROI
A ROI is defined by drawing an area in an image produced by the scripts (more precisly *1-make_images.R*). The images produced contains only the red and green channels of the image, leaving the blue channel empty. So in any image produced an area can be drawn in blue to represent the ROI. The image can not be resized since the scripts require the size to be the same.



## Scripts/pipeline

The scripts are designed to be executed one after the other (in order of the starting number in the scripts file name) to form a pipeline. Any script can be executed by it self if *0-project_data.R* is executed before. In addition to the scripts that are executed there is the script *library.R* used by the other scripts. To run the scripts the packages *png* and *bigmemory* are required. The different script forming the pipeline are as follows:

#### 0-project_data.R
Contains the different variables (the comments in the file should be enough what the different variables mean) used by the other scripts. Executing the script will also load the intensity matrix and the header files. The script will also calculate a position matrix used later for making images.

#### 1-make_images.R
Makes an png image for each m/z in the intensity matrix (each named as the m/z value), except when there are so few non-zero values that the image would be of a single colour (removed so that one does not have to look through unrelevant  images). Due to the uneven spacing of scans, an image with the scans (one pixel per scan) lined up in each line would be distorted. To remedy this the script finds the line with the most scans, then for each other line the scans with the longest IT will be elongated by one pixel until the line is as long as the longest line.

The images are coloured from black (for zero intensity) through red to yellow (max intensity). There is a problem with large outlier scans dominating the image and then each non outlier pixel will be darker such that structures in the image will be harder to distinguish. This is remedied by removing (set to NA, then set equal to the max of the remaining intensities) the outliers. Outliers are detected using the *boxplot.stats* function, outliers are any values paste the extreme of the upper whisker in a boxplot. Due to this that an image with few non-zero would be mono-coloured (yellow).


#### 2-check_roi.R


#### 3-make_roi_file.R


#### 4-targeted_roi.R


#### 5-mean_sd_data.R
