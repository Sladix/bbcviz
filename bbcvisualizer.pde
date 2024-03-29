/**
* TDL:
* Add some beat based multipliers for effects
*/
import ddf.minim.*;
import ddf.minim.analysis.*;

import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*; 

import com.hamoid.*;

VideoExport videoExport;
PostFX fx;
Minim minim;
AudioPlayer song;
FFT fft;

float BPM = 150.;
int songOffset = 160;
float beat = 0;
int temp = 0;

String SEP = "|";
float movieFPS = 30;
float frameDuration = 1 / movieFPS;
BufferedReader reader;

float DROP_OFF = 0.01;
float currentLow = 0;
float currentMid = 0;
float currentHi = 0;
float[] maxs;

// Variables qui définissent les "zones" du spectre
// Par exemple, pour les basses, on prend seulement les premières 4% du spectre total
float scoreLow = 0;
float scoreMid = 0;
float scoreHi = 0;
float scoreGlobal = 0;

// BG
int numLines = 60;
Background bg;

// Images
PImage pureel, pureer, truffl, truffr, title;
PImage bill;
//PVector[] facesPos = ;

//BPM related config
float interval = 60000/BPM;



//Partycles
ParticleSystem ps;
float coolDownBurst = 1;
float currentCDBurst = 0;

int[] globalBands = {8, 8, 11, 11, 22, 22};

void setup()
{
  //Charger la librairie minim
  minim = new Minim(this);
 
  //Charger la chanson
  String audioFilePath = "cash.mp3";
  song = minim.loadFile(audioFilePath);
  /*
  audioToTextFile(audioFilePath, globalBands);
  exit();
  */
  // Now open the text file we just created for reading
  reader = createReader(audioFilePath + ".txt");
  
  //Faire afficher en 2D sur tout l'écran
  //fullScreen(P2D);
  size(1920, 1080, P2D);
  //size(854, 480, P2D);
  imageMode(CENTER);
  smooth(10);
  frameRate(1000);
  fx = new PostFX(this);  
  fx.preload(RGBSplitPass.class);
  
  videoExport = new VideoExport(this);
  videoExport.setFrameRate(movieFPS);
  videoExport.setQuality(100, 128);
  videoExport.setAudioFileName("cash.mp3");
  bill = loadImage("dollarbill.jpg");
  pureel = loadImage("pureel.png");
  pureer = loadImage("pureer.png");
  truffl = loadImage("truffl.png");
  truffr = loadImage("truffr.png");
  title = loadImage("title_old.png");
  
  //Particle systems
  ps = new ParticleSystem(new PVector(width/2, height/2), bill);
  
  // Bg
  bg = new Background(numLines);
  
  //Créer l'objet FFT pour analyser la chanson
  //fft = new FFT(song.bufferSize(), song.sampleRate());
  
  // On essaye de récup le l'amplitude max
  
  //Fond noir
  background(0);
  
  //Commencer la chanson
  //song.play(0);
  videoExport.startMovie();
  
  maxs = new float[globalBands.length/2];
  String line;
  try {
    line = reader.readLine();
  }
  catch (IOException e) {
    e.printStackTrace();
    line = null;
  }
  String[] p = split(line, SEP);
  for(int ii = 0; ii < p.length; ii++){
    println(p[ii]);
    maxs[ii] = float(p[ii]);
  }
 
}

float Easing(float x, float t,float b,float c,float d) {
  return b+c*x;
}

void drawSpectrum(String[] p)
{
    int tlim = (p.length-1)/2;
    //image(rectImg, width/2, height/2, scoreMid, scoreMid);
    float w = width/(maxs.length);
    rect(0*w, height, w, - map(currentLow, 0, 1, 0, height));
    rect(1*w, height, w, - map(currentMid, 0, 1, 0, height));
    rect(2*w, height, w, - map(currentHi, 0, 1, 0, height));
    
    textSize(10);
    w = width/tlim;
    for(int i = 0; i < tlim; i++){
      pushMatrix();
      stroke(255);
      fill(color(scoreMid * 255,20,20));
      rect(i*w, height, w, - 30 - (float(p[1+i*2]) + float(p[2+i*2])));
      fill(255);
      text(i, i*w + w/2 - 5, height - 20);
      popMatrix();
    }
}

