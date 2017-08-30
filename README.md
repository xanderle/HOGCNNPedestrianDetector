# HOG CNN Pedestrian Detector

Uses a HOG trained linear svm and a linear svm trained by CNN used as a fixed feature extractor. 

The HOG trained svm is used to quickly find the initial bounding boxes, and the CNN trained svm classifies them as pedestrian or not.
