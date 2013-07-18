package {

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class FieldBitmap{
		const ViewSizeW:int = 16 * 10;
		const ViewSizeH:int = 16 * 20;
		const BlockW:int = 16;
		const BlockH:int = 16;
		private var m_parentMC:MovieClip;
		private var m_viewBitmapData:BitmapData;
		private var m_viewBitmap:Bitmap;
			
		public function FieldBitmap(){
		}
		function Init(parentMC:MovieClip, posX:Number, posY:Number):void{
			m_parentMC = parentMC;
			
			m_viewBitmapData = new BitmapData(ViewSizeW, ViewSizeH, false, 0x000000);  // 不透明赤色のBitmapDataを作る
			m_viewBitmap = new Bitmap();
			m_viewBitmap.bitmapData = m_viewBitmapData; // new Bitmap(bitmapData)としてもいい。
			m_parentMC.addChild(m_viewBitmap);
			m_viewBitmap.x = posX;
			m_viewBitmap.y = posY;
		}
		function End():void{
			m_parentMC.removeChild(m_viewBitmap);
			m_viewBitmapData = null;
			m_viewBitmap = null;
		}
		function Clear():void{
			var screenRect:Rectangle = new Rectangle(0, 0, ViewSizeW, ViewSizeH);
			m_viewBitmapData.fillRect(screenRect, 0x000000);
		}
		function CreateIkuraBitmap(type:int):BitmapData{
			var ikuraBitmap:BitmapData = null;
			switch(type){
				case 1:
					ikuraBitmap = new IkuraBlock01(0, 0);
					break;
				case 2:
					ikuraBitmap = new IkuraBlock02(0, 0);
					break;
				case 3:
					ikuraBitmap = new IkuraBlock03(0, 0);
					break;
				case 4:
					ikuraBitmap = new IkuraBlock04(0, 0);
					break;
				case 5:
					ikuraBitmap = new IkuraBlock05(0, 0);
					break;
				case 6:
					ikuraBitmap = new IkuraBlock06(0, 0);
					break;
				case 7:
				default:
					ikuraBitmap = new IkuraBlock07(0, 0);
					break;
			}
			return ikuraBitmap;
		}
		function Update(tetrisField:TetrisField):void{
			var w:int = tetrisField.GetW();
			var h:int = tetrisField.GetH();
			for(var yi:int=0;yi<h;yi++){
				for(var xi:int=0;xi<w;xi++){
					var type:int = tetrisField.GetBlock(xi,yi);
					if(0 < type){
						if(type < TetrisField.FlagHide){
							var ikuraBitmap:BitmapData = CreateIkuraBitmap(type);
							var point:Point = new Point(xi * BlockW, yi * BlockH);
							var rect:Rectangle = new Rectangle(0, 0, BlockW, BlockH);
							m_viewBitmapData.copyPixels(ikuraBitmap, rect, point);
						}
					}
				}
			}
		}
		function UpdatePiece(blockPiece:BlockPiece):void{
			var xo = blockPiece.GetPositionX();
			var yo = blockPiece.GetPositionY();
			
			var w:int = blockPiece.GetW();
			var h:int = blockPiece.GetH();
			
			for(var yi:int=0;yi<h;yi++){
				for(var xi:int=0;xi<w;xi++){
					var type:int = blockPiece.GetBlock(xi,yi);
					if(0 < type){
						var ikuraBitmap:BitmapData = CreateIkuraBitmap(type);
						var point:Point = new Point((xo+xi) * BlockW, (yo+yi) * BlockH);
						var rect:Rectangle = new Rectangle(0, 0, BlockW, BlockH);
						m_viewBitmapData.copyPixels(ikuraBitmap, rect, point);
					}
				}
			}
		}
	}
}