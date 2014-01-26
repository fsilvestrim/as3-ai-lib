/**
 * ...
 * >author		Filipe Silvestrim
 * >version		<version>
 */

package minimax
{

	public interface IAAction 
	{
		// ___________________________________________________________________ PROPERTIES
		
		// ___________________________________________________________________ METHODS
		function get x()				:int;
		function get y()				:int;
		function get weight()			:int;
		function get isCriticalMove()	:Boolean;
		function get isAttacking()		:Boolean;
	}
}

