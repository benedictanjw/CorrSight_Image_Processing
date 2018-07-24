macro "ChannelsScales Action Tool- C059T3e16A" {

um = getInfo("micrometer.abbreviation");

// Get Relevant Info

a = getMetadata("Info");
b = split(a,"\n");
c = b[0]; // Only the first line of the Image Info contains relevant info
d = split(c," ");

// Initialize variables (not sure if required)
j = "NaN=\"NaN\"";
k = "NaN=\"NaN\""; 
z = "NaN=\"NaN\"";
ch = "NaN=\"NaN\"";
l = "NaN=\"NaN\"";
m = "NaN=\"NaN\"";
Ch1 = "NaN=\"NaN\"";
Ch2 = "NaN=\"NaN\"";
Ch3 = "NaN=\"NaN\"";
Ch4 = "NaN=\"NaN\"";
ExpCh1 = "NaN=\"NaN\"";
ExpCh2 = "NaN=\"NaN\"";
ExpCh3 = "NaN=\"NaN\"";
ExpCh4 = "NaN=\"NaN\"";

// Loop over the lines to obtain the indices within the string that contain relevant info

for (i=0; i<=lengthOf(d)-1; i++){
	if (d[i]=="/><OME:ObjectiveSettings")
	j = i+1; // This line contains Magnification
	if (startsWith(d[i],"DimensionOrder"))
	k = i; // This line contains Dimension Order
	if (startsWith(d[i], "SizeZ"))
	z = i; // This line contains the number of slices per channel
	if (startsWith(d[i], "SizeC"))
	ch = i; // This line contains the number of channels
	if (startsWith(d[i], "PhysicalSizeX"))
	l = i; // This line contains the scale in microns
	if (startsWith(d[i], "PhysicalSizeZ"))
	m = i; // This line contains the actual voxel depth (step size)
	if (startsWith(d[i], "ID=\"Channel:0"))
	Ch1 = i+5; // This line contains the wavelength of Channel 1
	if (startsWith(d[i], "ID=\"Channel:1"))
	Ch2 = i+5; // This line contains the wavelength of Channel 2
	if (startsWith(d[i], "ID=\"Channel:2"))
	Ch3 = i+5; // This line contains the wavelength of Channel 3
	if (startsWith(d[i], "ID=\"Channel:3"))
	Ch4 = i+5; // This line contains the wavelength of Channel 4
	if (startsWith(d[i], "TheC=\"0\""))
	ExpCh1 = i+2; // This line contains the exposure time of Channel 1
	if (startsWith(d[i], "TheC=\"1\""))
	ExpCh2 = i+2; // This line contains the exposure time of Channel 2
	if (startsWith(d[i], "TheC=\"2\""))
	ExpCh3 = i+2; // This line contains the exposure time of Channel 3
	if (startsWith(d[i], "TheC=\"3\""))
	ExpCh4 = i+2; // This line contains the exposure time of Channel 4
};

// Combine only those lines containing relevant info

f = d[j]+d[k]+d[l]+d[m]+d[z]+d[ch];
g = split(f,"\""); // Info is generally stored between "", so split and take alternate lines
h = split(g[1],":");
mag = h[1];
DimOr = toLowerCase(g[3]); // Usually outputs xyzct
knowndist = g[5];
voxdep = g[7];
numSlices = g[9];
numSlices2 = numSlices;
numCh = g[11];

if (numCh == 3){
f = d[j]+d[k]+d[l]+d[m]+d[z]+d[ch]+d[Ch1]+d[Ch2]+d[Ch3]+d[ExpCh1]+d[ExpCh2]+d[ExpCh3];
g = split(f,"\""); // Info is generally stored between "", so split and take alternate lines
Ch1 = g[13];
Ch2 = g[15];
Ch3 = g[17];
ExpCh1 = g[19];
ExpCh2 = g[21];
ExpCh3 = g[23];

}

if (numCh == 4){
f = d[j]+d[k]+d[l]+d[m]+d[z]+d[ch]+d[Ch1]+d[Ch2]+d[Ch3]+d[Ch4]+d[ExpCh1]+d[ExpCh2]+d[ExpCh3]+d[ExpCh4];
g = split(f,"\""); // Info is generally stored between "", so split and take alternate lines
Ch1 = g[13];
Ch2 = g[15];
Ch3 = g[17];
Ch4 = g[19];
ExpCh1 = g[21];
ExpCh2 = g[23];
ExpCh3 = g[25];
ExpCh4 = g[27];
}

// Remove slices to correct for chromatic aberration
Dialog.create("Correct for chromatic aberration");
Dialog.addMessage("Correct for chromatic aberration?");
Dialog.addString("Choice", "Y");
Dialog.show();
CAC = Dialog.getString();
if (CAC == "Y"){

if (numCh == 3){
// Delete first slice of DAPI channel
setSlice(2*numSlices + 1);
run("Delete Slice");
// Delete first of Green Channel
setSlice(numSlices + 1);
run("Delete Slice");
// Delete last slice of Red Channel
setSlice(numSlices - 1);
run("Delete Slice");

numSlices2 = parseInt(numSlices) - 1;
}

if (numCh == 4){
// Delete first 3 slices of DAPI channel
setSlice(3*numSlices + 3);
run("Delete Slice");
setSlice(3*numSlices + 2);
run("Delete Slice");
setSlice(3*numSlices + 1);
run("Delete Slice");
// Delete first 3 slices of Green Channel
setSlice(2*numSlices + 3);
run("Delete Slice");
setSlice(2*numSlices + 2);
run("Delete Slice");
setSlice(2*numSlices + 1);
run("Delete Slice");
// Delete first 2 and last slice of Red Channel
setSlice(2*numSlices - 1);
run("Delete Slice");
setSlice(numSlices + 2);
run("Delete Slice");
setSlice(numSlices + 1);
run("Delete Slice");
// Delete last 3 slices of Magenta Channel
setSlice(numSlices - 1);
run("Delete Slice");
setSlice(numSlices - 2);
run("Delete Slice");
setSlice(numSlices - 3);
run("Delete Slice");

numSlices2 = parseInt(numSlices) - 3;
}

}

// Convert to Hyperstack

if (numCh == 3){
Hyperstackinfo = "order="+DimOr+" channels=3 slices="+numSlices2+" frames=1 display=Color";
run("Stack to Hyperstack...", Hyperstackinfo);

// Make Colours
Stack.setChannel(1);
run("Red");
Stack.setChannel(2);
run("Green");
Stack.setChannel(3);
run("Blue");
}

if (numCh == 4){
Hyperstackinfo = "order="+DimOr+" channels=4 slices="+numSlices2+" frames=1 display=Color";
run("Stack to Hyperstack...", Hyperstackinfo);

// Make Colours
Stack.setChannel(1);
run("Magenta");
Stack.setChannel(2);
run("Red");
Stack.setChannel(3);
run("Green");
Stack.setChannel(4);
run("Blue");
}


run("Set Scale...", "distance=1 known=knowndist unit=um");
run("Properties...", "channels=numCh slices=numSlices2 frames=1 unit=um pixel_width=knowndist pixel_width=knowndist voxel_depth=voxdep");

// Open Tools
run("Brightness/Contrast...");
setSlice(14);

// Wait for User to adjust B&C and ROI
makeRectangle(471, 205, 500, 500);
waitForUser("Waiting", "Adjust the B&C (roughly) and choose ROI");
getSelectionBounds(x, y, width, height);
showMessageWithCancel("Do you want to proceed?");
run("Crop");
waitForUser("Waiting", "Re-adjust the B&C");

// Convert to 8 bit and save
run("8-bit");
fname = getInfo("image.filename");
fdir = getInfo("image.directory");
fname2 = replace(fname,".tif"," 8bit");
fname3 = fdir+fname2;

List.clear; 
List.set("Name", fname2+".tif");
List.set("Magnification", mag);
List.set("NumberOfSlicesPerChannel", numSlices2);
List.set("StepSize", voxdep);
List.set("NumberOfChannels", numCh); 
List.set("Ch1Wavelength", Ch1);
List.set("Ch1Exposure", ExpCh1);
List.set("Ch2Wavelength", Ch2);
List.set("Ch2Exposure", ExpCh2);
List.set("Ch3Wavelength", Ch3);
List.set("Ch3Exposure", ExpCh3);
List.set("Ch4Wavelength", Ch4);
List.set("Ch4Exposure", ExpCh4);
List.set("SelectionXCoord", x);
List.set("SelectionYCoord", y);
List.set("SelectionWidth", width);
List.set("SelectionHeight", height);
setMetadata("Info", List.getList); 

saveAs("Tiff", fname3);