import processing.core.*;
import processing.event.MouseEvent;

public class Game extends PApplet {

	Plane plane = new Plane(200, 20, 200);

	public void settings() {
		size(500, 500, P3D);
	}

	public void setup() {
		noStroke();
	}

	public void draw() {
		background(200);
		lights();
		camera(500, 500, 0, width / 2, height / 2, 0, 0, 1, 0);
		translate(width / 2, height / 2, 0);
		rotateX(plane.getAngleX());
		rotateZ(plane.getAngleZ());
		box(plane.getX(),plane.getY(),plane.getZ());
	}

	public void mouseWheel(MouseEvent event) {
		plane.mouseWheel(event);
	}

	public void mouseDragged() {
		plane.mouseDragged(mouseX,pmouseX,mouseY,pmouseY);
	}

		public static void main(String[] args) {
		PApplet.main(new String[] { "Game" });
	}
}
