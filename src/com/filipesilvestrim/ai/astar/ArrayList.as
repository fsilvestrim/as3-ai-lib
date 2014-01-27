package com.filipesilvestrim.ai.astar
{
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Filipe
	 */
	public class ArrayList
	{
		private var _id	: int;
		protected var _nextList			: Array;
		protected var _list				: Dictionary;
		
		public function first() 		: * 		{ return _nextList[0]; }
		public function size() 			: int 		{ return _nextList.length; }
		public function contains(o : *) : Boolean 	{ return _list[o] || false; }
		
		public function ArrayList()					
		{ 
			_list 		= new Dictionary(true); 
			_nextList 	= new Array();
			
			_id = Math.random() * 0xffffff;
		}
		
		public function add(o : * ) 	: void 		
		{ 
			_list[o] = o;  		
			_nextList.unshift(o);
		}
		
		public function remove(o : * ) 	: void		
		{ 
			_nextList.splice(_nextList.indexOf(o), 1);
			_list[o] 	= null;
		}
		
		public function clear() 		: void		
		{ 
			for (var i : * in _list) 
				_list[i] = null; 
				
			_list 		= new Dictionary(true);
			_nextList 	= new Array(); 
		}
	}
}