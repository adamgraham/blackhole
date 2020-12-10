package com.zigurous 
{
	/////////////
	// IMPORTS //
	/////////////
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	public class Bullet extends MovieClip 
	{
		///////////////
		// VARIABLES //
		///////////////
		
		private var _angle:Number;
		
		private var _vx:Number;
		private var _vy:Number;
		private var _dx:Number;
		private var _dy:Number;
		
		private var _speedMultiplier:Number;
		private var _rotateSpeed:Number;
		
		private var _pulling:Boolean;
		private var _attached:Boolean;
		private var _released:Boolean;
		private var _freeze:Boolean;
		
		static public var BASE_SPEED:Number = 12.5;
		static public var MIN_SPEED:Number = BASE_SPEED * 0.2;
		static public var MAX_SPEED:Number = BASE_SPEED * 5.0;
		static public var MAX_SPEED_MULTIPLIER:Number = 2.0;
		static public var DAMAGE:int = 1;
		
		static public var ATTACH_DISTANCE:Number = 35.0;
		static public var ATTACH_ROTATE_SPEED:Number = 5.0 * DEG_TO_RAD;
		static public var ATTACH_SPEED_MULTIPLIER_INCREASE:Number = 0.03;
		static public var SUCKING_SPEED_MULTIPLIER:Number = 4.0;
		static public var RELEASE_SPEED_MULTIPLIER:Number = 6.0;
		
		static internal var _player:Player;
		
		static private const DEG_TO_RAD:Number = Math.PI / 180.0;
		
		/////////////////
		// CONSTRUCTOR //
		/////////////////
		
		public function Bullet( angle:Number ) 
		{
			init( angle );
		}
		
		////////////////////
		// PUBLIC METHODS //
		////////////////////
		
		public function destroy():void 
		{
			_player.removeBullet( this );
		}
		
		public function update():void 
		{
			if ( !_attached ) 
			{
				if ( !_pulling ) 
				{
					if ( !_freeze ) 
					{
						x += _vx * BASE_SPEED;
						y += _vy * BASE_SPEED;
						
						if ( x > Player._boundsRight ) 
						{
							x = Player._boundsRight;
							changeDirection( -1.0, 0.0 );
						}
						else if ( x < Player._boundsLeft ) 
						{
							x = Player._boundsLeft
							changeDirection( 1.0, 0.0 );
						}
						else if ( y > Player._boundsBottom ) 
						{
							y = Player._boundsBottom;
							changeDirection( 0.0, -1.0 );
						}
						else if ( y < Player._boundsTop ) 
						{
							y = Player._boundsTop;
							changeDirection( 0.0, 1.0 );
						}
					}
					
					if ( !_player.isPullingBullets() )
					{
						var enemies:Vector.<Enemy> = EnemySpawner._enemies;
						var i:uint = enemies.length;
						while ( i-- ) 
						{
							var enemy:Enemy = enemies[i];
							if ( isCollidingAABB( this, enemy ) ) 
							{
								enemy.damage( DAMAGE );
								destroy();
								
								break;
							}
						}
					} 
					else 
					{
						var dx:Number = _player.x - x;
						var dy:Number = _player.y - y;
						var distance:Number = Math.sqrt((dx * dx) + (dy * dy));
						if ( distance < Player.SUCK_RADIUS ) _pulling = true;
					}
				} 
				else 
				{
					var angle:Number = Math.atan2( _player.y - y, _player.x - x );
					calculateVelocity( angle, SUCKING_SPEED_MULTIPLIER );
					
					x += _vx * BASE_SPEED;
					y += _vy * BASE_SPEED;
					
					var dx2:Number = _player.x - x;
					var dy2:Number = _player.y - y;
					var distance2:Number = Math.sqrt((dx2 * dx2) + (dy2 * dy2));
					if ( distance2 < ATTACH_DISTANCE ) 
					{
						_attached = true;
						_rotateSpeed = ATTACH_ROTATE_SPEED * Random.directionFloat();
					}
				}
			} 
			else 
			{
				x = _player.x + (_dx * ATTACH_DISTANCE);
				y = _player.y + (_dy * ATTACH_DISTANCE);
				
				calculateVelocity( _angle + _rotateSpeed, _speedMultiplier + ATTACH_SPEED_MULTIPLIER_INCREASE );
			}
		}
		
		public function freeze():void 
		{
			_freeze = true;
		}
		
		public function unfreeze():void 
		{
			_freeze = false;
		}
		
		public function toggleFreeze():void 
		{
			_freeze = !_freeze;
		}
		
		//////////////////////
		// INTERNAL METHODS //
		//////////////////////
		
		internal function unattachBulletFromPlayer():void 
		{
			if ( _attached ) 
			{
				_attached = false;
				_pulling = false;
				_released = true;
				
				calculateVelocity( _angle + _rotateSpeed, RELEASE_SPEED_MULTIPLIER );
			}
		}
		
		/////////////////////
		// PRIVATE METHODS //
		/////////////////////
		
		private function init( angleRadians:Number ):void 
		{
			mouseChildren = false;
			mouseEnabled = false;
			tabChildren = false;
			tabEnabled = false;
			
			var scale:Number = Random.float( 0.25, 2.5 );
			
			scaleX = scale;
			scaleY = scale;
			
			calculateVelocity( angleRadians, 1.0 );
		}
		
		private function calculateVelocity( angleRadians:Number, speedMultiplier:Number = 1.0 ):void 
		{
			_angle = angleRadians;
			_speedMultiplier = speedMultiplier;
			
			_dx = Math.cos( _angle );
			_dy = Math.sin( _angle );
			
			_vx = _dx * _speedMultiplier;
			_vy = _dy * _speedMultiplier;
		}
		
		private function changeDirection( normalX:Number, normalY:Number ):void 
		{
			_speedMultiplier *= 1.1;
			
			if ( _speedMultiplier > MAX_SPEED_MULTIPLIER ) 
			{
				_speedMultiplier = MAX_SPEED_MULTIPLIER;
			}
			else if ( _released ) 
			{
				_speedMultiplier = MAX_SPEED_MULTIPLIER;
				_released = false;
			}
			
			_dx = -(2.0*(normalX * _dx)*normalX - _dx );
			_dy = -(2.0*(normalY * _dy)*normalY - _dy );
			
			_vx = _dx * _speedMultiplier;
			_vy = _dy * _speedMultiplier;
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