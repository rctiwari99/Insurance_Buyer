titanic <- read.csv(file.choose())
head(titanic)
summary(titanic)

library(Amelia)
missmap(titanic, main="Titanic Data - Missings Map", 
        col=c("yellow", "black"), legend=FALSE)
# EDA
library(ggplot2)
  ggplot(titanic,aes(factor(Survived))) +
   geom_bar()
  
  ggplot(titanic,aes(Pclass)) + 
  geom_bar(aes(fill=factor(Pclass)),alpha=0.5)

  ggplot(titanic,aes(Sex)) + 
  geom_bar(aes(fill=factor(Sex)),alpha=0.5)
  
  ggplot(titanic,aes(Age)) + 
  geom_histogram(fill='blue',bins=20,alpha=0.5)
  
  ggplot(titanic,aes(SibSp)) + 
  geom_bar(fill='red',alpha=0.5)
  
  ggplot(titanic,aes(Fare)) + 
  geom_histogram(fill='green',color='black',alpha=0.5)
  
  
  # cleaning
  
  # check the average age by passenger class
  pl <- ggplot(titanic,aes(Pclass,Age)) + geom_boxplot(aes(group=Pclass,fill=factor(Pclass),alpha=0.4)) 
  pl + scale_y_continuous(breaks = seq(min(0), max(80), by = 2))
  
  # use these average age values to impute based on Pclass for Age
  
  impute_age <- function(age,class){
    out <- age
    for (i in 1:length(age)){
      
      if (is.na(age[i])){
        
        if (class[i] == 1){
          out[i] <- 37
          
        }else if (class[i] == 2){
          out[i] <- 29
          
        }else{
          out[i] <- 24
        }
      }else{
        out[i]<-age[i]
      }
    }
    return(out)
  }

# imputing the average age per class 
titanic$fixed_age <- impute_age(titanic$Age,titanic$Pclass)

# missing data indicator - replacing original values with 0 and imputing 1 whereever data is missing
titanic$Age <- ifelse(is.na(titanic$Age),1,0)


# checking missing values

any(is.na(titanic))
titanic <- na.omit(titanic)
missmap(titanic, main="Titanic Data - Missings Map", 
        col=c("yellow", "black"), legend=FALSE)


# fare vs Pclass 
ggplot(titanic, aes(Pclass, Fare)) +
   geom_boxplot() +
  facet_wrap(~Pclass) 

##caTools used for splitting dataset into train and test dataset

library(caTools)

set.seed(7)
sample <- sample.split(titanic, SplitRatio = 0.7)

titanic_train <- subset(titanic, sample == TRUE)
titanic_test <- subset(titanic, sample == FALSE)

# building model on training data

str(titanic_train)

library(dplyr)

titanic_train <- select(titanic_train,-PassengerId,-Name,-Ticket,-Cabin)

titanic_train$Survived <- factor(titanic_train$Survived)
titanic_train$Pclass <- factor(titanic_train$Pclass)
titanic_train$Parch <- factor(titanic_train$Parch)
titanic_train$SibSp <- factor(titanic_train$SibSp)


log.model <- glm(formula=Survived ~ . , family = binomial(link='logit'),data = titanic_train)
  
summary(log.model)



titanic_test$Survived <- factor(titanic_test$Survived)
titanic_test$Pclass <- factor(titanic_test$Pclass)
titanic_test$Parch <- factor(titanic_test$Parch)
titanic_test$SibSp <- factor(titanic_test$SibSp)

test <- select(titanic_test, -Survived)
fitted.probabilities <- predict(log.model,newdata=test,type='response')


fitted.results <- ifelse(fitted.probabilities > 0.5,1,0)

accuracy <- mean(fitted.results == titanic_test$Survived)
accuracy

confusion_mat <- table(fitted.probabilities > 0.5, titanic_test$Survived)

accuracy_alt <- sum(diag(confusion_mat)) / sum(confusion_mat) *100

library(pROC)
ROC <- roc(titanic_test$Survived, fitted.probabilities)
plot(ROC, col = "red")
auc(ROC)

# 
###


# Forward stepwise approach to add predictors to the model one-by-one until no additional benefit is seen

# Null model with no predictors
null_model <- glm(Survived ~ 1, data =titanic_train, family = "binomial")

# Full model using all predictors
full_model <- glm(Survived ~. , data = titanic_train, family = "binomial")

# forward stepwise algorithm to build a parsimonious model
step_model <- step(null_model, scope = list(lower = null_model, upper = full_model), direction = "forward")

summary(step_model)
# stepwise donation probability
step_prob <- predict(step_model, type = "response")

# ROC and AUC of the stepwise model
ROC <- roc(data_t$Survived, step_prob)
plot(ROC, col = "red")
auc(ROC)

# prediction of probabilities for test data set using the step model
step_prob_t <- predict(step_model, newdata = test, type = "response")
ROC <- roc(titanic_test$Survived, step_prob_t)
plot(ROC, col = "red")
auc(ROC)
