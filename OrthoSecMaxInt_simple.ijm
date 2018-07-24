macro "Orthogonal sections Action Tool- C059T3e16C" {

// Get Relevant Info
a = getMetadata("Info");
a = split(a,"\n");

for (i=0; i<=lengthOf(a)-1; i++){
if (startsWith(a[i], "Magnification")){
c = split(a[i],"=");
mag = c[1];
}
if (startsWith(a[i], "NumberOfSlicesPerChannel")){
c = split(a[i],"=");
numSlices = c[1];
}
if (startsWith(a[i], "StepSize")){
c = split(a[i],"=");
voxdep = c[1];
}
if (startsWith(a[i], "NumberOfChannels")){
c = split(a[i],"=");
numCh = c[1];
}
if (startsWith(a[i], "Ch1Wavelength")){
c = split(a[i],"=");
Ch1 = c[1];
}
if (startsWith(a[i], "Ch1Exposure")){
c = split(a[i],"=");
ExpCh1 = c[1];
}
if (startsWith(a[i], "Ch2Wavelength")){
c = split(a[i],"=");
Ch2 = c[1];
}
if (startsWith(a[i], "Ch2Exposure")){
c = split(a[i],"=");
ExpCh2 = c[1];
}
if (startsWith(a[i], "Ch3Wavelength")){
c = split(a[i],"=");
Ch3 = c[1];
}
if (startsWith(a[i], "Ch3Exposure")){
c = split(a[i],"=");
ExpCh3 = c[1];
}
if (startsWith(a[i], "Ch4Wavelength")){
c = split(a[i],"=");
Ch4 = c[1];
}
if (startsWith(a[i], "Ch4Exposure")){
c = split(a[i],"=");
ExpCh4 = c[1];
}
if (startsWith(a[i], "SelectionXCoord")){
c = split(a[i],"=");
x = c[1];
}
if (startsWith(a[i], "SelectionYCoord")){
c = split(a[i],"=");
y = c[1];
}
if (startsWith(a[i], "SelectionWidth")){
c = split(a[i],"=");
width = c[1];
}
if (startsWith(a[i], "SelectionHeight")){
c = split(a[i],"=");
height = c[1];
}
}
	
fname = getInfo("image.filename");
fname2 = replace(fname,".tif","");
fdir = getInfo("image.directory");
fpar = File.getParent(fdir);
dirname = split(fpar,"\\");
dirname2 = dirname[lengthOf(dirname)-1];

// Function to extract position of cross-hairs
function coord(imgname) { 
        string=substring(imgname,3,lengthOf(imgname)); 
        return parseInt(string);
} 

// Pseudo 2D array to translate numbers to letters of channels
if (numCh == 3){
channelarray = newArray("D", "G", "R", "GR");
channelarray2 = newArray("001", "011", "101", "111");
}
else if (numCh == 4){
channelarray = newArray("D", "G", "R", "M", "GR", "GM", "RM", "GRM");
channelarray2 = newArray("0001", "0011", "0101", "1001", "0111", "1011", "1101", "1111");
}
crosshairX = 250;
crosshairY = 250;
slice = 7;

for (j=1; j<=21; j++){ 

// Generate Orthogonal Sections
if (numCh == 3){
Dialog.create("Create Orthogonal Sections");
Dialog.addMessage("Choose a composite channel to\ncreate orthogonal sections of.\nLook through all channels first to determine\napproximate position of cross-hairs to use\n0: DAPI only\n1: Green+DAPI\n2: Red+DAPI\n3: Merge All");
Dialog.addNumber("Choice:", 2);
Dialog.show();
ch = Dialog.getNumber();
}
else if (numCh == 4){
Dialog.create("Create Orthogonal Sections");
Dialog.addMessage("Choose a composite channel to\ncreate orthogonal sections of.\nLook through all channels first to determine\napproximate position of cross-hairs to use\n0: DAPI only\n1: Green\n2: Red\n3: Magenta\n4: Green+Red\n5: Green+Magenta\n6: Red+Magenta\n7: Merge All");
Dialog.addNumber("Choice:", 3);
Dialog.show();
ch = Dialog.getNumber();
}

fname3 = fname2+"_O_"+channelarray[ch];

selectWindow(fname);
Stack.setDisplayMode("composite");
Stack.setActiveChannels(channelarray2[ch]);
selectWindow(fname);
run("Orthogonal Views");
wait(2000);
Stack.setOrthoViews(crosshairX, crosshairY, slice-1);
selectWindow(fname);

waitForUser("Waiting", "Choose Position of Cross-hairs and the desired slice, then click OK");
selectWindow(fname);
selectImage(2);
img = getTitle();
crosshairX=coord(img);

selectImage(3); 
img = getTitle();
crosshairY=coord(img);

selectWindow(fname);
wait(1000);
Stack.getPosition(channel, slice, frame);

Dialog.create("Orthoviews")
Dialog.addMessage("Change crosshair positions:\n");
Dialog.addNumber("X:", crosshairX);
Dialog.addNumber("Y:", crosshairY);
Dialog.addNumber("Slice:", slice)
Dialog.show();
crosshairX = Dialog.getNumber();
crosshairY = Dialog.getNumber();
slice = Dialog.getNumber();



// Save Max intensity Projection
Dialog.create("Maximum Intensity Projection");
Dialog.addMessage("Proceed with Maximum Intensity Projection, Single Slice, or Cancel?");
Dialog.addCheckbox("Maximum Intensity Projections", true);
Dialog.addCheckbox("Single Slice", true); 
Dialog.show();
MI = Dialog.getCheckbox();
SS = Dialog.getCheckbox(); 

if (MI == 1){
run("Z Project...", "projection=[Max Intensity]");
selectWindow("MAX_"+fname);
run("Brightness/Contrast...");
wait(50);
waitForUser("Adjust B&C for Max Intensity Projection", "Adjust Brightness and Contrast, then click OK");
run("RGB Color");
wait(20);
saveAs("Tiff", fdir+fname3+"_MI"); // Save
close();
selectWindow("MAX_"+fname);
close();

if (SS == 1){

selectWindow(fname);
Stack.setDisplayMode("composite");
Stack.setActiveChannels(channelarray2[ch]);
wait(200);
selectWindow(fname);
run("Orthogonal Views");
wait(2000);
Stack.setOrthoViews(crosshairX, crosshairY, slice-1);
selectWindow(fname);
wait(20);
run("RGB Color", "keep");
wait(20);
saveAs("Tiff", fdir+fname3); // Save
close();
}
}

if (MI == 0){
if (SS == 1){

selectWindow(fname);
Stack.setDisplayMode("composite");
Stack.setActiveChannels(channelarray2[ch]);
wait(200);
selectWindow(fname);
run("Orthogonal Views");
wait(2000);
Stack.setOrthoViews(crosshairX, crosshairY, slice-1);
selectWindow(fname);
wait(20);
run("RGB Color", "keep");
wait(20);
saveAs("Tiff", fdir+fname3); // Save
close();
}
}

// Save the yz and xz views and obtain coordinates of crosshairs
selectWindow(fname);
run("Orthogonal Views");

Dialog.create("Wait for Orthogonal Views to load");
Dialog.addMessage("Click OK when loaded or Cancel to Terminate");
Dialog.show();
selectImage(2);
img = getTitle();
crosshairX=coord(img);
saveAs("Tiff", fdir+fname3+"_yz"); 

selectImage(3); 
img = getTitle();
crosshairY=coord(img);
saveAs("Tiff", fdir+fname3+"_xz"); 


wait(500);
newtext = fname3+".tif"+"\t"+slice+"\t"+crosshairX+"\t"+crosshairY+"\t"+Ch1+"\t"+ExpCh1+"\t"+Ch2+"\t"+ExpCh2+"\t"+Ch3+"\t"+ExpCh3+"\t"+Ch4+"\t"+ExpCh4+"\n"+"end";

write2file2 = File.openAsString(fpar+"\\"+dirname2+"_"+"record.txt");
write2file3 = split(write2file2,"\n");
wait(100);

for (i=1; i<=lengthOf(write2file3)-1; i++){
if (write2file3[i] == "end"){  // If line is "end", then replace with new info and break the loop
write2file3[i] = newtext;
p = i;
i = 1e99;
}
}
write2file4 = write2file3[0];
for (n=1; n<=p; n++){
write2file4 = write2file4+"\n"+write2file3[n]; // Create the new text file
}
write2file = File.open(fpar+"\\"+dirname2+"_"+"record.txt");
print(write2file, write2file4);
File.close(write2file);

close();

}
}