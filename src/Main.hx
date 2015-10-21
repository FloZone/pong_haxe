package;

import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import openfl.events.KeyboardEvent;
import openfl.media.Sound;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.Assets;


/**
 * ...
 * @author FloZone
 */
 enum GameState {
	Paused;
	Playing;
	Over;
}

enum Player {
	Human;
	AI;
}


class Main extends Sprite 
{
	var inited:Bool;

	private var platform1:Platform;
	private var platform2:Platform;
	private var ball:Ball;
	
	private var currentGameState:GameState;
	
	private var scorePlayer:Int;
	private var scoreAI:Int;
	
	private var scoreMessage:TextField;
	private var pauseMessage:TextField;
	
	private var arrowKeyUp:Bool;
	private var arrowKeyDown:Bool;

	private var margin:Int;

	private var missedSound:Sound;
	private var platformSound:Sound;
	private var wallSound:Sound;

	
	
	// initialisation
	function init() 
	{
		if (inited) return;
		inited = true;


		// dessiner la ligne du décor
		var background = new Background();
		var posBackground = -0.5 * background.height;
		do {
			background = new Background();
			background.x = (stage.stageWidth / 2) - (background.width / 2);
			background.y = posBackground;	
			this.addChild(background);
			
			posBackground += background.height * 1.5;
		} while (posBackground < stage.stageHeight);
		
		// marge pour l'affichage
		margin = 5;
		
		// initialiser les plateformes
		platform1 = new Platform();
		platform1.x = margin;
		platform1.y = (stage.stageHeight / 2) - (platform1.height / 2);
		this.addChild(platform1);
			
		platform2 = new Platform();
		platform2.x = stage.stageWidth - platform2.width - margin;
		platform2.y = (stage.stageHeight / 2) - (platform2.height / 2);
		this.addChild(platform2);

		// initialiser la balle
		ball = new Ball();
		ball.x = (stage.stageWidth/2) - (ball.width/2);
		ball.y = (stage.stageHeight/2) - (ball.height/2);
		this.addChild(ball);
		
		// initialiser et afficher le score
		var scoreFormat:TextFormat = new TextFormat(Assets.getFont("fonts/pixel.ttf").fontName, 28, 0xffffff, true);
		scoreFormat.align = TextFormatAlign.CENTER;
		scoreMessage = new TextField();
		addChild(scoreMessage);
		scoreMessage.width = stage.stageWidth;
		scoreMessage.y = 30;
		scoreMessage.defaultTextFormat = scoreFormat;
		scoreMessage.selectable = false;
		
		// initialiser et afficher le message de pause
		var messageFormat:TextFormat = new TextFormat(Assets.getFont("fonts/pixel.ttf").fontName, 18, 0xffffff, true);
		messageFormat.align = TextFormatAlign.CENTER;
		pauseMessage = new TextField();
		addChild(pauseMessage);
		pauseMessage.width = stage.stageWidth;
		pauseMessage.y = 450;
		pauseMessage.defaultTextFormat = messageFormat;
		pauseMessage.selectable = false;
		pauseMessage.text = "Press SPACE to start\nUse UP/DOWN to move your platform";
		
		// initialiser les scores
		scorePlayer = 0;
		scoreAI     = 0;
		
		// mettre le jeu en pause
		setGameState(Paused);
		
		// ajouter les listener sur le clavier
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		
		// initialiser les touches clavier
		arrowKeyUp   = false;
		arrowKeyDown = false;
		
		// charger les sonds
		// OGG pour HTML5
		missedSound   = Assets.getSound("audio/missed.ogg");
		platformSound = Assets.getSound("audio/platform.ogg");
		wallSound     = Assets.getSound("audio/wall.ogg");
		// WAV pour flash
		/*
		missedSound   = Assets.getSound("audio/missed.wav");
		platformSound = Assets.getSound("audio/platform.wav");
		wallSound     = Assets.getSound("audio/wall.wav");
		*/
		
		// boucle de jeu (à chaque frame)
		this.addEventListener(Event.ENTER_FRAME, everyFrame);
	}
	
