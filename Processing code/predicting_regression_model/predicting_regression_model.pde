import java.util.*;
import org.rosuda.REngine.*;
import org.rosuda.REngine.Rserve.*;
import java.io.*;

boolean gameStart = false;

RConnection c;
int i;
int ind;
double m;
double s;
double predp;
double pred;
float predf;
int numero;
float ww ;
float x = 150;
float y = 150;
float speedX = random(3, 5);
float speedY = random(3, 5);
int leftColor = 128;
int rightColor = 128;
int diam;
float rectSize = 150;
float diamHit;
FloatList positions;
double data;
Table table;

 
void setup() {
  i=0;
  size(500, 500);
  ww = float(width);
  noStroke();
  smooth();
  ellipseMode(CENTER); 
  try {
    c = new RConnection();
    c.eval("library('png');library('glmnet');setwd('~/Desktop/Tesis/Datos/PongTest/InstantPreds')");
    c.eval("movement <- read.csv('~/Desktop/Tesis/Datos/Pong Train/Train 8/movement.csv')");
    c.eval("mean <- mean(movement[1:dim(movement)[1],2])");
    c.eval("sd <- sd(movement[1:dim(movement)[1],2])");
    c.eval("cv.model1 <- readRDS('~/Desktop/Tesis/Datos/Pong Train/cv.model1.rds')");
    c.eval("lambda.min <- cv.model1$lambda.1se");
    
    

    
  } 
  catch ( REngineException e ) {
    e.printStackTrace();
  }
  positions = new FloatList();
  
  table = new Table();
  
  table.addColumn("frame");
  table.addColumn("movement");
}
 
void draw() {
    
  background(255);
 
  fill(128,128,128);
  diam = 20;
  ellipse(x, y, diam, diam);
 
  fill(leftColor);
  rect(0, 0, 20, height);
  fill(rightColor);
  
  if(!gameStart){
  rect(ww-30, 250-rectSize/2, 10, rectSize);
  }

  if (gameStart) {
    
    x = x + speedX;
    y = y + speedY;
    
    if (frameCount == 1) {} 
    else {
      if(frameCount <10) { 
      try {
      ind = frameCount -1;
      c.eval("nx <- t(as.matrix(readPNG('juego-0"+ind+".png')[1:40000]))");
      pred = c.eval("(predict(cv.model1, newx = nx, s = lambda.min,type='response'))*sd + mean").asDouble();
      predf = (float) pred;
      }catch ( REXPMismatchException rme ) {
        rme.printStackTrace();
      } catch ( REngineException e ) {
        e.printStackTrace();
      }
    } else{
    try {
      ind = frameCount -1;
      c.eval("nx <- t(as.matrix(readPNG('juego-"+ind+".png')[1:40000]))");
      pred = c.eval("(predict(cv.model1, newx = nx, s = lambda.min,type='response'))*sd + mean ").asDouble();
      predf = (float) pred;
      m = c.eval("mean <- mean(movement[1:dim(movement)[1],2])").asDouble();
      s = c.eval("sd <- sd(movement[1:dim(movement)[1],2])").asDouble();
      }catch ( REXPMismatchException rme ) {
        rme.printStackTrace();
      } catch ( REngineException e ) {
        e.printStackTrace();
      }
    }
   }
    
    
    //System.out.println(data);
    //System.out.println(pred);
   rect(ww-30, predf-rectSize/2, 10, rectSize);
   
    // if ball hits movable bar, invert X direction and apply effects
    if ( x > width-30 && x < width -20 && y > predf-rectSize/2 && y < predf+rectSize/2 ) {
      speedX = speedX * -1;
      x = x + speedX;
      rightColor = 0;
      fill(random(0,128),random(0,128),random(0,128));
      diamHit = random(75,150);
      ellipse(x,y,diamHit,diamHit);
      //rectSize = rectSize-10;
      rectSize = constrain(rectSize, 10,150);     
    }
 
    // if ball hits wall, change direction of X
    else if (x < 25) {
      speedX = speedX * -1.1;
      x = x + speedX;
      leftColor = 0;
    }
 
    else {    
      leftColor = 128;
      rightColor = 128;
    }
    // resets things if you lose
    if (x > width) {
      gameStart = false;
      x = 150;
      y = 150;
      speedX = random(3, 5);
      speedY = random(3, 5);
      rectSize = 150;
    }
    // código Diego

        

    // if ball hits up or down, change direction of Y  
    if ( y > height || y < 0 ) {
      speedY = speedY * -1;
      y = y + speedY;
    }
  }
    
  //if (!gameStart) {
  //}
  saveFrame("/Users/DiegoAgher/Desktop/Tesis/Datos/PongTest/InstantPreds/juego-##.png");
  //saveFrame("animacion-##.png");
  
  if (frameCount <10){
  System.out.println("juego-0"+frameCount+".png");
  String[] env = {"PATH=/Users/DiegoAgher/Library/Enthought/Canopy_64bit/User/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/opt/ImageMagick/bin:/usr/texbin"};
  String cmd = "/opt/ImageMagick/bin/convert /Users/DiegoAgher/Desktop/Tesis/Datos/PongTest/InstantPreds/juego-0"+frameCount+".png -resize 200x200! /Users/DiegoAgher/Desktop/Tesis/Datos/PongTest/InstantPreds/juego-0"+frameCount+".png";  //e.g test.sh -dparam1 -oout.txt
  try {
         Process process = Runtime.getRuntime().exec(cmd, env);
     } catch ( Exception exce ) {
        exce.printStackTrace();
      }
  } else {
      System.out.println("juego-"+frameCount+".png");
      String[] env = {"PATH=/Users/DiegoAgher/Library/Enthought/Canopy_64bit/User/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/opt/ImageMagick/bin:/usr/texbin"};
      String cmd = "/opt/ImageMagick/bin/convert /Users/DiegoAgher/Desktop/Tesis/Datos/PongTest/InstantPreds/juego-"+frameCount+".png -resize 200x200! /Users/DiegoAgher/Desktop/Tesis/Datos/PongTest/InstantPreds/juego-"+frameCount+".png";  //e.g test.sh -dparam1 -oout.txt
      try {
         Process process = Runtime.getRuntime().exec(cmd, env);
     } catch ( Exception exce ) {
        exce.printStackTrace();
      }
  }  

  System.out.println(pred);
  System.out.println(predf);
  System.out.println(m);
  System.out.println(s);
  
  TableRow newRow = table.addRow();
    newRow.setInt("frame", frameCount);
    newRow.setFloat("movement", mouseY);
    
  if (!gameStart) {
    saveTable(table, "data/movement.csv");
  }
  
}
void mousePressed() {
  gameStart = !gameStart;
}
