﻿package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	
	public class ikuras extends MovieClip {
		
		
		public function ikuras() {
			stop();
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		protected function addedToStageHandler(event:Event):void
		{
			UtilityFunc.Trace("addedToStageHandler.");
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			InitApp();
		}
		//------------------------------------------------------
		public function InitApp() : void{
/*			if(Define.Release == false){
				addChild(new FPSCounter(0,0,0xff0000));
			}*/
			InitSoundChannel();
			
			StartEnterFrame();
			
			SetNextPage(new PageTitle());
		}
		public function FinishApp() : void{
			EndEnterFrame();
		}
		
		//------------------------------------------------------
		private function StartEnterFrame() : void{
			addEventListener(Event.ENTER_FRAME, OnEnterFrame);
		}
		private function EndEnterFrame() : void{
			removeEventListener(Event.ENTER_FRAME, OnEnterFrame);
		}
		private function OnEnterFrame(event:Event):void
		{
			UpdatePage();
		}
		
		//------------------------------------------------------
		static const SoundChannelBgm:int = 0;
		static const SoundChannelSe:int = 1;
		static const SoundChannelNum:int = 2;
		private var m_soundChannel:ZacoSoundChannel = null;
		
		private function InitSoundChannel() : void{
			m_soundChannel = new ZacoSoundChannel();
			m_soundChannel.InitChannelNum(SoundChannelNum);
		}
		public function GetSoundChannel() : ZacoSoundChannel{
			return m_soundChannel;
		}
		//GetSunSoundChannel().PlaySound(SoundChannelGUI, SoundFilepathTabClick);
		
		//------------------------------------------------------
		private var m_currentPage:PageBase = null;
		private var m_nextPage:PageBase = null;
		
		public function SetNextPage(page:PageBase):void
		{
			m_nextPage = page;
		}
		private function UpdatePage():void
		{
			if(m_nextPage){
				if(m_currentPage){
					m_currentPage.End();
					m_currentPage = null;
				}
				m_currentPage = m_nextPage;
				m_currentPage.SetMainClass(this);
				m_currentPage.SetStage(this.stage);
				m_currentPage.Start();
				
				m_nextPage = null;
			}
		}
	}
	
}
