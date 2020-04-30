import java.util.Scanner; 

int cellSize = 10; 

int numPerLetter = 50; 
int numOfLetters = 10; 

Cell[][] grid; 

ArrayList<Integer[][]> trainingData; 

ArrayList<Training> distances; 


int xBound = 2;  
int yBound = 2; 

int trainingIndex;  




boolean generatingTests; 
int currLetter;  
int currTraining; 

void setup() {
  size(600,1000);
  textAlign(CENTER); 
  initialize(); 
  noStroke(); 
}


void draw() {
  if (generatingTests) {
    if(frameCount % 3 == 0) createTrainingData(); 
  } else {
    background(255);
    if (trainingData.size() == 0){
       trainingData = this.loadTraining();  
       println("Successfully loaded training data of " + trainingData.size() + " files!"); 
    }
    for(Cell[] row : grid){
        for(Cell c : row){
          c.drawCell();       
        }
      }
    if (mousePressed){
       if (mouseY < height / yBound && mouseY > 0 && mouseX > 0 && mouseX < width / xBound){
        Cell selected = grid[mouseY / cellSize][mouseX / cellSize];
        selected.c = color(0); 
      }
    }
      if (distances.size() > 0) {
      this.displayImage(width / xBound, 0, distances.get(trainingIndex).img);  
      Training optimal = distances.get(0); 
      this.displayImage(width / 4, height / 2, optimal.img); 
      textSize(20); 
      fill(0); 
      text("Assumed number: " + optimal.num + ". Training Number: " + optimal.trainingNum + ".\n With distance of: " + optimal.distance, width / 2, height - 50); 
      //trainingindex 
      text("Number: " + distances.get(trainingIndex).num + "\nTraining Index: " + distances.get(trainingIndex).trainingNum + ".\nDistance: " + distances.get(trainingIndex).distance, .8 * width, .6 * height); 
      } else {
        this.displayImage(width / xBound, 0, trainingData.get(trainingIndex));  
      }
    
    stroke(0); 
    line(0,height / yBound, width, height / yBound);
    line(width / xBound, 0, width/xBound, height / yBound); 
    noStroke(); 
    
  }
}

void keyPressed(){
    if (key == 'r') initialize();  
    if (key ==',') noStroke();  
    if (key == '.') stroke(0);  
    if (key == 'g') generatingTests = true;
    if (keyCode == LEFT) {
        trainingIndex--; 
        if (trainingIndex < 0) trainingIndex = (numOfLetters * numPerLetter)-1; 
    }
    if (keyCode == RIGHT){
       trainingIndex++; 
       if (trainingIndex >= numOfLetters * numPerLetter) trainingIndex = 0; 
    }
    if (key == ' '){
      calculateDistances(); 
      distances = sortTrainings(); 
      trainingIndex = 0; 
    }
}

//use distances 
ArrayList<Training> sortTrainings() {
    ArrayList<Training> unsorted = new ArrayList<Training>(distances); 
    ArrayList<Training> sorted = new ArrayList<Training>(); 
    while(unsorted.size() > 0){
        Training curr = unsorted.remove(0); 
        int indexToInsert;
        for(indexToInsert = 0; indexToInsert < sorted.size(); indexToInsert++){
            if (curr.distance < sorted.get(indexToInsert).distance) break; 
        }
        sorted.add(indexToInsert,curr); 
    }
    return sorted; 
}

//calculates the distances for all training data and converts them into training data pieces so that 
//they can be sorted by how close they are 
void calculateDistances() {
    distances = new ArrayList<Training>(); 
    int[][] drawnImage = new int[height/(yBound * cellSize)][width / (xBound * cellSize)]; 
    for(int i = 0;  i < height / (cellSize * yBound); i++){
      for(int j = 0; j < width / (cellSize * xBound); j++){
         drawnImage[i][j] = (int)(255 - red(get(j * cellSize, i * cellSize))); 
      }
    }
    for(int i = 0; i < trainingData.size(); i++){
      float currentDistance = this.distance(drawnImage, trainingData.get(i));    
      Training current = new Training(i / numPerLetter, i % numPerLetter, currentDistance, trainingData.get(i)); 
      distances.add(current); 
    }
   println("Successfully calculated " + distances.size() + " distance(s))"); 
}

