# 自動化處理行車記錄器影片
rm(list=ls())

## 載入套件
#library(stringr)
options(digits = 12)

## 移動到工作資料夾
setwd("/home/fisher/Dropbox/9.admin/job2021/18景翊科技/2專案資料/智慧城鄉/dashcam/自動化處理行車記錄器至mapillary/test2/")

## 列出影片數量
files=list.files(pattern = ".MP4")



## 擷取GPS資料
dataframe_tmp <- data.frame(video_file = character(),
                            no = integer(),
                            date = character(),
                            lat = character(),
                            lon = character(),
                            track = character(),
                            stringsAsFactors = FALSE)


dataframe_all <- data.frame(video_file = character(),
                 no = integer(),
                 date = character(),
                 lat = character(),
                 lon = character(),
                 track = character(),
                 stringsAsFactors = FALSE)
#i=3

for (i in 1 : length(files)){

cmd=paste("exiftool -ee ",files[i]," |grep GPS |grep Date")
date=substr(system(cmd, intern = TRUE),35,53)

find.list=list("\"", "deg", "'", '"')
pattern=paste(unlist(find.list), collapse = "|")
cmd=paste("exiftool -ee ",files[i]," |grep GPS |grep Latitude")
lat=gsub(pattern, replacement = " ",substr(system(cmd, intern = TRUE),34,49))
lat=as.numeric(substr(lat,1,3))+(as.numeric(substr(lat,5,8))/60)+(as.numeric(substr(lat,10,14))/3600)

cmd=paste("exiftool -ee ",files[i]," |grep GPS |grep Longitude")
lon=gsub(pattern,replacement = " ",substr(system(cmd, intern = TRUE),35,51))
lon=as.numeric(substr(lon,1,3))+(as.numeric(substr(lon,6,9))/60)+(as.numeric(substr(lon,10,15))/3600)

cmd=paste("exiftool -ee ",files[i]," |grep GPS |grep 'Track   '")
track=as.numeric(substr(system(cmd, intern = TRUE),35,40))

no=as.numeric(c(1:length(date)))

video_file=rep(files[i],length(date))

dataframe_tmp=as.data.frame(cbind(video_file,no,date,lat,lon,track),stringsAsFactors = F)

dataframe_all=rbind(dataframe_all,dataframe_tmp)

str(dataframe_tmp)
str(dataframe_all)
}

### 輸出 GPS資料
#write.csv(dataframe_all,"data",row.names = F)


## 各別影片擷取出JPG檔

### 創資料夾
system("mkdir pic")

### 批次讀檔，將影片切成一秒一張照片，會花一點時間，注意要輸出成jpg
for (i in 1 : length(files)){
cmd=paste("ffmpeg -i ",files[i]," -vf fps=1 pic/",gsub(".MP4","",files[i]),"_%4d.jpg",sep="")
system(cmd)
}

# 列出照片檔名，因為發現照片跟行車記錄器會誤差1秒，要先移除第一張照片，最後一欄補空值
files_jpg=list.files("pic")
length(files_jpg)
files_jpg=c(files_jpg[-1],"")

#jpg檔名併入dataframe
dataframe_all$pic_files=files_jpg

#移除dataframe最後一欄
dataframe_all=dataframe_all[-dim(dataframe_all)[1],]

### 輸出 GPS+照片資料
write.csv(dataframe_all,"data.csv",row.names = F)









#然後這個時候要用qgis載入data.csv檔案，手動畫出車行路線，將點位位移後，存成新的csv檔案，再用R讀入，準備寫exif資料到照片裡面。
#注意要做座標轉換成3826, tool box中選擇snap geometries to layer, 距離範圍至少要設定200m以上
#轉角通常有問題

# QGIS display 要加入語法，檢查圖片位置
# <table>
#   <tr>
#   <th>[% no %]</th>
#   </tr> 
#   <tr>
#   <th><img src="file:///home/XXXXXXXX/test2/pic/[% pic_files %]" width="350" height="250"></th>
#   </tr>
#   </table>

#symble加入track方向
#目前發現gps時間與照片時間有不一樣的地方，有偏移量，大概是四秒
#確認偏移時間後應該要重跑一次這個程式


# 假設QGIS對位成功，時間也沒有偏移，重新輸出成csv檔案，記得要更新他的x,y值，就讀進來
options(digits = 12)
setwd("/home/fisher/Dropbox/9.admin/job2021/18景翊科技/2專案資料/智慧城鄉/dashcam/自動化處理行車記錄器至mapillary/test2/")

exif_data=read.csv("path",header = T,stringsAsFactors = F)

#exif_data=read.csv("/home/fisher/Dropbox/9.admin/job2021/18景翊科技/2專案資料/智慧城鄉/dashcam/自動化處理行車記錄器至mapillary/test2/data.csv",header = T,stringsAsFactors = F)


#exif_data$x=exif_data$lon
#exif_data$y=exif_data$lat

str(exif_data)

files=list.files("pic/",pattern = ".jpg")

#exiftool -overwrite_original  -exif:DateTimeOriginal='2022:05:2413:41:06' -exif:gpslatitude="25.0757972222222" -exif:gpslatituderef=N -exif:gpslongitude="121.573780555556" -exif:gpslongituderef=E -exif:GPSTrack=207.32 20220524_0002.jpg 

i=100


for( i in 1:length(files)){
  cmd=paste("exiftool -overwrite_original -exif:DateTimeOriginal='",
            exif_data$date[i],
            "' -exif:gpslatitude='",exif_data$y[i],"' -exif:gpslatituderef=N -exif:gpslongitude='",exif_data$x[i],
            "' -exif:gpslongituderef=E -exif:GPSTrack='",exif_data$track[i],"' pic/",files[i],sep="")
  cmd
  system(cmd)
  
}


# 完成後就可以打開Mapillary程式進行上傳






