import controlP5.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import java.lang.System;
import java.util.Properties;
import java.util.concurrent.TimeUnit;
import java.io.*;
import java.io.File;
import javax.swing.JFileChooser;
import javax.swing.filechooser.FileNameExtensionFilter;
import java.lang.management.ManagementFactory;

AudioMetaData metaData;
Minim minim;
AudioPlayer player;
FFT fft;
ControlP5 cp5;

ArrayList filePaths;
DataList list;

int background = color(1);
int textColor = color(255);
int nowPlaying;
boolean fileLoaded = false;
boolean isPlaying = false;
boolean isRepeat = false;
boolean isVisualizer = true;
boolean isFileLoaded = false;
String title = "HIT603 Media Player";
float sliderValue = 0;
Button play,repeat,visualizer;
Slider slider,volumeSlider;
PImage bckgrd;

int progressBarAlpha = 150; // bar
int soundVisionAlpha = 50;  // visual;

void setup(){
  frameRate(30);
  size(500,300);
  bckgrd = loadImage("background.png");
  filePaths = new ArrayList();
  minim = new Minim(this);
    
  cp5 = new ControlP5(this);    
    cp5.addButton("add")
       .setPosition(462,225)
       .setImage(loadImage("add.png"))
       .updateSize();    
    cp5.addButton("prev")
       .setPosition(0,230)
       .setImage(loadImage("prev.png"))
       .updateSize();       
    play = cp5.addButton("play")
              .setPosition(60,230)
              .setImage(loadImage("play.png"))
              .updateSize();       
    cp5.addButton("next")
       .setPosition(120,230)
       .setImage(loadImage("next.png"))
       .updateSize(); 
    cp5.addButton("stop")
       .setPosition(180,230)
       .setImage(loadImage("stop.png"))
       .updateSize(); 
    visualizer = cp5.addButton("visualizer")
       .setPosition(460,270)
       .setImage(loadImage("visualizer.png"))
       .updateSize(); 
    repeat = cp5.addButton("repeat")
       .setPosition(300,230)
       .setImage(loadImage("repeat.png"))
       .updateSize(); 
    slider = cp5.addSlider("slider")
     .setPosition(0,220)
     .setSize(500,7)
     .setRange(0,200)
     .setValue(0)
     .setUpdate(true);
     
    slider.getValueLabel().setVisible(false);
     
    volumeSlider = cp5.addSlider("volume")
     .setPosition(340,240)
     .setSize(80,7)
     .setRange(0,100)
     .setValue(100)
     .setUpdate(true);
  
    list = new DataList(0, 0, width, height-80) {
      public void selected(int id) {
        println("Lets play: "+id);
        println("List at id contains: "+list.getPath(id));
        player.close();
        player = minim.loadFile(list.getPath(id));
        nowPlaying=id;
        slider.setRange(0,player.length()).setValue(0);
        player.play();
        isPlaying=true;
       //nothing for now
      }
    };
}
void draw(){
    background(background);
    fill(textColor);
    textSize(21);    //Prints title out
    textAlign(CENTER);
    text(title, width/2, 18);
    list.display();
    
    if(isPlaying){
      if(isVisualizer){
        soundVision();
      }
      fill(1);
      textSize(14);
      textAlign(LEFT);
      text(player.position()/60000 + ":" + nf(player.position()%60000/1000,2) + "/" + player.length()/60000 + ":" + player.length()%60000/1000, 5, 210);
      text(player.getMetaData().title(),100,210);
      play.setImage(loadImage("pause.png"));
    } else{
      play.setImage(loadImage("play.png"));
    }
    if (isPlaying && frameCount % 30 == 0) {
     slider.setValue(player.position());
    }
    if(slider.isMouseOver()){
      slider.setSize(500,10);
    }else{slider.setSize(500,7);}
    if(volumeSlider.isMouseOver()){
      volumeSlider.setSize(80,10);
    }else{volumeSlider.setSize(80,7);}
    
    if(isFileLoaded && isPlaying && player.position()>=(player.length()-5000)){
      if(isRepeat){
        player.rewind();
        player.skip(0);
        player.play();
      } else{
        next(); 
      }
    }
      
}

void mousePressed() {
    list.update();
}

public void controlEvent(ControlEvent theEvent) {
  println(theEvent.getController().getName());
  
}

public void add(int theValue) {
  println("add: "+theValue);
  //if(!fileLoaded){
    selectInput("Select a file to process:", "fileSelected");
  //}
}

public void stop() {
  player.rewind();
  player.skip(0);
  slider.setValue(0);
  player.pause();
  isPlaying=false;
}

public void play() {
  if(isPlaying){
    player.pause();
    isPlaying=false;
  } else{
    player.play();
    isPlaying=true;
  }
}

public void prev(){
  player.rewind();
  if(nowPlaying!=0){
    player.close();
    player = minim.loadFile(list.getPath(--nowPlaying));
  }
  slider.setRange(0,player.length()).setValue(0);
  player.play();
  isPlaying=true;
}

public void next(){
  player.rewind();
  player.close();
  println(nowPlaying+":"+list.getItems().size());
  if(nowPlaying<(list.getItems().size()-1)){   
    player = minim.loadFile(list.getPath(++nowPlaying));
    player.play();
    isPlaying=true;
  } else{
    stop();
  }
  slider.setRange(0,player.length()).setValue(0);
}

public void slider(int val) {
  if(mousePressed &&  mouseY > 220 && mouseY < 227) {
  player.rewind();
  player.skip((int)val);
  player.play();
  }
}

