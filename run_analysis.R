
# Although not required, for simplicity and my own future reference, I include this 
#process (downloading and unzipping the dataset):
dataset_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(dataset_url,"dataset.zip")
unzip("dataset.zip")

library(dplyr)
library(data.table)


##############################################################################
#Step 1: Merge the traning and test sets to creat one data set
#read in the data from the provided files

subtrain = read.table('./UCI HAR Dataset/train/subject_train.txt',header=FALSE)
xtrain   = read.table('./UCI HAR Dataset/train/X_train.txt',header=FALSE)
ytrain   = read.table('./UCI HAR Dataset/train/Y_train.txt',header=FALSE)
subtest  = read.table('./UCI HAR Dataset/test/subject_test.txt',header=FALSE)
xtest    = read.table('./UCI HAR Dataset/test/X_test.txt',header=FALSE)
ytest    = read.table('./UCI HAR Dataset/test/Y_test.txt',header=FALSE)
features = read.table('./UCI HAR Dataset/features.txt',header=FALSE)
activity = read.table('./UCI HAR Dataset/activity_labels.txt',header=FALSE)

#assigning names to data columns
colnames(activity)  = c('activity_id','activity_type')
colnames(subtrain)  = "subject_id"
colnames(subtest)   = "subject_id"
colnames(ytrain)    = "activity_id"
colnames(ytest)     = "activity_id"
colnames(xtrain)    = features[,2]
colnames(xtest)     = features[,2]

#create full training and testing data sets
training<-cbind(subtrain,ytrain,xtrain)
testing<-cbind(subtest,ytest,xtest)

#create the full combined data set
data<-rbind(training,testing)


###############################################################################
#Step 2: extract only the Mean and Standard Deviation measurements

Data<-tbl_df(data)
Data<-Data[,!duplicated(colnames(Data))]
sData<-select(Data,subject_id,activity_id,contains("Mean()"),contains("std()"))


#############################################################################
#Step 3:descriptive activity names to name the activities in the data set 

sData$activity_id<-as.factor(sData$activity_id)
levels(sData$activity_id)<-c("WALKING","WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING","STANDING", "LAYING")


#############################################################################
#Step 4: label the data set with descriptive variable names by replacing:
#prefix t with time
#prefix f   with frequency
#Acc        with Accelerometer
#Gyro       with Gyroscope
#Mag        with Magnitude 
#BodyBody   with Body

names(sData)<-gsub("^t", "time", names(sData))
names(sData)<-gsub("^f", "frequency", names(sData))
names(sData)<-gsub("Acc", "Acceleration", names(sData))
names(sData)<-gsub("Gyro", "Gyroscope", names(sData))
names(sData)<-gsub("Mag", "Magnitude", names(sData))
names(sData)<-gsub("BodyBody", "Body", names(sData))

##########################################################################
#Step 5: Create a second indpendent tidy data set with the average of each
#variable for each activity and each subject

#grp_cols<-c("subject_id","activity_id")
grp_cols<-names(sData["subject_id","activity_id"])

# Convert character vector to list of symbols
dots <- lapply(grp_cols, as.symbol)

#average over 66 columns (excluding subject_id and acitivity_id)
tidyData<-sData %>%
    group_by_(.dots=dots) %>%
    summarise_each(funs(mean))

#export the tidyData set
write.table(tidyData, "tidyData.txt", row.name=FALSE)