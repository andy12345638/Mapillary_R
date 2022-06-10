# A tool to procees Nextbase dashcam video and upload to Maillary

## Need
* Linux base computer
* Nextbase A263W (different type could be possible, depend on exiftool)

## Prepare

* Record video with Nextbase A263W
	+ set 5 minutes, as long as good
	+ .MP4
	+ Correction time before recording
	
* install exiftool on linux https://exiftool.org/
```
sudo apt install exiftool
```
or you can download it on web.

## Start

1. create a folder name __test2__ or smoething like this
2. copy all the camera MP4 video in it
3. excuting __Mapillary_R_process.r__ line by line to line 92
4. now you have a data.csv which include camera GPS information(datetime,lat,lon,track), usually the frequency is one secound.
5. now you have a folder called __pic__. and all video with cut in to jpg picture by one secound.
6. (optional) if the gps track didn't seem good, alternate it on qgis and save as new ___data.csv___
7. write data.csv data into jpg exif. excute __Mapillary_R_process.r__ line 120 to end
8. start uploading jpgs to Mapillary by using  [Mapillary desktop software](https://www.mapillary.com/desktop-uploader).


