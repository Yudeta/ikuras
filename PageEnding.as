package  {

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	
	
	public class PageEnding extends PageBase {

		static const ResultMode0:int = 0;
		static const ResultMode1:int = 1;
		static const ResultMode2:int = 2;
		private var m_resultMode:int;
		
		static const InputEnableTime:int = 1 * 1000;
		private var m_gameTimer:GameTimer;
		
		public function PageEnding() {
		}
		
		//----------------------------
		// リザルトモード設定
		//----------------------------
		public function SetResultMode(resultMode:int):void{
			m_resultMode = resultMode;
		}

		//----------------------------
		// 以下、override必要
		//----------------------------
		public override function Start():void
		{
			GetMainClass().gotoAndStop("ending");
			
			GetMainClass().endingScene.resultScene0.visible = false;
			GetMainClass().endingScene.resultScene1.visible = false;
			GetMainClass().endingScene.resultScene2.visible = false;
				
			if(m_resultMode == ResultMode0){
				GetMainClass().endingScene.resultScene0.visible = true;
				GetMainClass().endingScene.resultScene0.gotoAndPlay(1);
			}else if(m_resultMode == ResultMode1){
				GetMainClass().endingScene.resultScene1.visible = true;
				GetMainClass().endingScene.resultScene1.gotoAndPlay(1);
			}else{
				GetMainClass().endingScene.resultScene2.visible = true;
				GetMainClass().endingScene.resultScene2.gotoAndPlay(1);
			}
			m_gameTimer = new GameTimer();
			m_gameTimer.Start();
			
			GetMainClass().GetSoundChannel().PlaySound(ikuras.SoundChannelBgm, new SoundResult(), true);
			
			GetStage().addEventListener(MouseEvent.CLICK, OnClickTitleStartButton);
			GetStage().addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
		}
		public override function End():void
		{
			GetMainClass().GetSoundChannel().StopSound(ikuras.SoundChannelBgm);
			
			m_gameTimer = null;
			
			GetStage().removeEventListener(MouseEvent.CLICK, OnClickTitleStartButton);
			GetStage().removeEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
		}
		
		//----------------------------
		private function OnClickTitleStartButton(e:MouseEvent):void{
			Nextpage();
		}
		private function OnKeyDown(event:KeyboardEvent):void{
			Nextpage();
		}
		private function Nextpage():void{
			if(InputEnableTime <= m_gameTimer.GetElapsedTime()){
				SetNextPage(new PageTitle());
			}
		}
		
	}
	
}
