##Loading Libraries
library(data.table)
library(plyr)
library(dplyr)
library(tidyr)
library(mice)
library(ggplot2)
library(mlr)
library(VIM)

### load the dataset of the titanic disaster ###
#Loading the train $ test data set
train_df = read.csv('C:/Users/kaelo/Desktop/train.csv')
test_df = read.csv('C:/Users/kaelo/Desktop/test.csv')
#looking at columns of each of the variables ####
head(train_df)
head(test_df)
#we check for duplicated row none was found for the train
duplicated(train_df)

#we check for the duplicated row none was found for the test
duplicated(test_df)

#checking the structure for the train and test
str(train_df)
str(test_df)

#convert Survived to a factor
train_df$Survived<-as.factor(train_df$Survived)
## Univsersal Analysis
#choosing columns for continous variables
cont_train<-train_df%>%select(PassengerId,Pclass,SibSp,Parch,Fare)
summary(cont_train)

#choosing columns for a categorical variables
cat_train<-train_df%>%select(-Name,-PassengerId,Survived,-Pclass,Cabin,Ticket,-Age,-Parch,-SibSp,-Fare,Sex,Embarked)
summary(cat_train)

#checking the number of unique values for the categorical variables
apply(cat_train,2,function(x){length(unique(x))})

## print out count for Embarked
table(cat_train$Embarked)

# we plot the stacked barchart (categorical v categorical)
ggplot(cat_train,aes(Sex,fill=Survived))+geom_bar()+labs(title="Stacked Bar chart",x="Sex",y="Count")+theme_bw()

## counting the number of survival by class and third class died more 
#and the first class survived more
table(train_df$Survived, train_df$Pclass)

## delete the columns that is not necessary for the train data
train<-names(train_df)%in% c("Name","Ticket","Cabin","Embarked")
newdata<-train_df[!train]

##removing the passenger id
newdata<-newdata%>%select(-PassengerId)
##delete the columns that is not necessary for the test data
test<-names(test_df)%in% c("Name","Ticket","Cabin","Embarked")
newdata2<-test_df[!test]

## storing the passenger id for the test too
#newdata2<-newdata2%>%select(-PassengerId)


## checking missing variables values for the train and test
table(is.na(newdata))
table(is.na(newdata2))

#checking the missing columns
colSums(is.na(newdata))
colSums(is.na(newdata2))


## to check percentages of missing columns & rows

Pmiss<-function(x){sum(is.na(x))/length(x)*100}
apply(newdata,2,Pmiss) #columns
apply(newdata,1,Pmiss) # rows

# draw a histogram to investigate extreme values
hist(newdata$Age,col="purple",breaks=40)
hist(newdata$Fare,col="blue",breaks=40)
# I will use the boxplot to check for outliers for the Fare variables
boxplot(newdata$Fare,col="blue")

##  remove extreme outliers from the data
#inTrain = subset(newdata,Fare < 500) 
#summary(inTrain$Fare)

### check the histogram plot again is still not symmetric 
hist(newdata$Fare,col="blue",breaks=40)

#Taking log tranformation will normalize the data
newdata$Fare<-log(newdata$Fare)
## it now looks better now
hist(newdata$Fare,col="blue",breaks=40)

### we plot the stack barchart for Pclass and Survived
ggplot(newdata,aes(Pclass,fill=Survived))+geom_bar()+labs(title="Stacked Bar chart",x="Pclass",y="Count")+theme_bw()

md.pattern(newdata)
## another ways of finding variables that are missing
aggr_plot<-aggr(newdata,col=c('navyblue','red'),
                numbers=TRUE,sortVars=TRUE,labels=names(newdata),
                cex.axis=.7,gap=3,ylab=c("Histogram of missing data","pattern"))




##replacing missing with median
imputed_data<-impute(newdata,classes=list(numeric=imputeMedian()))

#update the newdata set with the imputed values
newdata<-imputed_data$data
#now we check again for the missing 
colSums(is.na(newdata))


#looking at the test data set for cleaning
#checking for missing columns
colSums(is.na(newdata2))

# draw a histogram to investigate extreme values for the test
hist(newdata2$Age,col="purple",breaks=40)
hist(newdata2$Fare,col="orange",breaks=40)

## get rid of extreme values
#inTest = subset(newdata2,Fare < 500)
#summary(inTest$Fare)

#sum(is.na(inTest$Fare))

newdata2$Fare<-log(newdata2$Fare)
hist(newdata2$Fare,col="pink",breaks=40)

##replacing missing with median for the test
imputed_data<-impute(newdata2,classes=list(numeric=imputeMedian()))
#update the inTest dataset  set with the imputed values
newdata2<-imputed_data$data
#After imputation no missing on the test data
rowSums(is.na(newdata2))

summary(newdata2)
## Building Machine Learning ##
dim(newdata);dim(newdata2)

## extract the target variables
train.y<-newdata$Survived
newdata<-newdata%>%select(-Survived)
library(caret)
library(rpart)
#model train and test datasets
set.seed(123)
train.tree<-rpart(train.y~.,data=newdata, method="class",control=rpart.control
                  (minsplit = 20,minbucket = 100,maxdepth = 20),xval=5)

#To look at the summary of these parameters
#1 minsplit - refers to minimum of obsn which exist in the node to split
#2 minibucket -refers  to minimum number of observations which exist in terminal node left
#3 maxdepth - refers to depth  of the tree
#4 xval-refers to cross validation

## Let see the summary to check variables of importances & other importants terms
#summary function shows variable importance, cp table and decision tree
summary(train.tree)

library(rpart.plot)
#for further understanding, let's plot this tree and visualize the tree
rpart.plot(train.tree)
#we could see that Sex is the most important variables including Parch,Fare and Age
#making predictions for the train
predict_train <-predict(train.tree, newdata = newdata,type = "class")

## make prediction For the test data

predict_test<-predict(train.tree, newdata = newdata2, type = "class")

#Analyzing the results
#We know we can use differents metrics to evaluate the model depending on the problem
#but here i am going to use prediction accuracy here.
#i will use confusion matrix to know the fractions of our accurate the model is...


confusionMatrix(predict_train, train.y)
# From the confusion matrix i was able to get 78% accuracy
solun_frame<-data.frame(PassengerId = newdata2$PassengerId, train.y = predict_test)
write.csv(solun_frame,file = "submission.csv")
