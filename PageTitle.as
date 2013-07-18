package  {

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	
	
	public class PageTitle extends PageBase {
		
		public function PageTitle() {
		}

		//----------------------------
		// 以下、override必要
		//----------------------------
		public override function Start():void
		{
			GetMainClass().gotoAndStop("title");
			GetMainClass().titlePlayButton.play();
			
			GetStage().addEventListener(MouseEvent.CLICK, OnClickTitleStartButton);
			GetStage().addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
		}
		public override function End():void
		{
			GetStage().removeEventListener(MouseEvent.CLICK, OnClickTitleStartButton);
			GetStage().removeEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
		}
		
		//----------------------------
		private function OnClickTitleStartButton(e:MouseEvent):void{
			NextPage();
		}
		private function OnKeyDown(event:KeyboardEvent):void{
			NextPage();
		}
		private function NextPage():void{
			GetMainClass().GetSoundChannel().PlaySound(ikuras.SoundChannelSe, new SoundStart());
			SetNextPage(new PagePlay());
		}
	}
	
}
