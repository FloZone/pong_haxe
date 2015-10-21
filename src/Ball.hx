package;

import openfl.display.Sprite;
import openfl.geom.Point;


/**
 * ...
 * @author FloZone
 */
class Ball extends Sprite
{
	// mouvement (vecteur)
	public var movement:Point;
	// vitesse
	public var defaultSpeed:Float;
	public var speed:Float;
	
	
	public function new() 
	{
		super();
		this.graphics.beginFill(0xffffff);
		//this.graphics.drawCircle(0, 0, 10);
		this.graphics.drawRect(0, 0, 15, 15);
		this.graphics.endFill();	
		
		this.movement = new Point(0, 0);
		this.defaultSpeed = 5.0;
		this.speed = 5.0;
	}
	
}