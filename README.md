# GettingAndCleaningDataCourseProject

## 
This file describes how the R script called run_analysis.R works. Following steps will be processed after executing this file on R / Rstudio. 

## 0. Makes a directory named CourseProjectData.
To analyse the data from the accelerometers from the Samsung Galaxy S smartphone, a directory named CourseProjectData is made first. All dataset is downloaded from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip and unzipped automatically.

if (!file.exists("./CourseProjectData")){
   dir.create("./CourseProjectData")
   fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
   download.file(fileURL, destfile = "./CourseProjectData/Dataset.zip", method = "curl")
   unzip(zipfile = "./CourseProjectData/Dataset.zip", exdir = "./CourseProjectData")
}

## 1. Merges the training and the test sets to create one data set.
After downloading the dataset, merging the training and the test sets to create one data set is executed. 

filepath <- file.path("./CourseProjectData", "UCI HAR Dataset")
fnames <- list.files(filepath, recursive = TRUE)
##
dataXTest <- read.table(file.path(filepath, "test", "X_test.txt"), header = FALSE)
dataXTrain <- read.table(file.path(filepath, "train", "X_train.txt"), header = FALSE)
dataSubjectTest <- read.table(file.path(filepath, "test", "subject_test.txt"), header = FALSE)
dataSubjectTrain <- read.table(file.path(filepath, "train", "subject_train.txt"), header = FALSE)
dataYTest <- read.table(file.path(filepath, "test", "Y_test.txt"), header = FALSE)
dataYTrain <- read.table(file.path(filepath, "train", "Y_train.txt"), header = FALSE)
##
dataX <- rbind(dataXTrain, dataXTest)
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataY <- rbind(dataYTrain, dataYTest)
##
featuresName <- read.table(file.path(filepath, "features.txt"), header = FALSE)
names(dataX) <- featuresName$V2
names(dataSubject) <- c("subject")
names(dataY) <- c("activity")
##
partData <- cbind(dataSubject, dataY)
allData <- cbind(dataX, partData) 


## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
The measurements regarding to the mean and standard deviation using the regular expression.

extractedName <- featuresName$V2[grep("mean\\(\\)|std\\(\\)", featuresName$V2)]
extracted <- c(as.character(extractedName), "subject", "activity")
extractedData <- subset(allData, select = extracted)


## 3. Uses descriptive activity names to name the activities in the data set
Activity names are loaded from the file named activity_labels.txt and used to name the activities in the data set.

activityLabel <- read.table(file.path(filepath, "activity_labels.txt"), header = FALSE)
labelNumber = 1
for (acLabel in activityLabel$V2) {
  extractedData$activity <- gsub(labelNumber, acLabel, extractedData$activity)
  labelNumber <- labelNumber + 1
}



## 4. Appropriately labels the data set with descriptive variable names. 

The labels of the datas set is changed appropriately using the regular expression.

names(extractedData)<-gsub("^t", "time", names(extractedData))
names(extractedData)<-gsub("^f", "frequency", names(extractedData))
names(extractedData)<-gsub("Acc", "Accelerometer", names(extractedData))
names(extractedData)<-gsub("Gyro", "Gyroscope", names(extractedData))
names(extractedData)<-gsub("Mag", "Magnitude", names(extractedData))
names(extractedData)<-gsub("BodyBody", "Body", names(extractedData))
names(extractedData)<-gsub("-std", "StdDev", names(extractedData))
names(extractedData)<-gsub("-mean", "Mean", names(extractedData))

## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Second independent tidy data set is created and stored in the file named secondTidyData.txt.

secondTidyData <- aggregate(. ~subject + activity, extractedData, mean)
secondTidyData <- secondTidyData[order(secondTidyData$subject, secondTidyData$activity),]
write.table(secondTidyData, "./secondTidyData.txt", row.name = FALSE)
