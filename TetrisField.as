package {
	
	public class TetrisField{
		private var m_fieldW:int;
		private var m_fieldH:int;
		private var m_field:Array;
		
		static const StateNone:int = 0;
		static const StateBlock:int = 1;
		
		public function TetrisField(){
		}
		
		//10x20
		public function InitSize(fieldW:int, fieldH:int) : void{
			m_fieldW = fieldW;
			m_fieldH = fieldH;
			m_field = new Array(m_fieldW * m_fieldH);
			for(var i:int=0;i<m_field.length;i++){
				m_field[i] = StateNone;
			}
		}
		public function SetBlock(posX:int, posY:int, blockState:int) : void{
			m_field[posX + posY * m_fieldW] = blockState;
		}
		public function GetBlock(posX:int, posY:int) : int{
			return m_field[posX + posY * m_fieldW];
		}
		public function GetW() : int{
			return m_fieldW;
		}
		public function GetH() : int{
			return m_fieldH;
		}
		
		public function Start() : void{
		}
		public function End() : void{
			m_field = null;
		}
	}

}