## Download and unzip the file

HPCzipFileURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip";
HPCzipFileURL = sub('https', 'http', HPCzipFileURL);
download.file( HPCzipFileURL, destfile = "./Project1/HPC.zip");
unzip("./Project1/HPC.zip", exdir = "./Project1");

## Since the unzipped filesize is reasonabley big (over 100mb), let's use the fread function which is much faster than the read function in base R
## In order to use fread, we need to load the "data.table" package
library(data.table)
HPCfullData <- fread("./Project1/household_power_consumption.txt", sep=";" , na.strings = "?", stringsAsFactors=False);

## Understand the datastructure of the file that has been read into R
head(HPCfullData);
tail(HPCfullData);
names(HPCfullData);
## Confirm that the read dataset has 2,075,259 rows and 9 columns
str(HPCfullData);

## Subset the full data to select data from 2007 Feb 1st onwards 
DT<- subset(HPCfullData,as.Date(HPCfullData$Date,format='%d/%m/%Y')>=as.Date('2007-02-01',format='%Y-%m-%d'));
## Subset the full data to select data upto 2007 Feb 2nd 
DT<- subset(DT,as.Date(DT$Date,format='%d/%m/%Y')<=as.Date('2007-02-02',format='%Y-%m-%d'));

## Confirm that the dataset DT now is much smaller - 
str(DT);

## 2880 rows matches with expectation since 24 hrs * 2 days * 60mins = 2880
## i.e. 2880 rows correspond to just the 2 days that are of interest to us (Feb 1st and Feb 2nd)

## Convert the table DT into a Data Frame DF
DF <- as.data.frame(DT);

## Remove the original full dataset with more than 2 million rows to free up memory in the R session
rm(HPCfullData)

## Date & Time columns of the DF dataframe are in Character format and are separate columns, 
## we need to add a new column which will have date & time together in a single column 
DateCol <- DF[,1];
TimeCol <- DF[,2];
DateTimeChar <- paste(DateCol, TimeCol);

## The DateTime vector is still in Character format. To convert it to POSIX date-time format, make use of the "lubridate" package
install.packages("lubridate");
library("lubridate");
DateTimeStamp <- dmy_hms(DateTimeChar)

## Confirm that DateTimeStamp vector is now in POSIXct format
str(DateTimeStamp);

## Add(i.e. append) the DateTimeStamp column to the dataframe DF using cbind function
DF2 <- cbind(DateTimeStamp, DF)

## Confirm that DateTimeStamp column is now added to DF2 data frame
str(DF2)

## Convert the other Character format columns to Numeric one by one
DF2$Global_active_power = as.numeric(as.character(DF2$Global_active_power));
DF2$Global_reactive_power = as.numeric(as.character(DF2$Global_reactive_power));
DF2$Voltage = as.numeric(as.character(DF2$Voltage));
DF2$Global_intensity = as.numeric(as.character(DF2$Global_intensity));
DF2$Sub_metering_1 = as.numeric(as.character(DF2$Sub_metering_1));
DF2$Sub_metering_2 = as.numeric(as.character(DF2$Sub_metering_2));

## Confirm that all the sensor measurement columns are now numeric format
str(DF2)


##### FINALLY ! The data is now in the right format for the plot2 (line plot) to be plotted ! 


png(file = "plot3.png", width = 480, height = 480);
with(DF2, plot(DF2$DateTimeStamp, DF2$Sub_metering_1, type =  "n", xlab = "", ylab = "Energy sub metering"));
lines(DF2$DateTimeStamp, DF2$Sub_metering_1, type =  "l");
lines(DF2$DateTimeStamp, DF2$Sub_metering_2, type =  "l", col="red");
lines(DF2$DateTimeStamp, DF2$Sub_metering_3, type =  "l", col="blue");
legend("topright", lty = 1, col = c("black", "red", "blue"), legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"));
dev.off();

