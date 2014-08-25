package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * ScreenTitle
	 * 
	 * Copyright (c) 2014, Twisted Words, LLC
	 *
	 * @author Tony Tyson (teesquared@twistedwords.net)
	 */
	public class ScreenTitle extends MovieClip
	{
		private var cw:ConnectedWords;

		/**
		 * ScreenTitle
		 */
		public function ScreenTitle()
		{
			//trace(this);
			cw = parent as ConnectedWords;

			if (stage != null) {
				init(null);
			}
			else {
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}

		/**
		 * init
		 *
		 * @param	e
		 */
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);

			version.text = ConnectedWords.VERSION;

			buttonStart.addEventListener(MouseEvent.CLICK, startClicked);
		}

		/**
		 * startClicked
		 *
		 * @param	e
		 */
		private function startClicked(e:MouseEvent):void 
		{
			cw.gotoAndStop("main");
		}
	}
}
