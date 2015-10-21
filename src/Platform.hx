package;

import openfl.display.Sprite;


/**
 * ...
 * @author FloZone
 */
class Platform extends Sprite
{
	// vitesse
	public var speed:Float;
	
	
	public function new() 
	{
		super();
		this.graphics.beginFill(0xffffff);
		this.graphics.drawRect(0, 0, 15, 100);
		this.graphics.endFill();
		
		this.speed = 7.0;
	}
	
}