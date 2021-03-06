// =================================================================================================
//
//	Starling Framework
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.core
{
    import flash.display3D.*;
    import flash.geom.*;
    import flash.utils.*;
    
    import starling.display.*;
    import starling.errors.*;
    import starling.utils.*;

    /** A class that contains helper methods simplifying Stage3D rendering.
     *
     *  A RenderSupport instance is passed to any "render" method of display objects. 
     *  It allows manipulation of the current transformation matrix (similar to the matrix 
     *  manipulation methods of OpenGL 1.x) and other helper methods.
     */
    public class RenderSupport
    {
        // members        
        private var mProjectionMatrix:Matrix3D;
        private var mMatrixStack:MatrixStack;
		private var mMVPMatrix:Matrix3D;
		private var mUsingPMA:Boolean = false;
		private var mBlendModeInitialized:Boolean = false;	
        
        // construction
        
        /** Creates a new RenderSupport object with an empty matrix stack. */
        public function RenderSupport()
        {
            mMatrixStack = new MatrixStack();
            mProjectionMatrix = new Matrix3D();
			mMVPMatrix = new Matrix3D();
            
            loadIdentity();
            setOrthographicProjection(400, 300);
        }
        
        // matrix manipulation
        
        /** Sets up the projection matrix for ortographic 2D rendering. */
        public function setOrthographicProjection(width:Number, height:Number, 
                                                  near:Number=-1.0, far:Number=1.0):void
        {
			// undo projection transform
			mProjectionMatrix.invert();
			mMVPMatrix.append(mProjectionMatrix);
			
            var coords:Vector.<Number> = new <Number>[                
                2.0/width, 0.0, 0.0, 0.0,
                0.0, -2.0/height, 0.0, 0.0,
                0.0, 0.0, -2.0/(far-near), 0.0,
                -1.0, 1.0, -(far+near)/(far-near), 1.0                
            ];
            
            mProjectionMatrix.copyRawDataFrom(coords);
			mMVPMatrix.append(mProjectionMatrix);
        }
        
        /** Changes the modelview matrix to the identity matrix. */
        public function loadIdentity():void
        {
			mMVPMatrix.identity();
			mMVPMatrix.append(mProjectionMatrix);
        }
        
        /** Prepends a translation to the modelview matrix. */
        public function translateMatrix(dx:Number, dy:Number, dz:Number=0):void
        {
			mMVPMatrix.prependTranslation(dx, dy, dz);
        }
        
        /** Prepends a rotation (angle in radians) to the modelview matrix. */
        public function rotateMatrix(angle:Number, axis:Vector3D=null):void
        {
			mMVPMatrix.prependRotation(angle / Math.PI * 180.0, 
				axis == null ? Vector3D.Z_AXIS : axis);
        }
        
        /** Prepends an incremental scale change to the modelview matrix. */
        public function scaleMatrix(sx:Number, sy:Number, sz:Number=1.0):void
        {
			mMVPMatrix.prependScale(sx, sy, sz);  
        }
        
        /** Prepends translation, scale and rotation of an object to the modelview matrix. */
        public function transformMatrix(object:DisplayObject):void
        {
			mMVPMatrix.prependTranslation(object.x, object.y, 0.0);
			mMVPMatrix.prependRotation(object.rotation / Math.PI * 180.0, Vector3D.Z_AXIS);
			mMVPMatrix.prependScale(object.scaleX, object.scaleY, 1.0);
			mMVPMatrix.prependTranslation(-object.pivotX, -object.pivotY, 0.0);			
        }
        
        /** Pushes the current modelview matrix to a stack from which it can be restored later. */
        public function pushMatrix():void
        {
			mMatrixStack.pushCopy(mMVPMatrix);
        }
        
        /** Restores the modelview matrix that was last pushed to the stack. */
        public function popMatrix():void
        {
			mMatrixStack.popCopy(mMVPMatrix);
        }
        
        /** Empties the matrix stack, resets the modelview matrox to the identity matrix. */
        public function resetMatrix():void
        {
            if (mMatrixStack.length != 0)
                mMatrixStack.reset();
            
            loadIdentity();
        }
		
        /** Calculates the product of modelview and projection matrix. */
        public function get mvpMatrix():Matrix3D
        {
			return mMVPMatrix;
        }
        
        /** Prepends translation, scale and rotation of an object to a custom matrix. */
        public static function transformMatrixForObject(matrix:Matrix3D, object:DisplayObject):void
        {
            matrix.prependTranslation(object.x, object.y, 0.0);
            matrix.prependRotation(object.rotation / Math.PI * 180.0, Vector3D.Z_AXIS);
            matrix.prependScale(object.scaleX, object.scaleY, 1.0);
            matrix.prependTranslation(-object.pivotX, -object.pivotY, 0.0);
        }
        
        // other helper methods
        
        /** Sets up the default blending factors, depending on the premultiplied alpha status. */
        public function setDefaultBlendFactors(premultipliedAlpha:Boolean):void
        {
			if (mBlendModeInitialized && (premultipliedAlpha == mUsingPMA))
				return;
			
            var destFactor:String = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
            var sourceFactor:String = premultipliedAlpha ? Context3DBlendFactor.ONE :
                                                           Context3DBlendFactor.SOURCE_ALPHA;
            Starling.context.setBlendFactors(sourceFactor, destFactor);
			
			mUsingPMA = premultipliedAlpha;
			mBlendModeInitialized = true;
        }
        
        /** Clears the render context with a certain color and alpha value. */
        public function clear(rgb:uint=0, alpha:Number=0.0):void
        {
            Starling.context.clear(
                Color.getRed(rgb)   / 255.0, 
                Color.getGreen(rgb) / 255.0, 
                Color.getBlue(rgb)  / 255.0,
                alpha);
        }
    }
}