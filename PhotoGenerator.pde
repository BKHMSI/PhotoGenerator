import controlP5.*;

/* @pjs preload="main_menu.png"; */

ControlP5 cp5;
PImage[] images, collage;
color[] avgColors;
PImage photo;
PImage main_menu;
int numOfImages = 100;
int imgRatio = 50;
boolean flag = true, flag2 = false;
int x = 0, y = 0;
PFont font;
boolean mainMenu = false;
int photoIndex = -1;
boolean change = false;
Button[]buttons;
int btnSz = 1;


void setup() {
  size(800, 550);
  smooth();
  font = createFont("arial", 20);
  images = new PImage[numOfImages];
  avgColors = new color[numOfImages];
  collage = new PImage[imgRatio*imgRatio];
  buttons = new Button[btnSz];
  createButtons();
  main_menu = loadImage("main_menu.png");
}

void draw() {
  if (!mainMenu) {
    image(main_menu, 0, 0);
    mainMenu = true;
  }
  if (!flag2) {
    if (overButton(98, 200, 180, 40)) {
      if (mousePressed) {
        selectFolder("Select a folder to process:", "folderSelected");
        mousePressed = false;
      }
    } else if (overButton(98, 260, 214, 40)) {
      if (mousePressed) {
        println("Process Images");
        mousePressed = false;
      }
    } else if (overButton(98, 315, 180, 40)) {
      if (mousePressed) {
        println("Select Image");
        mousePressed = false;
      }
    } else if (overButton(98, 365, 180, 40)) {
      if (mousePressed) {
        saveFrame();
        println("Save Image");
        mousePressed = false;
      }
    }
  }

  if (photoIndex!=-1 && photoIndex<=numOfImages) {
    if (!change) {
      flag2 = true;
      flag = false; 
      x = 800;
      y = 550;
      for (int i = 0; i<numOfImages; i++) {
        images[i].resize(x, y);
      }
      println("Hello");
      photo = images[photoIndex];
      frame.setSize(x, y);
      image(photo, 0, 0);
      createCollage();
      change = true;
    }
  }

  if (!flag) {
    int sizeX = x/imgRatio, sizeY = y/imgRatio;
    int pSizeX = 0, pSizeY = 0;
    for (int i = 0; i<imgRatio; i++) {
      for (int j = 0; j<imgRatio; j++) {
        image(collage[i*imgRatio+j], pSizeX, pSizeY);
        pSizeX+=sizeX;
      }
      pSizeY+=sizeY;
      pSizeX = 0;
    }
    if (keyPressed) {
      if (key == 's' || key == 'S') {
        saveFrame();
        displayImageSaved();
        keyPressed = false;
      }
    }
  }
}


void createButtons(){
  String[] title = {
    "Select Folder"
  };
  for (int i = 0; i<btnSz; i++) {
    buttons[i] = new Button(98,200,180,40,title[i]);
  }
}

void mousePressed() {
  // button 1: 98,200,180,40
  // button 2: 98,260,214,40
  // button 3: 98,315,180,40
  // button 4: 88,365,180,40
  
  for(int i = 0; i<btnSz; i++){
    if(buttons[i].overRect()){
      switch(i){
        case 0:
        break;
        default:
        break;
      }
    }
  }
  if (!change) {
    int k = 0;
    for (int i = 0; i<550; i+=50) {
      for (int j = 0; j<400; j+=50) {
        if (overButton(j+400, i, 50, 50)) {
          photoIndex = k;
          println("Image Selected: "+k);
        }
        k++;
      }
    }
  }
}

void displayImageSaved() {
  println("Image Saved!!");
}

boolean overCircle(int x, int y, int diameter) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  } else {
    return false;
  }
}

boolean overButton(int x, int y, int sizeX, int sizeY) {
  if (mouseX>=x && mouseX<=x+sizeX) {
    if (mouseY>=y && mouseY<=y+sizeY) {
      cursor(HAND);
      return true;
    }
  }
  cursor(ARROW);
  return false;
}

