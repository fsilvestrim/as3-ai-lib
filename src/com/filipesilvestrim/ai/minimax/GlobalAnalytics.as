/**
 * ...
 * >author		Filipe Silvestrim
 * >version		<version>
 */

package com.filipesilvestrim.ai.minimax
{
import minimax.*;
	import game.core.Globals;
	import game.models.CardModel;
	
	public class GlobalAnalytics 
	{
		// ___________________________________________________________________ CONSTANTS
		
		// ___________________________________________________________________ CLASS PROPERTIES
		
		// ___________________________________________________________________ INSTANCE PROPERTIES
		private var _player : Analytics;
		private var _enemy	: Analytics;
		
		// ___________________________________________________________________ GETTERS AND SETTERS
		
		// ___________________________________________________________________ CONSTRUCTOR
		public function GlobalAnalytics() {}
		
		// ___________________________________________________________________ PUBLIC METHODS
		/**
		 * 
		 * @param	player
		 * @param	enemy
		 */
		public function defineSides( player : Analytics, enemy : Analytics) : void
		{
			_player = player;
			_enemy 	= enemy;
		}
		
		/**
		 * 
		 * @param	piece
		 * @return com.filipesilvestrim.ai.minimax.IAAction
		 */
		public function attack( piece : Object ) : Object
		{
			var obj 		: Object = { };
			var finalMove	: Object;
			var maxValue	: int = 0;
			var strLog		: String;
			
			//TODO verify the cert attack (side card and attach acording an random), 
			//but use that card to move as attack or escape 
			//verificar se tem muitos inimigos animnhados ou em linha
			//_______________________________________________________________________________________'
			//---------------------------------------------------------------------------------------
			//menor n de adversarios entre a bandeira em potencial com maior probabilidade
			var highPotentialFlag 						: Object 	= _enemy.highPotentialFlag;
			var percentEnemyInsideSector				: int		= 0;
			var numberEnemyInsideSector					: int 		= 0;
			
			//for each (var $enemy : Object in _enemy.arrPiecesDiscovered)
			//{
				//if (_player.board.isInsideSector($enemy.x, $enemy.y, piece.x, piece.y, highPotentialFlag.x, highPotentialFlag.y))
				//{
					//numberEnemyInsideSector++;
				//}
			//}
			//
			//percentEnemyInsideSector = ((Globals.ENEMIES_PER_TEAM - numberEnemyInsideSector) / Globals.ENEMIES_PER_TEAM) * 100;
			
			//---------------------------------------------------------------------------------------
			//menor distancia ate a bandeira em potencial mais proxima
			var lessDistToHightPotFlag 	: int	 	= _player.distance(piece, highPotentialFlag);
			var percentDistNearestFlag 	: int		= ((24 - lessDistToHightPotFlag) / 24) * 100;
			//trace( "percentDistNearestFlag : " + percentDistNearestFlag );
			
			//---------------------------------------------------------------------------------------
			//tem adversarios no raio de acao da peca
			var nearestOponent		 		: Object 	= _enemy.getSomeNearestTo(piece);
			var percentStraightAttack	 	: int		= 0;
			
			if (nearestOponent != null)
				if (Math.abs(nearestOponent.x - piece.x) == 1 || Math.abs(nearestOponent.y - piece.y) == 1 && _player.board.getPieceId(piece.x, piece.y) != _player.board.getPieceId(nearestOponent.x, nearestOponent.y))
					percentStraightAttack = 100;
			
			//trace( "percentStraightAttack : " + percentStraightAttack );
			
			//---------------------------------------------------------------------------------------
			//***porcentagem de batalha
			var arrPiecesThatCahAttack 	: Array 	= [];
			var nCount					: int 		= 0;
			var numberWon				: int 		= 0;
			var maxNumberWon			: int 		= 0;
			var percentWonNear			: int 		= 0;
			var weakerEnemyPiece 		: Object;
			
			for each ( var $enemies : Object in _enemy.arrPotentialAttacks)
			{
				if (_player.board.isInsideRange(piece.x, piece.y, $enemies.x, $enemies.y, 5) && !CardModel($enemies.piece).isTrap)
					arrPiecesThatCahAttack.push($enemies);
			}
			
			for each ( var $objRelAttack : Object in arrPiecesThatCahAttack)
			{
				nCount++;
				numberWon = 0;
				if (CardModel(piece.piece).power > CardModel($objRelAttack.piece).power && CardModel($objRelAttack.piece).wasPowerShowed)
				{
					numberWon++;
				}
				if (CardModel(piece.piece).energy > CardModel($objRelAttack.piece).energy && CardModel($objRelAttack.piece).wasEnergyShowed)
				{
					numberWon++;
				}
				if (CardModel(piece.piece).attack > CardModel($objRelAttack.piece).attack && CardModel($objRelAttack.piece).wasAttackShowed)
				{
					numberWon++;
				}
				
				if (numberWon >= maxNumberWon)
				{
					maxNumberWon		= numberWon;
					weakerEnemyPiece 	= $objRelAttack;
				}
				
				percentWonNear += numberWon * 33;
			}
			
			percentWonNear 		= (percentWonNear / nCount);
			//trace( "percentWonNear : " + percentWonNear );
			
			//_______________________________________________________________________________________'
			/**
			 * Set priorities
			 */
			if (percentEnemyInsideSector > maxValue)
			{
				maxValue 	= percentEnemyInsideSector;
				finalMove 	= _player.moveToObjective(piece, _enemy.highPotentialFlag);
				//trace( "1 - _enemy.highPotentialFlag : " + _enemy.highPotentialFlag.x + " , " + _enemy.highPotentialFlag.y);
			}
			if (percentDistNearestFlag > maxValue)
			{
				maxValue 	= percentDistNearestFlag;
				finalMove 	= _player.moveToObjective(piece, _enemy.highPotentialFlag);
				//trace( "2 - _enemy.highPotentialFlag : " + _enemy.highPotentialFlag.x + " , " + _enemy.highPotentialFlag.y);
			}
			if (percentWonNear > maxValue)
			{
				maxValue 	= percentWonNear;
				finalMove 	= _player.moveToObjective(piece, weakerEnemyPiece);
				//trace( "3 - _enemy.weakerEnemyPiece : " + weakerEnemyPiece.x + " , " + weakerEnemyPiece.y);
			}
			if (percentStraightAttack > maxValue)
			{
				maxValue 	= percentStraightAttack;
				finalMove 	= _player.moveToObjective(piece, nearestOponent);
				//trace( "4 - _enemy.nearestOponent : " + nearestOponent.x + " , " + nearestOponent.y);
			}
			
			strLog = percentEnemyInsideSector + " " + percentDistNearestFlag + " " + percentStraightAttack + " " + percentWonNear + " 0 0 0  ";
			
			var criticalMove : Object = _player.hasEnemyInRatio(piece, finalMove);
			if ( criticalMove != null)
				finalMove = criticalMove;
			
			var needNewMove : Object = _player.wasLastMove(piece, finalMove);
			if (needNewMove != null)
				finalMove = needNewMove;
			
			if (_player.movablePieces.length == 1)
				finalMove  = criticalMove = _player.moveToObjective(piece, _enemy.highPotentialFlag);
			
			/**
			 * End Move
			 * TODO aqui deveria de chamar a rede neural, daí ela retorna o peso, x, y e se é critico
			 * sendo que dessa forma toda heurística acima iria pro saco
			 */
			obj.weight 			= int((percentEnemyInsideSector + percentDistNearestFlag + percentStraightAttack + percentWonNear) / 3);
			obj.x 				= finalMove.x;
			obj.y 				= finalMove.y;
			obj.isAttacking		= criticalMove != null;
			
			strLog += obj.weight + " " + obj.x + " " + obj.y + " ";
			obj.log = strLog;
			 
			return obj;
		}
		
		/**
		 * 
		 * @return
		 */
		public function protect ( piece : Object ) : Object
		{
			var obj 		: Object = { };
			var finalMove	: Object = { };
			var maxValue	: int = 0;
			var strLog		: String;
			
			//_______________________________________________________________________________________'
			//---------------------------------------------------------------------------------------
			//qual peca que esta mais proxima da bandeira em relacao a mais proxima dele
			var nearestEnemyPiece 	: Object = _enemy.getUnityNearestTo(_player.relatedFlag);
			var nearestMinePiece	: Object = _player.getUnityNearestTo(_player.relatedFlag);
			var nearestEnemy		: Object;
			var percentProtectFlag	: int;
			
			if (_player.distance(nearestEnemyPiece, _player.relatedFlag) ==  _player.distance(nearestMinePiece, _player.relatedFlag))
			{
				percentProtectFlag	= 80;
				nearestEnemy 		= _player.moveToObjective(piece, _player.relatedFlag);
			}
			else if (_player.distance(nearestEnemyPiece, _player.relatedFlag) <  _player.distance(nearestMinePiece, _player.relatedFlag))
			{
				if (_player.piecesInRange([nearestEnemyPiece], nearestEnemyPiece.x, nearestMinePiece.y, 1))
				{
					nearestEnemy 		= _player.moveToObjective(piece, nearestEnemyPiece);
					percentProtectFlag 	= 100;
				}
			}
			//trace( "percentProtectFlag : " + percentProtectFlag );
			
			//---------------------------------------------------------------------------------------
			//***verificar se a carta esta sozinha
			var percentAlonePiece		 		: int = 0;
			var alonePiece						: Object;
			
			for each (var $alonePiece : Object in _player.movablePieces)
			{
				if (piece == $alonePiece) { continue; }
				
				if (!_player.board.isInsideRange($alonePiece.x, $alonePiece.y, piece.x, piece.y, 3))
				{
					if ($alonePiece.y >= piece.y)
					{
						percentAlonePiece 	= int((_player.distance(piece, $alonePiece) / 9) * 100);
						alonePiece 			= $alonePiece;
					}
				}
			}
			//trace( "percentAlonePiece : " + percentAlonePiece );
			
			//---------------------------------------------------------------------------------------
			// se estiver mais de uma peca inimiga proxima a uma peca do meu time
			var percentNumberOfNearEnemies 		: int		= 0;
			var numberEnemyInsideRange			: int 		= 0;
			var majorNEnemyInsideRange			: int 		= 0;
			var pieceToProtect				 	: Object;
			
			for each (var $minesPieces : Object in _player.movablePieces)
			{
				if ($minesPieces == piece) { continue; }
				
				numberEnemyInsideRange = 0;
				
				for each (var $enemiesNear : Object in _enemy.movablePieces)
				{
					if (_player.board.isInsideRange($enemiesNear.x, $enemiesNear.y, $minesPieces.x, $minesPieces.y, 3))
					{
						numberEnemyInsideRange++;
					}
				}
				
				if (numberEnemyInsideRange >= majorNEnemyInsideRange)
				{
					majorNEnemyInsideRange			= numberEnemyInsideRange;
					pieceToProtect 					= $minesPieces;
				}
			}
			
			if (pieceToProtect != null)
				percentNumberOfNearEnemies = ((Globals.BOARD_WIDTH - _player.distance(piece, pieceToProtect)) / Globals.BOARD_WIDTH) * 100;
			
			//trace( "percentNumberOfNearEnemies : " + percentNumberOfNearEnemies );
			
			//---------------------------------------------------------------------------------------
			//se uma peca amiga estiver em possivel ameaca e em 2 ou + atributos ela perde
			
			//_______________________________________________________________________________________'
			/**
			 * Set priorities
			 */
			finalMove 	= _player.moveToObjective(piece, nearestEnemyPiece);
			
			if (percentProtectFlag > maxValue)
			{
				maxValue 	= percentProtectFlag;
				finalMove 	= _player.moveToObjective(piece, nearestEnemy);
			}
			if (percentAlonePiece > maxValue)
			{
				maxValue 	= percentAlonePiece;
				finalMove 	= _player.moveToObjective(piece, alonePiece);
			}
			if (percentNumberOfNearEnemies > maxValue)
			{
				maxValue 	= percentNumberOfNearEnemies;
				finalMove 	= _player.moveToObjective(piece, pieceToProtect);
			}
			strLog = "0 0 0 0 " + percentProtectFlag + " " + percentAlonePiece + " " + percentNumberOfNearEnemies + "  ";
			
			var criticalMove : Object = _player.hasEnemyInRatio(piece, finalMove);
			if ( criticalMove != null)
				finalMove = criticalMove;
			
			var needNewMove : Object = _player.wasLastMove(piece, finalMove);
			if (needNewMove != null)
				finalMove = needNewMove;
			
			if (_player.movablePieces.length == 1)
				finalMove  = criticalMove = _player.moveToObjective(piece, _enemy.highPotentialFlag);
				
			/**
			 * End Move
			 * TODO aqui deveria de chamar a rede neural, daí ela retorna o peso, x, y e se é critico
			 * sendo que dessa forma toda heurística acima iria pro saco
			 */
			obj.weight 			= int((percentProtectFlag + percentAlonePiece + percentNumberOfNearEnemies) / 3);
			obj.x 				= finalMove.x;
			obj.y 				= finalMove.y;
			obj.isAttacking		= criticalMove != null;
			
			strLog += obj.weight + " " + obj.x + " " + obj.y + " ";
			obj.log = strLog;
			
			return obj;
		}
		
		/**
		 * 
		 * @param	piece
		 * @param	move
		 * @return	{weight, x, y}
		 */
		public function nextWarning ( piece : Object, move : Object) : Object
		{
			var obj 		: Object = { };
			var finalMove	: Object = { };
			var strLog		: String;
			
			//---------------------------------------------------------------------------------------
			//# - posso perder a peca depois da jogada que farei?
			var percentLostPieceNextMove 	: int	= 0;
			var arrMoves 					: Array = _player.board.possibleMoves(piece.x + move.x, piece.y + move.y);
			var possibleEnemy				: CardModel;
			
			for each ( var $pieceLose : Object in arrMoves)
			{
				possibleEnemy = _player.board.getPiece($pieceLose.x, $pieceLose.y);
				
				if (possibleEnemy != null)
					if (possibleEnemy.isTrap || possibleEnemy.hasMoved && _player.board.getPieceId(piece.x, piece.y) != _player.board.getPieceId($pieceLose.x, $pieceLose.y))
						percentLostPieceNextMove = 150; break;
				
				for each ( var $nextMoves : Object in _player.board.possibleMoves($pieceLose.x, $pieceLose.y))
				{
					possibleEnemy = _player.board.getPiece($nextMoves.x, $nextMoves.y);
					
					if (possibleEnemy != null)
						if (possibleEnemy.isTrap || possibleEnemy.hasMoved && _player.board.getPieceId(piece.x, piece.y) != _player.board.getPieceId($nextMoves.x, $nextMoves.y))
							percentLostPieceNextMove = 150; break;
				}
			}
			
			//---------------------------------------------------------------------------------------
			//# - vou vencer o fazendo a proxima jogada?
			var percentWinGameNextMove 	: int 		= 0;
			var card 					: CardModel = CardModel(piece.piece);
			var possibleFlag			: CardModel;
			
			for each ( var $nextMovet : Object in card.arrPossibleMoves)
			{
				possibleFlag = _enemy.board.getPiece($nextMovet.x, $nextMovet.y);
				
				if (possibleFlag != null && !possibleFlag.hasMoved && !possibleFlag.isTrap)
				{
					percentWinGameNextMove 	= 100;
					finalMove				= _player.moveToObjective(piece,  $nextMovet);
				}
			}
			
			/**
			 * End Move
			 */
			obj.weight 	= percentWinGameNextMove - percentLostPieceNextMove;
			obj.x 		= finalMove.x;
			obj.y 		= finalMove.y;
			
			strLog = percentLostPieceNextMove + " " + percentWinGameNextMove;
			obj.log = strLog;
			
			return obj;
		}
		
		// ___________________________________________________________________ PRIVATE METHODS
		/**
		 * 
		 * @return new move (x,y), based on the escape strategy
		 * 			{x:, y:}
		 */
		private function analisePatterns () : Object
		{
			return { };
		}
		
		private function analiseByMemoryMove () : void
		{
			
		}
	}
	
}