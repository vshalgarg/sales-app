
package com.codemonks.hisabio

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.ValueAnimator
import android.app.Activity
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.os.Bundle
import android.view.View
import android.view.animation.AccelerateDecelerateInterpolator
import kotlin.math.cos
import kotlin.math.min
import kotlin.math.sin

class SplashActivity : Activity() {

    private var animator: ValueAnimator? = null
    private var hasNavigated = false

    private lateinit var splashView: SplashAnimationView

    override fun onCreate(savedInstanceState: Bundle?) {
        requestWindowFeature(
            android.view.Window.FEATURE_NO_TITLE
        )
        super.onCreate(savedInstanceState)

        window.statusBarColor = Color.WHITE
        window.navigationBarColor = Color.WHITE

        @Suppress("DEPRECATION")
        window.decorView.systemUiVisibility =
            View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR or
                    View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR

        val icon = BitmapFactory.decodeResource(
            resources,
            R.drawable.hisabio_icon_layer
        )

        val wordmark = BitmapFactory.decodeResource(
            resources,
            R.drawable.hisabio_wordmark_layer
        )

        val tagline = BitmapFactory.decodeResource(
            resources,
            R.drawable.hisabio_tagline_layer
        )

        splashView = SplashAnimationView(
            this,
            icon,
            wordmark,
            tagline
        )

        setContentView(splashView)

        startSplashAnimation()
    }

    private fun startSplashAnimation() {

        animator = ValueAnimator.ofFloat(0f, 1f).apply {

            duration = 2200L

            interpolator = AccelerateDecelerateInterpolator()

            addUpdateListener { animation ->

                splashView.progress =
                    animation.animatedValue as Float

                splashView.invalidate()
            }

            addListener(object : AnimatorListenerAdapter() {

                override fun onAnimationEnd(animation: Animator) {
                    openFlutterApp()
                }
            })

            start()
        }
    }

    private fun openFlutterApp() {

        if (hasNavigated || isFinishing) return

        hasNavigated = true

        startActivity(
            Intent(this, MainActivity::class.java).apply {
                addFlags(
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                            Intent.FLAG_ACTIVITY_SINGLE_TOP
                )
            }
        )

        overridePendingTransition(0, 0)

        finish()
    }

    override fun onDestroy() {

        animator?.cancel()
        animator = null

        if (::splashView.isInitialized) {
            splashView.release()
        }

        super.onDestroy()
    }

    @Suppress("DEPRECATION")
    override fun onBackPressed() {
        // Keep splash animation uninterrupted.
    }


    // --------------------------------------------------
    // SPLASH ANIMATION VIEW
    // --------------------------------------------------

    private class SplashAnimationView(
        context: android.content.Context,
        private val iconBitmap: Bitmap,
        private val wordmarkBitmap: Bitmap,
        private val taglineBitmap: Bitmap
    ) : View(context) {

        var progress = 0f

        private val imagePaint =
            Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG)

        private val ringPaint =
            Paint(Paint.ANTI_ALIAS_FLAG).apply {

                style = Paint.Style.STROKE
                strokeWidth = 3f
                strokeCap = Paint.Cap.ROUND
                color = Color.rgb(160, 90, 255)
            }

        private val glowPaint =
            Paint(Paint.ANTI_ALIAS_FLAG).apply {

                style = Paint.Style.FILL
                color = Color.rgb(160, 90, 255)
                setShadowLayer(
                    20f,
                    0f,
                    0f,
                    Color.rgb(165, 95, 255)
                )
            }

