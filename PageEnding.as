package  {

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	
	
	public class PageEnding extends PageBase {
		
		public function PageEnding() {
		}

		//----------------------------
		// 以下、override必要
		//----------------------------
		public override function Start():void
		{
			GetMainClass().gotoAndStop("ending");
			
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
			SetNextPage(new PageTitle());
		}
		private function OnKeyDown(event:KeyboardEvent):void{
			SetNextPage(new PageTitle());
		}
	}
	
}
