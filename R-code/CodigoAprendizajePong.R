library('png');library('glmnet')
#source("http://bioconductor.org/biocLite.R")
#biocLite("EBImage")
#library('EBImage')
library('glmnet')
library('nnet')
library('ggplot2')
library(Rserve)
Rserve(args='--no-save')
#extraer todos los archivos PNG del directorio
files <- list.files("Train\ 8", pattern="*.png", full.names=TRUE)

  #prueba de tiempos
files
time.l <- system.time(ldf <- lapply(files, readPNG))
img1 <- t(as.matrix(readPNG("InstantPreds/juego-04.png")[1:40000]))

#función para sacar los pixeles de la lista
#solo considera un canal (RGB) en pngs de 200x200
pixels <- function(FilesList){
  r <- unlist(FilesList)
  tr <- matrix(r,ncol = (200*200),byrow=T)
  dim1 <- dim(tr)[1]
  cols <- c(1:dim1)
  aux <- (cols %% 3)==1
  PixelsMatrix <- tr
  print(dim(PixelsMatrix))
  return(PixelsMatrix)
}

PixelsMatrix <- pixels(ldf)

movement <- read.csv("Train\ 8//movement.csv")

y <- movement[1:dim(movement)[1]-1,2]
y <- scale(movement[1:dim(movement)[1]-1,2])
mean <- mean(movement[1:dim(movement)[1],2])
sd <- sd(movement[1:dim(movement)[1],2])


cv.model1 <- cv.glmnet(PixelsMatrix,y,alpha=1,family="gaussian")
plot(cv.model1)
lambda.min <- cv.model1$lambda.1se

saveRDS(cv.model1, "~/Desktop/Tesis/Datos/Pong Train/cv.model1.rds")
cv.model1
summary(cv.model1)



#new data
filesTest <- list.files("InstantPreds", pattern="*.png", full.names=TRUE)
filesTest
fillistFilesTest <- lapply(filesTest, readPNG)
PixelMatrixTest <- pixels(listFilesTest)

preds <- predict(cv.model1, newx = PixelMatrixTest,s=lambda.min)
preds <- (preds*sd) + mean
preds <- data.frame(preds)
names(preds)<-c("p")
summary(preds)
export <- data.frame(preds)
names(export) <- "predMoves"
write.csv(export, file = "PredictionsMovesRegression.csv")
comparisson <- cbind(preds,movement[1:dim(movement)[1]-1,2])
comparisson <- data.frame(comparisson)
names(comparisson)<- c("predicted","observation")
ggplot(comparisson,aes(x=observation,y=predicted))+geom_point()+geom_abline(intercept=0,slope=1,aes(color='red'),size=1)


#red neuronal

dim(PixelsMatrix)
Data <- data.frame(PixelsMatrix,y)
tail(names(Data))
n <- names(Data)
Nn <- length(names(Data))
f1 <- as.formula(paste("y ~", paste(n[1:(Nn)], collapse = " + ")))
f2<- as.formula(paste(n[((Nn/2)+1) : Nn], collapse ="+"))
neural.net <- neuralnet( X40001~., data=data.nn, hidden = 2)
preds <- predict.nnet(neural.net, newdata= PixelMatrixTest)


"InstantPreds/juego-100.png"
filesTest[11:20]
filesTest[173:182]<-filesTest[11:20]
filesTest<-filesTest[-(11:20)]
filesTest

filesTest[12:21]
filesTest[182:191]<-filesTest[11:20]
filesTest<-filesTest[-(12:21)]
filesTest



nx <- t(as.matrix(readPNG('juego-124.png')[1:40000]))
head(nx)
class(nx)
dim(nx)
(predict(cv.model1, newx = nx, s = lambda.min,type='response'))*sd + mean
