package
{
	import flash.display.Sprite;
	import flash.text.TextField;

	/**
	 * Word
	 * 
	 * Copyright (c) 2014, Twisted Words, LLC
	 *
	 * @author Tony Tyson (teesquared@twistedwords.net)
	 */
	public class Word extends Sprite
	{
		private var originalText:String = null;

		/**
		 * Word
		 */
		public function Word()
		{
			textField.mouseEnabled = false;

			buttonMode = true;
			useHandCursor = true;
		}

		/**
		 * drawBackgroundRect
		 * 
		 * @param	isWrong
		 */
		public function drawBackgroundRect(percentRed:uint)
		{
			var color:uint = 0x8bb0ff;  // 0xFF00FF #0066FF

			if (percentRed) {
				if (percentRed > 100)
					percentRed = 100;

				const r:uint = 0xff * percentRed / 100;
				const g:uint = 0x44 * percentRed / 100;
				const b:uint = 0x39 * percentRed / 100;

				color = r << 16 | g << 8 | b;
			}

			hitArea.graphics.beginFill(color);
			hitArea.graphics.drawRoundRect(1, 1, textField.width - 2, textField.height - 2, 14);
			hitArea.graphics.endFill();
		}

		/**
		 * setText
		 * 
		 * @param	text
		 */
		public function setText(text:String):void
		{
			//trace(this, textField, text);

			originalText = text;
			textField.htmlText = text;
			textField.width = textField.textWidth + 4; // gutter

			var hitRect:Sprite = new Sprite();

			hitRect.graphics.beginFill(0x0);
			hitRect.graphics.drawRoundRect(0, 0, textField.width, textField.height, 16);
			hitRect.graphics.endFill();

			hitArea = hitRect;
			drawBackgroundRect(0);
			/*
			hitRect.graphics.beginFill(0x8bb0ff); // 0xFF00FF #0066FF
			hitRect.graphics.drawRoundRect(1, 1, textField.width - 2, textField.height - 2, 14);
			hitRect.graphics.endFill();
			*/

			hitRect.mouseEnabled = false;
			hitRect.visible = true; // false;

			addChildAt(hitRect, 0);
		}

		/**
		 * getOriginalText
		 *
		 * @return
		 */
		public function getOriginalText():String
		{
			return originalText;
		}

		/**
		 * toString
		 * @return
		 */
		override public function toString():String 
		{
			return textField.text; // + " (" + x + "," + y + ")";
		}
	}
}
