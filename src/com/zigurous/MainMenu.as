package com.zigurous 
{
	/////////////
	// IMPORTS //
	/////////////
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	
	final public class MainMenu extends Sprite 
	{
		///////////////
		// VARIABLES //
		///////////////
		
		static private var _player:Player;
		
		/////////////////
		// CONSTRUCTOR //
		/////////////////
		
		public function MainMenu() 
		{
			if ( stage == null ) addEventListener( Event.ADDED_TO_STAGE, init );
			else init( null );
		}
		
		////////////////////
		// PUBLIC METHODS //
		////////////////////
		
		static public function setPlayerReference( player:Player ):void 
		{
			_player = player;
		}
		
		/////////////////////
		// PRIVATE METHODS //
		/////////////////////
		
		private function init( event:Event ):void 
		{
			removeEventListener( Event.ADDED_TO_STAGE, init );
			
			mouseChildren = false;
			tabChildren = false;
			tabEnabled = false;
			
			addEventListener( MouseEvent.CLICK, onMenuClick );
		}
		
		private function onMenuClick( event:Event ):void 
		{
			removeEventListener( MouseEvent.CLICK, onMenuClick );
			
			visible = false;
			mouseEnabled = false;
			
			_player.start();
			_player = null;
			
			EnemySpawner.startAllSpawners();
		}
		
	}
	
}