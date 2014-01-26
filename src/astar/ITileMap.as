package 
{
	
	/**
	 * ...
	 * @author Filipe
	 */
	public interface ITileMap 
	{
		function getWidthInTiles() : int;
		function getHeightInTiles() : int;
		function pathFinderVisited(x : int, y : int) : void;
		function blocked(mover : *, x : int, y : int) : Boolean;
		function getCost(mover : *, sx : int, sy : int, tx : int, ty : int) : Number;
	}
}