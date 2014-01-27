package com.filipesilvestrim.ai.astar
{
	
	/**
	 * ...
	 * @author Filipe
	 */
	public class AStar implements IPathFind
	{
		private var _closed 			: ArrayList		= new ArrayList();
		private var _open 				: SortedList 	= new SortedList();
		
		private var _map				: ITileMap;
		private var _maxSearchDistance	: int;
		
		private var _nodes				: Vector.<Vector.<Node>>;
		private var _allowDiagMovement	: Boolean;
		private var _heuristic 			: IAStarHeuristic;
		
		public function AStar(map : ITileMap, maxSearchDistance : int, allowDiagMovement : Boolean, heuristic : IAStarHeuristic = null) {
			_heuristic 			= heuristic || new ClosestSquared();
			_map 				= map;
			_maxSearchDistance 	= maxSearchDistance;
			_allowDiagMovement 	= allowDiagMovement;
			
			var wIT : int = _map.getWidthInTiles();
			var hIT : int = _map.getHeightInTiles();
			var x 	: int, y : int;
			
			_nodes 			= new Vector.<Vector.<Node>>();
			_nodes.length	= wIT;
			_nodes.fixed 	= true;
			
			for (x = 0; x < wIT; x++)
			{
				_nodes[x] 			= new Vector.<Node>();
				_nodes[x].length 	= hIT;
				_nodes[x].fixed 	= true;
			}
			
			for (x = 0; x < wIT; x++)
				for (y = 0; y < hIT; y++)
					_nodes[x][y] = new Node(x, y);
					
		}
		
		protected function isValidLocation(mover : * , sx : int , sy : int , x : int , y : int) : Boolean
		{
			var invalid : Boolean = (x < 0) || (y < 0) || (x >= _map.getWidthInTiles()) || (y >= _map.getHeightInTiles());
			
			if ((!invalid) && ((sx != x) || (sy != y)))
				invalid = _map.blocked(mover, x, y);
			
			return !invalid;
		}
		
		public function getMovementCost(mover : * , sx : int, sy : int, tx : int, ty : int) 	: Number { return _map.getCost(mover, sx, sy, tx, ty); }
		public function getHeuristicCost(mover : * , x : int, y : int, tx : int, ty : int) 	: Number { return _heuristic.getCost(_map, mover, x, y, tx, ty); }
		
		protected function getFirstInOpen() 			: Node 		{ return _open.first(); }
		protected function addToOpen(node : Node) 		: void		{ _open.add(node); }
		protected function removeFromOpen(node : Node)	: void 		{ _open.remove(node); }
		protected function inOpenList(node : Node) 		: Boolean	{ return _open.contains(node); }
		protected function addToClosed(node : Node) 	: void		{ _closed.add(node);  }
		protected function inClosedList(node : Node) 	: Boolean	{ return _closed.contains(node); }
		protected function removeFromClosed(node : Node): void		{ _closed.remove(node); }
		
		
		/* INTERFACE com.ubisoft.kephren.ai.pathfind.IPathFind */
		
		public function findPath(mover : * , sx : int, sy : int, tx : int, ty : int) : Path
		{
			// easy first check, if the destination is blocked, we can't get there
			if (_map.blocked(mover, tx, ty))
				return null;
			
				
			// initial state for A*. The closed group is empty. Only the starting
			// tile is in the open list and it's cost is zero, i.e. we're already there
			_nodes[sx][sy].cost = 0;
			_nodes[sx][sy].depth = 0;
			_closed.clear();
			_open.clear();
			_open.add(_nodes[sx][sy]);
			
			_nodes[tx][ty].parent = null;
			
			// while we haven't found the goal and haven't exceeded our max search depth
			var maxDepth : int = 0;
			
			while ((maxDepth < _maxSearchDistance) && (_open.size() != 0)) 
			{
				// pull out the first node in our open list, this is determined to 
				// be the most likely to be the next step based on our heuristic
				var current : Node = getFirstInOpen();
				
				if (current == _nodes[tx][ty]) 
					break;
				
				removeFromOpen(current);
				addToClosed(current);
				
				// search through all the neighbours of the current node evaluating
				// them as next steps
				for (var x : int = -1; x < 2; x++) 
				{
					for (var y : int = -1; y < 2; y++) 
					{
						// not a neighbour, its the current tile
						if ((x == 0) && (y == 0)) 
							continue;
						
						// if we're not allowing diaganol movement then only 
						// one of x or y can be set
						if (!_allowDiagMovement) 
							if ((x != 0) && (y != 0)) 
								continue;
						
						// determine the location of the neighbour and evaluate it
						var xp : int = x + current.x;
						var yp : int = y + current.y;
						
						if (isValidLocation(mover, sx, sy, xp, yp)) 
						{
							// the cost to get to this node is cost the current plus the movement
							// cost to reach this node. Note that the heursitic value is only used
							// in the sorted open list
							var nextStepCost 	: Number 	= current.cost + getMovementCost(mover, current.x, current.y, xp, yp);
							var neighbour 		: Node 		= _nodes[xp][yp];
							_map.pathFinderVisited(xp, yp);
							
							// if the new cost we've determined for this node is lower than 
							// it has been previously makes sure the node hasn't been discarded. We've
							// determined that there might have been a better path to get to
							// this node so it needs to be re-evaluated
							if (nextStepCost < neighbour.cost) 
							{
								if (inOpenList(neighbour)) 
									removeFromOpen(neighbour);
									
								if (inClosedList(neighbour)) 
									removeFromClosed(neighbour);
							}
							
							// if the node hasn't already been processed and discarded then
							// reset it's cost to our current cost and add it as a next possible
							// step (i.e. to the open list)
							if (!inOpenList(neighbour) && !(inClosedList(neighbour))) 
							{
								neighbour.cost 		= nextStepCost;
								neighbour.heuristic = getHeuristicCost(mover, xp, yp, tx, ty);
								maxDepth 			= Math.max(maxDepth, neighbour.setParent(current));
								addToOpen(neighbour);
							}
						}
					}
				}
			}

			// since we've got an empty open list or we've run out of search 
			// there was no path. Just return null
			
			if (_nodes[tx][ty].parent == null)
				return null;
			
			// At this point we've definitely found a path so we can uses the parent
			// references of the nodes to find out way from the target location back
			// to the start recording the nodes on the way.
			var path 	: Path 	= new Path();
			var target 	: Node 	= _nodes[tx][ty];
			
			while (target != _nodes[sx][sy]) 
			{
				path.prependStep(target.x, target.y);
				target = target.parent;
			}
			
			path.prependStep(sx,sy);
			
			// thats it, we have our path 
			return path;
		}
	}
}

class Node
{
	internal var x			: int;
	internal var y			: int;
	internal var depth 		: int;
	internal var cost		: Number;
	internal var heuristic	: Number;
	internal var parent		: Node;
	
	public function Node(p_x : int, p_y : int) 
	{
		x = p_x;
		y = p_y;
	}
	
	public function setParent(p_parent : Node) : int 
	{
		depth 	= p_parent.depth + 1;
		parent 	= p_parent;
		
		return depth;
	}
	
	public function compareTo(p_other : *) : int 
	{
		var o 	: Node 		= p_other as Node;
		var f 	: Number 	= heuristic + cost;
		var of 	: Number 	= o.heuristic + o.cost;
		
		if (f < of) 		return -1;
		else if (f > of)	return 1;
		else				return 0;
	}
}