package 
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