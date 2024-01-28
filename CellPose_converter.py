#@File (style="file") filepath
from ij import IJ
from ij.plugin.frame import RoiManager
from ij.gui import PolygonRoi
from ij.gui import Roi
from java.awt import FileDialog

RM = RoiManager()
rm = RM.getRoiManager()

imp = IJ.getImage()

textfile = open(filepath.getPath(), "r")
for line in textfile:
    xy = map(int, line.rstrip().split(","))
    X = xy[::2]
    Y = xy[1::2]
    imp.setRoi(PolygonRoi(X, Y, Roi.POLYGON))
    # IJ.run(imp, "Convex Hull", "")
    roi = imp.getRoi()
    print(roi)
    rm.addRoi(roi)
textfile.close()

rm.runCommand("Associate", "true")
rm.runCommand("Show All with labels")