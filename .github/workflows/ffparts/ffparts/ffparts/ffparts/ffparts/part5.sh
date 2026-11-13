# FF DRAG PRO source, part 5 of 7
mkdir -p 'app/src/main/java/com/ffdragpro/app'
cat > 'app/src/main/java/com/ffdragpro/app/TrainerView.kt' <<'FFDRAG_EOF'
package com.ffdragpro.app

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.DashPathEffect
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.graphics.Typeface
import android.os.Build
import android.os.SystemClock
import android.util.AttributeSet
import android.util.TypedValue
import android.view.HapticFeedbackConstants
import android.view.MotionEvent
import android.view.View
import java.util.Locale
import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.hypot
import kotlin.math.sin
import kotlin.random.Random

/**
 * Drag-headshot practice surface.
 *
 * The crosshair is fixed at the centre of the screen, like in a shooter. When a target appears,
 * the crosshair is at chest height. Put a thumb down anywhere (like pressing fire), swipe up to
 * move the aim onto the head, and lift to take the shot. The shot is scored where the aim is at
 * the moment of release.
 *
 * Animation runs only while a session is active; when idle the view does not redraw.
 */
class TrainerView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
) : View(context, attrs) {

    interface Listener {
        fun onShot(record: ShotRecord, shotNumber: Int, totalShots: Int, headshots: Int)
        fun onSessionFinished(records: List<ShotRecord>)
    }

    private enum class Phase { IDLE, WAIT_SPAWN, ACTIVE, DRAGGING, FEEDBACK }

    var listener: Listener? = null
    var weapon: Weapon = Weapon.SMG
        set(value) {
            field = value
            invalidate()
        }
    var speedLevel: Int = 2
    var rounds: Int = 20
    /** Crosshair movement per pixel of finger movement (1.0 = 100 %). */
    var sensitivity: Float = 1f
    var showGuide: Boolean = true
        set(value) {
            field = value
            invalidate()
        }
    var hapticsEnabled: Boolean = true

    val isSessionRunning: Boolean get() = phase != Phase.IDLE

    private var phase = Phase.IDLE
    private val records = ArrayList<ShotRecord>()
    private var headshotCount = 0

    private val dm = resources.displayMetrics
    /** Physical vertical pixel density, used to express swipes in millimetres. */
    private val ydpi: Float = if (dm.ydpi > 50f) dm.ydpi else dm.densityDpi.toFloat()

    // Crosshair position on screen.
    private var cx = 0f
    private var cy = 0f
    // Aim (camera) offset: world = screen + aim.
    private var aimX = 0f
    private var aimY = 0f

    // Current target, in world pixels.
    private var tX = 0f
    private var tHeadY = 0f
    private var tHeadR = 0f
    private var tBodyTop = 0f
    private var tBodyBottom = 0f
    private var tBodyHalfW = 0f
    private var tVx = 0f
    private var tMinX = 0f
    private var tMaxX = 0f
    private var requiredMm = 0f

    private var phaseStart = 0L
    private var spawnTime = 0L
    private var spawnDelay = 0L
    private var downTime = 0L
    private var downX = 0f
    private var downY = 0f
    private var lastX = 0f
    private var lastY = 0f
    private var activePointerId = MotionEvent.INVALID_POINTER_ID
    private var lastFrame = 0L

    private var feedbackText = ""
    private var feedbackColor = Color.WHITE

    // ---- Paints (allocated once) ----------------------------------------------------------

    private val bgPaint = Paint().apply { color = 0xFF10141B.toInt() }
    private val floorPaint = Paint().apply { color = 0xFF161C25.toInt() }
    private val gridPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = 0x1FFFFFFF
        strokeWidth = dp(1f)
    }
    private val bodyPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = 0xFF56677F.toInt() }
    private val headPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = 0xFFE3E8EF.toInt() }
    private val zonePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeWidth = dp(1.5f)
        color = 0xAA3DDC84.toInt()
        pathEffect = DashPathEffect(floatArrayOf(dp(4f), dp(4f)), 0f)
    }
    private val crossPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeWidth = dp(2f)
        strokeCap = Paint.Cap.ROUND
        color = Color.WHITE
    }
    private val crossDotPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.WHITE }
    private val guidePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeWidth = dp(2f)
        strokeCap = Paint.Cap.ROUND
        color = COLOR_GUIDE
        pathEffect = DashPathEffect(floatArrayOf(dp(7f), dp(5f)), 0f)
    }
    private val arrowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = COLOR_GUIDE }
    private val trailPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeWidth = dp(3f)
        strokeCap = Paint.Cap.ROUND
        color = 0x66FFFFFF
    }
    private val timerPaint = Paint().apply { color = COLOR_GUIDE }
    private val labelPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = COLOR_GUIDE
        textSize = sp(14f)
        typeface = Typeface.DEFAULT_BOLD
    }
    private val infoPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = 0xFFA9B1BC.toInt()
        textSize = sp(15f)
        textAlign = Paint.Align.CENTER
    }
    private val bigPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        textSize = sp(26f)
        textAlign = Paint.Align.CENTER
        typeface = Typeface.DEFAULT_BOLD
    }
    private val rect = RectF()
    private val path = Path()

    // ---- Public control ------------------------------------------------------------------

    fun startSession() {
        records.clear()
        headshotCount = 0
        activePointerId = MotionEvent.INVALID_POINTER_ID
        enterWaitSpawn()
    }

    fun stopSession() {
        phase = Phase.IDLE
        activePointerId = MotionEvent.INVALID_POINTER_ID
        aimX = 0f
        aimY = 0f
        invalidate()
    }

    // ---- Session flow --------------------------------------------------------------------

    private fun now() = SystemClock.uptimeMillis()

    private fun enterWaitSpawn() {
        phase = Phase.WAIT_SPAWN
        phaseStart = now()
        // Higher speed = shorter wait before the next target.
        spawnDelay = (Random.nextLong(450L, 950L) / (0.6f + 0.2f * speedLevel)).toLong()
        aimX = 0f
        aimY = 0f
        lastFrame = 0L
        postInvalidateOnAnimation()
    }

    private fun spawnTarget() {
        val w = width.toFloat()
        val h = height.toFloat()
        val scale = weapon.rangeScale * (0.8f + 0.4f * Random.nextFloat())
        val bodyH = h * 0.30f * scale
        tHeadR = bodyH * 0.16f
        tBodyHalfW = bodyH * 0.21f
        // Chest lands near the crosshair: the classic drag-headshot starting position.
        val chestY = cy + (Random.nextFloat() - 0.5f) * h * 0.06f
        tX = cx + (Random.nextFloat() - 0.5f) * w * 0.10f
        tBodyTop = chestY - bodyH * 0.28f
        tBodyBottom = tBodyTop + bodyH
        tHeadY = tBodyTop - tHeadR * 1.15f
        val strafe = w * 0.07f * (speedLevel - 1) * weapon.strafeFactor
        tVx = if (Random.nextBoolean()) strafe else -strafe
        tMinX = cx - w * 0.30f
        tMaxX = cx + w * 0.30f
        requiredMm = DragEvaluator.pxToMm((cy - tHeadY) / sensitivity, ydpi)
        spawnTime = now()
        phaseStart = spawnTime
        phase = Phase.ACTIVE
    }

    private fun reactionLimitMs(): Long = 2600L - 400L * (speedLevel - 1)

    private fun update(t: Long, dt: Float) {
        when (phase) {
            Phase.WAIT_SPAWN -> if (t - phaseStart >= spawnDelay) spawnTarget()
            Phase.ACTIVE -> {
                moveTarget(dt)
                if (t - spawnTime > reactionLimitMs()) recordTimeout()
            }
            Phase.DRAGGING -> {
                moveTarget(dt)
                // Simulated recoil: aim climbs while the finger is held down.
                aimY -= weapon.recoilPerSec * height * dt
            }
            Phase.FEEDBACK -> if (t - phaseStart >= FEEDBACK_MS) nextOrFinish()
            Phase.IDLE -> Unit
        }
    }

    private fun moveTarget(dt: Float) {
        if (tVx == 0f) return
        tX += tVx * dt
        if (tX < tMinX) {
            tX = tMinX
            tVx = -tVx
        } else if (tX > tMaxX) {
            tX = tMaxX
            tVx = -tVx
        }
    }

    private fun recordTimeout() {
        addRecord(ShotRecord(ShotOutcome.TIMEOUT, -1L, 0L, 0f, 0f, requiredMm))
        showFeedback("TOO SLOW  ·  thumb down sooner", COLOR_YELLOW)
    }

    private fun fireShot() {
        val t = now()
        activePointerId = MotionEvent.INVALID_POINTER_ID
        val shotX = cx + aimX
        val shotY = cy + aimY
        val geometry = TargetGeometry(tX, tHeadY, tHeadR, tBodyTop, tBodyBottom, tBodyHalfW)
        val outcome = DragEvaluator.classify(shotX, shotY, geometry, weapon.headTolerance)
        val errorMm = DragEvaluator.pxToMm((tHeadY - shotY) / sensitivity, ydpi)
        val fingerMm = DragEvaluator.pxToMm(downY - lastY, ydpi)
        val swipeMs = t - downTime
        addRecord(ShotRecord(outcome, downTime - spawnTime, swipeMs, errorMm, fingerMm, requiredMm))

        val slow = if (outcome != ShotOutcome.HEADSHOT && swipeMs > weapon.maxSwipeMs) "  ·  slow swipe" else ""
        when (outcome) {
            ShotOutcome.HEADSHOT -> {
                showFeedback("HEADSHOT", COLOR_GREEN)
                if (hapticsEnabled) {
                    val effect = if (Build.VERSION.SDK_INT >= 30) HapticFeedbackConstants.CONFIRM
                    else HapticFeedbackConstants.VIRTUAL_KEY
                    performHapticFeedback(effect)
                }
            }
            ShotOutcome.BODY -> showFeedback(
                String.format(Locale.US, "BODY  ·  swipe %.1f mm further", abs(errorMm)) + slow, COLOR_YELLOW)
            ShotOutcome.OVERDRAG -> showFeedback(
                String.format(Locale.US, "OVER-DRAG  ·  %.1f mm too far", abs(errorMm)) + slow, COLOR_ORANGE)
            ShotOutcome.MISS -> showFeedback("MISS  ·  line up sideways first$slow", COLOR_RED)
            ShotOutcome.TIMEOUT -> showFeedback("TOO SLOW", COLOR_YELLOW)
        }
    }

    private fun addRecord(record: ShotRecord) {
        records += record
        if (record.outcome == ShotOutcome.HEADSHOT) headshotCount++
        listener?.onShot(record, records.size, rounds, headshotCount)
    }

    private fun showFeedback(text: String, color: Int) {
        feedbackText = text
        feedbackColor = color
        phase = Phase.FEEDBACK
        phaseStart = now()
    }

    private fun nextOrFinish() {
        if (records.size >= rounds) {
            phase = Phase.IDLE
            aimX = 0f
            aimY = 0f
            listener?.onSessionFinished(ArrayList(records))
        } else {
            enterWaitSpawn()
        }
    }

    // ---- Input ---------------------------------------------------------------------------

    override fun onTouchEvent(event: MotionEvent): Boolean {
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN, MotionEvent.ACTION_POINTER_DOWN -> {
                if (phase == Phase.ACTIVE && activePointerId == MotionEvent.INVALID_POINTER_ID) {
                    val i = event.actionIndex
                    activePointerId = event.getPointerId(i)
                    downX = event.getX(i)
                    downY = event.getY(i)
                    lastX = downX
                    lastY = downY
                    downTime = now()
                    phase = Phase.DRAGGING
                    phaseStart = downTime
                }
                return true
            }
            MotionEvent.ACTION_MOVE -> {
                if (phase == Phase.DRAGGING) {
                    val i = event.findPointerIndex(activePointerId)
                    if (i >= 0) applyFingerMove(event.getX(i), event.getY(i))
                }
                return true
            }
            MotionEvent.ACTION_UP, MotionEvent.ACTION_POINTER_UP -> {
                val i = event.actionIndex
                if (phase == Phase.DRAGGING && event.getPointerId(i) == activePointerId) {
                    applyFingerMove(event.getX(i), event.getY(i))
                    fireShot()
                } else if (phase == Phase.IDLE && event.actionMasked == MotionEvent.ACTION_UP) {
                    performClick()
                }
                return true
            }
            MotionEvent.ACTION_CANCEL -> {
                if (phase == Phase.DRAGGING) fireShot()
                activePointerId = MotionEvent.INVALID_POINTER_ID
                return true
            }
        }
        return super.onTouchEvent(event)
    }

    override fun performClick(): Boolean = super.performClick()

    private fun applyFingerMove(x: Float, y: Float) {
        aimX += (x - lastX) * sensitivity
        aimY += (y - lastY) * sensitivity
        lastX = x
        lastY = y
    }

    // ---- Drawing -------------------------------------------------------------------------

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        cx = w / 2f
        cy = h * 0.52f
    }

    override fun onDraw(canvas: Canvas) {
        val t = now()
        val dt = if (lastFrame == 0L) 0f else (t - lastFrame).coerceAtMost(50L) / 1000f
        lastFrame = t
        update(t, dt)
        drawScene(canvas, t)
        if (phase != Phase.IDLE) postInvalidateOnAnimation() else lastFrame = 0L
    }

    private fun drawScene(c: Canvas, t: Long) {
        val w = width.toFloat()
        val h = height.toFloat()
        c.drawRect(0f, 0f, w, h, bgPaint)
        drawFloor(c, w, h)

        when (phase) {
            Phase.IDLE -> {
                c.drawText("Thumb down when the target appears, swipe up to the head, lift to shoot.", w / 2f, h * 0.40f, infoPaint)
                c.drawText(
                    String.format(Locale.US, "%s  ·  speed %d  ·  %d targets  ·  sensitivity %d%%",
                        weapon.label, speedLevel, rounds, (sensitivity * 100).toInt()),
                    w / 2f, h * 0.40f + sp(24f), infoPaint)
            }
            Phase.WAIT_SPAWN -> c.drawText("Get ready…", w / 2f, h * 0.20f, infoPaint)
            Phase.ACTIVE, Phase.DRAGGING, Phase.FEEDBACK -> {
                drawTarget(c)
                if (phase == Phase.ACTIVE) {
                    val left = 1f - ((t - spawnTime).toFloat() / reactionLimitMs()).coerceIn(0f, 1f)
                    c.drawRect(0f, 0f, w * left, dp(3f), timerPaint)
                }
                if (showGuide && phase != Phase.FEEDBACK) drawGuide(c)
                if (phase == Phase.DRAGGING) {
                    c.drawLine(downX, downY, lastX, lastY, trailPaint)
                    c.drawCircle(downX, downY, dp(6f), trailPaint)
                }
                if (phase == Phase.FEEDBACK) {
                    bigPaint.color = feedbackColor
                    c.drawText(feedbackText, w / 2f, h * 0.17f, bigPaint)
                }
            }
        }
        drawCrosshair(c)
    }

    private fun drawFloor(c: Canvas, w: Float, h: Float) {
        val horizon = h * 0.70f - aimY * 0.6f
        if (horizon >= h) return
        val top = horizon.coerceAtLeast(0f)
        c.drawRect(0f, top, w, h, floorPaint)
        val spacing = dp(64f)
        val offset = ((aimX % spacing) + spacing) % spacing
        var x = -offset
        while (x <= w + spacing) {
            c.drawLine(x, top, x + (x - cx) * 0.6f, h, gridPaint)
            x += spacing
        }
    }

    private fun drawTarget(c: Canvas) {
        val sx = tX - aimX
        val headSy = tHeadY - aimY
        val top = tBodyTop - aimY
        val bottom = tBodyBottom - aimY
        val bodyH = bottom - top
        val torsoBottom = top + bodyH * 0.55f
        val corner = tBodyHalfW * 0.35f
        rect.set(sx - tBodyHalfW, top, sx + tBodyHalfW, torsoBottom)
        c.drawRoundRect(rect, corner, corner, bodyPaint)
        val legW = tBodyHalfW * 0.8f
        rect.set(sx - tBodyHalfW * 0.92f, torsoBottom - corner, sx - tBodyHalfW * 0.92f + legW, bottom)
        c.drawRoundRect(rect, corner, corner, bodyPaint)
        rect.set(sx + tBodyHalfW * 0.92f - legW, torsoBottom - corner, sx + tBodyHalfW * 0.92f, bottom)
        c.drawRoundRect(rect, corner, corner, bodyPaint)
        c.drawCircle(sx, headSy, tHeadR, headPaint)
        if (showGuide) c.drawCircle(sx, headSy, tHeadR * weapon.headTolerance, zonePaint)
    }

    private fun drawGuide(c: Canvas) {
        val hx = tX - aimX
        val hy = tHeadY - aimY
        val dist = hypot(hx - cx, hy - cy)
        if (dist < dp(8f)) return
        path.reset()
        path.moveTo(cx, cy)
        path.lineTo(hx, hy)
        c.drawPath(path, guidePaint)
        // Arrow head at the head end.
        val angle = atan2(hy - cy, hx - cx)
        val len = dp(12f)
        val spread = 0.5f
        path.reset()
        path.moveTo(hx, hy)
        path.lineTo(hx - len * cos(angle - spread), hy - len * sin(angle - spread))
        path.lineTo(hx - len * cos(angle + spread), hy - len * sin(angle + spread))
        path.close()
        c.drawPath(path, arrowPaint)
        // Remaining finger distance to the head centre.
        val remainingMm = DragEvaluator.pxToMm((cy - hy) / sensitivity, ydpi)
        val label = if (remainingMm >= 0f) String.format(Locale.US, "↑ %.1f mm", remainingMm)
        else String.format(Locale.US, "↓ %.1f mm", -remainingMm)
        c.drawText(label, (cx + hx) / 2f + dp(14f), (cy + hy) / 2f, labelPaint)
    }

    private fun drawCrosshair(c: Canvas) {
        val onHead = (phase == Phase.ACTIVE || phase == Phase.DRAGGING) &&
            DragEvaluator.classify(cx + aimX, cy + aimY,
                TargetGeometry(tX, tHeadY, tHeadR, tBodyTop, tBodyBottom, tBodyHalfW),
                weapon.headTolerance) == ShotOutcome.HEADSHOT
        val color = if (onHead) COLOR_GREEN else Color.WHITE
        crossPaint.color = color
        crossDotPaint.color = color
        val r = dp(10f)
        val a = dp(14f)
        val b = dp(22f)
        c.drawCircle(cx, cy, r, crossPaint)
        c.drawLine(cx - b, cy, cx - a, cy, crossPaint)
        c.drawLine(cx + a, cy, cx + b, cy, crossPaint)
        c.drawLine(cx, cy - b, cx, cy - a, crossPaint)
        c.drawLine(cx, cy + a, cx, cy + b, crossPaint)
        c.drawCircle(cx, cy, dp(2f), crossDotPaint)
    }

    private fun dp(v: Float): Float = v * resources.displayMetrics.density
    private fun sp(v: Float): Float =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, v, resources.displayMetrics)

    private companion object {
        const val FEEDBACK_MS = 700L
        val COLOR_GREEN = 0xFF3DDC84.toInt()
        val COLOR_YELLOW = 0xFFFFC53D.toInt()
        val COLOR_ORANGE = 0xFFFF8A3D.toInt()
        val COLOR_RED = 0xFFFF4D4F.toInt()
        val COLOR_GUIDE = 0xFFFFA940.toInt()
    }
}
FFDRAG_EOF
mkdir -p 'app/src/main/java/com/ffdragpro/app'
cat > 'app/src/main/java/com/ffdragpro/app/Weapon.kt' <<'FFDRAG_EOF'
package com.ffdragpro.app

/**
 * Weapon categories used by the trainer. The numbers shape the practice drill
 * (target distance, head tolerance, aim climb while the finger is held); they are
 * training parameters, not values read from Free Fire.
 */
enum class Weapon(
    val label: String,
    val examples: String,
    /** Target size multiplier. Close-range classes show bigger targets, so the chest-to-head swipe is longer. */
    val rangeScale: Float,
    /** Multiplier on the head radius that still counts as a headshot. */
    val headTolerance: Float,
    /** Upward aim drift while the finger is down, as a fraction of 
