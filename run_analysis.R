library(dplyr)
library(data.table)

## Downloading and unzipping data sets
if(!dir.exists("files")){ dir.create("files")}
if(!file.exists("files/zippedData.zip")){ download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile = "files/zippedData.zip") }
if(!file.exists("files/UCI HAR Dataset/")){ unzip("files/zippedData.zip", overwrite = T, exdir = "files") }

## Loading activity labels and features
activityLabels <- fread("files/UCI HAR Dataset/activity_labels.txt", col.names = c("activitycode", "activityname"))
features <- fread("files/UCI HAR Dataset/features.txt", col.names = c("featurecode", "featurename"))

## Select relevant features (means and standard deviations)
wantedFeatureIndexes <- grepl(".mean.|.std.", features$featurename)
wantedFeatureNames <- features[wantedFeatureIndexes]$featurename
wantedFeatureNames <- gsub("-mean", "Mean", wantedFeatureNames)
wantedFeatureNames <- gsub("-std", "Std", wantedFeatureNames)
wantedFeatureNames <- gsub("[-()]", "", wantedFeatureNames)

## Load training dataset
trainX <- fread("files/UCI HAR Dataset/train/X_train.txt")[, wantedFeatureIndexes, with = F]
trainY <- fread("files/UCI HAR Dataset/train/y_train.txt")
trainSubject <- fread("files/UCI HAR Dataset/train/subject_train.txt")
trainData <- cbind(trainSubject, trainY, trainX)

## Load test data
testX <- fread("files/UCI HAR Dataset/test/X_test.txt")[, wantedFeatureIndexes, with = F]
testY <- fread("files/UCI HAR Dataset/test/y_test.txt")
testSubject <- fread("files/UCI HAR Dataset/test/subject_test.txt")
testData <- cbind(testSubject, testY, testX)

## Merge data sets and add column names
allData <- rbind(trainData, testData)
colnames(allData) <- c("subject", "activity", wantedFeatureNames)

## Convert Activities and Subjects to factors
allData$activity <- factor(allData$activity, levels = activityLabels$activitycode, labels = activityLabels$activityname)
allData$subject <- as.factor(allData$subject)

## Melt data and calculate means
allDataMelted <- melt(allData, id = c("subject", "activity"))
allDataMeans <- dcast(allDataMelted, subject + activity ~ variable, mean)

## Write means table
write.table(allDataMeans, "tidyData.txt", row.names = F, quote = F)
