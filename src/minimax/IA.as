/**
 * ...
 * >author		Filipe Silvestrim
 */

package minimax
{
	import com.w3haus.utils.ArrayUtil;
	
	import de.polygonal.ds.HashMap;
	import de.polygonal.ds.TreeIterator;
	import de.polygonal.ds.TreeNode;
	
	import game.controllers.game.GameplayController;
	import game.controllers.game.InfoController;
	import game.core.Board;
	import game.core.Globals;
	import game.core.Warland;
	import game.events.BoardEvent;
	import game.models.CardModel;
	
	public class IA 
	{
		// ___________________________________________________________________ CONSTANTS
		public static const ACTION_START_TURN		 	: String = "ia_action_str";
		public static const ACTION_ATTACK_ENEMY_PIECE	: String = "ia_action_aep";
		public static const ACTION_PROTECT_OWN_PIECE 	: String = "ia_action_pop";
		
		public static const MINI 	: int = 1;
		public static const MAX 	: int = 2;
		
		// ___________________________________________________________________ CLASS PROPERTIES
		private var _maxDepth			: int			= Globals.IA_DUMMIE;
		private var _startPlayerId		: int;
		
		//distribut attributes
		private var aSum				: Array	= [];
		private var aValues				: Array	= [];
		private var aMin				: Array	= [];
		private var aMax				: Array	= [];
		
		// ___________________________________________________________________ INSTANCE PROPERTIES
		private var _player1Analysis	: Analytics;
		private var _player2Analysis	: Analytics;
		private var _board				: Board;
		private var _hashActions		: HashMap;
		private var _gameRef			: Warland;
		
		// ___________________________________________________________________ GETTERS AND SETTERS		
		/**
		 * 
		 */
		public function get playerAnalysis()	: Analytics		
		{ 
			var analysis : Analytics = _player1Analysis;
			
			if (_startPlayerId != Globals.ID_PLAYER_ONE)
			{
				analysis = _player2Analysis;
			}
			
			return analysis;
		}
		
		/**
		 * 
		 */
		public function get enemyAnalysis()	: Analytics		
		{ 
			var analysis : Analytics = _player2Analysis;
			
			if (_startPlayerId != Globals.ID_PLAYER_ONE)
			{
				analysis = _player1Analysis;
			}
			
			return analysis;
		}
		
		/**
		 * 
		 */
		public function get maxDepth():int { return _maxDepth; }
		public function set maxDepth(value:int):void 
		{
			_maxDepth = value;
		}
		
		public function get board():Board { return _board; }
		public function set board(value:Board):void 
		{
			_board = value;
			
			_player1Analysis.board			= _board;
			_player2Analysis.board			= _board;
			
			_player1Analysis.update();
			_player2Analysis.update();
		}
		
		public function set gameRef(value:Warland):void 
		{
			_gameRef = value;
		}
		
		// ___________________________________________________________________ CONSTRUCTOR
		public function IA ()
		{
			_player1Analysis				= new Analytics( "PLAYER 1", Globals.ID_PLAYER_ONE);
			_player2Analysis				= new Analytics( "PLAYER 2", Globals.ID_PLAYER_TWO);
			_hashActions					= new HashMap();
			
			_player1Analysis.globalAnalytics.defineSides(_player1Analysis, _player2Analysis);
			_player2Analysis.globalAnalytics.defineSides(_player2Analysis, _player1Analysis);
			
			_hashActions.insert(ACTION_ATTACK_ENEMY_PIECE	, new AttackEnemyPiece());
			_hashActions.insert(ACTION_PROTECT_OWN_PIECE	, new ProtectOwnPiece());
		}
		
		// ___________________________________________________________________ PUBLIC METHODS		
		public function minimax () : Object
		{
			_startPlayerId					= GameplayController.getInstance().getActualPlayer();
			board 							= GameplayController.getInstance().game.board.deepClone();
			playerAnalysis.update();
			enemyAnalysis.update();
			
			var tree : TreeNode = new TreeNode(new IATreeNode( ACTION_START_TURN , getPlayerAnalytics(MAX), getPlayerAnalytics(MAX, true)));
			minimaxValues(tree, MAX)
			
			TreeIterator.preorder(tree, cleanWeights);
			TreeIterator.postorder(tree, processNodeWeights);
			//trace(tree.dump());
			
			return IATreeNode(tree.data);
		}
		
		public function chooseAttribute (iaCard : CardModel, enemyCard : CardModel) : String
		{
			var attribute : String = "";
			
			if (enemyCard.wasAttackShowed) 			
			{
				if (iaCard.attack > enemyCard.attack) { attribute = Globals.ATTACK; return attribute;} 
			}
				
			if (enemyCard.wasEnergyShowed) 	
			{
				if (iaCard.energy > enemyCard.energy) { attribute = Globals.ENERGY; return attribute;} 
			}
				
			if (enemyCard.wasPowerShowed) 		
			{
				if (iaCard.power > enemyCard.power) { attribute = Globals.POWER; return attribute;} 
			}
			
			if (iaCard.power > iaCard.energy && iaCard.power > iaCard.attack && !enemyCard.wasPowerShowed)
			{
				attribute = Globals.POWER
			}
			else if (iaCard.energy > iaCard.power && iaCard.energy > iaCard.attack && !enemyCard.wasEnergyShowed)
			{
				attribute = Globals.ENERGY
			}
			else if (iaCard.attack > iaCard.power && iaCard.attack > iaCard.energy && !enemyCard.wasAttackShowed )
			{
				attribute = Globals.ATTACK
			}
			else
			{
				var features	: Array;
				
				switch (enemyCard.lastAttributeShowed) 
				{
					case Globals.POWER:
						features = [Globals.ATTACK, Globals.ENERGY];
						break;
					case Globals.ENERGY:
						features = [Globals.ATTACK, Globals.POWER];
						break;
					case Globals.ATTACK:
						features = [Globals.POWER, Globals.ENERGY];
						break;
					default:
						features = [Globals.ATTACK, Globals.POWER, Globals.ENERGY]
				}
				
				var index		: int 	= int((Math.random() * (features.length - 1)) + 0.5);
				attribute = features[index];
			}
			
			return attribute;
		}
		
		public function recoverAttributeInfos () : void
		{
			//preenche atributos
			var arrPiecesUser	: Array = InfoController.getInstance().playerOneInfo.team.cards;
			aSum[Globals.POWER] = aSum[Globals.ENERGY] = aSum[Globals.ATTACK] = 0;
			aMin[Globals.POWER] = aMin[Globals.ENERGY] = aMin[Globals.ATTACK] = 0xffffff;
			aMax[Globals.POWER] = aMax[Globals.ENERGY] = aMax[Globals.ATTACK] = 0;
			
			//FIXME [03/12] uma distribuição mais homogênea
			aValues[Globals.POWER] 	= [];
			aValues[Globals.ENERGY] = [];
			aValues[Globals.ATTACK] = [];
			
			for each ( var card : CardModel in arrPiecesUser )
			{
				if (card.type != Globals.CARD_PLAYER)
					continue;
				
				aValues[Globals.POWER].push(card.power); aSum[Globals.POWER] += card.power; aMax[Globals.POWER] = card.power > aMax[Globals.POWER] ? card.power : aMax[Globals.POWER]; aMin[Globals.POWER] = card.power < aMin[Globals.POWER] ? card.power : aMin[Globals.POWER];
				aValues[Globals.ENERGY].push(card.energy); aSum[Globals.ENERGY] += card.energy; aMax[Globals.ENERGY] = card.energy > aMax[Globals.ENERGY] ? card.energy : aMax[Globals.ENERGY]; aMin[Globals.ENERGY] = card.energy < aMin[Globals.ENERGY] ? card.energy : aMin[Globals.ENERGY];
				aValues[Globals.ATTACK].push(card.attack); aSum[Globals.ATTACK] += card.attack; aMax[Globals.ATTACK] = card.attack > aMax[Globals.ATTACK] ? card.attack : aMax[Globals.ATTACK]; aMin[Globals.ATTACK] = card.attack < aMin[Globals.ATTACK] ? card.attack : aMin[Globals.ATTACK];
			}
		}
		
		public function getAttributeValue ( attribute : String ) : int
		{
//			trace ("+++++++++ " + maxDepth);
			var sum 	: int;
			var rand 	: int;
			var min 	: int;
			var max 	: int;
			var media 	: int;
			
			switch (_maxDepth) 
			{
				case Globals.IA_DUMMIE:
					rand = -2 + Math.random() * 8;
					break;
				case Globals.IA_MEDIUM:
					rand = -4 + Math.random() * 12;
					break;
				case Globals.IA_EXPERT:
					rand = -5 + Math.random() * 15;
					break;
			}
			
			//FIXME[03/12]  sort
//			trace (".... " + rand);
			aValues[Globals.POWER] 	= ArrayUtil.sort(aValues[Globals.POWER]);
			aValues[Globals.ENERGY] = ArrayUtil.sort(aValues[Globals.ENERGY]);
			aValues[Globals.ATTACK] = ArrayUtil.sort(aValues[Globals.ATTACK]);
			
			//pool c/ random
			switch (attribute) 
			{
				case Globals.POWER:
//					min 	= aMin[Globals.POWER];
//					max 	= aMax[Globals.POWER];
					sum		= (aValues[Globals.POWER] as Array).pop();
					sum 	= sum + rand;
//					sum 	= (Math.random() * (max - min)) - (max - min)/4;
//					sum 	= sum > aSum[Globals.POWER] ? aSum[Globals.POWER] : sum;
//					sum 	= min + sum;
//					aSum[Globals.POWER] -= sum;
					break;
				case Globals.ENERGY:
//					min 	= aMin[Globals.ENERGY];
					max 	= aMax[Globals.ENERGY];
					sum		= (aValues[Globals.ENERGY] as Array).pop();
					sum 	= sum + rand;
//					sum 	= (Math.random() * (max - min)) - (max - min)/4;
//					sum 	= sum > aSum[Globals.ENERGY] ? aSum[Globals.ENERGY] : sum;
//					sum 	= min + sum;
//					aSum[Globals.ENERGY] -= sum;
					break;
				case Globals.ATTACK:
//					min 	= aMin[Globals.ATTACK];
//					max 	= aMax[Globals.ATTACK];
					sum		= (aValues[Globals.ATTACK] as Array).pop();
					sum 	= sum + rand;
//					sum 	= (Math.random() * (max - min)) - (max - min)/4;
//					sum 	= sum > aSum[Globals.ATTACK] ? aSum[Globals.ATTACK] : sum;
//					sum 	= min + sum;
//					aSum[Globals.ATTACK] -= sum;
					break;
			}
			return sum;
		}
		
		public function distributCards () : void
		{
			
			//TODO implement risk strategies (protect more trap than flag)
			var type 		: int 		= int(Math.random() * 10);
			var cardID      : int         = (InfoController.getInstance().playerTwoInfo.teamId == Globals.HUMAN) ? 1 : 13;
			var arrCards	: Array		= [];
			var game 		: Warland 	= _gameRef;
			
			//flag
			var lucky 		: int 	= int (Math.random() * 10);
			var posFlagY	: int 	= int (Math.random() * 3);
			var posFlagX	: int;
			
			if (lucky > 8)
			{
				posFlagX = int(4 + Math.random() * 4);
			}
			else
			{
				if ( lucky < 3 )
					posFlagX = int(Math.random() * 4);
				else
					posFlagX = int(8 + Math.random() * 4);
			}
			
			//posFlag
			arrCards.push({x:posFlagX, y:posFlagY});
			game.addPiece(posFlagX, posFlagY, InfoController.getInstance().playerTwoInfo.team.searchCardById(cardID), Globals.ID_PLAYER_TWO);
			cardID++;
			
			var rangeMultiplyerOffset : int = 1;
			
			if (type > 5) {
				// aberto 
				rangeMultiplyerOffset = 8;
			}else {
				// medio
				rangeMultiplyerOffset = 4;
			}
			
			//posTrap1
			var arrTraps	 : Array 	= [];
			var arrPoss 	: Array 	= _gameRef.board.possibleMoves(posFlagX, posFlagY, 1 + int(Math.random() * 2), 5);
			var pos			: Object	= arrPoss[int(Math.random() * arrPoss.length)];
			arrCards.push({x:pos.x, y:pos.y});
			arrTraps.push({x:pos.x, y:pos.y});
			game.addPiece(pos.x, pos.y, InfoController.getInstance().playerTwoInfo.team.searchCardById(cardID), Globals.ID_PLAYER_TWO);
			cardID++;
			
			//posTrap2
			arrPoss = _gameRef.board.possibleMoves(posFlagX, posFlagY, 1 + int(Math.random() * 2), 5);
			pos		= arrPoss[int(Math.random() * arrPoss.length)];
			arrCards.push({x:pos.x, y:pos.y});
			arrTraps.push({x:pos.x, y:pos.y});
			game.addPiece(pos.x, pos.y, InfoController.getInstance().playerTwoInfo.team.searchCardById(cardID), Globals.ID_PLAYER_TWO);
			cardID++;
			
			var cardSelected 	: Object;
			var rand 			: int = int(Math.random() * 2);
			
			for (var i:int = 0; i < Globals.ENEMIES_PER_TEAM; i++) 
			{
				for (var j:int = 0; j < arrCards.length; j++) 
				{
					//arrPoss = _gameRef.board.possibleMoves(arrCards[j].x, arrCards[j].y, rangeMultiplyerOffset, 5);
					arrPoss = _gameRef.board.possibleMoves(arrTraps[rand].x, arrTraps[rand].y, rangeMultiplyerOffset, 5);
					if (arrPoss.length > 0)
					{
						cardSelected = arrCards[j];
						break;
					}
				}
				
				pos		= arrPoss[int(Math.random() * arrPoss.length)];
				arrCards.push({x:pos.x, y:pos.y});
				game.addPiece(pos.x, pos.y, InfoController.getInstance().playerTwoInfo.team.searchCardById(cardID), Globals.ID_PLAYER_TWO);
				cardID++;
			}
		}
		
		// ___________________________________________________________________ PRIVATE METHODS
		private function loadWTS() : void
		{
//			Se não tiver camada oculta, numCamadas=2
//			back = new Backpropagation(10,2,1); 
			
//			//Caso possua camada oculta para cada uma delas faça o seguinte:
//			back.addHiddenLayer(2);
			
//			//O valor especificado no addHiddenLayer é o número de neurônios em tal camada
//			//Criar as funções de ativação das camadas ocultas e de saída
//			var af : AsymmetricSigmoidFunction = new AsymmetricSigmoidFunction();
//			back.setHiddenFunction(af);
//			back.setOutputFunction(af);

//			//Valor máximo na geração de pesos aleatórios
//			//neste caso pode ser zero porque os pesos vão ser 
//			//carregados do arquivo 'wts'
//			back.createTopology(0);
			
//			var importer : NevPropImporter = new NevPropImporter(); 
//			importer.callbackComplete = inportWeights;
//			importer.importFile("config.wts"); 
		}
		private function getPlayerAnalytics ( id : int, oposite : Boolean = false ) : Analytics
		{
			if (id == MAX)
			{
				return oposite == false ? playerAnalysis : enemyAnalysis;
			}
			else
			{
				return oposite == false ? enemyAnalysis : playerAnalysis;
			}
		}
		
		private function cleanWeights( node : TreeNode ):void
		{
			if (!node.isLeaf())
			{
				IATreeNode(node.data).newWeight = -0xffffff;
			}
		}
		
		private function processNodeWeights( node : TreeNode ):void
		{
			var changeValues 	: Boolean 	= false;
			
			if (node.parent == null) { return; }
			
			if ( IATreeNode(node.parent.data).turnId == MAX)
			{			
				changeValues = (IATreeNode(node.data).weight > IATreeNode(node.parent.data).weight);
			}
			else
			{
				changeValues = (IATreeNode(node.data).weight < IATreeNode(node.parent.data).weight || IATreeNode(node.parent.data).weight == -0xffffff);
			}
			
			if (changeValues)
			{
				IATreeNode(node.parent.data).newWeight = IATreeNode(node.data).weight;
					
				if (node.parent.isRoot())
				{
					IATreeNode(node.parent.data).addResults(IATreeNode(node.data));
				}
			}
		}
		
		private function minimaxValues(parentNode : TreeNode, idMiniMax : int, alpha : int = 0, beta : int = 0):void
		{
			if (parentNode.depth == maxDepth || gameEnded(IATreeNode(parentNode.data)))
			{
				//return evalGameState(game, MAX);
			}
			else
			{
				var childNode   	: TreeNode;
				var iaNode			: IATreeNode;
				var lastNode		: IATreeNode = null;	
				var bestValue		: int;
				
				for each (var i : String in IATreeNode(parentNode.data).actionList)
				{
					iaNode			= new IATreeNode( i, getPlayerAnalytics(idMiniMax), getPlayerAnalytics(idMiniMax, true), parentNode, idMiniMax);
					iaNode.addResults(IASituation(_hashActions.find(i)).evaluate(iaNode));
					childNode 		= new TreeNode(iaNode, parentNode);
					
					//Alpha-Beta cut
					if (iaNode.parent != null && lastNode != null)
					{
						if (iaNode.parent.idMiniMax == MINI)
						{
							if (lastNode.weight < iaNode.weight)
								iaNode.alphaBetaCut = true;
							if (lastNode.weight > iaNode.weight)
								lastNode.alphaBetaCut = true;
						}
						else
						{
							if (lastNode.weight > iaNode.weight)
								iaNode.alphaBetaCut = true;
							if (lastNode.weight < iaNode.weight)
								lastNode.alphaBetaCut = true;
						}
					}
					
					lastNode = iaNode;
					
					if (!iaNode.alphaBetaCut)
						minimaxValues(childNode, idMiniMax == MAX ? MINI : MAX, alpha, beta);
				}
			}
		}
		
		private function gameEnded( node : IATreeNode ):Boolean
		{
			return false;
		}
		
		// ___________________________________________________________________ EVENTS
		public function processCommand(p_ev:BoardEvent):void
		{
			//trace ("[LOG][BOARD].msg == " + p_ev.error);
		}
	}
}

