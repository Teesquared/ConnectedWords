package
{
	import flash.display.MovieClip;
	import flash.events.Event;

	/**
	 * ScreenLoading
	 * 
	 * Copyright (c) 2014, Twisted Words, LLC
	 *
	 * @author Tony Tyson (teesquared@twistedwords.net)
	 */
	public class ScreenLoading extends MovieClip
	{
		private var cw:ConnectedWords;

		/**
		 * ScreenLoading
		 */
		public function ScreenLoading() {
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

			if (cw.errorText && cw.errorText.length > 0) {
				displayText.htmlText = cw.errorText;
			}
		}
	}
}
