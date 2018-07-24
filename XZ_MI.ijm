run("Reslice [/]...", "output=0.300 start=Top avoid");
run("Scale...", "x=1.0 y=2.900 z=1.0 width=500 height=121 depth=500 interpolation=Bilinear average average create");
run("Z Project...", "projection=[Max Intensity]");
