# run_analysis.R

library(data.table)

setPath <- "/Users/geoid2001/downloads/"
setwd(setPath)
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

###Unzip DataSet to /data directory
unzip(zipfile="./data/Dataset.zip",exdir="./data")


###Load required packages
library(dplyr)

library(tidyr)

DataPath <- "/Users/geoid2001/downloads/data/UCI HAR Dataset/"

# Read into seperate data.tables the features and activity labels file and the data, subject,and activity, files for the training cases and for the test cases.

Features <- fread(file.path(DataPath, "features.txt"), sep=" ")
ActivityLabelSet<- fread(file.path(DataPath, "activity_labels.txt"), sep=" ")
DataTrainSet <- fread(file.path(DataPath, "train", "X_train.txt" ), sep=" ")
ActivityTrainSet <- fread(file.path(DataPath, "train", "y_train.txt"), sep=" ")
SubjectTrainSet <- fread(file.path(DataPath, "train", "subject_train.txt"), sep=" ")
DataTestSet  <- fread(file.path(DataPath, "test" , "X_test.txt" ), sep=" ")
ActivityTestSet  <- fread(file.path(DataPath, "test" , "y_test.txt" ), sep=" ")
SubjectTestSet  <- fread(file.path(DataPath, "test" , "subject_test.txt" ), sep=" ")

## Part 1. Merges the training and the test sets to create one data set.

## Merge the training and test datasets into a single datasets and rename columns appropiately.

CombinedSubjectSet <- rbind(SubjectTrainSet, SubjectTestSet)
setnames(CombinedSubjectSet, "V1", "SubjectsID")
CombinedActivitySet<- rbind(ActivityTrainSet, ActivityTestSet)
setnames(CombinedActivitySet, "V1", "ActivityID")
CombinedDataSet <- rbind(DataTrainSet, DataTestSet)
setnames(Features, names(Features), c("FeatureID", "Feature"))
colnames(CombinedDataSet) <- Features[,Feature]
setnames(ActivityLabelSet, names(ActivityLabelSet), c("ActivityID","Activity"))

# Merge datasets by columns
CombinedSubjectActivitySets<- cbind(CombinedSubjectSet, CombinedActivitySet)
CombinedFullDataSet <- cbind(CombinedSubjectActivitySets, CombinedDataSet)

## Part 2. Extracts only the measurements on the mean and standard deviation for each measurement.

## Extract from the Features data.table any feature utilizing mean and standard deviation for the measurements

FeaturesMeanStdSet <- Features[grep("std\\(\\)|mean\\(\\)",Feature),Feature] 
FeaturesMeanStdSet <-union(c("SubjectsID","ActivityID"),FeaturesMeanStdSet)
CombinedFullMeanStdDataSet <-subset(CombinedFullDataSet,select=FeaturesMeanStdSet) 

## Part 3. Uses descriptive activity names to name the activities in the data set

## Add activity names into CombinedFullMeanStdDataSet data.table

CombinedLabeledFullMeanStdDataSet <- merge(ActivityLabelSet, CombinedFullMeanStdDataSet , by="ActivityID", all.x=TRUE)

## part 4. Appropriately labels the data set with descriptive variable names.

## add readable names to the dataset

names(CombinedLabeledFullMeanStdDataSet)<-gsub("Acc", "Accelerometer", names(CombinedLabeledFullMeanStdDataSet))
names(CombinedLabeledFullMeanStdDataSet)<-gsub("BodyBody", "Body", names(CombinedLabeledFullMeanStdDataSet))
names(CombinedLabeledFullMeanStdDataSet)<-gsub("^f", "Frequency", names(CombinedLabeledFullMeanStdDataSet))
names(CombinedLabeledFullMeanStdDataSet)<-gsub("Gyro", "Gyroscope", names(CombinedLabeledFullMeanStdDataSet))
names(CombinedLabeledFullMeanStdDataSet)<-gsub("Mag", "Magnitude", names(CombinedLabeledFullMeanStdDataSet))
names(CombinedLabeledFullMeanStdDataSet)<-gsub("mean()", "Mean", names(CombinedLabeledFullMeanStdDataSet))
names(CombinedLabeledFullMeanStdDataSet)<-gsub("std()", "Standard Deviation", names(CombinedLabeledFullMeanStdDataSet))
names(CombinedLabeledFullMeanStdDataSet)<-gsub("^t", "Time", names(CombinedLabeledFullMeanStdDataSet))
for (subj in 1:30){
CombinedLabeledFullMeanStdDataSet[SubjectsID==subj,Subject:=paste("Subject",subj,sep=" ") ]
}
CombinedLabeledFullMeanStdDataSet[,SubjectsID:=Subject]
CombinedLabeledFullMeanStdDataSet[,ActivityID:=Activity]
CombinedLabeledFullMeanStdDataSet[,Subject:=NULL]
CombinedLabeledFullMeanStdDataSet[,Activity:=NULL]


# step 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## write a .txt file to storage

TidyDataSet<- CombinedLabeledFullMeanStdDataSet[, lapply(.SD, mean), by = 'SubjectsID,ActivityID']
write.table(TidyDataSet, file = "tidy.txt", row.names = FALSE)

