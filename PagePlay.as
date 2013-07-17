package  {

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	
	
	public class PagePlay extends PageBase {
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
			
			StartInput();
		}
		public override function End():void
		{
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