	// mettre à jour les scores
	private function updateScore():Void {
		scoreMessage.text = scorePlayer + "   " + scoreAI;
	}
	
	// mettre à jour le gamestate (début de la partie)
	private function setGameState(state:GameState):Void {
		currentGameState = state;
		updateScore();
		
		// si le jeu est en pause, afficher le message de pause
		if (state == Paused) {
			pauseMessage.alpha = 1;
		}
		// si on joue
		else if (state == Playing) {
			// faire disparaitre le message de pause (transparence)
			pauseMessage.alpha = 0;
			
			// reset la position des plateformes
			platform1.y = (stage.stageHeight/2) - (platform1.height/2);
			platform2.y = (stage.stageHeight/2) - (platform2.height/2);
			
			// reset la vitesse de la balle
			ball.speed = ball.defaultSpeed;
			
			// reset la position de la balle
			ball.x = (stage.stageWidth/2) - (ball.width/2);
			ball.y = (stage.stageHeight/2) - (ball.height/2);
			// droite/gauche aléatoire
			var direction:Int = (Math.random() > .5)?(1):( -1);
			// angle de 90 aléatoire
			var randomAngle:Float = (Math.random() * 0.8 * Math.PI / 2) + 0.2;
			ball.movement.x = direction * Math.cos(randomAngle);
			ball.movement.y = Math.sin(randomAngle);
		}
	}

	// appuie sur une touche
	private function keyDown(event:KeyboardEvent):Void {
		// si le jeu est en pause et SPACE
		if (currentGameState == Paused && event.keyCode == 32) {
			setGameState(Playing);
		}
		
		// si on joue
		// UP
		else if (currentGameState == Playing && event.keyCode == 38) {
			arrowKeyUp = true;
		}
		// DOWN
		else if (currentGameState == Playing && event.keyCode == 40) {
			arrowKeyDown = true;
		}
	}

	// touche relachée
	private function keyUp(event:KeyboardEvent):Void {
		// UP
		if (event.keyCode == 38) {
			arrowKeyUp = false;
		}
		// DOWN
		else if (event.keyCode == 40) {
			arrowKeyDown = false;
		}
	}

	// boucle de jeu
	private function everyFrame(event:Event):Void {
		// si on joue
		if (currentGameState == Playing) {
			// UP et joueur pas en haut
			if (arrowKeyUp && platform1.y > margin) {
				platform1.y -= platform1.speed;
			}
			// DOWN et joueur pas en bas
			else if (arrowKeyDown && platform1.y < (stage.stageHeight - platform1.height - margin)) {
				platform1.y += platform1.speed;
			}
			
			
			// déplacer la balle
			ball.x += ball.movement.x * ball.speed;
			ball.y += ball.movement.y * ball.speed;
			// si elle touche l'écran (haut/bas)
			if (ball.y < 0 || ball.y > (stage.stageHeight - ball.height)) {
				// son
				wallSound.play();
				// faire rebondir
				ball.movement.y *= -1;
			}
			// si elle sort de l'écran droite/gauche, faire gagner
			else if (ball.x < 0) winGame(AI);
			else if (ball.x > stage.stageWidth) winGame(Human);
			
			
			// si la balle va vers le joueur
			if (ball.movement.x < 0) {
				// si elle touche la raquette du joueur (ball.x à gauche du bord droit && ball.y entre les extrémités de la raquette)
				if(ball.x <= (margin + platform1.width) && (ball.y + ball.height) >= platform1.y && ball.y <= platform1.y + platform1.height) {
					// faire rebondir
					bounceBall(Human);
					// augmenter sa vitesse
					ball.speed += 0.3;
				}


				// replacer l'IA à peu près au milieu du terrain
				if ((platform2.y + 0.5 * platform2.height) < (0.5 * stage.stageHeight)) {
					platform2.y += platform2.speed;
				}
				else if ((platform2.y + 0.5 * platform2.height) > (0.5 * stage.stageHeight)) {
					platform2.y -= platform2.speed;
				}
			}
			
			// sinon, la balle va vers l'IA
			else {
				// si elle touche la raquette IA
				if ((ball.x + ball.width) >= (stage.stageWidth - margin - platform2.width) && (ball.y + ball.height) >= platform2.y && ball.y <= platform2.y + platform2.height) {
					bounceBall(AI);
					ball.speed += 0.3;
				}


				// si elle est est dans la partie droite du terrain (40%)
				if (ball.x > (stage.stageWidth * 0.4)) {
					// si son centre est au dessus d'1/4 de la raquette et qu'elle n'est pas en haut
					if ((ball.y + 0.5*ball.height) < (platform2.y + 0.25*platform2.height) && platform2.y > margin) {
						platform2.y -= platform2.speed;
					}
					// si son centre est au dessus de 3/4 de la raquette qu'ellle n'est pas en bas
					else if ((ball.y + 0.5*ball.height) > (platform2.y + 0.75*platform2.height) && platform2.y < (stage.stageHeight - platform2.height - margin)) {
						platform2.y += platform2.speed;
					}
				}
			}
		}
	}

