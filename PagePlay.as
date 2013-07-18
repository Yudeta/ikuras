package  {

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.utils.getTimer;
	import flash.events.Event;
	
	
	public class PagePlay extends PageBase {
		private var m_tetrisField:TetrisField;
		private var m_fieldBitmap:FieldBitmap;
		private var m_bg:Bg;
		private var m_blockPiece:BlockPiece;
		private var m_salmonNum:SalmonNum;
		private var m_salmonJumps:Array;
		private var m_gameover:Gameover;
		
		private var m_score:int;
		private var m_level:int; // 1～
		private var m_nextBlockType:int;
		
		public function PagePlay() {
		}

		//----------------------------
		// 以下、override必要
		//----------------------------
		public override function Start():void
		{
			GetMainClass().gotoAndStop("play");

			m_tetrisField = new TetrisField();
			m_tetrisField.InitSize(10, 20);
			m_tetrisField.Start();
			
			m_fieldBitmap = new FieldBitmap();
			m_fieldBitmap.Init(GetMainClass().blockFieldRoot, 160, 18);
			
			m_bg = new Bg();
			m_bg.InitMc(GetMainClass().playBg);
			m_bg.Start();
			
			m_blockPiece = new BlockPiece();
			m_blockPiece.SetPieceType(BlockPiece.PieceType_I);
			m_blockPiece.SetRotType(BlockPiece.RotType_0);
			m_blockPiece.SetPosition(0, 0);
			
			m_salmonNum = new SalmonNum();
			m_salmonNum.InitMc(GetMainClass().salmonNumDisp);
			m_salmonNum.Start();
			
			m_salmonJumps = new Array();
			var jumpPosList:Array = [360, 240, 120, 0];
			for(var i:int=0;i<4;i++){
				var salmonJump:SalmonJump = new SalmonJump();
				salmonJump.InitMC(GetMainClass().salmonJumpRoot, new SalmonJumpEffect(), jumpPosList[i], 242);
				salmonJump.Start();
				m_salmonJumps.push(salmonJump);
				salmonJump.Play();
			}
			
			m_gameover = new Gameover();
			m_gameover.InitMc(GetMainClass().gameoverDisp);
			m_gameover.Start();
			
			m_score = 1;
			m_level = 1;
			m_nextBlockType = UtilityFunc.xRandomInt(0, BlockType.Num - 1);
			
			m_bg.SetStage(m_level + 1);
			m_salmonNum.SetNum(m_score);
			
			StartPieceMove();
			StartGameLoop();
			StartInput();
			
			GenerateNewPiece();
		}
		public override function End():void
		{
			EndGameover();
			
			EndPieceMove();
			EndGameLoop();
			EndInput();
			
			m_gameover.End();
			m_gameover = null;
			
			for(var i:int=0;i<4;i++){
				m_salmonJumps[i].End();
				m_salmonJumps[i] = null;
			}
			m_salmonJumps = null;
			
			m_bg.End();
			m_bg = null;
			
			m_fieldBitmap.End();
			m_fieldBitmap = null;
			
			m_blockPiece.End();
			m_blockPiece = null;
			
			m_tetrisField.End();
			m_tetrisField = null;
		}
		

		//----------------------------
		// ゲームループ
		//----------------------------
		private var m_gameLoopTimer:GameTimer;
		
		private function StartGameLoop() : void{
			m_gameLoopTimer = new GameTimer();
			m_gameLoopTimer.Start();
			
			addEventListener(Event.ENTER_FRAME, OnEnterFrameGameLoop);
		}
		private function EndGameLoop() : void{
			removeEventListener(Event.ENTER_FRAME, OnEnterFrameGameLoop);
			
			m_gameLoopTimer = null;
		}
		private function OnEnterFrameGameLoop(event:Event):void
		{
			UpdatePieceMove(m_blockPiece);
			
			m_fieldBitmap.Clear();
			m_fieldBitmap.Update(m_tetrisField);
			m_fieldBitmap.UpdatePiece(m_blockPiece);
		}
		
		//----------------------------
		// ゲームオーバー処理
		//----------------------------
		static const GameoverAnimTime:int = 4 * 1000;
		
		private var m_gameoverTimer:GameTimer;
		
		private function StartGameover():void
		{
			EndGameLoop();
			
			m_gameover.Play();
			
			m_gameoverTimer = new GameTimer();
			m_gameoverTimer.Start();
			
			addEventListener(Event.ENTER_FRAME, OnEnterFrameGameover);
			
		}
		private function EndGameover():void
		{
			removeEventListener(Event.ENTER_FRAME, OnEnterFrameGameover);
			
			m_gameoverTimer = null;
		}
		private function OnEnterFrameGameover(event:Event):void
		{
			if(GameoverAnimTime <= m_gameoverTimer.GetElapsedTime()){
				EndGameover();
				
				SetNextPage(new PageEnding());
			}
		}
		
		//----------------------------
		// ピース生成
		//----------------------------
		private function GenerateNewPiece():void
		{
			var blockType:int = m_nextBlockType;

			m_blockPiece.SetPieceType(blockType);
			m_blockPiece.SetRotType(BlockPiece.RotType_0);
			m_blockPiece.SetPosition(3, 0);

			m_nextBlockType = UtilityFunc.xRandomInt(0, BlockType.Num - 1);
		}

		//----------------------------
		// ピース移動
		//----------------------------
		static const PieceMoveFastDownTime:int = 40; // 早く落とす入力時の落ちる時間[ms]
		static const PieceMoveAutoDownTime_0:int = 500; // 自動でピースが一段落ちる時間[ms]
		static const PieceMoveAutoDownTime_1:int = 300; // 自動でピースが一段落ちる時間[ms]
		static const PieceMoveAutoDownTime_2:int = 100; // 自動でピースが一段落ちる時間[ms]
		private var m_pieceMoveTimer:GameTimer;
		
		private function StartPieceMove():void{
			m_pieceMoveTimer = new GameTimer();
			m_pieceMoveTimer.Start();
		}
		private function EndPieceMove():void{
			m_pieceMoveTimer = null;
		}
		private function UpdatePieceMove(blockPiece:BlockPiece):void{
			// 時間で落下
			var downTime:int;
			
			if(IsDownKeyDown()){
				downTime = PieceMoveFastDownTime;
			}else{
				if(m_level <= 5){
					downTime = PieceMoveAutoDownTime_0;
				}else if(m_level < 10){
					downTime = PieceMoveAutoDownTime_1;
				}else{
					downTime = PieceMoveAutoDownTime_2;
				}
			}
			if(downTime <= m_pieceMoveTimer.GetElapsedTime()){
				m_pieceMoveTimer.Start();
				
				var oldPosX:int = blockPiece.GetPositionX();
				var oldPosY:int = blockPiece.GetPositionY();
				blockPiece.SetPosition(oldPosX, oldPosY + 1);
				if(CheckHit(m_tetrisField, m_blockPiece)){
					// 真下にブロックがあったら戻して定着
					blockPiece.SetPosition(oldPosX, oldPosY);
					FixPieceOnField(m_tetrisField, m_blockPiece);
					
					//trace("fix" + oldPosX + "," + oldPosY);
					// ★列が揃った判定
					//DumpField(m_tetrisField);
					
					// 次のピース生成
					GenerateNewPiece();
					
					//生成していきなりヒットしていたらゲームオーバー
					if(CheckHit(m_tetrisField, m_blockPiece)){
						StartGameover();
					}
				}
			}
		}
		private function MovePiece(addX:int, addY:int, blockPiece:BlockPiece):void
		{
			var oldPosX:int = blockPiece.GetPositionX();
			var oldPosY:int = blockPiece.GetPositionY();
			blockPiece.SetPosition(oldPosX + addX, oldPosY + addY);
			if(CheckHit(m_tetrisField, m_blockPiece)){
				blockPiece.SetPosition(oldPosX, oldPosY);
			}
		}
		private function RotatePiece(rotRight:Boolean = true):void
		{
			if(rotRight){
				m_blockPiece.RotateRight();
				if(CheckHit(m_tetrisField, m_blockPiece)){
					m_blockPiece.RotateLeft();
				}
			}else{
				m_blockPiece.RotateLeft();
				if(CheckHit(m_tetrisField, m_blockPiece)){
					m_blockPiece.RotateRight();
				}
			}
		}
		
		//----------------------------
		// ピースをフィールドに定着
		//----------------------------
		private function FixPieceOnField(tetrisField:TetrisField, blockPiece:BlockPiece):void
		{
			var fieldW:int = tetrisField.GetW();
			var fieldH:int = tetrisField.GetH();
			
			var pieceX0:int = blockPiece.GetPositionX();
			var pieceY0:int = blockPiece.GetPositionY();
			var pieceX1:int = blockPiece.GetPositionX() + blockPiece.GetW() - 1;
			var pieceY1:int = blockPiece.GetPositionY() + blockPiece.GetH() - 1;
			pieceX0 = Math.max(0, pieceX0);
			pieceY0 = Math.max(0, pieceY0);
			pieceX1 = Math.min(fieldW - 1, pieceX1);
			pieceY1 = Math.min(fieldH - 1, pieceY1);
			
			for(var yi:int=0;yi<=pieceY1-pieceY0;yi++){
				var ypos:int = pieceY0 + yi;
				for(var xi:int=0;xi<=pieceX1-pieceX0;xi++){
					var xpos:int = pieceX0 + xi;
					if(blockPiece.GetBlock(xi,yi) == 1){
						tetrisField.SetBlock(xpos, ypos, TetrisField.StateBlock);
					}
				}
			}
		}
/*		private function DumpField(tetrisField:TetrisField):void
		{
			var fieldW:int = tetrisField.GetW();
			var fieldH:int = tetrisField.GetH();
			trace("-----------------");
			for(var yi:int=0;yi<fieldH;yi++){
				var rows:String = "";
				for(var xi:int=0;xi<fieldW;xi++){
					rows += tetrisField.GetBlock(xi,yi);
				}
				trace(rows);
			}
		}*/
		//----------------------------
		// ピースとブロックのヒット
		//----------------------------
		// @return	true:hit
		private function CheckHit(tetrisField:TetrisField, blockPiece:BlockPiece):Boolean
		{
			var fieldW:int = tetrisField.GetW();
			var fieldH:int = tetrisField.GetH();
			
			var pieceX0:int = blockPiece.GetPositionX();
			var pieceY0:int = blockPiece.GetPositionY();
			var pieceX1:int = blockPiece.GetPositionX() + blockPiece.GetW() - 1;
			var pieceY1:int = blockPiece.GetPositionY() + blockPiece.GetH() - 1;
			
			for(var yi:int=0;yi<=pieceY1-pieceY0;yi++){
				var ypos:int = pieceY0 + yi;
				for(var xi:int=0;xi<=pieceX1-pieceX0;xi++){
					var xpos:int = pieceX0 + xi;
					if(blockPiece.GetBlock(xi, yi) == 1){
						if(ypos < 0 || fieldH <= ypos || xpos < 0 || fieldW <= xpos){
							return true;
						}
						if(tetrisField.GetBlock(xpos, ypos) == 1){
							return true;
						}
					}
				}
			}
			return false;
		}
		
		//----------------------------
		// 入力
		//----------------------------
		private var m_isDownKeyDown:Boolean;
		private var m_isDownKeyUp:Boolean;
		private var m_isDownKeyLeft:Boolean;
		private var m_isDownKeyRight:Boolean;
		
		private function StartInput():void
		{
			m_isDownKeyDown = false;
			m_isDownKeyUp = false;
			m_isDownKeyLeft = false;
			m_isDownKeyUp = false;
			GetStage().addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
			GetStage().addEventListener(KeyboardEvent.KEY_UP, OnKeyUp);
		}
		private function EndInput():void
		{
			GetStage().removeEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
			GetStage().removeEventListener(KeyboardEvent.KEY_UP, OnKeyUp);
		}
		
		private function OnKeyDown(event:KeyboardEvent):void{
			if(event.keyCode == KeyCode.Left){
				if(m_isDownKeyLeft == false){
					m_isDownKeyLeft = true;
					MovePiece(-1, 0, m_blockPiece);
				}
			}
			if(event.keyCode == KeyCode.Right){
				if(m_isDownKeyRight == false){
					m_isDownKeyRight = true;
					MovePiece(1, 0, m_blockPiece);
				}
			}
			if(event.keyCode == KeyCode.Up){
				if(m_isDownKeyUp == false){
					m_isDownKeyUp = true;
					RotatePiece();
				}
			}
			if(event.keyCode == KeyCode.Down){
				if(m_isDownKeyDown == false){
					m_isDownKeyDown = true;
					MovePiece(0, 1, m_blockPiece);
				}
			}
		}
		private function OnKeyUp(event:KeyboardEvent){
			if(event.keyCode == KeyCode.Down){
				m_isDownKeyDown = false;
			}else if(event.keyCode == KeyCode.Up){
				m_isDownKeyUp = false;
			}else if(event.keyCode == KeyCode.Left){
				m_isDownKeyLeft = false;
			}else if(event.keyCode == KeyCode.Right){
				m_isDownKeyRight = false;
			}
		}
		private function IsDownKeyDown():Boolean{
			return m_isDownKeyDown;
		}
	}
}


