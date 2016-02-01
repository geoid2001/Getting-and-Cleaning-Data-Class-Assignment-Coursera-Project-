# README

Getting-and-Cleaning-Data-Class-Assignment-Coursera-Project-

Elliot Klein

Saturday the 30th of January, 2016

Class Project for "Getting and Cleaning Data"

The purpose of this assignment is to download into R, the [Human Activity Recognition Using Smartphones](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) dataset in order to manipulate and analyze specific components of the data. Futhermore, completion of the assignment requires the output of a modidfied form of the original data, along with results from data analysis, into a new tidy dataset.

## An R script called [run_analysis.R] was written to accomplish the tasks assigned in this class Project. Listed here are the steps the R script follows to complete the class project:

`Load required library sets`

library(data.table)

`Download the zip file` 

setPath <- "/Users/geoid2001/downloads/"

setwd(setPath)

if(!file.exists("./data")){dir.create("./data")}

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

`Unzip dataset file and place folders and files into /data directory`

unzip(zipfile="./data/Dataset.zip",exdir="./data")
 
 `Read into seperate data.tables the features and activity labels file and the data, subject,and activity, files for the training cases and for the test cases.`
 
Features <- fread(file.path(DataPath, "features.txt"), sep=" ")

ActivityLabelSet<- fread(file.path(DataPath, "activity_labels.txt"), sep=" ")

DataTrainSet <- fread(file.path(DataPath, "train", "X_train.txt" ), sep=" ")

ActivityTrainSet <- fread(file.path(DataPath, "train", "y_train.txt"), sep=" ")

SubjectTrainSet <- fread(file.path(DataPath, "train", "subject_train.txt"), sep=" ")

DataTestSet  <- fread(file.path(DataPath, "test" , "X_test.txt" ), sep=" ")

ActivityTestSet  <- fread(file.path(DataPath, "test" , "y_test.txt" ), sep=" ")

SubjectTestSet  <- fread(file.path(DataPath, "test" , "subject_test.txt" ), sep=" ")

## Step 1. Merges the training and the test sets to create one data set.

`Merge the training and test datasets into a single datasets and rename columns appropiately.`

CombinedSubjectSet <- rbind(SubjectTrainSet, SubjectTestSet)

setnames(CombinedSubjectSet, "V1", "SubjectsID")

CombinedActivitySet<- rbind(ActivityTrainSet, ActivityTestSet)

setnames(CombinedActivitySet, "V1", "ActivityID")

CombinedDataSet <- rbind(DataTrainSet, DataTestSet)

setnames(Features, names(Features), c("FeatureID", "Feature"))

colnames(CombinedDataSet) <- Features[,Feature]

setnames(ActivityLabelSet, names(ActivityLabelSet), c("ActivityID","Activity"))

`Merge datasets by columns`

CombinedSubjectActivitySets<- cbind(CombinedSubjectSet, CombinedActivitySet)

CombinedFullDataSet <- cbind(CombinedSubjectActivitySets, CombinedDataSet) 

## Step 2. Extracts only the measurements on the mean and standard deviation for each measurement.

`Extract from the Features data.table any feature utilizing mean() and std() for the measurements

FeaturesMeanStdSet <- Features[grep("std\\(\\)|mean\\(\\)",Feature),Feature]

FeaturesMeanStdSet <-union(c("SubjectsID","ActivityID"),FeaturesMeanStdSet)

CombinedFullMeanStdDataSet <-subset(CombinedFullDataSet,select=FeaturesMeanStdSet) 

## Step 3. Uses descriptive activity names to name the activities in the data set

`Add activity names into CombinedFullMeanStdDataSet data.table`

CombinedLabeledFullMeanStdDataSet <- merge(ActivityLabelSet, CombinedFullMeanStdDataSet , by="ActivityID", all.x=TRUE)

## Step 4. Appropriately labels the data set with descriptive variable names.

`add readable names to the dataset`

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


## Part 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

`write a csv file to storage`

TidyDataSet<- CombinedLabeledFullMeanStdDataSet[, lapply(.SD, mean), by = 'SubjectsID,ActivityID']

write.csv(TidyDataSet, file = "tidy.csv", row.names = FALSE)

The output tidy data set can be viewed here: [tidy.csv](tidy.csv)

For more information about the datasets and the analyses see the [code book](CodeBook.md).

### Class Project Assignment Details 

Review criteria
1. The submitted data set is tidy.
2. The Github repo contains the required scripts.
3. GitHub contains a code book that modifies and updates the available codebooks with the data to indicate all the variables and summaries calculated, along with units, and any other relevant information.
4. The README that explains the analysis files is clear and understandable.
5. The work submitted for this project is the work of the student who submitted it.

Getting and Cleaning Data Course Project
The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

You should create one R script called run_analysis.R that does the following.

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