void processImages(String path) {
  // Load Images and Get their Average Colors
  File dir = new File(path);
  String[] children = dir.list();
  if (children == null) {
    // Either dir does not exist or is not a directory
  } else {
    for (int i=0; i<children.length-1; i++) {
      // Get filename of file or directory
      String filename = children[i+1];
      println(children[i+1]);
      images[i] = loadImage(path+"/"+filename);
      avgColors[i] = getAvgColor(images[i], images[i].width*images[i].height);
    }
  numOfImages = children.length-1;    
  } 
  displayImages();
  //println("Size of Small Image: "+photo.width/imgRatio+" , "+ photo.height/imgRatio);
}

void displayImages() {
  int k = 0;
  println("displayImages");
  for (int i = 0; i<550; i+=50) {
    for (int j = 0; j<400; j+=50) {
      if (k>=numOfImages) {
        fill(0);
        rect(j+400, i, 50, 50);
      } else {
        images[k].resize(50, 50);
        image(images[k], j+400, i);
      }
      k++;
    }
  }
}

color getAvgColor(PImage img, float size) {
  int r = 0, g = 0, b = 0;
  img.loadPixels();
  for (int i = 0; i<size; i++) {
    color c = img.pixels[i];
    r+=red(c);
    g+=green(c);
    b+=blue(c);
  }
  r/=size;
  g/=size;
  b/=size;
  //println("R: "+r+" | G: "+g+" | B: "+b);
  return color(r, g, b);
}

int searchColor(color c) {
  int range = 0;
  while (range<100) {
    for (int i = 0; i<numOfImages; i++) {
      float red = red(avgColors[i]), green = green(avgColors[i]), blue = blue(avgColors[i]);
      if (red-range<=red(c) && red+range>=red(c)) {
        if (green-range<=green(c) && green+range>=green(c)) {
          if (blue-range<=blue(c) && blue+range>=blue(c)) {
            return i;
          }
        }
      }
    }
    range++;
  }
  return -1;
}

void createCollage() {
  int sizeX = x/imgRatio, sizeY = y/imgRatio;
  println("X: "+x+" | Y: "+y);
  int pSizeX = 0, pSizeY = 0;

  for (int i = 0; i<imgRatio; i++) {
    for (int j = 0; j<imgRatio; j++) {
      color c = getAvgColor(get(pSizeX, pSizeY, sizeX, sizeY), sizeX*sizeY);
      int index = searchColor(c);
      if (index!=-1) {
        collage[i*imgRatio+j] = images[index];
      } else {
        collage[i*imgRatio+j] = images[23];
      }
      //(16,12) => images[index].width/imgRatio, images[index].height/imgRatio
      collage[i*imgRatio+j].resize(x/imgRatio, y/imgRatio);
      pSizeX+=sizeX;
    }
    pSizeX = 0;
    pSizeY+=sizeY;
  }
}

void displayMenu() {
  background(255);
  noStroke();
  fill(100, 100, 100);
  ellipse(width/2-100, height/2-100, 100, 100);
  fill(255);
  textSize(30);   
  textAlign(CENTER);
  text("RUN", width/2-100, height/2-100+10);
}

void folderSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    processImages(selection.getAbsolutePath());
  }
}

void createTextField() {
  cp5 = new ControlP5(this);  
  cp5.addTextfield("input")
    .setPosition(width/2, height/2+100)
      .setSize(200, 40)
        .setFont(font)
          .setFocus(true)
            .setColor(color(255, 0, 0));
}


class Button{
  float x, y, w, h;
  color c;
  String txt;
  Button(float _x, float _y, float _w, float _h, String s){
    x = _x; y = _y; w = _w; h = _h; txt = s;
    c = color(random(200), random(200), random(200));
  }
  
  void display(){
    if(overRect()){
      fill(c,180);
    }else{
      fill(c);
    }
    rect(x,y,w,h);
    fill(255);
    textAlign(CENTER);
    text(txt,x+w/2,y+4+h/2);
  }
  
  boolean overRect(){
    if(mouseX>=x && mouseX<=x+w && mouseY>=y && mouseY<=y+h)  return true;
    else return false;
  }
}
