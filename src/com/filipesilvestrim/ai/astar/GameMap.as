package com.filipesilvestrim.ai.astar
{
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Filipe
	 */
	public class GameMap implements ITileMap
	{
		
		public static const WIDTH 	: int = 30;
		public static const HEIGHT 	: int = 30;
		
		public static const GRASS 	: int = 0;
		public static const WATER 	: int = 1;
		public static const TREES 	: int = 2;
		public static const PLANE 	: int = 3;
		public static const BOAT 	: int = 4;
		public static const TANK 	: int = 5;
		
		private var _terrain : Dictionary = new Dictionary(true);
		private var _units 	: Dictionary = new Dictionary(true);
		private var _visited : Dictionary = new Dictionary(true);
		
		public function GameMap() 
		{
			// create some test data
			fillArea(0,0,5,5,WATER);
			fillArea(0,5,3,10,WATER);
			fillArea(0,5,3,10,WATER);
			fillArea(0,15,7,15,WATER);
			fillArea(7,26,22,4,WATER);
			
			fillArea(17,5,10,3,TREES);
			fillArea(20,8,5,3,TREES);
			
			fillArea(8,2,7,3,TREES);
			fillArea(10,5,3,3,TREES);
			
			setUnit(15, 15, TANK);
			setUnit(2, 7, BOAT);
			setUnit(20, 25, PLANE);
		}

		private function fillArea(x : int , y : int , width : int , height : int , type : int ) : void
		{
			for (var xp : int = x; xp < x + width; xp++) 
			{
				for (var yp : int = y; yp < y + height; yp++) 
				{					
					_terrain[getStringPos(xp, yp)] = type;
				}
			}
		}
		
		public function clearVisited() : void
		{
			for (var x : int = 0; x < getWidthInTiles(); x++) 
			{
				for (var y : int = 0; y < getHeightInTiles(); y++) 
				{
					_visited[getStringPos(x, y)] = false;
				}
			}
		}
		
		public function visited(x : int , y : int) : Boolean
		{
			return _visited[getStringPos(x, y)];
		}
		
		public function getTerrain(x: int , y: int ) : int
		{
			return _terrain[getStringPos(x, y)];
		}
		
		public function getUnit(x: int , y: int ) : int
		{
			return _units[getStringPos(x, y)];
		}
		
		public function setUnit(x : int, y : int , unit : int) : void
		{
			_units[getStringPos(x, y)] = unit;
		}
		
		public function blocked(mover : * , x : int , y : int) : Boolean
		{
			// if theres a unit at the location, then it's blocked
			if (getUnit(x,y) != 0) {
				return true;
			}
			
//			var unit : int = (mover as UnitMover).getType();
//			
//			// planes can move anywhere
//			if (unit == PLANE) {
//				return false;
//			}
//			// tanks can only move across grass
//			if (unit == TANK) {
//				return getTerrain(x, y) != GRASS;
//			}
//			// boats can only move across water
//			if (unit == BOAT) {
//				return getTerrain(x, y) != WATER;
//			}
			
			// unknown unit so everything blocks
			return false;
		}
		
		public function getCost(mover : *, sx : int, sy : int , tx : int , ty : int) : Number
		{
			return 1;
		}
		
		public function  getHeightInTiles() : int 
		{
			return WIDTH;
		}
		
		public function getWidthInTiles() : int
		{
			return HEIGHT;
		}
		
		public function pathFinderVisited(x : int , y : int) : void
		{
			_visited[getStringPos(x, y)] = true;
		}
		
		private function getStringPos ( p_x : int, p_y : int) : String
		{
			return p_x + "_" + p_y;
		}
	}
}