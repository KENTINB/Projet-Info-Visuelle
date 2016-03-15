import processing.core.*;

public class Mover {

	PVector location;
	PVector velocity;

	public Mover() {
		location = new PVector(width / 2, height / 2);
		velocity = new PVector(1, 1);
	}

	public void update() {
		location.add(velocity);
	}

	public void display() {
		stroke(0);
		strokeWeight(2);
		fill(127);
		ellipse(location.x, location.y, 48, 48);
	}

	public void checkEdges() {
		if (location.x > width) {
			location.x = 0;
		} else if (location.x < 0) {
			location.x = width;
		}
		if (location.y > height) {
			location.y = 0;
		} else if (location.y < 0) {
			location.y = height;
		}
	}

	public static void main(String[] args) {
		PApplet.main(new String[] { "Mover" });
	}
}
