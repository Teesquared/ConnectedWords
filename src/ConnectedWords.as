package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.utils.ByteArray;

	/**
	 * ConnectedWords
	 * 
	 * Copyright (c) 2014, Twisted Words, LLC
	 *
	 * @author Tony Tyson (teesquared@twistedwords.net)
	 */
	public class ConnectedWords extends MovieClip
	{
		public static var CW:ConnectedWords;

		public static const VERSION:String = "2";

		public var tweet:Object = null;
		public var score:uint = 0;
		public var retries:uint = 5;
		public var games:uint = 0;

		public var defaultProfileBitmapData:BitmapData = new DefaultProfileImage();
		public var profileBitmap:Bitmap = new Bitmap(defaultProfileBitmapData);

		private var tweetPack:Array = null;
		private var tweetPackNum:uint = 0;

		public var errorText:String = null;

		/**
		 * ConnectedWords
		 */
		public function ConnectedWords()
		{
			//trace(this);

			CW = this;

			tweetPackNum = 1000 * Math.random();

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

			// broken yay
			//Security.loadPolicyFile("http://pbs.twimg.com/crossdomain.xml");

			loadTweetPack();
		}

		/**
		 * loadTweetPack
		 */
		public function loadTweetPack():void
		{
			var url:String = "http://www.twistedwords.net/getTweetPack.php?i=1&v=1&n=" + (tweetPackNum++ % 1000);

			var urlRequest:URLRequest = new URLRequest(url);

			var urlLoader:URLLoader = new URLLoader();

			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;

			urlLoader.addEventListener(Event.COMPLETE, tweetPackLoadCompleted);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, tweetPackLoadFailed);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, tweetPackLoadFailed);

			try {
				urlLoader.load(urlRequest);
			}
			catch (error:Error) {
				tweetPackLoadFailed(null);
			}

			gotoAndStop("loading");
		}

		/**
		 * tweetPackLoadCompleted
		 * 
		 * @param	e
		 */
		private function tweetPackLoadCompleted(e:Event):void 
		{
			var urlLoader:URLLoader = e.target as URLLoader;

			if (!urlLoader) {
				tweetPackLoadFailed(null);
				return;
			}

			var bytes:ByteArray = urlLoader.data as ByteArray;

			if (!bytes) {
				tweetPackLoadFailed(null);
				return;
			}

			try {
				bytes.uncompress();

				tweetPack = JSON.parse(bytes.toString()) as Array;
			}
			catch (error:Error) {
				tweetPackLoadFailed(null);
				return;
			}

			if (!pickRandomTweet()) {
				tweetPackLoadFailed(null);
				return;
			}

			if (currentLabel == "loading") {
				if (isGameInProgress())
					gotoAndStop("main");
				else {
					resetGame();
					gotoAndStop("title");
				}
			}
		}

		/**
		 * profileImageLoadCompleted
		 *
		 * @param	e
		 */
		private function profileImageLoadCompleted(e:Event):void 
		{
			var loader:Loader = e.target.loader as Loader;

			if (!loader)
				return;

			const bitmap:Bitmap = loader.content as Bitmap;

			if (!bitmap)
				return;

			profileBitmap.bitmapData = bitmap.bitmapData;

			const size:uint = 96;

			var needsResize:Boolean = true;

			if (profileBitmap.width == size && profileBitmap.height <= size) {
				needsResize = false;
			}

			if (profileBitmap.height == size && profileBitmap.width <= size) {
				needsResize = false;
			}

			if (profileBitmap.width > profileBitmap.height && needsResize) {
				profileBitmap.height = profileBitmap.height / profileBitmap.width * size;
				profileBitmap.width = size;
			}
			else if (needsResize) {
				profileBitmap.width = profileBitmap.width / profileBitmap.height * size;
				profileBitmap.height = size;
			}

			profileBitmap.x = (size - profileBitmap.width) * 0.5;
			profileBitmap.y = (size - profileBitmap.height) * 0.5;
		}

		/**
		 * tweetPackLoadFailed
		 *
		 * @param	e
		 */
		private function tweetPackLoadFailed(e:Event):void 
		{
			trace("tweetPackLoadFailed");

			// this needs to only be called when we are in loading frame
			//gotoAndStop("loading");

			errorText = "<B>\nError!!!\n\nPlease refresh your browser or restart the app to try again.</B>";

			if (screenLoading) {
				screenLoading.displayText.htmlText = errorText;
			}
		}

		/**
		 * pickRandomTweet
		 * 
		 * @return true if valid tweet picked
		 */
		public function pickRandomTweet():Boolean
		{
			tweet = null;

			if (!tweetPack || tweetPack.length == 0)
				return false;

			var pick1:uint = tweetPack.length * Math.random();

			var tweets:Array = tweetPack[pick1];

			if (!tweets || tweets.length == 0)
				return false;

			var pick2:uint = tweets.length * Math.random();

			tweet = tweets[pick2];

			if (!tweet) {
				return false;
			}

			if (tweet.retweeted_status != null) {
				//trace(this, "pickRandomTweet", "retweet");
				tweet.retweeted_status.retweeted_by = tweet.user.name;
				tweet = tweet.retweeted_status;
			}

			tweets.splice(pick2, 1);

			if (tweets.length == 0)
				tweetPack.splice(pick1, 1);

			profileBitmap.bitmapData = defaultProfileBitmapData;

			var loader:Loader = new Loader();
			var imageUrl:String = tweet.user.profile_image_url.replace("_normal", "_reasonably_small");
			trace(imageUrl);
			var request:URLRequest = new URLRequest("http://www.twistedwords.net/ld30/twimg_proxy.php?url=" + imageUrl);

			try {
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, profileImageLoadCompleted);
				loader.load(request);
			}
			catch (e:Error) {
				trace(this, "pickRandomTweet", e.message);
			}

			return true;
		}

		/**
		 * resetGame
		 */
		public function resetGame():void
		{
			score = 0;
			retries = 5;
			games = 0;
		}

		/**
		 * isGameInProgress
		 *
		 * @return
		 */
		public function isGameInProgress():Boolean 
		{
			return score > 0 && retries > 0;
		}
	}
}
