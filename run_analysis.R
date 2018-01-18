
# Data Load ---------------------------------------------------------------

Train.data = read.table("train/X_train.txt")
Train.labels = read.table("train/y_train.txt")
Test.data = read.table("test/X_test.txt")
Test.labels = read.table("test/y_test.txt")

Activity.labels = read.table("activity_labels.txt")
Features.list= read.table("features.txt")


# Data Merge --------------------------------------------------------------
#Merges the training and the test sets to create one data set.

library(plyr)
library(dplyr)

Train.datal <-cbind(Train.labels,Train.data)
colnames(Train.datal)[1]<-"DataLabel"
Test.datal <-cbind(Test.labels,Test.data)
colnames(Test.datal)[1]<-"DataLabel"
merged.data<-join(Train.datal,Test.datal,by="DataLabel",type="inner")

# Labels, Activities & Variable  ------------------------------------------
#Appropriately labels the data set with descriptive variable names. 

merged.data[,1]<- factor(merged.data[,1], levels = Activity.labels[,1], labels = Activity.labels[,2])
merged.features<-as.character(rep(Features.list[,2],2))
colnames(merged.data)<-c("activity", merged.features) #repeat the feautures list and add on the Data label column as "activity"

# Mean and STDEV Extaction --------------------------------------------------
#Extracts only the measurements on the mean and standard deviation for each measurement

mean.cols<-grep("mean",colnames(merged.data))
stdev.cols<-grep("std",colnames(merged.data))

merged.data.ms<-merged.data[,c(1,mean.cols,stdev.cols)]

# Tidy Data Set of Means and STDEV ----------------------------------------
#creates a second, independent tidy data set with the average of each variable for each activity and each subject.


merged.data.grouped<-group_by(merged.data.ms, activity)

#clean up some of those variable names

colnames(merged.data.grouped)<-c(gsub("-","",colnames(merged.data.grouped)))
colnames(merged.data.grouped)<-c(gsub("\\.","",colnames(merged.data.grouped)))
colnames(merged.data.grouped)<-c(gsub("\\()","",colnames(merged.data.grouped)))

#summarize data table
merged.data.tidy<-summarize_each(merged.data.grouped, funs(mean)) 
#output to a .txt file
write.table(merged.data.tidy,file="tidydata.txt",row.names=F,quote=F)

