library("aws.s3")
library("arrow")
library("dplyr")
library("lubridate")
library("tidyr")
library("readr")
library("stringr")

# make sure you can connect to your bucket and open SubTreeFileSystem
bucket <- s3_bucket("stg4-eaa")

# list everything in your bucket in a recursive manner
bucket$ls(recursive = TRUE)

# identify path where you will be writing the .parq files
s3_path <- bucket$path("")

aoi_texas_buffer<-read_csv("/home/data/texas_buffer_spatial_join.csv")

# list files that start with st4 and ends with .txt
raw_grib2_text = list.files("/home/data", pattern = "^st4_conus.*.txt$",full.names=FALSE)

for (h in raw_grib2_text) {
  name <- h |>
    str_replace("st4_conus.", "t") |>
    str_replace(".01h.txt","")
  
  aa<-read_csv(paste0("/home/data/",h), col_names=FALSE) %>%
  #aa<-read_csv(h, col_names=FALSE) %>%
    setNames(c("x1","x2","x3","x4","center_lon","center_lat",name)) %>%
    select(-x1,-x2,-x3,-x4)   
  
  # joins by "center_lon", "center_lat"
  bb<- left_join(aoi_texas_buffer,aa,by=NULL)%>%
    pivot_longer(!1:5, names_to = "time", values_to = "rain_mm") %>%
    mutate(time = ymd_h(str_sub(time,2,11))) %>%
    mutate (year = year(time), month = month(time), day = day(time), hour = hour(time)) %>%
    relocate(rain_mm, .after = last_col()) 
}  

bb|>
  group_by(year,month) |>
  write_dataset(path = s3_path,
                format = "parquet")



