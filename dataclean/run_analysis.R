run_analysis  <- function() {
        #This function loads the data and cleans it up to form a tidy data set.
        #See README.md file for detailed description of its working.
        
        #load the packages
        library("dplyr")
        library("sqldf")
        library("gdata")
        
        #load the features file and create a vector of column names
        cnames <- read.table("features.txt")
        cn <- as.vector(cnames[,2])
        
        #load the activity labels
        xactl <- read.table("activity_labels.txt",col.names=c("activityid","activitylabel"))
        
        #load test data and name columns using the features data
        xtest <- read.table("./test/X_test.txt", col.names=cn)        
        #load subject and activity id's
        xsub  <- read.table("./test/subject_test.txt")
        xact <- read.table("./test/y_test.txt")
        #add these as columns to the test data set and name the columns
        xtest <- bind_cols(xsub[1],xtest)
        names(xtest)[1] <- "subject"
        xtest <- bind_cols(xact[1],xtest)
        names(xtest)[1] <- "activityid"
        
        #load the training data and name columns using the features data
        xtrain <- read.table("./train/X_train.txt",col.names=cn)
        #load subject and activity id's
        xsub  <- read.table("./train/subject_train.txt")
        xact <- read.table("./train/y_train.txt")
        #add these as columns to the test data set and name the columns
        xtrain <- bind_cols(xsub[1],xtrain)
        names(xtrain)[1] <- "subject"
        xtrain <- bind_cols(xact[1],xtrain)
        names(xtrain)[1] <- "activityid"
        
        #add the test and training data together into one data frame
        xdata <- bind_rows(xtest,xtrain)
        
        #create a new data frame with columns that have only mean or standard deviation
        xmeanstd <- xdata[,c(1,2,grep("(mean|std)", names(xdata)))]
        
        #tidy up the column names by expanding short forms, removing periods and turning it to lower case
        names(xmeanstd)  <- tolower(names(xmeanstd))
        names(xmeanstd)  <- gsub("std","stddev",names(xmeanstd))
        names(xmeanstd)  <- gsub("\\.","",names(xmeanstd))
        names(xmeanstd)  <- gsub("acc","acceleration",names(xmeanstd))
        names(xmeanstd)  <- gsub("mag","magnitude",names(xmeanstd))
        
        #add the descriptive activity label as a column
        xmeanstd <- sqldf("select xactl.activitylabel, xmeanstd.* from xmeanstd join xactl using(activityid)")

        #create the tidy data set with the mean of all the variable for each subject and activity
        xmeanstd  <- frameApply(xmeanstd, by = c('activitylabel', 'subject'), on = c(4:82), fun = colMeans)
        
        #return the data set
        xmeanstd
}