	// fin de la partie
	private function winGame(player:Player):Void {
		// son
		missedSound.play();
		
		// si le joueur gagne
		if (player == Human) {
			++scorePlayer;
		}
		// si l'IA gagne
		else {
			++scoreAI;
		}
		setGameState(Paused);
	}
	
	// faire rebondir la balle
	private function bounceBall(player:Player):Void {
		// son
		platformSound.play();
		// récupérer les anciennes valeurs de mouvement
		var previousX = ball.movement.x;
		var previousY = ball.movement.y;
		
		// si le rebond est du côté joueur
		if (player == Human) {
			// si le milieu de la balle touche le milieu de la raquette (la moitié au centre) rebond serré
			if ((ball.y + 0.5 * ball.height) > (platform1.y + 0.25 * platform1.height) && (ball.y + 0.5 * ball.height) < (platform1.y + 0.75 * platform1.height)) {
				// changer le déplacement vers la gauche -> vers la droite
				ball.movement.x = -1 * ball.movement.x;
			}
			// si le milieu de la balle touche une extrémité de la raquette (1/4) rebond large
			else if ( ((ball.y + 0.5 * ball.height) <= (platform1.y + 0.25 * platform1.height))
			|| ((ball.y + 0.5 * ball.height) >= (platform1.y + 0.75 * platform1.height)) ) {
				// changer le déplacement vers la gauche -> vers la droite  et ajouter un angle de 90 degré
				ball.movement.x = (previousY < 0) ? -1 * previousY : previousY;
				ball.movement.y = (previousY < 0) ? previousX : -1 * previousX;
			}
			// remettre la balle à droite de la raquette joueur
			ball.x = margin + platform1.width + 1;
		}
		// si le rebond est du côté IA
		else if (player == AI) {
			if ((ball.y + 0.5 * ball.height) > (platform2.y + 0.25 * platform2.height) && (ball.y + 0.5 * ball.height) < (platform2.y + 0.75 * platform2.height)) {
				ball.movement.x = -1 * ball.movement.x;
			}
			else if ( ((ball.y + 0.5 * ball.height) <= (platform2.y + 0.25 * platform2.height))
			|| ((ball.y + 0.5 * ball.height) >= (platform2.y + 0.75 * platform2.height)) ) {
				ball.movement.x = (previousY > 0) ? -1 * previousY : previousY;
				ball.movement.y = (previousY > 0) ? previousX : -1 * previousX;
			}
			// remettre la balle à gauche de la raquette IA
			ball.x = stage.stageWidth - margin - platform2.width - ball.width - 1;
		}
	}
	
	
	/* SETUP */
	
	// si la taille de la fenêtre change
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
	}

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
		//
	}
}