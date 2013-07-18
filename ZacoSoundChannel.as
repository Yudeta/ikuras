package{
	
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;

	public class ZacoSoundChannel{
		private var m_channelNum:int;
		private var m_channelInfos:Array = null;
		private var m_defaultVolume:Number = 1.0;
		
		
		public function ZacoSoundChannel() {
			m_channelNum = 0;
		}
		private function Finish() : void{
		}
		
		public function InitChannelNum(n:int) : void{
			m_channelNum = n;
			m_channelInfos = new Array();
			for(var i:int=0;i<m_channelNum;i++){
				m_channelInfos.push(new ChannelInfo());
			}
		}
		
		public function SetDefaultVolume(vol:Number) : void{
			m_defaultVolume = vol;
		}
		public function GetDefaultVolume() : Number{
			return m_defaultVolume;
		}
		
		
		// @param	loopStartTime	[ms]
		public function PlaySound(channelId:int, sound:Sound, isLoop:Boolean=false, loopStartTime:Number=0) : void{
			StopSound(channelId);

			var trans:SoundTransform = new SoundTransform();
			trans.volume = m_defaultVolume;

			m_channelInfos[channelId].m_sound = sound;
			if(isLoop){
				// 自前のループ再生よりもシステム側に頼った方が安定していると考えるので、Sound::play()に頼る。
				// 完全な無限ループではないが、十分多いループ回数なので良しとする。
				m_channelInfos[channelId].m_soundChannel = sound.play(loopStartTime, int.MAX_VALUE, trans);
			}else{
				m_channelInfos[channelId].m_soundChannel = sound.play(0, 0, trans);
			}
		}
		public function StopSound(channelId:int) : void{
			if(m_channelInfos[channelId].m_soundChannel != null){
				m_channelInfos[channelId].m_soundChannel.stop();
				m_channelInfos[channelId].m_soundChannel = null;
				m_channelInfos[channelId].m_sound = null;
			}
		}
/*
		// 自前無限ループをやるなら
		m_channelInfos[channelId].m_loopStartTime = loopStartTime;
		m_channelInfos[channelId].m_soundChannel.addEventListener(Event.SOUND_COMPLETE, onCompleteLoopSound(channelId));
		
		private function onCompleteLoopSound(channelId:int):Function
		{
			return function(event:Event):void
			{
				m_channelInfos[channelId].m_soundChannel = m_channelInfos[channelId].m_sound.play();
			}
		}
*/
		public function StopAll() : void{
			for(var i:int=0;i<m_channelNum;i++){
				StopSound(i);
			}
		}
		
		
		public function SetVolume(channelId:int, vol:Number) : void{
			if(m_channelInfos[channelId].m_soundChannel != null){
				var transform:SoundTransform = m_channelInfos[channelId].m_soundChannel.soundTransform;
				transform.volume = vol;
				m_channelInfos[channelId].m_soundChannel.soundTransform = transform;
			}
        }
		public function GetVolume(channelId:int) : Number{
			if(m_channelInfos[channelId].m_soundChannel != null){
				var transform:SoundTransform = m_channelInfos[channelId].m_soundChannel.soundTransform;
				return transform.volume;
			}
			return -1;
        }
		public function SetVolumeAll(vol:Number) : void{
			for(var i:int=0;i<m_channelNum;i++){
				SetVolume(i, vol);
			}
		}
    }
}


import flash.media.Sound;
import flash.media.SoundChannel;

class ChannelInfo{
	public var m_sound:Sound = null;
	public var m_soundChannel:SoundChannel = null;
	//public var m_isLoop:Boolean = false;
	//public var m_loopStartTime:Number = 0;
	
	public function ChannelInfo(){
		m_sound = null;
		m_soundChannel = null;
		//m_isLoop = false;
		//m_loopStartTime = 0;
	}
}