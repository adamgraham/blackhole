package com.zigurous 
{
	/////////////
	// IMPORTS //
	/////////////
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class EnemySpawner extends Sprite 
	{
		///////////////
		// VARIABLES //
		///////////////
		
		private var _timer:Timer;
		
		static internal var _gameStage:DisplayObjectContainer;
		static internal var _enemies:Vector.<Enemy>;
		static internal var _spawners:Vector.<EnemySpawner> = new <EnemySpawner>[];
		
		static private var BASE_SPAWN_INTERVAL:Number = 10.0;
		
		/////////////////
		// CONSTRUCTOR //
		/////////////////
		
		public function EnemySpawner() 
		{
			if ( stage == null ) addEventListener( Event.ADDED_TO_STAGE, init );
			else init( null );
		}
		
		////////////////////
		// PUBLIC METHODS //
		////////////////////
		
		static public function setGameStage( gameStage:DisplayObjectContainer ):void 
		{
			_gameStage = gameStage;
		}
		
		//////////////////////
		// INTERNAL METHODS //
		//////////////////////
		
		internal function start():void 
		{
			_timer.addEventListener( TimerEvent.TIMER_COMPLETE, spawn );
			_timer.start();
		}
		
		internal function addEnemy( enemy:Enemy ):void 
		{
			_gameStage.addChild( enemy );
			_enemies.push( enemy );
		}
		
		internal function removeEnemy( enemy:Enemy ):void 
		{
			var index:int = _enemies.indexOf( enemy );
			if ( index != -1 ) 
			{
				if ( index + 1 < _enemies.length ) _enemies[index] = _enemies.pop();
				else _enemies.pop();
			}
			
			_gameStage.removeChild( enemy );
		}
		
		static public function startAllSpawners():void 
		{
			var i:uint = _spawners.length;
			while ( i-- ) _spawners[i].start();
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
			
			_timer = new Timer( BASE_SPAWN_INTERVAL * Math.random() * 1000.0, 1 );
			_spawners.push( this );
			
			if ( _enemies == null ) 
			{
				_enemies = new <Enemy>[];
				Enemy._speedMultiplier = 1.0;
				
				addEventListener( Event.ENTER_FRAME, update );
			}
		}
		
		private function update( event:Event ):void 
		{
			var i:uint = _enemies.length;
			while ( i-- ) _enemies[i].update();
		}
		
		private function spawn( event:TimerEvent ):void 
		{
			var enemy:Enemy = new Enemy( this );
			
			enemy.x = x;
			enemy.y = y;
			
			_timer.delay = BASE_SPAWN_INTERVAL * Math.random() * 1000.0;
			_timer.reset();
			_timer.start();
		}
		
	}
	
}