package com.zigurous 
{
	/////////////
	// IMPORTS //
	/////////////
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	public class Enemy extends MovieClip 
	{
		///////////////
		// VARIABLES //
		///////////////
		
		private var _spawner:EnemySpawner;
		
		private var _health:int;
		private var _rotationSpeed:Number;
		
		static public var BASE_SPEED:Number = 2.0;
		static public var MIN_SPEED:Number = BASE_SPEED * 0.2;
		static public var MAX_SPEED:Number = BASE_SPEED * 5.0;
		static public var BASE_HEALTH:int = 8;
		static public var ROTATION_SPEED:Number = 5.0;
		
		static internal var _player:Player;
		static internal var _speedMultiplier:Number;
		static internal var _enemiesVisible:Boolean;
		static internal var _enemyColorFrame:int;
		
		static private const RAD_TO_DEG:Number = 180.0 / Math.PI;
		
		/////////////////
		// CONSTRUCTOR //
		/////////////////
		
		public function Enemy( spawner:EnemySpawner ) 
		{
			init( spawner );
		}
		
		////////////////////
		// PUBLIC METHODS //
		////////////////////
		
		public function destroy():void 
		{
			_spawner.removeEnemy( this );
		}
		
		public function update():void 
		{
			var angle:Number = Math.atan2( _player.y - y, _player.x - x );
			
			x += Math.cos( angle ) * BASE_SPEED * _speedMultiplier;
			y += Math.sin( angle ) * BASE_SPEED * _speedMultiplier;
			
			rotation += _rotationSpeed;
			
			if ( isCollidingAABB( this, _player ) ) 
			{
				_player.flipColors();
				destroy();
			}
		}
		
		public function damage( amount:int ):void 
		{
			_health -= amount;
			if ( _health <= 0 ) destroy();
		}
		
		/////////////////////
		// PRIVATE METHODS //
		/////////////////////
		
		private function init( spawner:EnemySpawner ):void 
		{
			mouseChildren = false;
			mouseEnabled = false;
			tabChildren = false;
			tabEnabled = false;
			
			_spawner = spawner;
			_spawner.addEnemy( this );
			_health = BASE_HEALTH;
			_speedMultiplier += 0.01;
			_rotationSpeed = ROTATION_SPEED * Random.directionFloat() * Random.float( 0.5, 1.5 );
			
			if ( Math.random() > 0.5 ) scaleY *= -1.0;
			if ( _enemiesVisible ) play();
			else gotoAndStop( _enemyColorFrame );
		}
		
		private function isCollidingAABB( a:DisplayObject, b:DisplayObject ):Boolean 
		{
			var dx:Number = a.x - b.x;
			var dy:Number = a.y - b.y;
			
			dx = (dx < 0) ? -dx : dx;
			dy = (dy < 0) ? -dy : dy;
			
			return (dx < (a.width * 0.5) + (b.width * 0.5)) ? ((dy < (a.height * 0.5) + (b.height * 0.5)) ? true : false) : false;
		}
		
	}
	
}