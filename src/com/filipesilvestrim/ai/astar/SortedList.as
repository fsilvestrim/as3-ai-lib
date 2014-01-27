package com.filipesilvestrim.ai.astar
{
	/**
	 * ...
	 * @author Filipe
	 */
	public class SortedList extends ArrayList
	{
		override public function add(o : * ) : void { 
			super.add(o);
			
			//dictonary sort
			_nextList.sort();
		}
	}
}