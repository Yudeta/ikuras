package  {

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.utils.getTimer;
	import flash.events.Event;
	
	
	public class PagePlay extends PageBase {
		private var m_tetrisField:TetrisField;
		private var m_fieldBitmap:FieldBitmap;
		private var m_nextPieceBitmap:NextPieceBitmap
		private var m_bg:Bg;
		private var m_blockPiece:BlockPiece;
		private var m_nextBlockPiece:BlockPiece;
		private var m_salmonNum:SalmonNum;
		private var m_levelNum:LevelNum;
		private var m_salmonJumps:Array;
		private var m_lineBreakEffect:Array;
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
			
			m_nextPieceBitmap = new NextPieceBitmap();
			m_nextPieceBitmap.Init(GetMainClass().blockFieldRoot, 380, 50);
			
			m_bg = new Bg();
			m_bg.InitMc(GetMainClass().playBg);
			m_bg.Start();
			
			m_blockPiece = new BlockPiece();
			m_blockPiece.SetPieceType(BlockPiece.PieceType_I);
			m_blockPiece.SetRotType(BlockPiece.RotType_0);
			m_blockPiece.SetPosition(0, 0);
			
			m_nextBlockPiece = new BlockPiece();
			m_nextBlockPiece.SetPieceType(BlockPiece.PieceType_I);
			m_nextBlockPiece.SetRotType(BlockPiece.RotType_0);
			m_nextBlockPiece.SetPosition(0, 0);
			
			m_salmonNum = new SalmonNum();
			m_salmonNum.InitMc(GetMainClass().salmonNumDisp);
			m_salmonNum.Start();
			
			m_levelNum = new LevelNum();
			m_levelNum.InitMc(GetMainClass().levelDisp);
			m_levelNum.Start();
			
			InitLineBreakEffect();
			
			var i:int;
			
			m_salmonJumps = new Array();
			var jumpPosList:Array = [360, 240, 120, 0];
			for(i=0;i<4;i++){
				var salmonJump:SalmonJump = new SalmonJump();
				salmonJump.InitMC(GetMainClass().salmonJumpRoot, new SalmonJumpEffect(), jumpPosList[i], 242);
				salmonJump.Start();
				m_salmonJumps.push(salmonJump);
				//salmonJump.Play();
			}
			m_lineBreakEffect = new Array();
			var lineBreakInstList:Array = [GetMainClass().lineBreakEffect1, GetMainClass().lineBreakEffect2, GetMainClass().lineBreakEffect3, GetMainClass().lineBreakEffect4];
			for(i=0;i<4;i++){
				var lineBreakEffect:LineBreakEffect = new LineBreakEffect();
				lineBreakEffect.InitMC(lineBreakInstList[i]);
				lineBreakEffect.Start();
				m_lineBreakEffect.push(lineBreakEffect);
			}
			
			m_gameover = new Gameover();
			m_gameover.InitMc(GetMainClass().gameoverDisp);
			m_gameover.Start();
			
			m_score = 0;
			m_level = 1;
			m_nextBlockType = UtilityFunc.xRandomInt(0, BlockType.Num - 1);
			m_nextBlockPiece.SetPieceType(m_nextBlockType);
			m_nextPieceBitmap.UpdatePiece(m_nextBlockPiece);
			
			m_bg.SetStage(m_level);
			m_levelNum.SetNum(m_level);
			m_salmonNum.SetNum(m_score);
			
			StartPieceMove();
			StartGameLoop();
			StartInput();
			
			GenerateNewPiece();
			
			GetMainClass().GetSoundChannel().PlaySound(ikuras.SoundChannelBgm, new SoundBgm(), true);
		}
		public override function End():void
		{
			GetMainClass().GetSoundChannel().StopSound(ikuras.SoundChannelBgm);
			EndGameover();
			
			EndPieceMove();
			EndGameLoop();
			EndInput();
			
			m_gameover.End();
			m_gameover = null;
			
			var i:int;
			
			for(i=0;i<4;i++){
				m_salmonJumps[i].End();
				m_salmonJumps[i] = null;
			}
			m_salmonJumps = null;
			
			for(i=0;i<4;i++){
				m_lineBreakEffect[i].End();
				m_lineBreakEffect[i] = null;
			}
			m_lineBreakEffect = null;
			
			m_bg.End();
			m_bg = null;
			
			m_salmonNum.End();
			m_salmonNum = null;
			
			m_levelNum.End();
			m_levelNum = null;
			
			m_fieldBitmap.End();
			m_fieldBitmap = null;
			
			m_nextPieceBitmap.End();
			m_nextPieceBitmap = null;
			
			m_blockPiece.End();
			m_blockPiece = null;
			
			m_nextBlockPiece.End();
			m_nextBlockPiece = null;
			
			m_tetrisField.End();
			m_tetrisField = null;
		}
		

		//----------------------------
		// ゲームループ
		//----------------------------
		private var m_isPauseGameLoop:Boolean;
		private var m_gameLoopTimer:GameTimer;
		
		private function StartGameLoop() : void{
			m_gameLoopTimer = new GameTimer();
			m_gameLoopTimer.Start();
			
			m_isPauseGameLoop = false;
			
			addEventListener(Event.ENTER_FRAME, OnEnterFrameGameLoop);
		}
		private function EndGameLoop() : void{
			removeEventListener(Event.ENTER_FRAME, OnEnterFrameGameLoop);
			
			m_gameLoopTimer = null;
		}
		private function OnEnterFrameGameLoop(event:Event):void
		{
			UpdatePieceMove(m_blockPiece);
			UpdateLineBreakEffect();
			
			m_fieldBitmap.Clear();
			m_fieldBitmap.Update(m_tetrisField);
			if(!IsPauseGameLoop()){
				m_fieldBitmap.UpdatePiece(m_blockPiece);
			}
		}
		private function PauseGameLoop(b:Boolean):void
		{
			// ゲーム処理は停止し、描画だけは行う
			m_isPauseGameLoop = b;
		}
		private function IsPauseGameLoop():Boolean
		{
			return m_isPauseGameLoop;
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
			
			GetMainClass().GetSoundChannel().PlaySound(ikuras.SoundChannelSe, new SoundGameover());
			
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
				
				var page:PageEnding = new PageEnding();
				if(m_level <= 5){
					page.SetResultMode(PageEnding.ResultMode0);
				}else if(m_level < 10){
					page.SetResultMode(PageEnding.ResultMode1);
				}else{
					page.SetResultMode(PageEnding.ResultMode2);
				}
				SetNextPage(page);
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
			m_nextBlockPiece.SetPieceType(m_nextBlockType);
			m_nextPieceBitmap.UpdatePiece(m_nextBlockPiece);
		}

		//----------------------------
		// ピース移動
		//----------------------------
		static const PieceMoveFastDownTime:int = 40; // 早く落とす入力時の落ちる時間[ms]
		static const PieceMoveAutoDownTime_0:int = 500; // 自動でピースが一段落ちる時間[ms]
		static const PieceMoveAutoDownTime_1:int = 400; // 自動でピースが一段落ちる時間[ms]
		static const PieceMoveAutoDownTime_2:int = 300; // 自動でピースが一段落ちる時間[ms]
		static const PieceMoveAutoDownTime_3:int = 200; // 自動でピースが一段落ちる時間[ms]
		static const PieceMoveAutoDownTime_4:int = 100; // 自動でピースが一段落ちる時間[ms]
		private var m_pieceMoveTimer:GameTimer;
		
		private function StartPieceMove():void{
			m_pieceMoveTimer = new GameTimer();
			m_pieceMoveTimer.Start();
		}
		private function EndPieceMove():void{
			m_pieceMoveTimer = null;
		}
		private function UpdatePieceMove(blockPiece:BlockPiece):void{
			if(IsPauseGameLoop() == false){
				// 時間で落下
				var downTime:int;
				
				if(IsDownKeyDown()){
					downTime = PieceMoveFastDownTime;
				}else{
					if(m_level <= 2){
						downTime = PieceMoveAutoDownTime_0;
					}else if(m_level <= 5){
						downTime = PieceMoveAutoDownTime_1;
					}else if(m_level <= 7){
						downTime = PieceMoveAutoDownTime_2;
					}else if(m_level < 10){
						downTime = PieceMoveAutoDownTime_3;
					}else{
						downTime = PieceMoveAutoDownTime_4;
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
						
						var breakCount:int = CountBreakableLine(m_tetrisField);
						if(0 < breakCount){
							StartLineBreakEffect(breakCount);
						/*	m_score += breakCount;
							m_salmonNum.SetNum(m_score);
							
							m_level = Math.min(10, Math.floor(m_score/3) + 1);
							m_bg.SetStage(m_level);
							m_levelNum.SetNum(m_level);
							
							for(var i:int=0;i<breakCount;i++){
								m_salmonJumps[i].Play();
							}
							m_lineBreakEffect[breakCount - 1].Play();*/
						}else{
							NewPiece();
						}
					}
				}
			}
		}
		private function NewPiece():void
		{
			// 次のピース生成
			GenerateNewPiece();
			
			//生成していきなりヒットしていたらゲームオーバー
			if(CheckHit(m_tetrisField, m_blockPiece)){
				StartGameover();
			}
		}
		private function MovePiece(addX:int, addY:int, blockPiece:BlockPiece):void
		{
			if(IsPauseGameLoop() == false){
				var oldPosX:int = blockPiece.GetPositionX();
				var oldPosY:int = blockPiece.GetPositionY();
				blockPiece.SetPosition(oldPosX + addX, oldPosY + addY);
				if(CheckHit(m_tetrisField, m_blockPiece)){
					blockPiece.SetPosition(oldPosX, oldPosY);
				}
			}
		}
		private function RotatePiece(rotRight:Boolean = true):void
		{
			if(IsPauseGameLoop() == false){
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
				GetMainClass().GetSoundChannel().PlaySound(ikuras.SoundChannelSe, new SoundRot());
			}
		}
		
		//----------------------------
		// ライン消し演出
		//----------------------------
		private var m_lineBreakFunction:Function;
		private var m_lineBreakCount:int;
		private var m_lineBreakBlinkFlag:Boolean;
		private var m_lineBreakTimer:GameTimer;
		static const LineBreakBlinkTime:int = 500; //[ms]
		
		private function InitLineBreakEffect():void
		{
			m_lineBreakFunction = null;
		}
		private function StartLineBreakEffect(lineBreakCount:int):void
		{
			m_lineBreakFunction = UpdateLineBreakEffect0;
			m_lineBreakCount = lineBreakCount;
			PauseGameLoop(true);
			
			m_lineBreakBlinkFlag = true;
			m_lineBreakTimer = new GameTimer();
			m_lineBreakTimer.Start();
		}
		private function EndLineBreakEffect():void
		{
			m_score += m_lineBreakCount;
			m_salmonNum.SetNum(m_score);
			
			m_level = Math.min(10, Math.floor(m_score/3) + 1);
			m_bg.SetStage(m_level);
			m_levelNum.SetNum(m_level);
			
			m_lineBreakFunction = null;
			m_lineBreakTimer = null;
			
			PauseGameLoop(false);
			NewPiece();
		}
		private function UpdateLineBreakEffect():void
		{
			if(m_lineBreakFunction != null){
				m_lineBreakFunction();
			}
		}
		private function UpdateLineBreakEffect0():void
		{
			for(var i:int=0;i<m_lineBreakCount;i++){
				m_salmonJumps[i].Play();
			}
			GetMainClass().GetSoundChannel().PlaySound(ikuras.SoundChannelSe, new SoundJump());
			
			UpdateLineBreakBlink();
			
			m_lineBreakFunction = UpdateLineBreakEffect1;
		}
		private function UpdateLineBreakEffect1():void
		{
			UpdateLineBreakBlink();
			
			if(m_salmonJumps[0].IsPlay() == false){
				m_lineBreakEffect[m_lineBreakCount - 1].Play();
				m_lineBreakFunction = UpdateLineBreakEffect2;
				GetMainClass().GetSoundChannel().PlaySound(ikuras.SoundChannelSe, new SoundShake());
			}
		}
		private function UpdateLineBreakEffect2():void
		{
			UpdateLineBreakBlink();
			
			if(m_lineBreakEffect[m_lineBreakCount - 1].IsPlay() == false){
				BreakLine(m_tetrisField);
				EndLineBreakEffect();
			}
		}
		private function UpdateLineBreakBlink():void
		{
			if(LineBreakBlinkTime <= m_lineBreakTimer.GetElapsedTime()){
				m_lineBreakBlinkFlag = !m_lineBreakBlinkFlag;
				BlinkBreakableLine(m_tetrisField, m_lineBreakBlinkFlag);
				m_lineBreakTimer.Start();
			}
		}
		
		//----------------------------
		// ラインが揃っていたら壊す処理
		//----------------------------
		private function CutLine(tetrisField:TetrisField, ypos:int):void
		{
			var fieldW:int = tetrisField.GetW();
			var fieldH:int = tetrisField.GetH();
			var xi:int;
			var yi:int;
			
			for(yi=ypos;0<yi;yi--){
				var upperY:int = yi - 1;
				for(xi=0;xi<fieldW;xi++){
					tetrisField.SetBlock(xi, yi, tetrisField.GetBlock(xi, upperY));
				}
			}
			for(xi=0;xi<fieldW;xi++){
				tetrisField.SetBlock(xi, 0, TetrisField.StateNone);
			}
		}
		private function BreakLine(tetrisField:TetrisField):int
		{
			var breakCount:int = 0;
			var fieldW:int = tetrisField.GetW();
			var fieldH:int = tetrisField.GetH();
			
			for(var yi:int=fieldH-1;0<=yi;){
				var count:int = 0;
				for(var xi:int=0;xi<fieldW;xi++){
					if(0 < tetrisField.GetBlock(xi,yi)){
						count++;
					}
				}
				if(count == fieldW){
					CutLine(tetrisField, yi);
					breakCount++;
				}else{
					yi--;
				}
			}
			return breakCount;
		}
		private function CountBreakableLine(tetrisField:TetrisField):int
		{
			var breakCount:int = 0;
			var fieldW:int = tetrisField.GetW();
			var fieldH:int = tetrisField.GetH();
			
			for(var yi:int=0;yi<fieldH;yi++){
				var count:int = 0;
				for(var xi:int=0;xi<fieldW;xi++){
					if(0 < tetrisField.GetBlock(xi,yi)){
						count++;
					}
				}
				if(count == fieldW){
					breakCount++;
				}
			}
			return breakCount;
		}
		private function BlinkBreakableLine(tetrisField:TetrisField, isVisible:Boolean):void
		{
			var fieldW:int = tetrisField.GetW();
			var fieldH:int = tetrisField.GetH();
			
			for(var yi:int=0;yi<fieldH;yi++){
				var count:int = 0;
				var xi:int;
				for(xi=0;xi<fieldW;xi++){
					if(0 < tetrisField.GetBlock(xi,yi)){
						count++;
					}
				}
				if(count == fieldW){
					for(xi=0;xi<fieldW;xi++){
						var type = tetrisField.GetBlock(xi,yi);
						if(isVisible){
							if(TetrisField.FlagHide <= type){
								tetrisField.SetBlock(xi,yi, type - TetrisField.FlagHide);
							}
						}else{
							if(type < TetrisField.FlagHide){
								tetrisField.SetBlock(xi,yi, type + TetrisField.FlagHide);
							}
						}
					}
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
			
			for(var yi:int=0;yi<=pieceY1-pieceY0;yi++){
				var ypos:int = pieceY0 + yi;
				for(var xi:int=0;xi<=pieceX1-pieceX0;xi++){
					var xpos:int = pieceX0 + xi;
					
					if(ypos < 0 || fieldH <= ypos || xpos < 0 || fieldW <= xpos){
						continue;
					}
					
					var type:int = blockPiece.GetBlock(xi,yi);
					if(0 < type){
						tetrisField.SetBlock(xpos, ypos, type);
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
					if(0 < blockPiece.GetBlock(xi, yi)){
						if(ypos < 0 || fieldH <= ypos || xpos < 0 || fieldW <= xpos){
							return true;
						}
						if(0 < tetrisField.GetBlock(xpos, ypos)){
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


class Bg{
	private var m_mc:MovieClip;
	
	public function Bg(){
	}
	
	public function InitMc(mc:MovieClip) : void{
		m_mc = mc;
	}
	public function Start():void
	{
	}
	public function End() : void{
	}
	
	// @param	stageIndex	1..10
	public function SetStage(stageIndex:int):void
	{
		m_mc.gotoAndStop(stageIndex);
	}
}


class LevelNum{
	private var m_mc:TextField;
	
	public function LevelNum(){
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
	
	public function IsPlay() : Boolean{
		return m_mc.visible;
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

class LineBreakEffect{
	private var m_mc:MovieClip = null;
	private var m_parentMc:MovieClip = null;
	
	public function LineBreakEffect(){
	}
	
	public function InitMC(mc:MovieClip) : void{
		m_mc = mc;
	}
	public function Start() : void{
		Stop();
	}
	public function End() : void{
		if(m_mc != null){
			Stop();
			m_mc = null;
		}
	}
	
	public function IsPlay() : Boolean{
		return m_mc.visible;
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

