package com.filipesilvestrim.ai.astar
{
	
	/**
	 * ...
	 * @author Filipe
	 */
	public interface IPathFind 
	{
		function findPath(mover : * , sx : int, sy : int, tx : int, ty : int) : Path;
	}
	
}