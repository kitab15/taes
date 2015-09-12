import controlP5.*;
import java.awt.Frame;
import SimpleOpenNI.*;

ControlP5 cp5;

ControlFrame cf;

SimpleOpenNI  context;

// ----------------------------
// Joints
PVector com = new PVector();
PVector com2d = new PVector();

PVector head = new PVector();
PVector head2d = new PVector();

PVector rightHand = new PVector();
PVector rightHand2d = new PVector();

PVector leftHand = new PVector();
PVector leftHand2d = new PVector();

PVector rightFoot = new PVector();
PVector rightFoot2d = new PVector();

PVector leftFoot = new PVector();
PVector leftFoot2d = new PVector();
// ----------------------------

// para cambiar fluidamente entre las escenas
SceneManager manager;

boolean stopDraw = false;

void setup(){
  size(1280,960);
  cf = addControlFrame("Controladores", 450,700);
  manager = new SceneManager();
  
  // cosas kinect
  context = new SimpleOpenNI(this);
  if(context.isInit() == false){
     println("Can't init SimpleOpenNI, maybe the camera is not connected!");
     exit();
     return;
  }
  
  stroke(0,0,255);
  strokeWeight(3);
  smooth();
  
  //---------------------------
  // enable depthMap generation
  context.enableDepth();

  //--------------------------------------------
  // enable skeleton generation for all joints
  context.enableUser();
}

void drawJoint(PVector joint){
  float x_coord  = map(joint.x, 0, 640, 0, 1280);
  float y_coord = map(joint.y, 0, 480, 0, 960);
  ellipse(x_coord,y_coord, 50,50);
}

void drawSkeleton(int userId){  
  // draw limbs  
  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
 
  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
 
  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
 
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
 
  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
 
  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  
}

void updateJointsPosition(){
  
  stroke(0,0,0);
  // update the cam
  context.update();
  
  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  
  for(int i=0;i<userList.length;i++){
    
    if(context.isTrackingSkeleton(userList[i])){
    
      //stroke(255,0,255);
      //drawSkeleton(userList[i]);
      // Get Center of Mass
      if(context.getCoM(userList[i],com)){
        context.convertRealWorldToProjective(com,com2d);
      }
      // Get Head
      context.getJointPositionSkeleton(userList[i],SimpleOpenNI.SKEL_HEAD,head);
      context.convertRealWorldToProjective(head,head2d);
      
      // Get right hand
      context.getJointPositionSkeleton(userList[i],SimpleOpenNI.SKEL_RIGHT_HAND,rightHand);
      context.convertRealWorldToProjective(rightHand,rightHand2d);
      
      // Get left hand
      context.getJointPositionSkeleton(userList[i],SimpleOpenNI.SKEL_LEFT_HAND,leftHand);
      context.convertRealWorldToProjective(leftHand,leftHand2d);
      
      // Get right foot
      context.getJointPositionSkeleton(userList[i],SimpleOpenNI.SKEL_RIGHT_FOOT,rightFoot);
      context.convertRealWorldToProjective(rightFoot,rightFoot2d);
      
      // Get left foot
      context.getJointPositionSkeleton(userList[i],SimpleOpenNI.SKEL_LEFT_FOOT,leftFoot);
      context.convertRealWorldToProjective(leftFoot,leftFoot2d);
    }
  }
}

void draw(){
  updateJointsPosition();  
  if(!stopDraw) manager.actualScene.drawScene();
  
  fill(0,255,0);
  drawJoint(com2d);
  fill(255,0,0);
  drawJoint(head2d);
  fill(255,255,0);
  drawJoint(rightHand2d);
  fill(255,255,0);
  drawJoint(leftHand2d);
  fill(0,255,255);
  drawJoint(rightFoot);
  fill(0,255,255);
  drawJoint(leftFoot);
}

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  curContext.startTrackingSkeleton(userId);
}
