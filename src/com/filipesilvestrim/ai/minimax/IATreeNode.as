/**
 * ...
 * >author		Filipe Silvestrim
 * >version		<version>
 */


package com.filipesilvestrim.ai.minimax
{
public class IATreeNode
	{ 
		// ___________________________________________________________________ CONSTANTS
		
		// ___________________________________________________________________ CLASS PROPERTIES
		private var _action			: String;
		private var _actionList		: Array;
		private var _turnId			: int		= -1;
		private var _weight			: int		= -1;
		private var _destX			: int		= 0;
		private var _destY			: int		= 0;
		private var _alphaBetaCut	: Boolean	= false;
		private var _idMiniMax		: int;
		
		// ___________________________________________________________________ INSTANCE PROPERTIES
		private var _ia					: IA;
		private var _playerAnalytics	: Analytics;
		private var _enemyAnalytics		: Analytics;
		private var _board				: Object;
		private var _associatedNode		: Object;
		private var _selected			: Object;
		private var _data				: Object;
		private var _parent				: IATreeNode;
		
		// ___________________________________________________________________ GETTERS AND SETTERS
		public function get playerAnalytics()	:Analytics 	{ return _playerAnalytics; }
		public function get enemyAnalytics()	:Analytics 	{ return _enemyAnalytics; }
		public function get selected()			:Object 	{ return _selected; }
		public function get board()				:Object 		{ return _board; }
		public function get action()			:String 	{ return _action; }
		public function get actionList()		:Array 		{ return _actionList; }
		public function get weight()			:int 		{ return _weight; }
		public function get turnId()			:int 		{ return _turnId; }
		public function get x()					:int 		{ return _destX; }
		public function get y()					:int 		{ return _destY; }	
		public function get alphaBetaCut()		:Boolean 	{ return _alphaBetaCut; }
		public function get parent()			:IATreeNode { return _parent; }
		public function get idMiniMax()			:int 		{ return _idMiniMax; }
		
		public function set newWeight(value:int):void 
		{
			_weight = value;
		}
		
		public function set alphaBetaCut(value:Boolean):void 
		{
			_alphaBetaCut = value;
		}
		
		// ___________________________________________________________________ CONSTRUCTOR
		
		public function IATreeNode (action : String , playerAnalytics : Analytics, enemyAnalytics : Analytics, parentNode : Object = null, idMiniMax : int = -1)
		{
			_action				= action;
//			_parent				= parentNode != null ? parentNode.data : null;
			_idMiniMax			= idMiniMax;
			_playerAnalytics	= playerAnalytics;
			_enemyAnalytics		= enemyAnalytics;
			_turnId				= _playerAnalytics.actualPlayerId;
			_actionList			= _playerAnalytics.actionList;
//			_board				= parentNode == null ? _playerAnalytics.board.deepClone() : IATreeNode(parentNode.data).board.deepClone();
//			_ia 				= GameIAController.getInstance().ia;
//			_board.addListener(GameIAController.getInstance().ia.processCommand);
		}
		
		// ___________________________________________________________________ PUBLIC METHODS
		public function build () : void
		{
			
		}
		
		public function destroy () : void
		{
			
		}
		
		/**
		 * 
		 * @return weight
		 */
		public function addResults ( obj : Object ) : void
		{
			_data 		= obj;
			_weight 	= _data.weight;
			_selected 	= _data.selected;
			_destX 		= _data.x;
			_destY 		= _data.y;
		}
		
		public function toString () : String
		{
			return "[IATreeNode] :: {player : " + _playerAnalytics.name + ", turnId: " + _turnId + ", action: " + _action + ", weight: " + _weight + " ||  " + dump(); 
		}
		
		public function dump () : String
		{
			return "[IATreeNode].data :: {selected:[" + _selected.x + "," + _selected.y + "], x: " + _destX + ", y: " + _destY + "}";
		}
		// ___________________________________________________________________ PRIVATE METHODS
		
		
		// ___________________________________________________________________ EVENTS
	}
}

