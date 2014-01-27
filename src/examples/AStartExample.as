package examples
{
import com.filipesilvestrim.ai.astar.*;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author ...
	 */
	[SWF(width=600, height=600)]
	public class AStartExample extends Sprite
	{
		private var map 	: GameMap 	= new GameMap();
		private var finder	: IPathFind;
		private var path 	: Path;
		
		private var tiles : Dictionary = new Dictionary();
		
		private var selectedx : int = -1;
		private var selectedy : int = -1;
		private var lastFindX : int = -1;
		private var lastFindY : int = -1;
		
		public function AStartExample() 
		{
			tiles[GameMap.TREES] 	= 0x00cc00;
			tiles[GameMap.GRASS] 	= 0x00aa00;
			tiles[GameMap.WATER] 	= 0x0000cc;
			tiles[GameMap.TANK] 	= 0xcccccc;
			tiles[GameMap.PLANE] 	= 0x888888;
			tiles[GameMap.BOAT] 	= 0x333333;
			
			finder = new AStar(map, 100, true);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, function (e : MouseEvent) : void {
				handleMousePressed(stage.mouseX, stage.mouseY);
			});
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, function (e : MouseEvent) : void {
				handleMouseMoved(stage.mouseX, stage.mouseY);
			});
			
			repaint();
		}
		
		private function handleMouseMoved(x : int , y : int ) : void
		{
			//x -= 50;
			//y -= 50;
			x /= 30;
			y /= 30;
			
			if ((x < 0) || (y < 0) || (x >= map.getWidthInTiles()) || (y >= map.getHeightInTiles())) 
				return;
			
			if (selectedx != -1) 
			{
				if ((lastFindX != x) || (lastFindY != y)) 
				{
					lastFindX = x;
					lastFindY = y;
					path = finder.findPath(new Object(), selectedx, selectedy, x, y);
					
					repaint();
				}
			}
		}
		
		private function handleMousePressed(x : int , y : int) : void
		{
			//x -= 50;
			//y -= 50;
			x /= 30;
			y /= 30;
			
			if ((x < 0) || (y < 0) || (x >= map.getWidthInTiles()) || (y >= map.getHeightInTiles())) 
				return;
			
			if (map.getUnit(x, y) != 0) 
			{
				selectedx = x;
				selectedy = y;
				lastFindX = - 1;
			}
			else 
			{
				if (selectedx != -1) 
				{
					map.clearVisited();
					path = finder.findPath(new Object(), selectedx, selectedy, x, y);
					
					if (path != null) 
					{
						
						path 			= null;
						var unit : int 	= map.getUnit(selectedx, selectedy);
						
						map.setUnit(selectedx, selectedy, 0);
						map.setUnit(x,y,unit);
						
						selectedx = x;
						selectedy = y;
						lastFindX = - 1;
					}
				}
			}
			
			repaint();
			
			
		}
		
		
		private function repaint():void
		{
			graphics.clear();
			
			// cycle through the tiles in the map drawing the appropriate
			// image for the terrain and units where appropriate
			for (var x : int = 0; x < map.getWidthInTiles(); x++) 
			{
				for (var y : int = 0; y < map.getHeightInTiles(); y++) 
				{
					graphics.beginFill(tiles[map.getTerrain(x, y)]);
					graphics.drawRect(x * GameMap.WIDTH, y * GameMap.HEIGHT, GameMap.WIDTH, GameMap.HEIGHT);
					graphics.endFill();
					
					if (map.getUnit(x, y) != 0) 
					{
						graphics.beginFill(tiles[map.getUnit(x, y)]);
						graphics.drawRect(x * GameMap.WIDTH, y * GameMap.HEIGHT, GameMap.WIDTH, GameMap.HEIGHT);
						graphics.endFill();
					}
				}
			}
			
			if(path)
			{
				var step : *;
				for	(var i : int = 0; i < path.getLength(); i++)
				{
					trace(path.getX(i) , path.getY(i))
					graphics.beginFill(0x000000, .3);
					graphics.drawRect(path.getX(i) * GameMap.WIDTH, path.getY(i) * GameMap.HEIGHT, GameMap.WIDTH, GameMap.HEIGHT);
					graphics.endFill();
				}
			}
			
			// if a unit is selected then draw a box around it
			if (selectedx != -1) 
			{
				graphics.lineStyle(2, 0xff0000, 1);
				graphics.beginFill(0x000000, 0);
				graphics.drawRect(selectedx * GameMap.WIDTH, selectedy * GameMap.HEIGHT, GameMap.WIDTH, GameMap.HEIGHT);
				graphics.endFill();
				//g.drawRect((selectedx*16)-2, (selectedy*16)-2, 19, 19);
				//g.setColor(Color.white);
				//g.drawRect((selectedx*16)-1, (selectedy*16)-1, 17, 17);
			}
			
			
		}
	}
}