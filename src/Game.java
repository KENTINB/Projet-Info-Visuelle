import processing.core.*;
import processing.event.MouseEvent;
import processing.opengl.*;

public class Game extends PApplet {

	Plane plane = new Plane(500, 10, 500);
	PFont f;


	public void settings() {
		size(500, 500, P3D);
	}

	public void setup() {
		noStroke();
		f = createFont("Arial Bold",16,true);
	}


	public void draw() {
		background(200);
		lights();
		translate(width / 2, height / 2, 0);

		textFont(f, 16);
		text("angleX: " + plane.getAngleX() + "\n angleZ: " + plane.getAngleZ()+ "\n vitesse:"+plane.getCon()  , -width, -height,40);

		camera(0, 100, width / 2, 0, 0, 0, 0, 1, 1);

		rotateX(plane.getAngleX());
		rotateZ(plane.getAngleZ());
		box(plane.getX(), plane.getY(), plane.getZ());

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
