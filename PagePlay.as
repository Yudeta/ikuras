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
		private var m_salmonNum:SalmonNum;
		private var m_salmonJumps:Array;
		private var m_gameover:Gameover;
		
		private var m_score:int;
		private var m_level:int;
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
			m_level = 0;
			m_nextBlockType = UtilityFunc.xRandomInt(0, BlockType.Num - 1);
			
			m_bg.SetStage(m_level + 1);
			m_salmonNum.SetNum(m_score);
			
			StartGameLoop();
			StartInput();
		}
		public override function End():void
		{
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
			if(100 <= m_gameLoopTimer.GetElapsedTime()){
				m_gameLoopTimer.Start();
				
				var posX:int = UtilityFunc.xRandomInt(0, m_tetrisField.GetW() - 1);
				var posY:int = UtilityFunc.xRandomInt(0, m_tetrisField.GetH() - 1);
				m_tetrisField.SetBlock(posX, posY, 1);
	
				m_fieldBitmap.Update(m_tetrisField);
			}
		}
		

		
		//----------------------------
		// マウス入力
		//----------------------------
		private function StartInput():void
		{
			GetStage().addEventListener(MouseEvent.CLICK, OnClick);
			GetStage().addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
			GetStage().addEventListener(KeyboardEvent.KEY_UP, OnKeyUp);
		}
		private function EndInput():void
		{
			GetStage().removeEventListener(MouseEvent.CLICK, OnClick);
			GetStage().removeEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
			GetStage().removeEventListener(KeyboardEvent.KEY_UP, OnKeyUp);
		}
		private function OnClick(e:MouseEvent):void{
			SetNextPage(new PageEnding());
		}
		
		private function OnKeyDown(event:KeyboardEvent){
			if(event.keyCode == KeyCode.Left){
				UtilityFunc.Trace("down a");
			}
		}
		private function OnKeyUp(event:KeyboardEvent){
			if(event.keyCode == KeyCode.Left){
				UtilityFunc.Trace("up a");
			}
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
	function Update(tetrisField:TetrisField):void{
		var screenRect:Rectangle = new Rectangle(0, 0, ViewSizeW, ViewSizeH);
		m_viewBitmapData.fillRect(screenRect, 0xf04040);
		
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
}

class TetrisField{
	private var m_fieldW:int;
	private var m_fieldH:int;
	private var m_field:Array;
	
	const StateNone:int = 0;
	const StateBlock:int = 1;
	
	public function TetrisField(){
	}
	
	//10x20
	public function InitSize(fieldW:int, fieldH:int) : void{
		m_fieldW = fieldW;
		m_fieldH = fieldH;
		m_field = new Array(m_fieldW * m_fieldH);
		for(var i:int=0;i<m_field.length;i++){
			m_field[i] = StateNone;
		}
	}
	public function SetBlock(posX:int, posY:int, blockState:int) : void{
		m_field[posX * posY * m_fieldW] = blockState;
	}
	public function GetBlock(posX:int, posY:int) : int{
		return m_field[posX * posY * m_fieldW];
	}
	public function GetW() : int{
		return m_fieldW;
	}
	public function GetH() : int{
		return m_fieldH;
	}
	
	public function Start() : void{
	}
	public function End() : void{
		m_field = null;
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
		m_mc.visible = false;
	}
	public function End() : void{
	}
	
	public function SetActive(b:Boolean) : void{
		if(b){
			m_mc.visible = true;
			m_mc.gotoAndPlay(1);
		}else{
			m_mc.visible = false;
		}
	}
}

