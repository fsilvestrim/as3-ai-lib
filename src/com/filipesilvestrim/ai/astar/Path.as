package com.filipesilvestrim.ai.astar
{
	/**
	 * ...
	 * @author Filipe
	 */
	public class Path
	{
		private var _steps : Array 		= new Array();
		
		public function getLength() 						: int  	{ return _steps.length; }
		public function getStep(p_index : int) 				: Step	{ return _steps[p_index]; }
		public function getX(p_index : int) 				: int  	{ return getStep(p_index).x; }
		public function getY(p_index : int) 				: int  	{ return getStep(p_index).y; }
		public function appendStep(p_x : int, p_y : int) 	: void  { _steps.push(new Step(p_x, p_y));}
		public function prependStep(p_x : int, p_y : int) 	: void  { _steps.unshift(new Step(p_x, p_y)); }
		
		public function contains(p_x : int, p_y : int)		: Boolean 
		{
			return _steps.some(function (element:*, index:int, arr:Array):Boolean {
				return (element.toString() == this.toString());
			}, new Step(p_x, p_y));
		}
	}
}

class Step 
{
	private var _x : int;
	private var _y : int;
	
	public function get x():int { return _x; }
	public function get y():int { return _y; }
	
	public function Step(p_x : int, p_y : int) 
	{
		_x = p_x;
		_x = p_y;
	}
	
	public function hashCode() : int
	{
		return _x * _y;
	}

	public function equals(p_other : *) : Boolean
	{
		if (p_other is Step) 
		{
			var o : Step = (p_other as Step);
			
			return (o.x == x) && (o.y == y);
		}
		
		return false;
	}
	
	public function toString():String 
	{
		return "pos: " + _x + "," + _y + "; hash: " + hashCode();
	}
}