void drawDebug(){
  pushMatrix();
  StringBuilder indicator = new StringBuilder();
  indicator.append(String.format("%.2f", videoExport.getCurrentTime()));
  indicator.append("/");
  indicator.append(song.length()/1000);
  fill(255);
  textMode(CENTER);
  text(indicator.toString(), 10,20);
  indicator.setLength(0);
  indicator.append(temp);
  indicator.append("|");
  indicator.append(beat);
  text(indicator.toString(), 10,50);
  popMatrix();
}

void draw()
{
    String line;
  try {
    line = reader.readLine();
  }
  catch (IOException e) {
    e.printStackTrace();
    line = null;
  }
  if (line == null) {
    // Done reading the file.
    // Close the video file.
    videoExport.endMovie();
    exit();
  } else {
    String[] p = split(line, SEP);
    // The first column indicates 
    // the sound time in seconds.
    //println("draw");
    
    float soundTime = float(p[0]);
    scoreLow = (float(p[globalBands[0]*2+1]) + float(p[globalBands[0]*2+2])) / maxs[0];
    scoreMid = (float(p[globalBands[2]*2+1]) + float(p[globalBands[2]*2+2])) / maxs[1];
    scoreHi = (float(p[globalBands[4]*2+1]) + float(p[globalBands[4]*2+2])) / maxs[2];
    scoreGlobal = (scoreLow + scoreMid + scoreHi) / 3;
    
    while (videoExport.getCurrentTime() < soundTime + frameDuration) {
      float vt = videoExport.getCurrentTime() * 1000.;
      int et = int(vt) - songOffset;
      boolean onBeat = vt > songOffset && et % interval <= 10;
      
      if (onBeat) {
        // On compte les temps  
        temp = int(beat % 4 + 1);
        if(temp == 1 || temp == 3){
            ps.changeOffsets();
        }
        if (temp == 3/* && beat >= 78*/) {
          if(scoreHi > 0.4){
            ps.popParticles();
          }
        }
        beat++;
      }
      
      currentLow = (scoreLow > currentLow) ? scoreLow : currentLow-DROP_OFF;
      currentMid = (scoreMid > currentMid) ? scoreMid : currentMid-DROP_OFF;
      currentHi = (scoreHi > currentHi) ? scoreHi : currentHi-DROP_OFF;
      
      
      /*** BEGIN DRAW ***/
      background(0);
      noStroke();
      
      // Particles run
      ps.run();
      // Background run and draw
      bg.run(ps.particles);
      
      noTint();
      // MIDDLE
      pushMatrix();
      float ratioPuree = float(pureel.height)/(float(pureel.width)*1.3);
      float s = max(pow(currentLow,2)*(height/2), 70);
      float ox = width/6;
      float oy = height/2;
      PVector v = new PVector(ox, oy);
      image(pureel, v.x, v.y, s/ratioPuree, s);
      image(pureer,(v.x)*5, v.y, s/ratioPuree, s);
      popMatrix();
      
      // BOTTOM
      pushMatrix();
      float ratioTruff = float(truffl.height)/float(truffl.width);
      float faceSize =  height/5;
      //tint(255, int(map(currentHi, 0, 1, 0, 255)));
      float rampUp = 1.5;
      float ty = map(pow(constrain(currentLow*rampUp, 0 ,1),2), 0, 1, height+faceSize/2, height-faceSize/2);
      image(truffr, width-(faceSize/2)*2, ty, faceSize/ratioTruff, faceSize);
      image(truffl, (faceSize/2)*2, ty, faceSize/ratioTruff, faceSize);
      popMatrix();
      
      // TITLE
      pushMatrix();
      fill(0);
      noStroke();
      rectMode(CENTER);
      translate(width/2, height/2);
      rect(0, 0, title.width+70, title.height+70);
      popMatrix();
      
      ps.display();
      
      // Titre
      pushMatrix();
      translate(width/2, height/2);
      scale(1+pow(currentMid,4)*0.5, 1+pow(currentMid,4)*0.5);
      noTint();
      image(title, 0, 0);
      popMatrix();
      
      imageMode(CORNER);
      fx.render()
        .rgbSplit(currentHi*190)
        .compose();
      imageMode(CENTER);
      
      /** DEBUG **/
      /*
      drawDebug(p);
      */
      /** END DEBUG **/
      
      
      /*** END DRAW ***/

      videoExport.saveFrame();
    }
  }
}

