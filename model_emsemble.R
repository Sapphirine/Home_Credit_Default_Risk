
library(data.table)
library(pROC)


#Load Base Datasets
train <- read.csv( '~/Desktop/2019 Spring/Advanced Big Data Analysis/my project/home-credit-default-risk-milestone3/data/application_train.csv' )
test  <- read.csv( '~/Desktop/2019 Spring/Advanced Big Data Analysis/my project/home-credit-default-risk-milestone3/data/application_test.csv' )
table(train$TARGET)
dim(train)
dim(test)


# Logistic Regression
tmp1 <- fread('~/Desktop/2019 Spring/Advanced Big Data Analysis/my project/home-credit-default-risk-milestone3/log_reg_baseline_train-2.csv')
tmp2 <- fread('~/Desktop/2019 Spring/Advanced Big Data Analysis/my project/home-credit-default-risk-milestone3/logreg_baseline.csv')
model1 <- rbind( tmp1, tmp2  )


# Random Forest
tmp1 <- fread('~/Desktop/2019 Spring/Advanced Big Data Analysis/my project/home-credit-default-risk-milestone3/random_forest_baseline_train.csv')
tmp2 <- fread('~/Desktop/2019 Spring/Advanced Big Data Analysis/my project/home-credit-default-risk-milestone3/rf_baseline.csv')
model2 <- rbind( tmp1, tmp2  )


# Light GBM
tmp1 <- fread('~/Desktop/2019 Spring/Advanced Big Data Analysis/my project/home-credit-default-risk-milestone3/ooflight_GBM.csv')
tmp2 <- fread('~/Desktop/2019 Spring/Advanced Big Data Analysis/my project/home-credit-default-risk-milestone3/submissionlight_GBM.csv')
tmp3 <- tmp1[,c(1,2)]
colnames(tmp3) <- c("SK_ID_CURR","TARGET")
model3 <- rbind(tmp3, tmp2)



#Merge all models by SK_ID_CURR
raw <- data.table( SK_ID_CURR=c(train$SK_ID_CURR, test$SK_ID_CURR)  )
raw <- merge(raw, model1, by="SK_ID_CURR", sort=F )
raw <- merge(raw, model2, by="SK_ID_CURR", sort=F )
raw <- merge(raw, model3, by="SK_ID_CURR", sort=F )



#Split Train and Test
tr <- data.table( SK_ID_CURR=train$SK_ID_CURR )
tr <- raw[ raw$SK_ID_CURR %in% train$SK_ID_CURR  ]
ts <- raw[ raw$SK_ID_CURR %in% test$SK_ID_CURR  ]
target <- train[ train$SK_ID_CURR %in% raw$SK_ID_CURR,'TARGET'  ]
tr[, SK_ID_CURR:=NULL ]
ts[, SK_ID_CURR:=NULL ]



#turn Matrix
tr <- as.matrix(tr)
ts <- as.matrix(ts)

#Optim transform function
fn.optim.sub <- function( mat, pars ){
  as.numeric( rowSums( mat * matrix( pars, nrow=nrow(mat) , ncol=ncol(mat), byrow=T ) ) )
}


#Optim evaluation maximization function
fn.optim <- function( pars ){
  auc( target , fn.optim.sub( tr , pars ) )
}



#Bag optim 3 times using random initial Weigths
set.seed(2)
initial_w <- rep(1/ncol(tr),ncol(tr) ) + runif( ncol(tr) ,-0.005,0.005 )
opt1 <- optim( par=initial_w , fn.optim ,control = list(maxit=3333, trace=T, fnscale = -1)   )

set.seed(3)
initial_w <- c(1/6,1/6,2/3) + runif( ncol(tr) ,-0.005,0.005 )
opt2 <- optim( par=initial_w , fn.optim, control = list(maxit=3333, trace=T, fnscale = -1)   )

set.seed(1234)
initial_w <- c(1/4,1/4,1/2) + runif( ncol(tr) ,-0.005,0.005 )
opt3 <- optim( par=initial_w , fn.optim, control = list(maxit=3333, trace=T, fnscale = -1)   )



#Show AUC
auc( target , fn.optim.sub( tr , opt1$par ) )
print( data.frame( colnames(tr) , opt1$par ) )

auc( target , fn.optim.sub( tr , opt2$par ) )
print( data.frame( colnames(tr) , opt2$par ) )

auc( target , fn.optim.sub( tr , opt3$par ) )
print( data.frame( colnames(tr) , opt3$par ) )

tmp <-       rank( fn.optim.sub( tr, opt1$par ) )
tmp <- tmp + rank( fn.optim.sub( tr, opt2$par ) )
tmp <- tmp + rank( fn.optim.sub( tr, opt3$par ) )
print( auc( target , tmp ) )




#Calcule predictions of TestSet
tmp <-       rank( fn.optim.sub( ts, opt1$par ) )
tmp <- tmp + rank( fn.optim.sub( ts, opt2$par ) )
tmp <- tmp + rank( fn.optim.sub( ts, opt3$par ) )




#Build Submission File
sub  <- data.frame( SK_ID_CURR=test$SK_ID_CURR, TARGET = tmp/max(tmp) )
hist(sub$TARGET,1000)
summary( sub$TARGET  )
write.table( sub, '~/Desktop/2019 Spring/Advanced Big Data Analysis/my project/home-credit-default-risk-milestone3//final_submission.csv', row.names=F, quote=F, sep=','  )