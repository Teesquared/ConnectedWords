package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * ScreenGameOver
	 * 
	 * Copyright (c) 2014, Twisted Words, LLC
	 *
	 * @author Tony Tyson (teesquared@twistedwords.net)
	 */
	public class ScreenGameOver extends MovieClip
	{
		private var cw:ConnectedWords;

		/**
		 * ScreenGameOver
		 */
		public function ScreenGameOver()
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

			buttonOk.addEventListener(MouseEvent.CLICK, okClicked);

			score.htmlText = "<B>" + cw.score + "</B>";
		}

		/**
		 * okClicked
		 *
		 * @param	e
		 */
		private function okClicked(e:MouseEvent):void 
		{
			cw.resetGame();
			if (cw.pickRandomTweet()) {
				cw.gotoAndStop("title");
			}
			else {
				cw.loadTweetPack();
			}
		}
	}
}