void audioToTextFile(String fileName, int[] bands) {
  PrintWriter output;

  Minim minim = new Minim(this);
  output = createWriter(dataPath(fileName + ".txt"));

  AudioSample track = minim.loadSample(fileName, 2048);

  int fftSize = track.bufferSize();
  float sampleRate = track.sampleRate();

  float[] fftSamplesL = new float[fftSize];
  float[] fftSamplesR = new float[fftSize];

  float[] samplesL = track.getChannel(AudioSample.LEFT);
  float[] samplesR = track.getChannel(AudioSample.RIGHT);  

  FFT fftL = new FFT(fftSize, sampleRate);
  FFT fftR = new FFT(fftSize, sampleRate);

  fftL.logAverages(11, 3);
  fftR.logAverages(11, 3);

  int totalChunks = (samplesL.length / fftSize) + 1;
  int fftSlices = fftL.avgSize();
  
  float[] maxs = new float[bands.length/2];
  StringBuilder msg = new StringBuilder();
  for (int ci = 0; ci < totalChunks; ++ci) {
    int chunkStartIndex = ci * fftSize;   
    int chunkSize = min( samplesL.length - chunkStartIndex, fftSize );

    System.arraycopy( samplesL, chunkStartIndex, fftSamplesL, 0, chunkSize);      
    System.arraycopy( samplesR, chunkStartIndex, fftSamplesR, 0, chunkSize);      
    if ( chunkSize < fftSize ) {
      java.util.Arrays.fill( fftSamplesL, chunkSize, fftSamplesL.length - 1, 0.0 );
      java.util.Arrays.fill( fftSamplesR, chunkSize, fftSamplesR.length - 1, 0.0 );
    }

    fftL.forward( fftSamplesL );
    fftR.forward( fftSamplesR );

    // The format of the saved txt file.
    // The file contains many rows. Each row looks like this:
    // T|L|R|L|R|L|R|... etc
    // where T is the time in seconds
    // Then we alternate left and right channel FFT values
    // The first L and R values in each row are low frequencies (bass)
    // and they go towards high frequency as we advance towards
    // the end of the line.
    msg.append(nf(chunkStartIndex/sampleRate, 0, 3).replace(',', '.'));
    for (int i=0; i<fftSlices; ++i) {
      for (int j = 0; j < maxs.length; j++) {
        float sum = fftL.getAvg(i) + fftR.getAvg(i);
        if(i >= bands[j*2] && i/2 <= bands[j*2+1] && sum > maxs[j]) {
          maxs[j] = sum;
        }
      }
      
      msg.append(SEP + nf(fftL.getAvg(i), 0, 4).replace(',', '.'));
      msg.append(SEP + nf(fftR.getAvg(i), 0, 4).replace(',', '.'));
    }
    msg.append(System.getProperty("line.separator"));
  }
  StringBuilder max = new StringBuilder();
  for(int aa = 0; aa < maxs.length; aa++) {
    max.append(nf(maxs[aa], 0, 4).replace(',', '.')+SEP);
  }
  max.deleteCharAt(max.length()-1);
  msg.setLength(msg.length() - 4);
  output.println(max.toString());
  output.println(msg.toString());
  track.close();
  output.flush();
  output.close();
  println("Sound analysis done");
}