//calculates the distance between the drawn image and the provided training data 
float distance(int[][] drawn, Integer[][] img){
  float sum = 0; 
  for(int i = 0; i < drawn.length; i++){
     for(int j = 0; j < drawn[0].length; j++){
       //println(drawn[i][j] + " " + img[i][j]); 
         sum += sq(drawn[i][j] - img[i][j]); 
     }
  }
  sum = sqrt(sum);
  return sum; 
}


void createTrainingData() {
    background(255); 
    PrintWriter output; 
    String fileName = "training" + currLetter + "_" + currTraining + ".txt"; 
    output = createWriter(fileName); 
    noStroke(); 
    fill(0); 
    textSize(random(100,350)); 
    text(currLetter, width / (2 * xBound) + random(-1,1) * (width /(4 * xBound)), height / (2 * yBound) + random(-1,1) * (height / (5 * yBound))); 
    for(int row = cellSize/2; row < height / yBound; row += cellSize) {
        for(int col = cellSize/2; col < width / xBound; col += cellSize){
           output.print((int)(255 - red(get(col,row))) + " "); 
          }
        output.print("\n"); 
      }
    output.flush(); 
    output.close(); 
    if (currTraining >= numPerLetter){
       currLetter += 1; 
       currTraining = 0; 
    } else {
       currTraining++; 
    }
    if (currLetter > 9) {
       generatingTests = false;  
    }
}

//Displays the provided 2d array of pixels given a 2d array and a starting xval and yVal 
void displayImage(int x, int y, Integer[][]image) {
   for(int i = 0; i < image.length; i++){
      for(int  j = 0; j < image[0].length; j++){
        fill(color((255 - image[i][j])));
        int xCord = x + j * cellSize; 
        int yCord = y + i * cellSize; 
        rect(xCord - cellSize/2, yCord - cellSize/2, cellSize, cellSize); 
      }
   }
}

//loads the images from the list of testing images 
ArrayList<Integer[][]> loadTraining() {
    ArrayList<Integer[][]> output = new ArrayList<Integer[][]>(); 
    for(int i = 0; i < numOfLetters; i++){
       for(int training = 0; training < numPerLetter; training++){
          String fileName = "training" + i + "_" + training + ".txt";
          output.add(loadFile(fileName)); 
       }
    }
    return output; 
}
//Loads the numerical pixel values of a given file 
Integer[][] loadFile(String fileName){
    Integer[][] output = new Integer[height / (yBound * cellSize)][width / (cellSize * xBound)]; 
    String[] lines = loadStrings(fileName); 
    int row = 0; 
    for(String curr : lines){
       Scanner scanner = new Scanner(curr);  
       int col = 0; 
       while(scanner.hasNext()){
         int next = scanner.nextInt();
          output[row][col] = next; 
          col++; 
       }
       row += 1; 
       scanner.close(); 
    }
    return output; 
}


void initialize() {
  generatingTests = false; 
  currLetter = 0;
  currTraining = 0; 
  grid = new Cell[height/(yBound * cellSize)][width / (xBound * cellSize)]; 
  for(int row = 0; row < grid.length; row++){
     for(int col = 0; col < grid[row].length; col++){
        grid[row][col] = new Cell(col, row);  
     }
  }
  trainingIndex = 0; 
  trainingData = new ArrayList<Integer[][]>(); 
  distances = new ArrayList<Training>(); 
  println(grid.length + " x " + grid[0].length + " size grid created holding " + grid.length * grid[0].length + " pixels!"); 
}
