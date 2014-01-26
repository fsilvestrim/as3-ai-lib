/**
 * ...
 * >author		Filipe Silvestrim
 */

package minimax
{
	import game.controllers.game.GameplayController;
	import game.core.Board;
	import game.core.Globals;
	import game.models.CardModel;

	public class Analytics 
	{
		// ___________________________________________________________________ CONSTANTS
		//number of tiles (normal) that defines the near offset
		private const OFFSET_PIECE_RADAR		: int = 2;
		private const OFFSET_PROXIMIT			: int = 3;
		private const OFFSET_FLAG_BATTLE		: int = 4;
		
		// ___________________________________________________________________ CLASS PROPERTIES
		private var _name						: String;
		private var _actualPlayerId 			: int;
		private var _relatedTraps				: Array;
		private var _movablePieces				: Array;
		private var _allPieces					: Array;
		private var _arrPiecesNearEnemyFlag		: Array;
		private var _arrPiecesNearEnemies		: Array;
		private var _arrEnemiesNearFound		: Array;
		private var _actionList					: Array;
		
		// ___________________________________________________________________ INSTANCE PROPERTIES
		private var _board						: Board;
		private var _relatedFlag				: Object;
		private var _globalAnalytics			: GlobalAnalytics;
		
		// ___________________________________________________________________ GETTERS AND SETTERS
		/**
		 * represents the number of enemies near each one of team pieces
		 * ex.: if the piece x have k enemies near and the piece y have l enemies near
		 * the enemies list resulting is the sum k + l - the repeateds enemies
		 * the offset of the near is setted by the OFFSET_PIECE_RADAR const
		 */
		public function get arrEnemiesNearFound()	:Array 		{ return _arrEnemiesNearFound; }
		
		/**
		 * Id of the actual team (player 1 or 2)
		 */
		public function get actualPlayerId()		:int 		{ return _actualPlayerId; }
		public function set actualPlayerId(value:int):void 
		{
			_actualPlayerId = value;
		}
		
		/**
		 * Flag Object Related to this team
		 */
		public function get relatedFlag()			:Object 	{ return _relatedFlag; }
		
		/**
		 * An Array with the flags of the team
		 */
		public function get relatedTraps()			:Array 		{ return _relatedTraps; }
		
		/**
		 * Array Representing the pieces that can moves (excluding the flag and the traps)
		 */
		public function get movablePieces () : Array
		{
			return _movablePieces = _board.getPieceList(_actualPlayerId).filter(filterMovables);
		}
		
		public function get highPotentialFlag () : Object
		{
			var flag 		: Object 	= { };
			var arrAleat	: Array		= [];
			
			flag.flagPotential = 0;
			
			for each ( var o : Object in potentialFlags) 
			{
				if (CardModel(_board.getPiece(o.x, o.y)).flagPotential > flag.flagPotential)
				{
					flag 				= o;
					flag.flagPotential 	= CardModel(_board.getPiece(o.x, o.y)).flagPotential;
				}
				else if (CardModel(_board.getPiece(o.x, o.y)).flagPotential == flag.flagPotential && flag.flagPotential != 0)
				{
					arrAleat.push(o);
				}
			}
			
			if (arrAleat.length > 0)
			{
				return arrAleat[int(Math.random() * arrAleat.length)];
			}
			
			return flag;
		}
		
		/**
		 * Array Representing the flags in potential
		 */
		public function get arrPiecesDiscovered () : Array
		{
			return _board.getPieceList(_actualPlayerId).filter(filterMoveds);
		}
		
		/**
		 * Array Representing the flags in potential
		 */
		public function get potentialFlags () : Array
		{
			return _board.getPieceList(_actualPlayerId).filter(filterUnmoveds);
		}
		
		/**
		 * Array Representing the flags in potential
		 */
		public function get arrPotentialAttacks () : Array
		{
			return _board.getPieceList(_actualPlayerId).filter(filterPotentialAttacks);
		}
		
		/**
		 * Array that represents actual team enemies near the enemy flag
		 * the offset of the near is setted by the OFFSET_PIECE_RADAR const
		 */
		public function get arrPiecesNearEnemyFlag() : Array
		{
			return _arrPiecesNearEnemyFlag = movablePieces.filter(filterNearFlag);
		}
		
		/**
		 * represents the number of pieces near enemies
		 * ex.: if the piece x have k enemies near and the piece y have l enemies near
		 * the pieces list will have x and y, even the x and y pieces sharing the same enemies
		 */
		public function get arrPiecesNearEnemies() : Array
		{
			return _arrPiecesNearEnemies = movablePieces.filter(filterNearEnemies);
		}
		
		/**
		 * Sum of the attributes (power + energy + attack) of all movable pieces of this team
		 */
		public function get sumOfMovablePiecesAttributes() : int
		{
			return sumPowerFromArray(movablePieces);
		}
		
		public function get actionList()	: Array 
		{ 
			return _actionList = getAllPossibleActions(); 
		}
		
		public function get board():Board { return _board; }
		
		public function set board(value:Board):void 
		{
			_board = value;
		}
		
		public function get name():String { return _name; }
		
		public function get globalAnalytics():GlobalAnalytics { return _globalAnalytics; }
		
		// ___________________________________________________________________ CONSTRUCTOR
		
		public function Analytics ( name : String, playerId : int )
		{
			_name							= name;
			_actualPlayerId 				= playerId;
			_globalAnalytics				= new GlobalAnalytics();
		}
		
		// ___________________________________________________________________ PUBLIC METHODS
		
		public function toString () : String
		{
			return "Analytics.name" + _name;
		}
		
		public function build () : void
		{
			
		}
		
		public function destroy () : void
		{
			//_actionList
		}
		
		public function update () : void
		{			
			_relatedFlag					= getFlag();
			_relatedTraps					= getTraps();
			_allPieces						= _board.getPieceList(_actualPlayerId);
			setPiecesProperties(_allPieces);
		}
		/**
		 * 
		 * @param	arr
		 * @param	o
		 */
		public function averageMovesTo( arr : Array, o : Object) : int 
		{
			var sum 	: int = 0;
			var count	: int = 0;
			
			for each (var i : Object in arr)
			{
				sum += Math.sqrt((i.x - o.x) * (i.x - o.x) + (i.y - o.y) * (i.y - o.y)) - 1;
				count++;
			}
			
			return sum / count;
		}
		
		//TODO melhorar esse heuristica
		public function wasLastMove ( piece : Object, move : Object) : Object
		{
			var newMove 	: Object 		= null;
			var card		: CardModel 	= CardModel(piece.piece);
			
			if (card.memoryMoves.length == 0) { return newMove; }
			
			for each ( var memMov : Object in card.memoryMoves)
			{
				if (move.x == memMov.x && move.y == memMov.y)
				{
					for each ( var mov : Object in card.arrPossibleMoves)
					{
						for each ( var memNewMov : Object in card.memoryMoves)
						{
							if (mov != memNewMov)
								newMove = mov;
						}
					}
				}
			}
			
			return newMove;
		}
		
		//verifica se esta ao lado de alguem e se pode ganhar do mesmo
		//FIXME [03/12] arrumei aqui pra validar jogada, só caminha se tiver inimigo
		public function hasEnemyInRatio ( piece : Object, finalMove : Object = null) : Object
		{
			var enemyRadio 		: Object 	= null;
			var pieceCard		: CardModel = CardModel(piece.piece);
			var possibleCard	: CardModel;
			
			for each ( var mov : Object in CardModel(piece.piece).arrPossibleMoves)
			{
				possibleCard = CardModel(_board.getPiece(mov.x, mov.y));
				if ( possibleCard != null ) 
					if (possibleCard.hasMoved)
					{
						if (finalMove!=null)
							if(mov.x != finalMove.x || mov.y != finalMove.y)
								continue;
						//if (possibleCard.wasPowerShowed && pieceCard.power > possibleCard.power)
							//enemyRadio = moveToObjective(piece, mov);
						//else if (possibleCard.wasEnergyShowed && pieceCard.energy > possibleCard.energy)
							//enemyRadio = moveToObjective(piece, mov);
						//else if (possibleCard.wasAttackShowed && pieceCard.attack > possibleCard.attack)
							//enemyRadio = moveToObjective(piece, mov);
						//else if (!possibleCard.wasPowerShowed && !possibleCard.wasEnergyShowed && !possibleCard.wasAttackShowed)
						enemyRadio = moveToObjective(piece, mov);
					}
			}          
			
			return enemyRadio;
		}
		
		//TODO ver se ganha do inimigo que esta numa jogada adiante e escolhe a jogada
		public function hasEnemyInNextMove ( piece : Object ) : Object
		{
			var enemyRadio : Object = null;
			
			for each ( var mov : Object in CardModel(piece.piece).arrPossibleMoves)
			{
				if (CardModel(_board.getPiece(mov.x, mov.y)) != null)
					if (CardModel(_board.getPiece(mov.x, mov.y)).hasMoved)
						enemyRadio = moveToObjective(piece, mov);
			}          
			
			return enemyRadio;
		}
		
		public function moveToObjective (from : Object, to : Object) : Object
		{
			var card : CardModel = from.piece;
			var move : Object = { };
			move.x = 0;
			move.y = 0;
			
			var dx 	: int = to.x - from.x;
			var dy 	: int = to.y - from.y;
			var mx	: int;
			var my	: int;
			
			mx = dx != 0 ? dx / Math.abs(dx) : 0;
			my = dy != 0 ? dy / Math.abs(dy) : 0;
			
			var hasTrap : Boolean = false;
			if (CardModel(_board.getPiece(from.x + mx, from.y + my)) != null)
			{
				if (CardModel(_board.getPiece(from.x + mx, from.y + my)).isTrap)
				{
					hasTrap = true;
				}
			}
			//se o objetivo ja estiver ocupado
			//ou se essa o ocupado for do meu time
			if (_board.getPieceId(from.x + mx, from.y + my) != -1 && _board.getPieceId(from.x, from.y) == _board.getPieceId(from.x + mx, from.y + my) || hasTrap)
			{
				//pega menor distancia pro objetivo
				var minorDistObje : Object = minorDistanceTo(_board.possibleMoves(from.x, from.y), to, true, from);
				
				mx = minorDistObje.x - from.x;
				my = minorDistObje.y - from.y;
			}
			
			move.x = mx;
			move.y = my;
			
			return move;
		}
		
		/**
		 * 
		 * @param	arr
		 * @param	o
		 */
		public function distance( from : Object, to : Object) : int 
		{
			var i		: Object	= from;
			var o		: Object	= to;
			
			return int(Math.abs(i.x - o.x) + Math.abs(i.y - o.y));
		}
		
		/**
		 * 
		 * @param	arr
		 * @param	o
		 */
		public function minorDistanceTo( arr : Array, o : Object, forceJumpFlag : Boolean, from : Object = null) : Object 
		{
			var obj		: Object 	= null;
			var minor 	: int 		= 0xffffff;
			var dist	: int 		= 0;
			
			for each (var i : Object in arr)
			{
				if ( forceJumpFlag)
				{
					if (CardModel(_board.getPiece(i.x, i.y)) != null)
						if (CardModel(_board.getPiece(i.x, i.y)).isTrap)
							continue;
					if (CardModel(from.piece).memoryMoves.length > 0)
						if (CardModel(from.piece).memoryMoves[CardModel(from.piece).memoryMoves.length - 1] == i)
							continue;
					if (CardModel(from.piece).memoryMoves.length > 1)
						if (CardModel(from.piece).memoryMoves[CardModel(from.piece).memoryMoves.length - 2] == i)
							continue;
				}
				
				dist 	= int(Math.abs(i.x - o.x) + Math.abs(i.y - o.y)) ;
				
				if (dist < minor)
				{
					minor 			= dist;
					obj				= i;
				}
			}
			
			return obj;
		}
		
		/**
		 * 
		 * @param	arr
		 * @param	{selection, distance}
		 */
		public function minorMoveTo( o : Object) : Object 
		{
			var obj		: Object 	= { };
			var minor 	: int 		= 0xffffff;
			var dist	: int 		= 0;
			
			if (o == null) 
			{ 
				obj.selection 	= null;
				obj.distance 	= 12;
				
				return obj; 
			};
			
			for each (var i : Object in movablePieces)
			{
				if (o.x == i.x && o.y == i.y) { continue;  }
				
				dist 	= int(Math.abs(i.x - o.x) + Math.abs(i.y - o.y)) ;
				
				if (dist < minor)
				{
					minor 			= dist;
					obj.selection 	= i;
					obj.distance 	= minor;
				}
			}
			
			return obj;
		}
		
		/**
		 * 
		 * @param	arr
		 * @param	o
		 */
		public function getSomeNearestTo( o : Object) : Object 
		{
			var oldDist	: int = 0xffffff;
			var dist	: int = 0;
			var unity	: Object;
			
			for each (var i : Object in _board.getPieceList(_actualPlayerId))
			{
				if (i.x == o.x && i.y == o.y)
					continue;
				
				if (CardModel(_board.getPiece(i.x, i.y)) != null)
				{
					if (CardModel(_board.getPiece(i.x, i.y)).isTrap)
						continue;
				}
				
				dist 	= int(Math.abs(i.x - o.x) + Math.abs(i.y - o.y)) ;
				if (dist < oldDist) 
				{ 
					unity 	= i
					oldDist = dist;
				};
			}
			
			return unity;
		}
		
		/**
		 * 
		 * @param	arr
		 * @param	o
		 */
		public function getUnityNearestTo( o : Object) : Object 
		{
			var oldDist	: int = 0xffffff;
			var dist	: int = 0;
			var unity	: Object;
			
			for each (var i : Object in movablePieces)
			{
				if (i.x == o.x && i.y == o.y) { continue; }
				
				dist 	= int(Math.abs(i.x - o.x) + Math.abs(i.y - o.y)) ;
				if (dist < oldDist) 
				{ 
					unity 	= i
					oldDist = dist;
				};
			}
			
			return unity;
		}
		
		/**
		 * 
		 * @param	arr
		 * @param	destX
		 * @param	destY
		 * @param	offset
		 * @return
		 */
		public function piecesInRange (arr : Array, destX : int, destY : int, offset : int) : int
		{
			var count : int = 0;
			
			for each (var o : Object in arr)
			{
				if (_board.isInsideRange(o.x, o.y, destX, destY, offset))
				{
					count++;
				}
			}
			
			return count;
		}
		
		public function getFlankCards ( range : int ) : Array
		{
			var upperLineWithCard : int;
			
			return [];
		}
		
		public function getHighCard ( arr : Array ) : Object
		{
			return { };
		}
		
		// ___________________________________________________________________ PRIVATE METHODS
		
		/**
		 * 
		 * @param	item
		 * @param	index
		 * @param	array
		 * @return
		 */
		private function setPiecesProperties(array:Array) : void
		{
			var card 		: CardModel;
			
			for each (var i : Object in array)
			{
				card = CardModel(_board.getPiece(i.x, i.y));
				card.addPossibleMoves(_board.possibleMoves(i.x, i.y));
			}
		}
		
		/**
		 * 
		 * @param	item
		 * @param	index
		 * @param	array
		 * @return
		 */
		private function filterMovables(item:*, index:int, array:Array) : Boolean
		{
			var card 		: CardModel 	= CardModel(_board.getPiece(item.x, item.y));
			card.addPossibleMoves(_board.possibleMoves(item.x, item.y));
			
			return (card.type == Globals.CARD_PLAYER &&  card.possibleMovesLenght > 0);
		}
		
		/**
		 * 
		 * @param	item
		 * @param	index
		 * @param	array
		 * @return
		 */
		private function filterUnmoveds(item:*, index:int, array:Array) : Boolean
		{
			var card 		: CardModel 	= CardModel(_board.getPiece(item.x, item.y));
			card.flagPotential = analiseFlagWeight(card);
			return (!card.hasMoved && !card.isTrap && card.flagPotential != 0);
		}
		
		/**
		 * 
		 * @param	item
		 * @param	index
		 * @param	array
		 * @return
		 */
		private function filterPotentialAttacks(item:*, index:int, array:Array) : Boolean
		{
			var card 		: CardModel 	= CardModel(_board.getPiece(item.x, item.y));
			return (card.hasMoved && card.flagPotential == 0);
		}
		
		
		/**
		 * 
		 * @param	item
		 * @param	index
		 * @param	array
		 * @return
		 */
		private function filterMoveds(item:*, index:int, array:Array) : Boolean
		{
			var card 		: CardModel 	= CardModel(_board.getPiece(item.x, item.y));
			return (card.hasMoved);
		}
		
		/**
		 * 
		 * @param	item
		 * @param	index
		 * @param	array
		 * @return
		 */
		private function filterNearFlag(item:*, index:int, array:Array) : Boolean
		{
			var card 		: CardModel 	= CardModel(_board.getPiece(item.x, item.y));
			var hasFlag 	: Boolean		= false;
			var cardEnemy	: CardModel;
			
			for (var x:int = item.x - OFFSET_PROXIMIT; x <= item.x + OFFSET_PROXIMIT; x++)
			for (var y:int = item.y - OFFSET_PROXIMIT; y <= item.y + OFFSET_PROXIMIT; y++)
			{
				if (_board.isInside(x, y))
				{
					cardEnemy = _board.getPiece(x, y);
					
					if (cardEnemy != null)
					{
						if 
						(
							cardEnemy.type == Globals.CARD_FLAG
							&& cardEnemy.id != card.id
							&& GameplayController.getInstance().getTeamByCard(card) != GameplayController.getInstance().getTeamByCard(cardEnemy)
						)
						{
							hasFlag = true;
							break;
						}
					}
				}
			}
			
			return hasFlag;
		}
		
		/**
		 * 
		 * @param	item
		 * @param	index
		 * @param	array
		 * @return
		 */
		private function filterNearEnemies(item:*, index:int, array:Array) : Boolean
		{
			var card 		: CardModel 	= CardModel(_board.getPiece(item.x, item.y));
			var cardEnemy	: CardModel;
			var hasEnemy 	: Boolean		= false;
			_arrEnemiesNearFound			= [];
			
			for (var x:int = item.x - OFFSET_PROXIMIT; x <= item.x + OFFSET_PROXIMIT; x++)
			for (var y:int = item.y - OFFSET_PROXIMIT; y <= item.y + OFFSET_PROXIMIT; y++)
			{
				if (_board.isInside(x, y))
				{
					cardEnemy = _board.getPiece(x, y);
					
					if (cardEnemy != null)
					{
						if 
						(
							cardEnemy.type == Globals.CARD_PLAYER
							&& _arrEnemiesNearFound.indexOf(cardEnemy) == -1
							&& cardEnemy.id != card.id
							&& GameplayController.getInstance().getTeamByCard(card) != GameplayController.getInstance().getTeamByCard(cardEnemy)
						)
						{
							_arrEnemiesNearFound.push(cardEnemy);
							hasEnemy = true;
						}
					}
				}
			}
			
			return hasEnemy;
		}
		
		/**
		 * 
		 * @param	arr
		 * @return
		 */
		private function sumPowerFromArray( arr : Array ) : int 
		{
			var sum : int = 0;
			
			for each ( var i : Object in arr )
			{
				sum += i.piece.power + i.piece.energy + i.piece.attack;
			}
			
			return sum;
		}
		
		/**
		 * 
		 * @param	teamId
		 * @return
		 */
		private function getFlag () : Object
		{
			var arr 	: Array 	= _board.getPieceList(_actualPlayerId);
			var card 	: CardModel = null;
			
			for each (var o : Object in arr)
			{
				card = CardModel(_board.getPiece(o.x, o.y));
				if (card.type == Globals.CARD_FLAG) { return o; }
			}
			
			return null;
		}
		
		/**
		 * 
		 * @param	teamId
		 * @return
		 */
		private function getTraps () : Array
		{
			var arr 	: Array 	= _board.getPieceList(_actualPlayerId);
			var traps 	: Array		= [];
			var card 	: CardModel = null;
			
			for each (var o : Object in arr)
			{
				card = CardModel(_board.getPiece(o.x, o.y));
				if (card.type == Globals.CARD_TRAP) 
				{ 
					traps.push(card);
				}
			}
			
			return traps;
		}
		
		/**
		 * 
		 * @param	arr
		 * @param	o
		 * @return
		 */
		private function averageBattlesToWinFlag( arr : Array, o : Object) : int 
		{
			var count 		: int = 0;
			var card		: CardModel;
			
			for (var x:int = o.x - OFFSET_FLAG_BATTLE; x <= o.x + OFFSET_FLAG_BATTLE; x++)
			for (var y:int = o.y - OFFSET_FLAG_BATTLE; y <= o.y + OFFSET_FLAG_BATTLE; y++)
			{
				if (_board.isInside(x, y))
				{
					card = _board.getPiece(x, y);
					
					if (card!= null)
					{
						if 
						(
							o.piece.type == card.type
						)
						{
							count++;
						}
					}
				}
			}
			
			return count;
		}
		
		/**
		 * The average of all pieces move needed to go straight to the enemyFlag  
		 * @param	enemyFlag
		 * @return
		 */
		public function getNumberOfMovesLackToFoundFlag( enemyFlag : Object ) : int
		{
			if (enemyFlag == null) {return Globals.BOARD_WIDTH}
			return averageMovesTo(movablePieces, enemyFlag);
		}
		
		/**
		 * The average of all battles need be won by each piece in the area
		 * of distance from actual piece to enemyFlag
		 * @param	enemyFlag
		 * @return
		 */
		public function getNumberOfBattlesToWinToFlag ( enemyFlag : Object ) : int
		{
			if (enemyFlag == null) {return Globals.BOARD_WIDTH}
			return averageBattlesToWinFlag(movablePieces, enemyFlag);
		}
		
		/**
		 * The Possible Actions
		 * @return Array of IASituation elements
		 */
		private function getAllPossibleActions() : Array
		{
			return [IA.ACTION_ATTACK_ENEMY_PIECE, IA.ACTION_PROTECT_OWN_PIECE]; //IA.ACTION_ATTACK_ENEMY_FLAG, , IA.ACTION_PROTECT_OWN_FRAG
		}
		
		
		/**
		 * 
		 * @param	item
		 * @param	index
		 * @param	array
		 * @return
		 */
		private function analiseFlagWeight(card : CardModel) : int
		{
			if (card.hasMoved || card.isTrap) return 0;
			
			var posDifCalc : int;
			
			if (_actualPlayerId == Globals.ID_PLAYER_ONE)
			{
				return int(((card.position.y - 6) / 6) * 10) + (piecesInRange(_board.getPieceList(_actualPlayerId), card.position.x, card.position.y, 2) / 8);// + (Math.random() > .8 ? int(card.type == Globals.CARD_FLAG) * (Math.random() * 10) : 0);  + Math.abs(((5.5 - card.position.x)/6) * 5)
			}
			else
			{
				return int((card.position.y / 6) * 10) + (piecesInRange(_board.getPieceList(_actualPlayerId), card.position.x, card.position.y, 2) / 8);// + (Math.random() > .8 ? int(card.type == Globals.CARD_FLAG) * (Math.random() * 10) : 0);
			}
			
		}
		
		// ___________________________________________________________________ EVENTS
	}
}

