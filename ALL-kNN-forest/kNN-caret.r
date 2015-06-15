source("../get-geneexpression.r")
library(caret)

cv <- replicate(3, createFolds(y, k = 5), simplify=FALSE)
trControl <- trainControl(
    method = "none",
    preProcOptions = list(k = 5),
    returnData = FALSE)
rf <- getModelInfo("parRF")$parRF
rf$fit <- function(x, y, wts, param, lev, classProbs, ...){
    randomForest(x, y, mtry = param$mtry, ...)
}

error <- matrix(NA, 3, 5)
for(i in seq_along(cv)){
    for(j in 2:length(cv[[i]])){
        gc()
        trainIndex <- unlist(cv[[i]][-c(1,j)])
        testIndex <- cv[[i]][[j]]
        model <- train(x[trainIndex,], y[trainIndex],
                       method = rf,
                       pre_process = "knn",
                       tuneGrid = expand.grid(mtry = floor(sqrt(ncol(x)))),
                       ntree = 500,
                       trControl = trControl)
        prediction <- predict(model, x[testIndex,])
        error[i, j-1] <- 1 - postResample(prediction, y[testIndex])["Accuracy"]
        rm(trainIndex, testIndex, model, prediction)
    }
}

Sys.sleep(3)