void moveBar(){
  slider.setValue(player.position());
}

public void volumeSlider(int val){ 
  player.setGain(val-47);
}

public void repeat(){
  if(isRepeat){
    isRepeat=false;
    repeat.setImage(loadImage("repeat.png"));
  }else{
    isRepeat=true;
    repeat.setImage(loadImage("repeated.png"));
  }
}

public void visualizer() {
  if(isVisualizer){
    visualizer.setImage(loadImage("visualizerDisabled.png"));
    isVisualizer=false;
  } else{
    visualizer.setImage(loadImage("visualizer.png"));
    isVisualizer=true;
  }
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    String filePath = selection.getAbsolutePath();
    println("User selected " + filePath);
    // load file here    
    if(isFileLoaded){player.close();}
    isFileLoaded=true;
    player = minim.loadFile(filePath);
    player.setGain(0.5);
    println("Files:"+ filePaths);
    fft = new FFT( player.bufferSize(), player.sampleRate());
    metaData = player.getMetaData();
    String[] data = {
        metaData.title(), metaData.album(), metaData.author(), metaData.genre(), filePath
      };
    list.addItem(data);
    fileLoaded = true;
    title = metaData.title();
  }
}



//Data List
abstract class DataList {
  ArrayList<ListItem> items;
 
  PVector loc;
  PVector dim;
  DataList(float x, float y, float w, float h) {
    items = new ArrayList<ListItem>();   
    loc = new PVector(x, y);
    dim = new PVector(w, h);
  }
 
  void addItem(String[] data) {
    items.add(new ListItem(data, items.size()));
  }
 
  void update() {
    if(mousePressed && mouseX > loc.x && mouseX < loc.x + dim.x && mouseY > loc.y && mouseY < loc.y + dim.y) {
      int over = (int) (mouseY - (loc.y + 5)) / 20;
      if(over > -1 && over < items.size())
        selected(over);
    }
  }
 
  void display() {
    strokeWeight(1);
    stroke(0);
    fill(250,50);
    for (int i = 0; i<900; i+=200) {
      image(bckgrd, i, 20);              //Stamps background Image.
    }
    rect(loc.x, loc.y, dim.x, dim.y);
   
    textSize(12);
    textAlign(LEFT, TOP);
    noStroke();
   
    float down = 0;
    boolean dark = false;
    for(ListItem item : items) {
      if(dark)
        fill(204);
      else
        fill(250);
      rect(loc.x + 1, loc.y + 1 + down, dim.x - 1, 20 - 1);
     
      fill(0);
     
      float over = 0;
      for(String data : item.data) {
        if(textWidth(data + "...") > ((dim.x - 10) / item.data.length) - 5) {
          while(textWidth(data + "...") > ((dim.x - 10) / item.data.length) - 5) {
            data = data.substring(0, data.length() - 1);
          }
         
          data += "...";
        }
       
        text(data, loc.x + 5 + over, loc.y + 3 + down);
       
        over += (dim.x - 10) / item.data.length;
      }
     
      down += 20;
      dark = !dark;
    }
   
    //stroke(0);
    //line(loc.x, loc.y + down, loc.x + dim.x, loc.y + down);
   
    if(dark)
      fill(204,50);
    else
      fill(250,50);
   
    rect(loc.x + 1, loc.y + 1 + down, dim.x - 1, dim.y - (down + 1));
  }
  
  String getPath(int id){
    return items.get(id).getPath();
  }
  
  ArrayList getItems(){
    return items;
  }
 
  abstract void selected(int id);
}
class ListItem {
  int id;
  String[] data;
 
  ListItem(String[] data, int id) {
    this.id = id;
    this.data = data;
  }
  String getPath(){
    return data[4];
  }
}


/*

****************
Sound Visualizer
****************

*/


void soundVision() {
  fft.forward( player.mix );

  fill(#45ADA8, soundVisionAlpha);
  stroke(#3D3B38);
  strokeWeight(1);


  if (progressBarAlpha<200 && soundVisionAlpha<255) {
    soundVisionAlpha+=3;
  } else if (soundVisionAlpha>50) {
    soundVisionAlpha-=5;
  }

  for (int i = 0; i < fft.specSize (); i+=5) {

    // draw the line for frequency band i, scaling it up a bit so we can see it
    colorMode(HSB);
    //stroke(i, 255, 255);

    //line( i, height, i, height - fft.getBand(i)*8 );



    rect(i+width/2, height - fft.getBand(i)*8, 10, height);
    //ellipse(i+width/2,height + 10 - fft.getBand(i)*5, 10,10);
  }

  for (int i = 0; i < fft.specSize (); i+=5) {

    // draw the line for frequency band i, scaling it up a bit so we can see it
    colorMode(HSB);
    //stroke(i, 255, 255);

    // strokeWeight(10);
    // stroke(#45ADA8,50);
    //fill(#45ADA8,20);
    //line( i+width/2, height, i+width/2, height - fft.getBand(i)*8 );


    rect(i, height - fft.getBand(i)*8, 10, height);
    //ellipse(i,height + 10 - fft.getBand(i)*5, 10,10);
  }
}
void keyPressed() {
  //If the user presses n, play the next song
  if (key=='n') {
    next();
  } else if(key=='p'){
    prev();
  } else if(key=='s'){
    stop();
  } else if(key==' '){
    play();
  } else if(key=='v'){
    visualizer();
  }else if(key=='r'){
    repeat();
  }  
}