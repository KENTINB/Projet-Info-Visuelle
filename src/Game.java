import processing.core.*;
import processing.event.MouseEvent;

public class Game extends PApplet {
	float angleX = 0;
	float angleZ = 0;
	float con = 1;

	public void settings() {
		size(500, 500, P3D);
	}

	public void setup() {
		noStroke();
	}

	public void draw() {
		background(200);
		lights();
		camera(500, 500, 0, width/2, height/2, 0, 0, 1, 0);
		translate(width / 2, height / 2, 0);
		rotateZ(angleX);
		rotateX(angleZ);
		box(200, 20, 200);
	}

	public float clamp(float x,float min, float max){
		if(x>max){return max;}
		else if(x<min){return min;}
		return x;
	}

	public void mouseDragged() {

		float dZ = (mouseX - pmouseX);
		float dX = (mouseY - pmouseY);
		if (dX > 1.0) {
			angleX= clamp(angleX+con*PI/24,-PI/3,PI/3);
		} else if (dX < -1.0) {
			angleX= clamp(angleX-con*PI/24,-PI/3,PI/3);
		} else if (dZ > 1.0) {
			angleZ= clamp(angleZ+con*PI/24,-PI/3,PI/3);
		} else if (dZ < -1.0) {
			angleZ= clamp(angleZ-con*PI/24,-PI/3,PI/3);

		}
	}

	public void mouseWheel(MouseEvent event) {
		float e = event.getCount();
		//Signe?
		if(e < 0) con *= 1.05;
		else con *= 0.95;
	}

	public static void main(String[] args) {
		PApplet.main(new String[] { "Game" });
	}
}
