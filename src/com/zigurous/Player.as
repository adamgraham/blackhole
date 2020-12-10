package com.zigurous 
{
	/////////////
	// IMPORTS //
	/////////////
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	public class Player extends MovieClip 
	{
		///////////////
		// VARIABLES //
		///////////////
		
		private var _bullets:Vector.<Bullet>;
		private var _shootDelayTimer:Timer;
		
		private var _left:Boolean;
		private var _right:Boolean;
		private var _up:Boolean;
		private var _down:Boolean;
		
		private var _shootDelay:Number;
		
		private var _colorFrame:int;
		private var _bulletColorFrame:int;
		
		private var _fire:Boolean;
		private var _pulling:Boolean;
		private var _freeze:Boolean;
		
		static public var BASE_SPEED:Number = 10.0;
		static public var MIN_SPEED:Number = BASE_SPEED * 0.2;
		static public var MAX_SPEED:Number = BASE_SPEED * 5.0;
		static public var SHOOT_DELAY_BLACK:Number = 0.05;
		static public var SHOOT_DELAY_WHITE:Number = 0.0;
		static public var SUCK_RADIUS:Number = 400.0;
		
		static internal var _stage:Stage;
		static internal var _gameStage:DisplayObjectContainer;
		static internal var _background:MovieClip;
		
		static internal var _boundsLeft:Number;
		static internal var _boundsRight:Number;
		static internal var _boundsTop:Number;
		static internal var _boundsBottom:Number;
		
		static private const RAD_TO_DEG:Number = 180.0 / Math.PI;
		static private const DEG_TO_RAD:Number = Math.PI / 180.0;
		
		//////////////////
		// CONSTRUCTOR //
		/////////////////
		
		public function Player() 
		{
			if ( stage == null ) addEventListener( Event.ADDED_TO_STAGE, init );
			else init( null );
		}
		
		////////////////////
		// PUBLIC METHODS //
		////////////////////
		
		public function isPullingBullets():Boolean 
		{
			return _pulling;
		}
		
		static public function setGameStage( gameStage:DisplayObjectContainer, mBackground:MovieClip ):void 
		{
			_gameStage = gameStage;
			_background = mBackground;
		}
		
		//////////////////////
		// INTERNAL METHODS //
		//////////////////////
		
		internal function start():void 
		{
			_colorFrame = 2;
			flipColors();
			
			_stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyboardDown );
			_stage.addEventListener( KeyboardEvent.KEY_UP, onKeyboardUp );
			_stage.addEventListener( MouseEvent.MOUSE_DOWN, onLeftMouseDownState );
			_stage.addEventListener( MouseEvent.MOUSE_UP, onLeftMouseUpState );
			_stage.addEventListener( MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDownState );
			_stage.addEventListener( MouseEvent.RIGHT_MOUSE_UP, onRightMouseUpState );
			_stage.addEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );
			_stage.addEventListener( Event.ENTER_FRAME, update );
		}
		
		internal function flipColors():void 
		{
			_colorFrame = (_colorFrame == 1) ? (Random.integerInclusive( 2, totalFrames )) : 1;
			
			var enemies:Vector.<Enemy> = EnemySpawner._enemies;
			var i:uint = EnemySpawner._enemies.length;
			
			if ( _colorFrame == 1 ) 
			{
				_shootDelay = SHOOT_DELAY_BLACK;
				_bulletColorFrame = 1;
				
				Enemy._enemiesVisible = false;
				Enemy._enemyColorFrame = 1;
				
				_background.gotoAndStop( 1 );
				while ( i-- ) enemies[i].gotoAndStop( 1 );
			} 
			else 
			{
				_shootDelay = SHOOT_DELAY_WHITE;
				_bulletColorFrame = Random.integerInclusive( 1, totalFrames );
				
				//Enemy._enemiesVisible = true;
				Enemy._enemyColorFrame = Random.integerInclusive( 2, totalFrames );
				
				_background.gotoAndStop( _colorFrame );
				while ( i-- ) enemies[i].gotoAndStop( Enemy._enemyColorFrame );
			}
			
			gotoAndStop( _colorFrame );
		}
		
		internal function removeBullet( bullet:Bullet ):void 
		{
			var index:int = _bullets.indexOf( bullet );
			if ( index != -1 ) 
			{
				if ( index + 1 < _bullets.length ) _bullets[index] = _bullets.pop();
				else _bullets.pop();
				
				_gameStage.removeChild( bullet );
			}
		}
		
		/////////////////////
		// PRIVATE METHODS //
		/////////////////////
		
		private function init( event:Event ):void 
		{
			removeEventListener( Event.ADDED_TO_STAGE, init );
			
			mouseChildren = false;
			mouseEnabled = false;
			tabChildren = false;
			tabEnabled = false;
			
			_stage = stage;
			
			_boundsLeft = 0.0;
			_boundsRight = _stage.stageWidth;
			_boundsTop = 0.0;
			_boundsBottom = _stage.stageHeight;
			
			_shootDelay = SHOOT_DELAY_BLACK;
			_colorFrame = 1;
			
			_bullets = new <Bullet>[];
			_shootDelayTimer = new Timer( _shootDelay * 1000.0, 1 );
			
			Bullet._player = this;
			Enemy._player = this;
		}
		
		private function update( event:Event ):void 
		{
			if ( _left  ) { if ( x > _boundsLeft ) x -= BASE_SPEED; }
			else if ( _right ) { if ( x < _boundsRight ) x += BASE_SPEED; }
			
			if ( _up ) { if ( y > _boundsTop ) y -= BASE_SPEED; }
			else if ( _down ) { if ( y < _boundsBottom ) y += BASE_SPEED; }
			
			var angleRadians:Number = Math.atan2( _stage.mouseY - y, _stage.mouseX - x );
			rotation = angleRadians * RAD_TO_DEG;
			
			var i:uint = _bullets.length;
			
			if ( _fire ) 
			{
				if ( !_shootDelayTimer.running ) 
				{
					var bullet:Bullet = new Bullet( angleRadians );
					
					bullet.x = x;
					bullet.y = y;
					
					if ( Math.random() < 0.85 ) bullet.gotoAndStop( _bulletColorFrame );
					else bullet.play();
					
					_gameStage.addChildAt( bullet, 1 );
					_bullets.push( bullet );
					
					if ( _shootDelay > 0.0 ) 
					{
						_shootDelayTimer.reset();
						_shootDelayTimer.start();
					}
					
					i++;
				}
			}
			
			while ( i-- ) _bullets[i].update();
		}
		
		private function onKeyboardDown( event:KeyboardEvent ):void 
		{
			switch ( event.keyCode ) 
			{
				case Keyboard.W:
					_up = true;
					break;
				
				case Keyboard.A:
					_left = true;
					break;
				
				case Keyboard.S:
					_down = true;
					break;
				
				case Keyboard.D:
					_right = true;
					break;
				
				case Keyboard.SPACE:
					onFreezeControl();
					break;
			}
		}
		
		private function onKeyboardUp( event:KeyboardEvent ):void 
		{
			switch ( event.keyCode ) 
			{
				case Keyboard.W:
					_up = false;
					break;
				
				case Keyboard.A:
					_left = false;
					break;
				
				case Keyboard.S:
					_down = false;
					break;
				
				case Keyboard.D:
					_right = false;
					break;
			}
		}
		
		private function onLeftMouseDownState( event:MouseEvent ):void 
		{
			_fire = true;
		}
		
		private function onLeftMouseUpState( event:MouseEvent ):void 
		{
			_fire = false;
		}
		
		private function onRightMouseDownState( event:MouseEvent ):void 
		{
			_pulling = true;
		}
		
		private function onRightMouseUpState( event:MouseEvent ):void 
		{
			if ( _pulling ) 
			{
				_pulling = false;
				
				var i:uint = _bullets.length;
				while ( i-- ) _bullets[i].unattachBulletFromPlayer();
			}
		}
		
		private function onMouseWheel( event:MouseEvent ):void 
		{
			var delta:Number = event.delta * 0.5;
			
			BASE_SPEED  = clamp( BASE_SPEED + delta, MIN_SPEED, MAX_SPEED );
			Bullet.BASE_SPEED = clamp( Bullet.BASE_SPEED + delta, Bullet.MIN_SPEED, Bullet.MAX_SPEED );
			Enemy.BASE_SPEED = clamp( Enemy.BASE_SPEED + delta, Enemy.MIN_SPEED, Enemy.MAX_SPEED );
		}
		
		private function freezeBullets():void 
		{
			var i:uint = _bullets.length;
			while ( i-- ) _bullets[i].freeze();
		}
		
		private function unfreezeBullets():void 
		{
			var i:uint = _bullets.length;
			while ( i-- ) _bullets[i].unfreeze();
		}
		
		private function toggleFreezeBullets():void 
		{
			var i:uint = _bullets.length;
			while ( i-- ) _bullets[i].toggleFreeze();
		}
		
		private function onFreezeControl():void 
		{
			if ( _freeze ) 
			{
				unfreezeBullets();
				_freeze = false;
			} 
			else 
			{
				toggleFreezeBullets();
				_freeze = true;
			}
		}
		
		private function clamp( val:Number, min:Number, max:Number ):Number 
		{
			var val2:Number = (max < val) ? max : val;
			return (min > val2) ? min : val2;
		}
		
	}
	
}