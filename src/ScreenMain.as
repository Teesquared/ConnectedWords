package
{
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * ScreenMain
	 * 
	 * Copyright (c) 2014, Twisted Words, LLC
	 *
	 * @author Tony Tyson (teesquared@twistedwords.net)
	 */
	public class ScreenMain extends MovieClip
	{
		private var dragArea:Sprite;
		private var orderedWords:Vector.<Word> = null;
		private var isDragging:Boolean = false;
		private var rightWords:Array = null;
		private var cw:ConnectedWords;

		/**
		 * ScreenMain
		 */
		public function ScreenMain()
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

			dragArea = new Sprite();
			addChild(dragArea);

			buttonConnect.addEventListener(MouseEvent.CLICK, connectClicked);

			updateStats();

			if (cw.tweet == null || cw.tweet.text == null || cw.tweet.text.length == 0) {
				trace("Invalid tweet!");
				cw.gotoAndStop("loading");
				return;
			}

			startGame(cw.tweet.text);

			//startGame("FOOBAR.");
			//startGame("FOO BAR.");
			//startGame("THIS IS A TESTTESTTEST.");
			//startGame("THIS IS A FOO BAR TESTTESTTEST.");

			//startGame("THIS IS A FOO\r\rBAR TESTTESTTEST.");
			//startGame("THIS IS A FOO\n\rBAR TESTTESTTEST. http://pbs.twimg.com/small.jpeg");
			//startGame("A B C D E F G H I J K L M N O P Q R S T U V W 1 2 3 4 5 6 7 8 9 0.");
			//startGame("A B C D E F G H I J K L M N O P Q R S T U V W 1 2 3 4 5 6 7 8 9 0. A B C D E F G H I J K L M N O P Q R S T U V W 1 2 3 4 5 6 7 8 9 0.");
		}

		/**
		 * updateStats
		 */
		private function updateStats():void
		{
			score.htmlText = "<B>" + cw.score + "</B>";
			retries.htmlText = "<B>" + cw.retries + "</B>";
		}

		/**
		 * updateSentence
		 */
		private function updateSentence():void
		{
			orderedWords = null;

			for (var i:uint = 0; i < dragArea.numChildren; ++i)
			{
				var word:Word = dragArea.getChildAt(i) as Word;

				if (!word)
					continue;

				if (!orderedWords) {
					orderedWords = new Vector.<Word>();
					orderedWords.push(word);
				}
				else {
					for (var j:uint = 0; j < orderedWords.length; ++j) {
						const ow:Word = orderedWords[j];
						//trace(word, " -> ", orderedWords.join(", "));

						const sameRow:Boolean = Math.abs(ow.y - word.y) < 32;

						if (sameRow && ow.x > word.x)
							break;

						if (!sameRow && ow.y > word.y)
							break;
					}

					orderedWords.splice(j, 0, word);
					//trace("updateSentence", j);
				}
			}

			//sentenceText.text = orderedWords.join(" ");
			sentenceText.htmlText = "<B>" + orderedWords.join(" ") + "</B>";

			drawConnections();
		}

		/**
		 * drawConnections
		 */
		private function drawConnections():void
		{
			var g:Graphics = dragArea.graphics;

			g.clear();

			g.lineStyle(1, 0x8bb0ff);

			for (var i:uint = 0; i < orderedWords.length; ++i) {
				const w:Word = orderedWords[i];

				if (i == 0) {
					g.moveTo(w.x + w.width / 2, w.y + w.height / 2);
				}
				else {
					g.lineTo(w.x + w.width / 2, w.y + w.height / 2);
				}
			}
		}

		/**
		 * groupRightWords
		 */
		private function groupRightWords():void
		{
			var groupedWords:Array = new Array();

			while (rightWords.length > 1) {
				var oneMore:Boolean = rightWords.length > 2 && Math.random() < 0.2;

				groupedWords.push(rightWords.shift() + " " + rightWords.shift() + (oneMore ? " " + rightWords.shift() : ""));
			}

			rightWords = groupedWords.concat(rightWords);
		}

		/**
		 * startGame
		 *
		 * @param	sentence
		 */
		private function startGame(sentence:String):void
		{
			trace(this, "start", "[" + sentence + "]");

			sentence = sentence.replace(/http\S*/g, "[LINK]");
			sentence = sentence.replace(/[\r\n]+/g, " ");

			trace(this, "start", "[" + sentence + "]");

			rightWords = sentence.split(' ');

			if (rightWords.length > 10)
				groupRightWords();

			var words:Array = rightWords.concat();

			var x:uint = 32;
			var y:uint = 80;

			for (var i:uint = 0; i < words.length; ++i) {
				const j:uint = Math.random() * words.length;

				if (i != j) {
					var tmp:String = words[i];
					words[i] = words[j];
					words[j] = tmp;
				}
			}

			for (var k:uint = 0; k < words.length; ++k) {
				var w:String = words[k];
				var word:Word = new Word();

				if (k && k % 6 == 0) {
					x += 64
					y = 80;
					if (k % 12 != 0)
						y += 24;
				}

				word.x = x;
				word.y = y;

				y += 48;

				dragArea.addChild(word);

				word.setText(w);

				//word.addEventListener(MouseEvent.CLICK, wordClicked);
				word.addEventListener(MouseEvent.MOUSE_DOWN, wordDrag);
				word.addEventListener(MouseEvent.MOUSE_UP, wordDrop);

				addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			}

			updateSentence();
		}

		/**
		 * mouseMove
		 *
		 * @param	e
		 */
		private function mouseMove(e:MouseEvent):void 
		{
			if (isDragging) {
				updateSentence();
			}
		}
		
		/**
		 * wordClicked
		 *
		 * @param	e
		 */
		private function wordClicked(e:MouseEvent):void 
		{
			var word:Word = e.target as Word;
			trace(e.target);
			if (word) {
				trace(word.getOriginalText());
			}
		}

		/**
		 * wordDrag
		 *
		 * @param	e
		 */
		private function wordDrag(e:MouseEvent):void 
		{
			var word:Word = e.target as Word;
			//trace(e.target);
			if (word) {
				dragArea.addChild(word);
				word.startDrag();
				isDragging = true;
			}
		}

		/**
		 * wordDrop
		 * 
		 * @param	e
		 */
		private function wordDrop(e:MouseEvent):void 
		{
			var word:Word = e.target as Word;
			//trace(e.target);
			if (word) {
				word.stopDrag();
				isDragging = false;
				updateSentence();
			}
		}

		/**
		 * connectClicked
		 *
		 * @param	e
		 */
		private function connectClicked(e:MouseEvent):void 
		{
			if (checkSentence()) {
				cw.score += rightWords.length;

				if ( (++cw.games % 5) == 0 )
					++cw.retries;

				cw.gotoAndStop("tweet");
			}
			else {
				if (--cw.retries == 0)
					cw.gotoAndStop("tweet"); // game over
			}

			updateStats();
		}

		/**
		 * checkSentence
		 *
		 * @return
		 */
		private function checkSentence():Boolean
		{
			var result:Boolean = true;

			for (var i:uint = 0; i < rightWords.length; ++i) {
				var word:Word = orderedWords[i];
				var text:String = word.getOriginalText();

				if (rightWords[i] != text) {
					result = false;

					var offset:uint = Math.abs(i - rightWords.indexOf(text));
					var lm2:int = rightWords.length - 2;
					var percent:Number = lm2 > 0 ? (offset - 1) / lm2 : 0;

					word.drawBackgroundRect(100 - 50 * percent);
				}
				else {
					word.drawBackgroundRect(0);
				}
				
			}

			return result;
		}
	}
}