        private val whitePaint =
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.WHITE
            }

        private val ribbonPath = Path()

        private val density =
            resources.displayMetrics.density

        private val designWidth = 615f
        private val designHeight = 615f

        init {
            setLayerType(View.LAYER_TYPE_SOFTWARE, null)
            setBackgroundColor(Color.WHITE)
        }

        override fun onDraw(canvas: Canvas) {

            super.onDraw(canvas)

            canvas.drawColor(Color.WHITE)

            if (width == 0 || height == 0) return

            val scale = min(
                width * 0.90f / designWidth,
                height * 0.72f / designHeight
            )

            val offsetX =
                (width - designWidth * scale) / 2f

            val offsetY =
                (height - designHeight * scale) / 2f

            canvas.save()

            canvas.translate(offsetX, offsetY)
            canvas.scale(scale, scale)

            drawGlowingCircle(canvas)
            drawHFormation(canvas)
            drawRibbonSweep(canvas)
            drawChartAndReceipt(canvas)
            drawWordmark(canvas)
            drawTagline(canvas)

            canvas.restore()
        }


        // --------------------------------------------------
        // STAGE 1: 0 - 400 ms
        // GLOWING CIRCLE
        // --------------------------------------------------

        private fun drawGlowingCircle(canvas: Canvas) {

            if (progress >= 0.182f) return

            val stage = (
                    progress / 0.182f
                    ).coerceIn(0f, 1f)

            val cx = 307.5f
            val cy = 210f
            val radius = 133f

            val rect = RectF(
                cx - radius,
                cy - radius,
                cx + radius,
                cy + radius
            )

            ringPaint.alpha =
                (255 * stage).toInt()

            canvas.drawArc(
                rect,
                -90f,
                350f * stage,
                false,
                ringPaint
            )

            val angle = Math.toRadians(
                -90.0 + 350.0 * stage
            )

            val x =
                cx + radius * cos(angle).toFloat()

            val y =
                cy + radius * sin(angle).toFloat()

            glowPaint.alpha = 255
            whitePaint.alpha = 255

            canvas.drawCircle(
                x,
                y,
                9f * density,
                glowPaint
            )

            canvas.drawCircle(
                x,
                y,
                3.5f * density,
                whitePaint
            )
        }


        // --------------------------------------------------
        // STAGE 2: 400 - 800 ms
        // H SHAPE FORMATION
        // --------------------------------------------------

        private fun drawHFormation(canvas: Canvas) {

            if (progress < 0.182f) return

            val stage = (
                    (progress - 0.182f) / 0.182f
                    ).coerceIn(0f, 1f)

            val revealHeight = 405f * stage

            // Left side of H

            drawIconPart(
                canvas,
                RectF(
                    135f,
                    10f,
                    225f,
                    15f + revealHeight
                )
            )

            // Right side of H

            drawIconPart(
                canvas,
                RectF(
                    385f,
                    10f,
                    475f,
                    15f + revealHeight
                )
            )
        }


        // --------------------------------------------------
        // STAGE 3: 800 - 1200 ms
        // RIBBON SWEEP
        // --------------------------------------------------

        private fun drawRibbonSweep(canvas: Canvas) {

            if (progress < 0.364f) return

            val stage = (
                    (progress - 0.364f) / 0.182f
                    ).coerceIn(0f, 1f)

            val right = 140f + 335f * stage

            ribbonPath.reset()

            // Curved ribbon reveal path.

            ribbonPath.moveTo(135f, 235f)

            ribbonPath.cubicTo(
                155f, 190f,
                230f, 185f,
                290f, 195f
            )

            ribbonPath.cubicTo(
                360f, 210f,
                420f, 195f,
                right, 155f
            )

            ribbonPath.lineTo(right, 310f)

            ribbonPath.cubicTo(
                400f, 355f,
                300f, 310f,
                240f, 310f
            )

            ribbonPath.cubicTo(
                185f, 310f,
                155f, 350f,
                135f, 380f
            )

            ribbonPath.close()

            canvas.save()

            canvas.clipPath(ribbonPath)

            drawIconPart(
                canvas,
                RectF(
                    135f,
                    175f,
                    right,
                    380f
                )
            )

            canvas.restore()
        }


        // --------------------------------------------------
        // STAGE 4: 1200 - 1700 ms
        // CHART, ARROW AND RECEIPT
        // --------------------------------------------------

        private fun drawChartAndReceipt(canvas: Canvas) {

            if (progress < 0.545f) return

            val stage = (
                    (progress - 0.545f) / 0.228f
                    ).coerceIn(0f, 1f)

            // Chart and arrow reveal

            val chartRight =
                225f + 155f * stage

            drawIconPart(
                canvas,
                RectF(
                    225f,
                    25f,
                    chartRight,
                    220f
                ),
                stage
            )

            // Receipt and rupee symbol reveal

            val receiptRight =
                275f + 170f * stage

            drawIconPart(
                canvas,
                RectF(
                    275f,
                    215f,
                    receiptRight,
                    415f
                ),
                stage
            )
        }


        // --------------------------------------------------
        // STAGE 5: 1700 - 2200 ms
        // WORDMARK
        // --------------------------------------------------

        private fun drawWordmark(canvas: Canvas) {

            if (progress < 0.773f) return

            val stage = (
                    (progress - 0.773f) / 0.227f
                    ).coerceIn(0f, 1f)

            val scale =
                0.94f + (0.06f * stage)

            val alpha =
                (255 * stage).toInt()

            imagePaint.alpha = alpha

            canvas.save()

            canvas.translate(
                307.5f,
                491f
            )

            canvas.scale(scale, scale)

            canvas.translate(
                -307.5f,
                -491f
            )

            canvas.drawBitmap(
                wordmarkBitmap,
                0f,
                421f,
                imagePaint
            )

            canvas.restore()

            imagePaint.alpha = 255
        }


        // --------------------------------------------------
        // STAGE 5: TAGLINE
        // --------------------------------------------------

        private fun drawTagline(canvas: Canvas) {

            if (progress < 0.773f) return

            val stage = (
                    (progress - 0.773f) / 0.227f
                    ).coerceIn(0f, 1f)

            imagePaint.alpha =
                (255 * stage).toInt()

            canvas.drawBitmap(
                taglineBitmap,
                0f,
                563f,
                imagePaint
            )

            imagePaint.alpha = 255
        }


        // --------------------------------------------------
        // ORIGINAL ICON DRAWING
        // --------------------------------------------------

        private fun drawIconPart(
            canvas: Canvas,
            clip: RectF,
            alpha: Float = 1f
        ) {

            canvas.save()

            canvas.clipRect(clip)

            imagePaint.alpha =
                (255 * alpha).toInt()

            // Original icon asset is 510 x 415.
            // Position it inside the 615 x 615 artwork.

            canvas.drawBitmap(
                iconBitmap,
                98f,
                4f,
                imagePaint
            )

            imagePaint.alpha = 255

            canvas.restore()
        }


        // --------------------------------------------------
        // RELEASE BITMAPS
        // --------------------------------------------------

        fun release() {

            if (!iconBitmap.isRecycled) {
                iconBitmap.recycle()
            }

            if (!wordmarkBitmap.isRecycled) {
                wordmarkBitmap.recycle()
            }

            if (!taglineBitmap.isRecycled) {
                taglineBitmap.recycle()
            }
        }
    }
}
