package starling.core
{
	import flash.geom.Matrix3D;

	public class MatrixStack {
		
		private var freeIndex:uint = 0;
		private const stack:Vector.<Matrix3D> = new Vector.<Matrix3D>();
		
		public function MatrixStack() {
		}
		
		public function pushCopy(matrix:Matrix3D):void {
			if (freeIndex == stack.length) {
				stack.push(matrix.clone());
			} else {
				stack[freeIndex].copyFrom(matrix);
			}
			
			freeIndex++;
		}
		
		public function popCopy(destination:Matrix3D):void {
			freeIndex--;
			return stack[freeIndex].copyToMatrix3D(destination);
		}
		
		public function reset():void {
			freeIndex = 0;
		}
		
		public function get length():uint {
			return stack.length;
		}
	}
}