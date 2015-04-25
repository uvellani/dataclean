---
title: "Data Cleaning Project"
output: html_document
---

This data was generated from mobile devices that recorded the movement of the various subjects while undertaking the six activities - (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING). The raw data that was collected was cleaned to generate a data set that has the mean and standard deviation of the observations for each subject and activity.

The data cleaning program does the following -

Load the packages for the functions that are used in the program.
```{r}
        library("dplyr")
        library("sqldf")
        library("gdata")
```

Load the features file and create a vector of column names which can be passed to the loading function to name the columns.
```{r}
        cnames <- read.table("features.txt")
        cn <- as.vector(cnames[,2])
```

Load the activity labels file into a data frame to use in the data set.
```{r}
xactl <- read.table("activity_labels.txt",col.names=c("activityid","activitylabel"))
```

In this step the test and train data are loaded and named using the names loaded above.
Then the subject and activity are loaded into data frames which are then added to the data set using bind_cols function from dplyr package. The two new columns are then named.
```{r}
        xtest <- read.table("./test/X_test.txt", col.names=cn)        
        xsub  <- read.table("./test/subject_test.txt")
        xact <- read.table("./test/y_test.txt")
        xtest <- bind_cols(xsub[1],xtest)
        names(xtest)[1] <- "subject"
        xtest <- bind_cols(xact[1],xtest)
        names(xtest)[1] <- "activityid"
        
        xtrain <- read.table("./train/X_train.txt",col.names=cn)
        xsub  <- read.table("./train/subject_train.txt")
        xact <- read.table("./train/y_train.txt")
        xtrain <- bind_cols(xsub[1],xtrain)
        names(xtrain)[1] <- "subject"
        xtrain <- bind_cols(xact[1],xtrain)
        names(xtrain)[1] <- "activityid"
```

Now the test and train data frames are joined together into one data frame.
```{r}
        xdata <- bind_rows(xtest,xtrain)
```

From that data frame, a new data frame is created with columns that have only mean or standard deviation values plus the subject and activity. 'grep' is used to determine which columns to select.
```{r}
        xmeanstd <- xdata[,c(1,2,grep("(mean|std)", names(xdata)))]
```

Tidy up the column names by expanding short forms, removing periods and turning it to lower case.
```{r}
        names(xmeanstd)  <- tolower(names(xmeanstd))
        names(xmeanstd)  <- gsub("std","stddev",names(xmeanstd))
        names(xmeanstd)  <- gsub("\\.","",names(xmeanstd))
        names(xmeanstd)  <- gsub("acc","acceleration",names(xmeanstd))
        names(xmeanstd)  <- gsub("mag","magnitude",names(xmeanstd))
```

Add the descriptive activity label as a column.
```{r}
        xmeanstd <- sqldf("select xactl.activitylabel, xmeanstd.* from xmeanstd join xactl using(activityid)")
```
 This produces a clean data set with a row for each individual observation for each activty and subject. 
 
 The final tidy data set that is produced is the mean of all the variables for each subject and activity. "by = ", the key that it is averaged on and "on =", the variables whose mean is produced.
 
```{r}
        frameApply(dfMeter, by = c('activitylabel', 'subject'), on = c(4:82), fun = colMeans)
```
