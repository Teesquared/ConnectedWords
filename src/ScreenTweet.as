package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.globalization.DateTimeFormatter;
	import flash.globalization.DateTimeStyle;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;

	/**
	 * ScreenTweet
	 * 
	 * Copyright (c) 2014, Twisted Words, LLC
	 *
	 * @author Tony Tyson (teesquared@twistedwords.net)
	 */
	public class ScreenTweet extends MovieClip
	{
		private static var createAtFormatter:DateTimeFormatter = new DateTimeFormatter("en-US", DateTimeStyle.MEDIUM, DateTimeStyle.SHORT);
		private static var createAtDate:Date = new Date();

		private var cw:ConnectedWords;

		/**
		 * ScreenTweet
		 */
		public function ScreenTweet()
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

			buttonBack.addEventListener(MouseEvent.CLICK, backClicked);
			buttonOpen.addEventListener(MouseEvent.CLICK, openClicked);

			profileImage.mask = profileImage.getChildAt(0);
			profileImage.addChild(cw.profileBitmap);

			const tweet:Object = cw.tweet;

			userName.htmlText = "<B>" + tweet.user.name + "</B>";

			screenName.htmlText = "<B>@" + tweet.user.screen_name + "</B>";

			if (tweet.retweeted_by != null)
				retweetedBy.text = "Retweeted by " + tweet.retweeted_by;
			else
				retweetedBy.text = "";

			createAtDate.setTime(Date.parse(tweet.created_at));

			tweetDate.text = createAtFormatter.format(createAtDate);

			tweetText.htmlText = "<B>" + tweet.text + "</B>";
		}

		/**
		 * backClicked
		 *
		 * @param	e
		 */
		private function backClicked(e:MouseEvent):void 
		{
			if (cw.isGameInProgress()) {
				if (cw.pickRandomTweet()) {
					cw.gotoAndStop("main");
				}
				else {
					cw.loadTweetPack();
				}
			}
			else {
				cw.gotoAndStop("gameOver");
			}
		}

		/**
		 * openClicked
		 *
		 * @param	e
		 */
		private function openClicked(e:MouseEvent):void 
		{
			const tweet:Object = ConnectedWords.CW.tweet;

			var path:URLRequest = new URLRequest("https://twitter.com/" + tweet.user.screen_name + "/status/" + tweet.id_str);
			path.method = URLRequestMethod.GET;

			navigateToURL(path, "_blank");
		}
	}
}
