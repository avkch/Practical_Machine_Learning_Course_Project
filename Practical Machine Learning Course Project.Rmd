---
title: "Practical Machine Learning Course Project"
author: "avkch"
date: "18 January 2017"
output: html_document
---

## Introduction
### Background

Using devices such as Jawbone Up, Nike FuelBand, and Fitbit it is now possible to collect a large amount of data about personal activity relatively inexpensively. These type of devices are part of the quantified self movement - a group of enthusiasts who take measurements about themselves regularly to improve their health, to find patterns in their behavior, or because they are tech geeks. One thing that people regularly do is quantify how much of a particular activity they do, but they rarely quantify how well they do it. In this project, your goal will be to use data from accelerometers on the belt, forearm, arm, and dumbell of 6 participants. They were asked to perform barbell lifts correctly and incorrectly in 5 different ways. More information is available from the website here: http://groupware.les.inf.puc-rio.br/har (see the section on the Weight Lifting Exercise Dataset).

### Data
The training data for this project are available here: https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv
The test data are available here:
https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv
The data for this project come from this source: http://groupware.les.inf.puc-rio.br/har. If you use the document you create for this class for any purpose please cite them as they have been very generous in allowing their data to be used for this kind of assignment.

### Goal
The goal of this project is to build prediction model for the manner in which they did the exercise. This is the "classe" variable in the training set. This prediction model will be used to predict 20 different test cases.

## Setting up the environment
Loading the packages necessary for the analysis.
```{r message=FALSE}
library(rpart)
library(caret)
library(randomForest)
```


## Getting and cleaning the data
Both dataset will be downloaded and stored in data frames  `training` and `testing`. Missing values, and  #DIV/0! will be replaced with NA, strings will be imported as factors.
```{r cashe=TRUE}
training <- read.csv("https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv", na.strings=c("NA", "", "#DIV/0!"), stringsAsFactors = TRUE)
testing <- read.csv("https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv", na.strings=c("NA", "", "#DIV/0!"), stringsAsFactors = TRUE)

```

Checking the proportion of the missing observations per every variable
```{r}
plot(colMeans((is.na(training))))
```
It is obvious that many columns(variables) are with nearly 100% missing values, those columns can be removed.
```{r}
training <- training[, colMeans(is.na(training))<0.8]
```

Another set of columns that are not going to give us any sensible information are: index column ("X"), columns containing information about the time ("raw_timestamp_part_1",  "raw_timestamp_part_2" and "cvtd_timestamp") and columns "new_window"and "num_window".
```{r}
training <- training[, -(3:7)]
training <- training[, -1]
training <- training[, colMeans(is.na(training))<0.8]
```
The testing data set should be transformed in the same way so that all the columns are the same with the training set (except the classe)
```{r}
testing <- testing[,intersect(colnames(training), colnames(testing))]
```

After removing the unnecessary columns the training dataset is partitioned to two datasets 70% to `myTraining` (will be used to build the prediction) and 30% to `myTesting` (will be used to cross validate the model).
```{r}
set.seed(3366)
inTrain <- createDataPartition(training$classe, p=0.7, list=FALSE)
myTraining <- training[inTrain, ]
myTesting <- training[-inTrain, ]
```

## Prediction
### Decision Tree
The first model that will be tested is the Decision tree (rpart package)
```{r cashe=TRUE}
treefit <- rpart(classe ~ ., data=myTraining, method="class")
predictionsDT <- predict(treefit, myTesting, type = "class")
cmtree <- confusionMatrix(predictionsDT, myTesting$classe)
cmtree
```
The accuracy of this model is 0.72 which is not great, so another model should be tested.

### Random Forest
The second model to test is Random Forest (randomForest package)
```{r cashe=TRUE}
forestfit <- randomForest(classe ~ ., data=myTraining)
predictionRF <- predict(forestfit, myTesting, type = "class")
cmforest <- confusionMatrix(predictionRF, myTesting$classe)
cmforest
```
The accuracy is 0.9951 which is much better. The out of sample error is 1-0.995 = 0.0049

This model is good enough to be used for prediction of the testing dataset.

### Final Prediction
```{r}
prediction <- predict(forestfit, testing, type = "class")
prediction
```

