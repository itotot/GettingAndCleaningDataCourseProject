library(plyr)
##
if (!file.exists("./CourseProjectData")){
   dir.create("./CourseProjectData")
   fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
   download.file(fileURL, destfile = "./CourseProjectData/Dataset.zip", method = "curl")
   unzip(zipfile = "./CourseProjectData/Dataset.zip", exdir = "./CourseProjectData")
}
##
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
##
extractedName <- featuresName$V2[grep("mean\\(\\)|std\\(\\)", featuresName$V2)]
extracted <- c(as.character(extractedName), "subject", "activity")
extractedData <- subset(allData, select = extracted)
##
activityLabel <- read.table(file.path(filepath, "activity_labels.txt"), header = FALSE)
labelNumber = 1
for (acLabel in activityLabel$V2) {
  extractedData$activity <- gsub(labelNumber, acLabel, extractedData$activity)
  labelNumber <- labelNumber + 1
}
##
names(extractedData)<-gsub("^t", "time", names(extractedData))
names(extractedData)<-gsub("^f", "frequency", names(extractedData))
names(extractedData)<-gsub("Acc", "Accelerometer", names(extractedData))
names(extractedData)<-gsub("Gyro", "Gyroscope", names(extractedData))
names(extractedData)<-gsub("Mag", "Magnitude", names(extractedData))
names(extractedData)<-gsub("BodyBody", "Body", names(extractedData))
names(extractedData)<-gsub("-std", "StdDev", names(extractedData))
names(extractedData)<-gsub("-mean", "Mean", names(extractedData))
##
secondTidyData <- aggregate(. ~subject + activity, extractedData, mean)
secondTidyData <- secondTidyData[order(secondTidyData$subject, secondTidyData$activity),]
write.table(secondTidyData, "./secondTidyData.txt", row.name = FALSE)