package 
{
	
	/**
	 * ...
	 * @author Filipe
	 */
	public class ClosestSquared implements IAStarHeuristic
	{
		
		public function getCost(map : ITileMap, mover : *, x : int, y : int, tx : int, ty : int) : Number
		{		
			var dx : Number = tx - x;
			var dy : Number = ty - y;
			
			return ((dx * dx) + (dy * dy));
		}
	}

}