package starling.events
{
	import starling.core.Starling;

	public class StarlingChangedEvent extends Event
	{
		public static const CHANGED:String = "starling_changed"
		
		private var mOldStarling:Starling
		private var mNewStarling:Starling;
		
		public function StarlingChangedEvent(type:String, oldStarling:Starling, newStarling:Starling, bubbles:Boolean=false)
		{
			super(type, bubbles);
			mOldStarling = oldStarling;
			mNewStarling = newStarling;
		}
		
		public function get oldStarling():Starling 
		{
			return oldStarling;
		}
		
		public function get newStarling():Starling 
		{
			return mNewStarling;
		}
	}
}