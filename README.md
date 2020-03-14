# Benchmark datasets for sports video analysis.

## About the Dataset
The data set contains a total of 104 full-length sports videos having a cumulative duration of more than `230 hours`. The videos were captured in an “as it is form” from internet sources. These videos contain commercials, TV logos, some logos and themes superimposed by bloggers, etc. These videos belong to 12 different categories of sports, that is why they heavily vary in length. Some of the sports categories are time-based sports and some are score based sports such as cricket, baseball etc.
All the videos are in `mp4` format. Here are some statistics about the videos:

| Sports cateagory  | Number of videos | Frame rate range  | Cummulative durations (HH:MM) |
| ------------- | ------------- | ------------- | ------------- |
| Cricket  | 11 | 23∼30 |  42:23|
| Rugby  | 10 | 23∼30 |  21:28|
| Soccer  | 22 | 23∼30 |  39:08|
| Basketball  | 11 | 25∼30 |  17:59|
| Baseball  | 7 | 25∼30 |   18:21|
| Football  | 8 | 25∼30 |    18:51|
| Tennis  | 7 | 27∼30 |    17:14|
| Handball  | 9 | 24∼30 |     12:11|
| Snooker  | 4 | 25~30 |      06:07|
|Volleyball| 4 |25∼25 |05:48|
|Ice Hockey |7 |25∼30 |16:07|
|Hockey |4 |25∼30| 08:04|

### Some selected frame samples
![Some samples from the dataset](https://raw.githubusercontent.com/abdkhanstd/Sports/master/samples.jpg)

The complexity of the dataset can clearly be seen from the sample frames. Sports videos are challenging due to the huge amount of cluttering in the background and 3D-induced marketing items which are usually painted on the playfield.
### Download Videos
The videos in this dataset are approximate 105 GigaBytes in size with varying qualities. These videos are shared via Microsoft OneDrive business account (other mirrors can be arranged on demand. Please refer to contact info.)
Videos can be downloaded from [here](https://stduestceducn-my.sharepoint.com/:f:/g/personal/201714060114_std_uestc_edu_cn/EsYRaX2slJ1EjrMe-7SdZeQBB8dh3Wo_bHJrSAu8o5Uj0g?e=0XNfJe)

### Download Converted Audio files
For ease to the users and synchronize the timeline, pre-extracted audio files (.mp3 format) can be downloaded from [here](https://stduestceducn-my.sharepoint.com/:f:/g/personal/201714060114_std_uestc_edu_cn/Eu_uKfUiHpVBn3Y8N5s9UmoBZrJC0xzLbPnIfAB16URDRw?e=BbPqbd)

### Description of JSON files
The scorebox availability and location data can be found in the “scorebox availability and location” folder. 
The corresponding JSON data file contains the ground truth “Time”, “Availability” and “Location” of the scorebox. Please note that the time of the video is represented in seconds. The “Location” contains four parameters Ymin, Ymax, Xmin, and Xmax. Ymin represents the starting and Ymax represents the end Y-axis pixel location of ground truth SB. Vice versa, Xmin represents the starting and Xmax represents the end X-axis pixel location of ground truth SB.
The starting and end time of an event, with respect to the video, can be found in the representative JSON file in the Events folder.

### How to cite?
@article{DBLP:journals/npl/k2020,<br /> 
&nbsp;&nbsp;author    = {Abdullah Aman Khan and <br /> 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Jie Shao and <br /> 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Waqar Ali and <br /> 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Saifullah Tumrani},<br /> 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  title     = "{Content-Aware Summarization of Broadcast Sports Videos:An Audio–Visual Feature Extraction Approach}",  <br /> 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  journal   = {Neural Processing Letters},<br /> 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  pages     = {1--24}, <br /> 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  year      = {2020},<br /> 
}
#### Contact
`Abdullah K.`
`abdkhan@std.uestc.edu.cn`
Please note that I may respond late but I will.



#### Important note
More details (code + results) will be added later.
