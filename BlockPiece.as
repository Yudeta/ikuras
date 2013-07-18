package {
	
	public class BlockPiece {
		
		static const PieceWidth:int = 4;
		static const PieceHeight:int = 4;
		
		static const RotType_0:int = 0;
		static const RotType_90:int = 1;
		static const RotType_180:int = 2;
		static const RotType_270:int = 3;
		static const RotType_Num:int = 4;
		
		static const PieceType_I:int = 0;
		static const PieceType_O:int = 1;
		static const PieceType_S:int = 2;
		static const PieceType_Z:int = 3;
		static const PieceType_J:int = 4;
		static const PieceType_L:int = 5;
		static const PieceType_T:int = 6;
		static const PieceType_Num:int = 7;
		
		static const PieceDataI:Array = [
						 0, 0, 0, 0,
						 0, 0, 0, 0,
						 1, 1, 1, 1,
						 0, 0, 0, 0
					];
		static const PieceDataO:Array = [
						 0, 0, 0, 0,
						 0, 1, 1, 0,
						 0, 1, 1, 0,
						 0, 0, 0, 0
					];
		static const PieceDataS:Array = [
						 0, 0, 0, 0,
						 0, 1, 1, 0,
						 1, 1, 0, 0,
						 0, 0, 0, 0
					];
		static const PieceDataZ:Array = [
						 0, 0, 0, 0,
						 0, 1, 1, 0,
						 0, 0, 1, 1,
						 0, 0, 0, 0
					];
		static const PieceDataJ:Array = [
						 0, 0, 0, 0,
						 0, 1, 0, 0,
						 0, 1, 1, 1,
						 0, 0, 0, 0
					];
		static const PieceDataL:Array = [
						 0, 0, 0, 0,
						 0, 0, 1, 0,
						 1, 1, 1, 0,
						 0, 0, 0, 0
					];
		static const PieceDataT:Array = [
						 0, 0, 0, 0,
						 0, 1, 0, 0,
						 1, 1, 1, 0,
						 0, 0, 0, 0
					];
		
		private var m_pieceType:int;
		private var m_rotType:int;
		private var m_posX:int;
		private var m_posY:int;
		
		public function BlockPiece() {
			m_pieceType = PieceType_I;
			m_rotType = RotType_0;
			m_posX = m_posY = 0;
		}
		public function End() : void{
		}
		
		public function SetPieceType(pieceType:int) : void{
			m_pieceType = pieceType;
		}
		public function GetPieceType() : int{
			return m_pieceType;
		}
		public function SetRotType(rotType:int) : void{
			m_rotType = rotType;
		}
		public function GetRotType() : int{
			return m_rotType;
		}
		public function RotateRight() : void{
			m_rotType = ((m_rotType + 1) % RotType_Num);
		}
		public function RotateLeft() : void{
			m_rotType = ((m_rotType + 3) % RotType_Num);
		}
		public function SetPosition(posX:int, posY:int) : void{
			m_posX = posX;
			m_posY = posY;
		}
		public function GetPositionX() : int{
			return m_posX;
		}
		public function GetPositionY() : int{
			return m_posY;
		}
		public function GetBlock(posX:int, posY:int) : int{
			const PieceDataArray:Array = [PieceDataI, PieceDataO, PieceDataS, PieceDataZ, PieceDataJ, PieceDataL, PieceDataT];
			var targetPieceData:Array = PieceDataArray[m_pieceType];
			
			var ret:int;
			switch(m_rotType){
				case RotType_0:
					ret = targetPieceData[posX + posY * PieceWidth];
					break;
				case RotType_90:
					ret = targetPieceData[((PieceWidth - 1) - posY) + posX * PieceHeight];
					break;
				case RotType_180:
					ret = targetPieceData[((PieceWidth - 1) - posX) + ((PieceHeight - 1) - posY) * PieceWidth];
					break;
				case RotType_270:
					ret = targetPieceData[posY + ((PieceHeight - 1) - posX) * PieceWidth];
					break;
			}
			return ret;
		}
		public function GetW() : int{
			return PieceWidth;
		}
		public function GetH() : int{
			return PieceHeight;
		}

	}
}