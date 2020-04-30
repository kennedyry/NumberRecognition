class Cell {
 int x,y; 
 color c; 
 
 Cell(int x, int y){
   this.x = x; 
   this.y = y;
   c = color(255); 
 }
 
 void drawCell() {
   fill(c); 
   rect(this.x * cellSize, this.y * cellSize, cellSize, cellSize); 
 }
  
}
