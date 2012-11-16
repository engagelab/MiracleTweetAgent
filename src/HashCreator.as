package
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	import listeners.HashCreatorEvent;
	
	public class HashCreator extends EventDispatcher {
		
		private var tweetBody:String;
		private var foundTags:Array;
		private var fromUser:String;
		private var tweetServiceUrl:String;
		private var hashTags:Array;
		
		private var postedTweet:Object;
		
		/**
		 * 
		 * Constructor
		 * 
		 **/ 
		public function HashCreator(target:IEventDispatcher=null) {
			super(target);
		}
		
		
		/**
		 * 
		 * Static method to post a tweet
		 * 
		 **/
		public function postHashToService(bdy:String, from:String, tweetServiceUrl:String, hashTags:Array):void {
			this.hashTags = hashTags;
			this.tweetBody = bdy;
			this.fromUser = from;
			this.tweetServiceUrl = tweetServiceUrl;
			this.foundTags = getTagsForContent(bdy);
			
			if(foundTags.length > 0) {
				postTweetForTag(foundTags.pop());
			}
			else {
				var ioev:HashCreatorEvent = new HashCreatorEvent(HashCreatorEvent.NO_HASH_FOUND, true);
				dispatchEvent(ioev);
			}
		}
		
		protected function postTweetForTag(tag:String):void {
			var extractedOwnerName:String = extractOwner(tweetBody).toLowerCase();
			
			var urlRequest:URLRequest = new URLRequest(tweetServiceUrl);
			urlRequest.method = URLRequestMethod.POST;
			urlRequest.contentType = "application/json";
			var params:Object = new Object();
			params.userName = cleanResource(fromUser.toLowerCase());
			params.ownerName = extractedOwnerName;
			params.text = tweetBody;
			params.xpos = 0;
			params.ypos = 0;
			params.isVisible = true;
			params.isPortfolio = false;
			params.source = false;
			params.tag = tag.substr(1);
			urlRequest.data = com.adobe.serialization.json.JSON.encode(params);
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, completeHandler);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.load(urlRequest);
		}
		
		/**
		 * 
		 * Function to return the owner of the tweet, based on the JSON object
		 * 
		 **/
		protected function extractOwner(message:String):String {
			var owner:String = "";
			
			try {
				var res:Object = com.adobe.serialization.json.JSON.decode(message);
				owner = new String(res.ownerName);
			}
			catch(error:Error) {
			}
			
			return owner;
		}
		
		/**
		 * 
		 * Function to return a clean "from" user (without '-UID')
		 * 
		 **/
		protected function cleanResource(initialFrom:String):String {
			initialFrom = initialFrom.split("-")[0];
			return initialFrom;
		}
		
		/**
		 * 
		 * extract the tags from the tweet content
		 * 
		 **/
		protected function getTagsForContent(message:String):Array {
			var tags:Array = new Array();

			for each (var tag:String in hashTags) {
				trace(message.indexOf(tag));
				if(message.indexOf(tag) > -1 && tags.indexOf(tag) == -1) {
					tags.push(tag);
				}
			}
			
			return tags;
		}
		
		/**
		 * 
		 * Event handler for Event.COMPLETE
		 * 
		 **/
		protected function completeHandler(evt:Event):void {
			var ioev:HashCreatorEvent = new HashCreatorEvent(HashCreatorEvent.POST_SUCCESSFUL, true);
			ioev.result = evt.target.data;
			dispatchEvent(ioev);
			
			if(foundTags.length > 0) {
				postTweetForTag(foundTags.pop());
			}
			else {
				var ioev:HashCreatorEvent = new HashCreatorEvent(HashCreatorEvent.NO_HASH_FOUND, true);
				dispatchEvent(ioev);
			}
		}
		
		/**
		 * 
		 * Event handler for HTTPStatusEvent.HTTP_STATUS
		 * 
		 **/
		protected function httpStatusHandler(evt:HTTPStatusEvent):void {
			trace("TweetUpdater httpStatusHandler: "+evt.status);
		}
		
		/**
		 * 
		 * Event handler for IOErrorEvent.IO_ERROR
		 * 
		 **/
		protected function ioErrorHandler(evt:IOErrorEvent):void {
			var ioev:HashCreatorEvent = new HashCreatorEvent(HashCreatorEvent.POST_FAILED, true);
			ioev.result = evt.errorID;
			dispatchEvent(ioev);
		}
	}
}