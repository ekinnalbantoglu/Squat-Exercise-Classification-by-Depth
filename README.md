# Squat-Exercise-Classification-by-Depth
EE417 Computer Vision Term Project 
### Functions
##### 1) opticalFlow_main.m
This function takes 10 videos where people are doing the squat exercise,
while reading frame by frame, calculates the optic flow attributes. The built-in
opticalFlowHS function computes the displacement between the
corresponding pixels in successive video frames to determine the velocity of a
pixel. Judging by the vector magnitudes and vector directions, it detects the
frame where the person in the video is at the vertically lowest point and
extracts this frame, that is to be used in Squat_classifier_main function.
To determine the lowest position of the exercise, motion vector magnitudes
are compared and a reference based vertical movement threshold has been
applied. This reference system is to differentiate between successive frames
of one repetition of the exercise. If the person is idle for multiple frames at the
max depth of the squat exercise, then in order not to extract all of these
frames as a valid frame, this approach has been implemented. The
referenced frame is a previous frame where the person is found to be moving.
However, this movement is required to have a certain mobility and direction(
from up to down ) so that the frames who reference this frame can be
considered as valid cases.
##### 2) Squat_classifier_main.m
First section of this script is used to iterate over the images that are in the
current MATLAB directory. These images display a human doing the squat
exercise. The person is facing left and image size is 300*200. Image names
are formed inside the loop and for every image, function ‘process_and_draw’
is called. As an output to one image, 2 figures that explain if the person in
the image has the correct depth range while doing squat exercises are generated. The
variable sensitivity is used for the circle detection that will be conducted under
subfunctions of this function.  
Second section of this script is used to save all open figures to the current
MATLAB directory.
##### 3) process_and_draw.m
This function is responsible for the joint detection and depth
classifier functions. The original image is taken as input along with the
sensitivity value and investigated under 4 versions: Grayscale, Red Channel, Green
Channel and Blue Channel. This seperation increases the chances of knee and hip detections that may have gone unnoticed otherwise by taking advantage of the color difference between the person's clothing or skin and the background. For every variety of the input image, joints are
detected, selected and collected. This collection is fed into the function
‘channel_polling’ in order to determine the final classification of the input
image.
##### 4) process_circles.m
In this function, knee and hip regions of the person are detected from the
edge detected image, and location and radii values are returned. The knee
and hip detection are done separately to increase the accuracy. Knee
detection was conducted between 40-80% of the row span and left hand side
of the image, whereas hip detection was done on the right hand side of the
image with the same vertical limitations. After this detection on both ends,
‘Circularity’ values of detected circular regions are calculated with
regionprops’s ‘Circularity’ attribute and locations that correspond to ‘NaN’
value are deleted from potential candidate list. This operation is beneficial for
the early elimination of false positives and computationally efficient for the
remainder of the steps.
##### 5) clear_overlaps.m
This function accepts the smoothed but not edge detected image in order to
decide between overlapping circles that were detected in the previous step.
For the course of this algorithm, the circles that are intended to be deleted are
equalised to 0 and at the end of the loops, they are deleted. There are 2
similar parts to this algorithm, clearing knee detection overlaps and hip
detection overlaps. ( If there are multiple detections for the hip region but
these circles are not overlapping, then they are not removed.)
For every circle detected, a scalar value is obtained. This scalar value is then
compared with the other candidates if two circles are overlapping. If these two
scalar values are in close proximity, namely 10%, then the one with the larger
radius is selected as the prevailing circle. If not, the circle with greater scalar
value is selected.  
The computation of scalar value ‘gradient1’ and ‘gradient2’ is as follows:
If the region is a knee region, and since the person is facing left on the image,
there should be a strong boundary where one encounters going from the
center of the knee to the left, and same for the hip but for going right. That’s
why the intensity difference between the reference pixel and the center pixel
of the circle should indicate a high scalar value compared to the false positives.
This approach is experimented to be a computationally efficient alternative to
General Hough Transform(GHT) to compare curvature values to each other or
calculating the gradient like an edge detection operation. GHT usage would have assumed the highest curvature value obtained in a detected circle to be selected as knee or hip respectively. Usage of an accumulator array in that scenario is both computationally costly and prone to small mistakes that may occur in the edge detection part.  Below image
visualizes the scalar value comparison operation of this function:  
![image1](/example-images/clear-overlaps.png)  
(Blue numbers are the scalar values obtained for each circle)
This approach yielded better results when used with different channels of the
original image, since it takes advantage of the different color sensitivities.
##### 6) channel_polling.m
This function is used to handle a variety of cases that might appear among
outputs of different channels and the grayscale image. After deciding on the
outcome, plots the necessary horizontal lines on the joints to display visual
comparison.  
The decision depends on the results of the mentioned 4 variations of the
image. Decision mechanism of the algorithm is as follows( Applied for knee
first and then hip ):
 - Every channel’s output set is trimmed to a maximum 1 knee and 1 hip
detection with respect to the scalar values found at the start
 - Between agreements, ( isClose value is true for compared circles), larger
radius is selected
 - Between disagreements, scalar value is used to decide which one will be
picked.  

As mentioned at the Squat_classifier_main, there are 2 figures for each input
image. The first figure displays the channel-wise ultimate findings( after
overlap clearance ), while the second one, created in this function, displays
the final outcome with total circles lowered to <=1 for knee and hip
respectively.
##### 7) hipGrad.m
This function calculates and places the scalar values explained to an array
after taking an array of circle center locations and radius values for hip
detections.
##### 8) kneeGrad.m
This function calculates and places the scalar values explained to an array
after taking an array of circle center locations and radius values for knee
detections.
##### 9) isClose.m
This function takes the coordinates of 2 points and returns true if the distance
between them is lower than 5 and returns false if greater or equal than 5
pixels.

### Example Results
![image2](/example-images/good-squat.png)  

![image3](/example-images/bad-squat.png)

### Areas of Usage
Due to the position of the body during the exercise, it is hard for one to check their own posture while performing the squat. That's why this script is most beneficial for people who would like to train alone. It is both applicable to home and gym environments, and only a basic camera equipment like a mobile phone or webcam is required.  
On top of casual sportspeople, this application tackles an important problem in the International Powerlifting Federation(IPF) competitions. Due to the heavy loads contestants attempt to squat, depth of the movement is aimed to be just over the legal limit. Going deeper makes the rep harder and increases the risk of failure. However, due to these close calls, referees, limited by the human eye's physical conditions, are prone to misjudgements. A computer vision aided refereeing system like this project alongside traditional referees will be resulting in a better judgemental environment for the contestants.
### Trying out yourself
To try this script yourselves, add the functions to the current MATLAB directory. After that, record yourselves with the help of your camera. For the best results, make sure the shot it captures consists mostly of your body and not unnecessary background. The background you perform the rep in front of, should preferably be plain and your clothes should not occlude knee and hip joints. If you are not facing left in the video, simply mirror it horizontally before using the script. After this,  at 'opticalFlow_main.m', change the most outer for loop's index limits according to the number of videos you would like to examine, and change the corresponding if-else statement for your videos' names. Run the function to observe lowest-depth frames that are being saved to your current MATLAB directory. After that, 'Squat_classifier_main.m' can be run with setting the loop index limits according to the number of images generated in the previous step.
### Future Research
This script can be enhanced by implementing a real time mobile application that can classify the performer's squats on the point and can audibly indicate the classification of the rep so that without the training being interrupted, performer can understand he/she is doing it correctly or should reach lower depths in the next rep.