import flash.display.MovieClip;
import flash.text.TextField;
import flash.events.Event;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

class FieldBitmap{
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
	function Update(tetrisField:TetrisField):void{
		var w:int = tetrisField.GetW();
		var h:int = tetrisField.GetH();
		for(var yi:int=0;yi<h;yi++){
			for(var xi:int=0;xi<w;xi++){
				if(tetrisField.GetBlock(xi,yi) == 1){
					var ikuraBitmap:BitmapData = new IkuraBlock01(0, 0);
					var point:Point = new Point(xi * BlockW, yi * BlockH);
					var rect:Rectangle = new Rectangle(0, 0, BlockW, BlockH);
					m_viewBitmapData.copyPixels(ikuraBitmap, rect, point);
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
				if(blockPiece.GetBlock(xi, yi) == 1){
					var ikuraBitmap:BitmapData = new IkuraBlock01(0, 0);
					var point:Point = new Point((xo+xi) * BlockW, (yo+yi) * BlockH);
					var rect:Rectangle = new Rectangle(0, 0, BlockW, BlockH);
					m_viewBitmapData.copyPixels(ikuraBitmap, rect, point);
				}
			}
		}
	}
}


class Bg{
	private var m_mc:MovieClip;
	
	public function Bg(){
	}
	
	public function InitMc(mc:MovieClip) : void{
		m_mc = mc;
	}
	// @param	stageIndex	1..5
	public function Start():void
	{
	}
	public function End() : void{
	}
	
