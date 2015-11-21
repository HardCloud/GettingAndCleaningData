---
title: "GETTING & CLEANING DATA - PROJECT"
author: "HardCloud"
date: "Friday, November 20, 2015"
output: html_document
---

# Project and Source Data
The aim of this project is to extract clean useable data from the zip file whose source code can be found [here](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip). 

This file is in turn found in [The UCI Machine Learning Repository](http://archive.ics.uci.edu/ml/datasets/Smartphone-Based+Recognition+of+Human+Activities+and+Postural+Transitions). 

# This repository includes the following files:

* run_analysis.R : the R-code run on the data set

* tidyData.txt : the clean data extracted from the original data via run_analysis.R

* CodeBook.md : reference to the variables in tidyData.txt

* README.md : a description of the code in run_analysis.R


# Data Transformation details

The project includes 5 steps:

1. Merge the training and the test sets to create one data set
2. Extract only the measurements on the mean and standard deviation for each measurement
3. Use descriptive activity names to name the activities in the data set
4. Appropriately label the data set with descriptive activity names
5. Create a second, independent tidy data set with the average of each variable for each activity and each subject.


# The implementation of the above steps in run_analysis.R
* Prior to performing the required steps, the raw data is assumed to have been downloaded and unzipped. Although not required, this process is included in the run_analysis.R. 

* The required libraries:
```{r}
library(data.table)
library(dplyr)
```
* Reading the training data
```{r}
subtrain = read.table('./UCI HAR Dataset/train/subject_train.txt',header=FALSE)
xtrain   = read.table('./UCI HAR Dataset/train/X_train.txt',header=FALSE)
ytrain   = read.table('./UCI HAR Dataset/train/Y_train.txt',header=FALSE)
```
* Reading the test data
```{r}
subtest  = read.table('./UCI HAR Dataset/test/subject_test.txt',header=FALSE)
xtest    = read.table('./UCI HAR Dataset/test/X_test.txt',header=FALSE)
ytest    = read.table('./UCI HAR Dataset/test/Y_test.txt',header=FALSE)
```
* Reading other (meta) data
```{r}
features = read.table('./UCI HAR Dataset/features.txt',header=FALSE)
activity = read.table('./UCI HAR Dataset/activity_labels.txt',header=FALSE)
```
* STEP 1
    * Naming the columns
    ```{r}
    colnames(activity)  = c('activity_id','activity_type')
colnames(subtrain)  = "subject_id"
colnames(subtest)   = "subject_id"
colnames(ytrain)    = "activity_id"
colnames(ytest)     = "activity_id"
colnames(xtrain)    = features[,2]
colnames(xtest)     = features[,2]
    ```
    * Creating the training and testing data sets
    ```{r}
    training<-cbind(subtrain,ytrain,xtrain)
    testing<-cbind(subtest,ytest,xtest)
    ```
    * Merging them into one data set
    ```{r}
    data<-rbind(training,testing)
    ```
* STEP 2
    * After removing the duplicate column names, the dplyr package is used to extract only the columns that include the mean(mean()) and the standard deviation (std()) data.
    ```{r}
    sData<-select(Data,subject_id,activity_id,contains("Mean()"),contains("std()"))
    ```
* STEP 3
    * Here we add desctiptive names such as "walking", "sitting" etc to the activities in the data set.
    ```{r}
    levels(sData$activity_id)<-c("WALKING","WALKING_UPSTAIRS","WALKING_DOWNSTAIRS","SITTING","STANDING","LAYING")
    ```
 * STEP 4
    * The data set is then labeled with descriptive variable names by replacing some abbrevations as follows:
        * prefix t  is replaced with time
        * prefix f  is replaced  with frequency
        * Acc       is replaced with Accelerometer
        * Gyro      is replaced with Gyroscope
        * Mag       is replaced with Magnitude 
        * BodyBody  is replaced with Body
    ```{r}
    -gsub("^t", "time", names(sData))
names(sData)<-gsub("^f", "frequency", names(sData))
names(sData)<-gsub("Acc", "Acceleration", names(sData))
names(sData)<-gsub("Gyro", "Gyroscope", names(sData))
names(sData)<-gsub("Mag", "Magnitude", names(sData))
names(sData)<-gsub("BodyBody", "Body", names(sData))
    ```    
    
* STEP 5:
    * The final "tidy" data set is then created by calculating the mean of each column except for acitivity_id and subject_id. As the subjects are identifiied with integers, we turn the row values to symbols before calculating the mean of each column.
    ```{r}
    tidyData<-sData %>%
        group_by_(.dots=dots) %>%
            summarise_each(funs(mean))
    ```
    * The final tidy data set (tidyData) is saved in the text file "tidyData.txt".
    ```{r}
    write.table(tidyData, "tidyData.txt", row.name=FALSE)
    ```
