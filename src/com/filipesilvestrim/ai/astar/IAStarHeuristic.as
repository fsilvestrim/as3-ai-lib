package com.filipesilvestrim.ai.astar
{
	
	/**
	 * ...
	 * @author Filipe
	 */
	public interface IAStarHeuristic 
	{
		function getCost(map : ITileMap, mover : *, x : int, y : int, tx : int, ty : int) : Number;
	}
	
}