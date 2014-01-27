/**
 * ...
 * >author		Filipe Silvestrim
 * >version		<version>
 */

package com.filipesilvestrim.ai.minimax
{
import minimax.*;
	import game.controllers.game.GameIAController;
	import game.core.Board;
	import game.core.Globals;
	import game.models.CardModel;
	
	public class DecisionMaster 
	{
		// ___________________________________________________________________ CONSTANTS
		
		// ___________________________________________________________________ CLASS PROPERTIES
		
		// ___________________________________________________________________ INSTANCE PROPERTIES
		
		private static var _instance : DecisionMaster;
		
		// ___________________________________________________________________ GETTERS AND SETTERS
		
		// ___________________________________________________________________ CONSTRUCTOR
		
		public function DecisionMaster (singleton:SingletonObligate)
		{
			
		}
		
		// ___________________________________________________________________ PUBLIC METHODS
		
		public static function getInstance () : DecisionMaster
		{
			if (!DecisionMaster._instance)
			{
				DecisionMaster._instance = new DecisionMaster(new SingletonObligate());
			}
			return DecisionMaster(DecisionMaster._instance);
		}
		
		/**
		 * 
		 * @param	playList
		 * @param	board
		 * @param	turnPlay
		 * @return 	{piece, x, y, weight}
		 */
		public function evaluate ( playList : Array, board : Board ) : Object
		{
			var sortedArray		: Array  	= playList.sortOn("weight", Array.NUMERIC | Array.DESCENDING);
			var betterChoise	: Object	= sortedArray.shift();
			
			if (!validPlay(betterChoise, board) && sortedArray.length > 1)
				evaluate(sortedArray, board);
			
			return betterChoise;
		}
		
		// ___________________________________________________________________ PRIVATE METHODS
		private function validPlay ( actualPlay : Object, board : Board) : Boolean
		{
			var isValidPlay		: Boolean 	= false;
			var play 			: Object 	= actualPlay;
			var clonedBoard 	: Board		= board.deepClone(); 
			var card			: CardModel = CardModel(play.piece);
			var arrPossibleMov	: Array;
			
			//is the stronger character? 
			
			clonedBoard.unselect();
			clonedBoard.select(play.selection.x, play.selection.y, play.player.actualPlayerId);
			clonedBoard.move(play.x, play.y);
			clonedBoard.unselect();
			
			var posNextMoveX	: int = play.selection.x + play.x;
			var posNextMoveY	: int = play.selection.y + play.y;
			
			//now or never situation
			var isNowOrNever : Boolean = Math.random() > .8;
			
			//memoria
			var returnMemory 	: Boolean = true;
			var lastMemoryMove 	: Object;
			if (card.memoryMoves.length > 0)
			{
				lastMemoryMove = card.memoryMoves[card.memoryMoves.length - 1];
				if ( lastMemoryMove.x == play.x && lastMemoryMove.y == play.y )
					returnMemory =  false;
			}
			
			if (card.memoryMoves.length > 1)
			{
				lastMemoryMove = card.memoryMoves[card.memoryMoves.length - 2];
				if ( lastMemoryMove.x == play.x && lastMemoryMove.y == play.y )
					returnMemory =  false;
			}
			
			//ataca
			var returnAttack : Boolean = false;
			if (play.isAttacking)
				returnAttack = true;
			
			//inimigo por perto
			var returnAttackEnenmy : Boolean = false;
			for each (var mMove : Object in Analytics(play.enemy).movablePieces)
				if (clonedBoard.isInsideRange(posNextMoveX, posNextMoveY, posNextMoveX, posNextMoveY, 1))
					returnAttackEnenmy = true;
					
			//inimigo por perto
			var returnNearEnenmy : Boolean = false;
			var possEnemyPiece : Object;
			for each (var mRange : Object in Analytics(play.enemy).movablePieces)
				if (clonedBoard.isInsideRange(posNextMoveX, posNextMoveY, mRange.x, mRange.y, 3))
					returnNearEnenmy = true;
		
			//possible threat
			var returnPossibleThreat : Boolean = true;
			if (play.weight < 0)
				returnPossibleThreat = false;
			
			//longe
			var retunFar			: Boolean = true;
			var numberPiecesInTeam	: int =  Analytics(play.player).movablePieces.length;
			var countPiecesInRange 	: int;
			var percentInRange 		: int;
			for each (var pFriends : Object in Analytics(play.player).movablePieces)
				if (clonedBoard.isInsideSector(pFriends.x, pFriends.y, 0, play.selection.y, 12, 12))
					countPiecesInRange++;
			
			percentInRange = (countPiecesInRange / numberPiecesInTeam) * 100;
			
			if (percentInRange > 50)
				retunFar = false;
			
			//grupos
			arrPossibleMov		= clonedBoard.possibleMoves(posNextMoveX, posNextMoveY, 2, -1, true);
			var returnGroups	: Boolean = false;
			var cardIdInMove	: int;
			var cardIdPlay		: int = clonedBoard.getPieceId(posNextMoveX, posNextMoveY);
			
			for each ( var move : Object in arrPossibleMov)
			{
				cardIdInMove = clonedBoard.getPieceId(move.x, move.y);
				if ( cardIdInMove != -1 && cardIdInMove == cardIdPlay)
					returnGroups = true;
			}
			
			//FIXME [04/12] mimetismo acrescentado e  nivel de dificuldade por easy e resto
			//mimetismo
			var returnMoveMimet		: Boolean = true;
			for each ( var moveM : Object in arrPossibleMov)
			{
				cardIdInMove = clonedBoard.getPieceId(moveM.x, moveM.y);
				if ( cardIdInMove != -1 && cardIdInMove == cardIdPlay)
					if(!card.hasMoved)
						if (Math.random() > .3)
							returnMoveMimet = false;
			}
			
			//isNowOrNever
			//returnMemory// true
			//returnAttack// false
			//returnAttackEnenmy// false
			//returnNearEnenmy// false
			//returnPossibleThreat// true
			//retunFar// true
			//returnGroups// false
			
//			isValidPlay = !returnPossibleThreat && ((returnNearEnenmy || returnAttack) || returnMemory && returnGroups && retunFar);

			if (GameIAController.getInstance().ia.maxDepth == Globals.IA_DUMMIE)
				isValidPlay = (isNowOrNever || ((returnAttack || returnMemory)) && (returnMoveMimet || !returnPossibleThreat && (returnNearEnenmy || returnGroups || retunFar)));
			else
				isValidPlay = (returnAttack || returnMemory) && (returnMoveMimet && !returnPossibleThreat && (returnNearEnenmy || returnGroups && retunFar));
				
//			isValidPlay = returnMoveMimet && !returnPossibleThreat && ((returnNearEnenmy || returnAttack) || returnMemory && returnGroups && retunFar);
//			else if (GameIAController.getInstance().ia.maxDepth == Globals.IA_MEDIUM)
//				isValidPlay = !returnPossibleThreat && (returnAttack || (returnMemory && returnGroups && retunFar));
//			else
//				isValidPlay = !returnPossibleThreat && ((returnNearEnenmy || returnAttack) || returnMemory && returnGroups && retunFar);

			return isValidPlay;
		}
		
		// ___________________________________________________________________ EVENTS
	}
}

class SingletonObligate {}
