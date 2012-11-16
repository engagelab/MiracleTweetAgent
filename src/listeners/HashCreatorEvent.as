package listeners
{
	import flash.events.Event;
	
	public class HashCreatorEvent extends Event
	{
		public static const POST_SUCCESSFUL:String = "POST_SUCCESSFUL";
		public static const POST_FAILED:String = "POST_FAILED";
		public static const NO_HASH_FOUND:String = "NO_HASH_FOUND";
		
		public var result:Object;
		
		public function HashCreatorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}