/**
 * Each one will have 5 steps at first, and each setp has as best value 10 and worst 0
 * We have 2 pattern steps that evaluate if the action will turn the situaction vulnerable or if will win the game
 * At this point we can evaluate the best action to choose
 */

import game.controllers.game.GameIAController;
import game.core.Globals;
import game.ia.IATreeNode;
import game.ia.IASituation;
import game.ia.Analytics;
import game.models.CardModel;
import game.ia.DecisionMaster;

/**
 * Walk in direction to an battle
 */
class AttackEnemyPiece implements IASituation
{
	public function AttackEnemyPiece () { }
	
	public function evaluate (  node : IATreeNode  ) : Object
	{
		var player 			: Analytics = node.playerAnalytics;
		var enemy 			: Analytics = node.enemyAnalytics;
		
		var selection 		: Object;
		var finalMove		: Object;
		var weight			: int;
		
		GameIAController.getInstance().ia.board = node.board;
		
		/**
		 * Inicio das analises
		 */
		var bestAttack 	: int = 0;
		var objAttack	: Object;
		var objWarning	: Object;
		var listWeights	: Array = [];
		
		for each ( var $piece : Object in player.movablePieces)
		{
			bestAttack	= 0;
			objAttack 	= player.globalAnalytics.attack($piece);
			objWarning 	= player.globalAnalytics.nextWarning($piece, objAttack);
			
			//-------------------------------
			//[!!!!LOG DA REDE NEURAL!!!!!!!]
			//-------------------------------
			trace(objAttack.log + objWarning.log)
			
			//if (objAttack.weight > bestAttack)
			//{
				bestAttack 	= objAttack.weight;
				selection	= $piece;
				finalMove	= objAttack;
				
				if (objWarning.weight > 0)
					finalMove	= objWarning;
				if (objWarning.weight != 0)
					bestAttack	+= objWarning.weight;
			//}
			
			listWeights.push( {piece:selection.piece, selection:selection, enemy:enemy, player:player, x:finalMove.x, y:finalMove.y, weight:bestAttack } );
		}
		//weight = bestAttack;
		
		var finalEvaluate : Object = DecisionMaster.getInstance().evaluate(listWeights, node.board);
		selection 	= finalEvaluate.selection;
		finalMove.x = finalEvaluate.x;
		finalMove.y = finalEvaluate.y;
		weight		= finalEvaluate.weight;
		
		/**
		 * Selecao e retorno
		 */
		node.board.unselect();
		node.board.select(selection.x, selection.y, player.actualPlayerId);
		node.board.move(finalMove.x, finalMove.y);
		
		return { selected:selection, x:finalMove.x, y:finalMove.y, weight:weight };
	}
}

