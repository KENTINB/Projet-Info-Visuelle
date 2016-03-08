import processing.core.*;

public class Game extends PApplet {
	float angleX = 0;
	float angleZ = 0;

	public void settings() {
		size(500, 500, P3D);
	}

	public void setup() {
		noStroke();
	}

	public void draw() {
		background(200);
		lights();
		camera(0, 0, 450, 250, 250, 0, 0, 1, 0);
		translate(width / 2, height / 2, 0);
		rotateZ(angleX);
		rotateX(angleZ);
		box(200, 20, 200);
	}

	public void mouseDragged() {
		float dX = (mouseX - pmouseX);
		float dZ = (mouseY - pmouseY);
		if (dX > 1.0) {
			angleX += PI / 10;
		} else if (dX < -1.0) {
			angleX -= PI / 10;
		} else if (dZ > 1.0) {
			angleZ += PI / 10;
		} else if (dZ < -1.0) {
			angleZ -= PI / 10;
		}
	}

	public static void main(String[] args) {
		PApplet.main(new String[] { "Game" });
	}

}