	// @param	stageIndex	1..5
	public function SetStage(stageIndex:int):void
	{
		m_mc.gotoAndStop(stageIndex);
	}
}

class SalmonNum{
	private var m_mc:TextField;
	
	public function SalmonNum(){
	}
	
	public function InitMc(mc:TextField) : void{
		m_mc = mc;
	}
	public function Start():void
	{
	}
	public function End() : void{
	}
	
	public function SetNum(num:int):void
	{
		m_mc.text = String(num);
	}
}

class SalmonJump{
	private var m_mc:MovieClip = null;
	private var m_parentMc:MovieClip = null;
	
	public function SalmonJump(){
	}
	
	public function InitMC(parentMc:MovieClip, mc:MovieClip, posX:Number, posY:Number) : void{
		m_parentMc = parentMc;
		m_mc = mc;
		m_parentMc.addChild(m_mc);
		m_mc.x = posX;
		m_mc.y = posY;
	}
	public function Start() : void{
		Stop();
	}
	public function End() : void{
		if(m_mc != null && m_parentMc != null){
			Stop();
			m_parentMc.removeChild(m_mc);
			m_mc = null;
			m_parentMc = null;
		}
	}
	
	public function Play() : void{
		m_mc.addEventListener("onMovieComp", onComp);
		m_mc.gotoAndPlay(1);
		m_mc.visible = true;
	}
	public function Stop() : void{
		m_mc.stop();
		m_mc.visible = false;
	}
	private function onComp(e:Event):void
	{
		m_mc.removeEventListener("onMovieComp", onComp);
		
		Stop();
	}
}

class Gameover{
	private var m_mc:MovieClip;
	
	public function Gameover(){
	}
	
	public function InitMc(mc:MovieClip) : void{
		m_mc = mc;
	}
	public function Start() : void{
		Stop();
	}
	public function End() : void{
	}
	
	public function Play() : void{
		m_mc.addEventListener("onMovieComp", onComp);
		m_mc.gotoAndPlay(1);
		m_mc.visible = true;
	}
	public function Stop() : void{
		m_mc.stop();
		m_mc.visible = false;
	}
	private function onComp(e:Event):void
	{
		m_mc.removeEventListener("onMovieComp", onComp);
		
		Stop();
	}
}

