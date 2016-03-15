import processing.event.MouseEvent;

/**
 * Create a plane with some width, length, height; angle is set to 0; and speed of rotation to 1.0x.
 * By moving the wheel of the mouse up, the user can speed up the rotation and by moving it down he can slow it.
 * By Click and Drag, the user can rotate the plane, from -pi/6 up to pi/6 at the X and Z axis.
 */
public class Plane {
    final static float PI = (float) Math.PI;
    final private float x;
    final private float y;
    final private float z;
    private float angleX = 0;
    private float angleZ = 0;
    private float con = 1;

    public Plane(float x, float y, float z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public float getX() {
        return x;
    }

    public float getY() {
        return y;
    }

    public float getZ() {
        return z;
    }

    public float getCon() {
        return con;
    }

    public float getAngleX() {
        return angleX;
    }

    public float getAngleZ() {
        return angleZ;
    }

    private float clamp(float x,float min, float max){
        if(x>max){return max;}
        else if(x<min){return min;}
        return x;
    }

    public void mouseDragged(int mouseX, int pmouseX, int mouseY, int pmouseY) {

        float dZ = (mouseX - pmouseX);
        float dX = (mouseY - pmouseY);
        if (dX < -1) {
            angleX= clamp(angleX+con*PI/48,-PI/3,PI/3);
        } else if (dX > 1) {
            angleX= clamp(angleX-con*PI/48,-PI/3,PI/3);
        }
        if (dZ > 1) {
            angleZ= clamp(angleZ+con*PI/48,-PI/3,PI/3);
        } else if (dZ < -1) {
            angleZ= clamp(angleZ-con*PI/48,-PI/3,PI/3);

        }
    }

    public void mouseWheel(MouseEvent event) {
        float e = event.getCount();
        //Signe?
        if(e < 0) con = clamp( con*1.05f, 0.2f,2f);
        else con = clamp( con*0.95f, 0.2f,2f);
    }
}
