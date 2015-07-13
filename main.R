
library(dplyr)
library(sqldf)
library(FSelector)
library(rpart)
library(ROCR)
library(neuralnet)

source("load_data.R")
source("prepare_session.R")
source("prepare_receipts.R")
source("prepare_returns.R")
source("prepare_customer.R")
source("join_customer.R")

data<-load_data()

data_session <- data$session
data_receipts <- data$receipts
data_returns <- data$returns
data_customer <- data$customer
rm(data)

today <- max(data_receipts$signalDate)

data_session_prep <- prepare_session(data_session, today)
data_receipts_prep <- prepare_receipts(data_receipts, today)
data_returns_prep <- prepare_returns(data_returns, today)
data_customer_prep <- prepare_customer(data_customer, today)
rm(data_session)
rm(data_receipts)
rm(data_returns)
rm(data_customer)

customer <- join_customer(data_customer_prep, data_session_prep, 
                          data_receipts_prep, data_returns_prep)

#============================================================
# Train / Test

train_ix <- sample(1:nrow(customer), round(nrow(customer)/3*2,0))
customer_train <- customer[train_ix,]
customer_test <- customer[-train_ix,]

#============================================================
# Normalizing

customer_train_stand <- as.data.frame(scale(customer_train))
customer_train_stand$churn <- customer_train$churn
customer_train_stand$customerId2 <- customer_train$customerId2
avg <- sapply(customer_train,mean)
std <- sapply(customer_train,sd)

customer_test_stand <- t((t(customer_test) - avg) / std)
customer_test_stand <- as.data.frame(customer_test_stand)
customer_test_stand$churn <- customer_test$churn
customer_test_stand$customerId2 <- customer_test$customerId2

#============================================================
# Feature selection

weights <- linear.correlation(churn~., customer_train)
feat_subset <- cutoff.k(weights, 21)
f <- as.simple.formula(subset, "churn")

#============================================================
# Decision Tree

mytree <- rpart(f, dat = customer_train_stand, method = "anova")

tree_prediction <- predict(mytree, customer_test_stand)

tree_val <- data.frame(expected = customer_test_stand$churn, 
                          tree_output = tree_prediction)

pred2 <- prediction(tree_val$tree_output, tree_val$expected)

# Cumulative Gains chart
perf_gain <- performance(pred2, "tpr", "rpp")
plot(perf_gain, main="Decision Tree: Cumulative Gains")

# Lift chart
perf_lift <- performance(pred2, "lift", "rpp")
plot(perf_lift, main="Decision Tree: Lift curve")

# ROC curve
perf_roc <- performance(pred2,"tpr","fpr")
plot(perf_roc, main="Decision Tree: ROC curve")

#============================================================
# Neural Network

nn <- neuralnet(f,
                   data = customer_train_stand[1:200000, ],
                   hidden = 8, 
                   err.fct = "sse",
                   linear.output = FALSE)

customer_test_stand_sel<-customer_test_stand[,feat_subset]
nn_prediction <- compute(nn, customer_test_stand_sel)
nn_val <- data.frame(expected = customer_test_stand$churn, 
                          nn_output = nn_prediction$net.result[,1])

pred3 <- prediction(nn_val$nn_output, nn_val$expected)

# Cumulative Gains chart
perf_gain <- performance(pred3, "tpr", "rpp")
plot(perf_gain, main="Neural Network: Cumulative Gains")

# Lift chart
perf_lift <- performance(pred3, "lift", "rpp")
plot(perf_lift, main="Neural Network: Lift curve")

# ROC curve
perf_roc <- performance(pred3,"tpr","fpr")
plot(perf_roc, main="Neural Network: ROC curve")