/**
 * Walk in direction to some of mine movable to protect flag or to safe solo pieces
 */
class ProtectOwnPiece implements IASituation
{
	public function ProtectOwnPiece () { }
	
	public function evaluate (  node : IATreeNode  ) : Object
	{
		var player 			: Analytics = node.playerAnalytics;
		var enemy 			: Analytics = node.enemyAnalytics;
		
		var selection 		: Object;
		var finalMove		: Object;
		var weight			: int;
		
		GameIAController.getInstance().ia.board = node.board;
		
		/**
		 * Inicio das analises
		 */
		var bestAttack 	: int = 0;
		var objAttack	: Object;
		var objWarning	: Object;
		var listWeights	: Array = [];
		
		for each ( var $piece : Object in player.movablePieces)
		{
			bestAttack	= 0;
			objAttack 	= player.globalAnalytics.protect($piece);
			objWarning 	= player.globalAnalytics.nextWarning($piece, objAttack);
			
			//-------------------------------
			//[!!!!LOG DA REDE NEURAL!!!!!!!]
			//-------------------------------
			trace(objAttack.log + objWarning.log)
			
			//if (objAttack.weight > bestAttack)
			//{
				bestAttack 	= objAttack.weight;
				selection	= $piece;
				finalMove	= objAttack;
				
				if (objWarning.weight > 0)
					finalMove	= objWarning;
				if (objWarning.weight != 0)
					bestAttack	+= objWarning.weight;
			//}
			
			listWeights.push( { piece:selection.piece, selection:selection, enemy:enemy, player:player, x:finalMove.x, y:finalMove.y, weight:bestAttack } );
		}
		
		var finalEvaluate : Object = DecisionMaster.getInstance().evaluate(listWeights, node.board);
		selection 	= finalEvaluate.selection;
		finalMove.x = finalEvaluate.x;
		finalMove.y = finalEvaluate.y;
		weight		= finalEvaluate.weight;
		
		/**
		 * Selecao e retorno
		 */
		node.board.unselect();
		node.board.select(selection.x, selection.y, player.actualPlayerId);
		node.board.move(finalMove.x, finalMove.y);
		
		return { selected:selection, x:finalMove.x, y:finalMove.y, weight:weight };
	}
}
