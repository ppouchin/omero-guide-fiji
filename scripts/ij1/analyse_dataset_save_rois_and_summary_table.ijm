// @String(label="Username") USERNAME
// @String(label="Password", style='password') PASSWORD
// @String(label="Host", value='wss://workshop.openmicroscopy.org/omero-ws') HOST
// @Integer(label="Port", value=4064) PORT
// @Integer(label="Dataset ID", value=2331) dataset_id

run("OMERO Extensions");

connected = Ext.connectToOMERO(HOST, PORT, USERNAME, PASSWORD);

setBatchMode("hide");
if(connected == "true") {
    images = Ext.list("images", "dataset", dataset_id);
    imageIds = split(images, ",");
    
    for(i=0; i<imageIds.length; i++) {
        ijId = Ext.getImage(imageIds[i]);
        ijId = parseInt(ijId);
        roiManager("reset");
        run("8-bit");
        run("Auto Threshold", "method=MaxEntropy stack");
        run("Analyze Particles...", "size=10-Infinity pixel display clear add stack");
        run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding summarize feret's median stack display redirect=None decimal=3");
        roiManager("Measure");
        nROIs = Ext.saveROIs(imageIds[i], "");
        Ext.addToTable(imageIds[i]);
        print("Image " + imageIds[i] + ": " + nROIs + " ROI(s) saved.");
        roiManager("reset");
        close("Results");
        selectImage(ijId);
        close();
    }
}
//TODO: Add method to save table as csv
Ext.saveTable("Dataset", dataset_id, "Summary_from_Fiji");
setBatchMode(false);

Ext.disconnect();
print("processing done");