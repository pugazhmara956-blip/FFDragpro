# FF DRAG PRO source, part 3 of 7
mkdir -p 'app/src/main/java/com/ffdragpro/app'
cat > 'app/src/main/java/com/ffdragpro/app/OverlayService.kt' <<'FFDRAG_EOF'
package com.ffdragpro.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.content.res.ColorStateList
import android.content.res.Configuration
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.ColorDrawable
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.Icon
import android.graphics.drawable.RippleDrawable
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.util.DisplayMetrics
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import kotlin.math.hypot
import kotlin.math.roundToInt

/**
 * Optional floating panel shown over other apps (including the game) while the user has it
 * switched on. It is a small bubble that expands into a few shortcuts. It never reads the
 * screen, never sends touches and only receives touches that land on the bubble itself.
 *
 * Runs as a foreground service only while enabled; it holds no timers, sensors or wake locks.
 */
class OverlayService : Service() {

    companion object {
        const val ACTION_STOP = "com.ffdragpro.app.action.STOP_OVERLAY"
        const val ACTION_REFRESH = "com.ffdragpro.app.action.REFRESH_OVERLAY"
        private const val CHANNEL_ID = "floating_panel"
        private const val NOTIFICATION_ID = 1001

        @Volatile
        var isRunning = false
            private set

        fun start(context: Context) {
            context.startForegroundService(Intent(context, OverlayService::class.java))
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, OverlayService::class.java))
        }

        /** Re-applies opacity / position settings to a running panel. */
        fun refresh(context: Context) {
            if (isRunning) {
                context.startService(Intent(context, OverlayService::class.java).setAction(ACTION_REFRESH))
            }
        }
    }

    private lateinit var wm: WindowManager
    private lateinit var prefs: Prefs
    private lateinit var params: WindowManager.LayoutParams
    private var root: LinearLayout? = null
    private var panel: View? = null
    private var guide: TextView? = null
    private var guideWeapon = Weapon.SMG

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        wm = getSystemService(WINDOW_SERVICE) as WindowManager
        prefs = Prefs(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopSelf()
                return START_NOT_STICKY
            }
            ACTION_REFRESH -> {
                applySettings()
                return START_NOT_STICKY
            }
        }
        if (!startAsForeground()) {
            stopSelf()
            return START_NOT_STICKY
        }
        if (!Settings.canDrawOverlays(this)) {
            Toast.makeText(this, R.string.overlay_need_permission, Toast.LENGTH_LONG).show()
            stopSelf()
            return START_NOT_STICKY
        }
        if (root == null) createOverlay()
        isRunning = true
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        isRunning = false
        root?.let {
            try {
                wm.removeView(it)
            } catch (e: IllegalArgumentException) {
                // Already removed.
            }
        }
        root = null
        super.onDestroy()
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        // Rotation (e.g. the game switching to landscape): keep the bubble on its edge and on screen.
        root?.post { dockToSavedSide() }
    }

    // ---- Foreground notification ----------------------------------------------------------

    private fun startAsForeground(): Boolean {
        val nm = getSystemService(NotificationManager::class.java)
        val channel = NotificationChannel(
            CHANNEL_ID, getString(R.string.overlay_channel_name), NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = getString(R.string.overlay_channel_desc)
            setShowBadge(false)
        }
        nm.createNotificationChannel(channel)

        val stopIntent = PendingIntent.getService(
            this, 1,
            Intent(this, OverlayService::class.java).setAction(ACTION_STOP),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        val openIntent = PendingIntent.getActivity(
            this, 2, Intent(this, MainActivity::class.java), PendingIntent.FLAG_IMMUTABLE
        )
        val notification = Notification.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_ffdrag)
            .setContentTitle(getString(R.string.overlay_notif_title))
            .setContentText(getString(R.string.overlay_notif_text))
            .setOngoing(true)
            .setContentIntent(openIntent)
            .addAction(
                Notification.Action.Builder(
                    Icon.createWithResource(this, R.drawable.ic_stat_ffdrag),
                    getString(R.string.overlay_close), stopIntent
                ).build()
            )
            .build()
        return try {
            if (Build.VERSION.SDK_INT >= 34) {
                startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
            true
        } catch (e: Exception) {
            false
        }
    }

    // ---- Overlay views --------------------------------------------------------------------

    private fun createOverlay() {
        val container = LinearLayout(this).apply { orientation = LinearLayout.VERTICAL }

        val bubble = TextView(this).apply {
            text = getString(R.string.overlay_bubble_text)
            setTextColor(Color.WHITE)
            setTypeface(typeface, Typeface.BOLD)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
            gravity = Gravity.CENTER
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(0xF2FF6A00.toInt())
                setStroke(dp(2), Color.WHITE)
            }
            contentDescription = getString(R.string.overlay_bubble_desc)
            setOnClickListener { setExpanded(panel?.visibility != View.VISIBLE) }
        }
        container.addView(bubble, LinearLayout.LayoutParams(dp(46), dp(46)))

        val panelView = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            background = roundedBackground()
            setPadding(dp(6), dp(6), dp(6), dp(6))
            visibility = View.GONE
            addView(panelButton(getString(R.string.overlay_open_game)) { openGame() })
            addView(panelButton(getString(R.string.overlay_trainer)) { openTrainer() })
            addView(panelButton(getString(R.string.overlay_guide)) { toggleGuide() })
            addView(panelButton(getString(R.string.overlay_collapse)) { setExpanded(false) })
            addView(panelButton(getString(R.string.overlay_close)) { stopSelf() })
        }
        container.addView(panelView, LinearLayout.LayoutParams(dp(176), ViewGroup.LayoutParams.WRAP_CONTENT).apply {
            topMargin = dp(6)
        })

        val guideView = TextView(this).apply {
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
            setLineSpacing(dp(2).toFloat(), 1f)
            background = roundedBackground()
            setPadding(dp(12), dp(10), dp(12), dp(10))
            visibility = View.GONE
            setOnClickListener {
                guideWeapon = guideWeapon.next()
                updateGuideText()
                reposition()
            }
        }
        container.addView(guideView, LinearLayout.LayoutParams(dp(240), ViewGroup.LayoutParams.WRAP_CONTENT).apply {
            topMargin = dp(6)
        })

        panel = panelView
        guide = guideView
        guideWeapon = prefs.weapon
        bubble.setOnTouchListener(BubbleTouchListener())

        val (_, screenH) = screenSize()
        params = WindowManager.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            // Not focusable: the game keeps keyboard/back focus; touches outside the bubble go to the game.
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 0
            y = if (prefs.overlayY >= 0) prefs.overlayY else screenH / 3
        }
        container.alpha = prefs.overlayAlpha / 100f
        root = container
        wm.addView(container, params)
        container.post { dockToSavedSide() }
    }

    private fun applySettings() {
        val v = root ?: return
        v.alpha = prefs.overlayAlpha / 100f
        if (prefs.overlayY < 0) {
            params.y = screenSize().second / 3
        }
        dockToSavedSide()
    }

    private fun setExpanded(expanded: Boolean) {
        panel?.visibility = if (expanded) View.VISIBLE else View.GONE
        if (!expanded) guide?.visibility = View.GONE
        reposition()
    }

    private fun toggleGuide() {
        val g = guide ?: return
        if (g.visibility == View.VISIBLE) {
            g.visibility = View.GONE
        } else {
            updateGuideText()
            g.visibility = View.VISIBLE
        }
        reposition()
    }

    private fun updateGuideText() {
        val w = guideWeapon
        val sb = StringBuilder()
        sb.append(w.label).append("  (").append(w.examples).append(")\n")
        for (tip in w.tips.take(2)) sb.append("• ").append(tip).append('\n')
        val personal = prefs.headshotSwipe(w)
        if (personal != null) {
            sb.append(getString(R.string.guide_personal, w.label, personal.first, personal.second))
        } else {
            sb.append(getString(R.string.guide_personal_none))
        }
        sb.append('\n').append(getString(R.string.overlay_guide_next))
        guide?.text = sb
    }

    private fun openGame() {
        setExpanded(false)
        val game = GameLauncher.resolveGame(this, prefs)
        if (game == null || !GameLauncher.launch(this, game.packageName)) {
            Toast.makeText(this, R.string.overlay_no_game, Toast.LENGTH_LONG).show()
            startActivity(Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        }
    }

    private fun openTrainer() {
        setExpanded(false)
        startActivity(TrainerActivity.intent(this, prefs.weapon).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
    }

    // ---- Positioning ----------------------------------------------------------------------

    /** After a size change, keep the docked edge and stay on screen. */
    private fun reposition() {
        root?.post { dockToSavedSide() }
    }

    private fun dockToSavedSide() {
        val v = root ?: return
        val (screenW, screenH) = screenSize()
        val w = if (v.width > 0) v.width else dp(46)
        val h = if (v.height > 0) v.height else dp(46)
        val right = prefs.overlaySideRight
        params.x = if (right) (screenW - w).coerceAtLeast(0) else 0
        params.y = params.y.coerceIn(0, (screenH - h).coerceAtLeast(0))
        v.gravity = if (right) Gravity.END else Gravity.START
        updateLayout()
    }

    private fun updateLayout() {
        val v = root ?: return
        try {
            wm.updateViewLayout(v, params)
        } catch (e: IllegalArgumentException) {
            // View not attached (service stopping).
        }
    }

    private inner class BubbleTouchListener : View.OnTouchListener {
        private var downRawX = 0f
        private var downRawY = 0f
        private var startX = 0
        private var startY = 0
        private var dragging = false
        private val slop = ViewConfiguration.get(this@OverlayService).scaledTouchSlop

        override fun onTouch(v: View, event: MotionEvent): Boolean {
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    downRawX = event.rawX
                    downRawY = event.rawY
                    startX = params.x
                    startY = params.y
                    dragging = false
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = event.rawX - downRawX
                    val dy = event.rawY - downRawY
                    if (!dragging && !prefs.overlayLocked && hypot(dx, dy) > slop) dragging = true
                    if (dragging) {
                        val (screenW, screenH) = screenSize()
                        val view = root ?: return true
                        params.x = (startX + dx.roundToInt()).coerceIn(0, (screenW - view.width).coerceAtLeast(0))
                        params.y = (startY + dy.roundToInt()).coerceIn(0, (screenH - view.height).coerceAtLeast(0))
                        updateLayout()
                    }
                }
                MotionEvent.ACTION_UP -> {
                    if (dragging) finishDrag() else v.performClick()
                }
                MotionEvent.ACTION_CANCEL -> if (dragging) finishDrag()
            }
            return true
        }

        private fun finishDrag() {
            dragging = false
            val r = root ?: return
            val screenW = screenSize().first
            prefs.overlaySideRight = params.x + r.width / 2 > screenW / 2
            prefs.overlayY = params.y
            dockToSavedSide()
        }
    }

    // ---- Helpers --------------------------------------------------------------------------

    private fun panelButton(label: String, action: () -> Unit): TextView = TextView(this).apply {
        text = label
        setTextColor(Color.WHITE)
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
        setPadding(dp(12), dp(10), dp(12), dp(10))
        background = RippleDrawable(ColorStateList.valueOf(0x40FFFFFF), null, ColorDrawable(Color.WHITE))
        isClickable = true
        setOnClickListener { action() }
    }

    private fun roundedBackground() = GradientDrawable().apply {
        cornerRadius = dp(14).toFloat()
        setColor(0xF01A1F27.toInt())
        setStroke(dp(1), 0x33FFFFFF)
    }

    private fun screenSize(): Pair<Int, Int> =
        if (Build.VERSION.SDK_INT >= 30) {
            val b = wm.currentWindowMetrics.bounds
            Pair(b.width(), b.height())
        } else {
            legacyScreenSize()
        }

    @Suppress("DEPRECATION")
    private fun legacyScreenSize(): Pair<Int, Int> {
        val metrics = DisplayMetrics()
        wm.defaultDisplay.getRealMetrics(metrics)
        return Pair(metrics.widthPixels, metrics.heightPixels)
    }

    private fun dp(v: Int): Int = (v * resources.displayMetrics.density).roundToInt()
}
FFDRAG_EOF
mkdir -p 'app/src/main/java/com/ffdragpro/app'
cat > 'app/src/main/java/com/ffdragpro/app/Prefs.kt' <<'FFDRAG_EOF'
package com.ffdragpro.app

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import kotlin.math.max

data class HistoryEntry(
    val timeMs: Long,
    val weapon: Weapon,
    val speed: Int,
    val summary: SessionSummary,
)

/** Settings and training history, stored locally in SharedPreferences. Nothing leaves the device. */
class Prefs(context: Context) {

    private val sp: SharedPreferences =
        context.applicationContext.getSharedPreferences("ffdragpro_prefs", Context.MODE_PRIVATE)

    var weapon: Weapon
        get() = Weapon.fromName(sp.getString(K_WEAPON, null)) ?: Weapon.SMG
        set(value) = sp.edit().putString(K_WEAPON, value.name).apply()

    var speedLevel: Int
        get() = sp.getInt(K_SPEED, 2).coerceIn(1, 5)
        set(value) = sp.edit().putInt(K_SPEED, value.coerceIn(1, 5)).apply()

    var rounds: Int
        get() = sp.getInt(K_ROUNDS, 20).coerceIn(10, 50)
        set(value) = sp.edit().putInt(K_ROUNDS, value.coerceIn(10, 50)).apply()

    /** Drag sensitivity in percent: how far the crosshair moves per millimetre of finger movement. */
    var sensitivityPct: Int
        get() = sp.getInt(K_SENS, 100).coerceIn(50, 200)
        set(value) = sp.edit().putInt(K_SENS, value.coerceIn(50, 200)).apply()

    var showGuide: Boolean
        get() = sp.getBoolean(K_GUIDE, true)
        set(value) = sp.edit().putBoolean(K_GUIDE, value).apply()

    var haptics: Boolean
        get() = sp.getBoolean(K_HAPTICS, true)
        set(value) = sp.edit().putBoolean(K_HAPTICS, value).apply()

    var overlayAlpha: Int
        get() = sp.getInt(K_OV_ALPHA, 85).coerceIn(30, 100)
        set(value) = sp.edit().putInt(K_OV_ALPHA, value.coerceIn(30, 100)).apply()

    var overlayLocked: Boolean
        get() = sp.getBoolean(K_OV_LOCK, false)
        set(value) = sp.edit().putBoolean(K_OV_LOCK, value).apply()

    /** Which screen edge the floating bubble is docked to. */
    var overlaySideRight: Boolean
        get() = sp.getBoolean(K_OV_RIGHT, false)
        set(value) = sp.edit().putBoolean(K_OV_RIGHT, value).apply()

    /** Bubble Y position in pixels, or -1 for the default position. */
    var overlayY: Int
        get() = sp.getInt(K_OV_Y, -1)
        set(value) = sp.edit().putInt(K_OV_Y, value).apply()

    /** Package chosen by the user as "the game", or null to auto-detect Free Fire. */
    var gamePackage: String?
        get() = sp.getString(K_GAME, null)
        set(value) = sp.edit().putString(K_GAME, value).apply()

    // ---- History -------------------------------------------------------------------------

    fun addSession(weapon: Weapon, speed: Int, s: SessionSummary, timeMs: Long = System.currentTimeMillis()) {
        val arr = readHistoryArray()
        val o = JSONObject()
        o.put("t", timeMs)
        o.put("w", weapon.name)
        o.put("sp", speed)
        o.put("shots", s.shots)
        o.put("hs", s.headshots)
        o.put("body", s.body)
        o.put("over", s.overdrag)
        o.put("miss", s.miss)
        o.put("to", s.timeout)
        o.put("rx", s.avgReactionMs)
        o.put("sw", s.avgSwipeMs)
        o.put("mse", s.meanSignedErrorMm.toDouble())
        o.put("mae", s.meanAbsErrorMm.toDouble())
        o.put("spr", s.errorSpreadMm.toDouble())
        s.avgHeadshotSwipeMm?.let { o.put("hsw", it.toDouble()) }
        arr.put(o)
        val trimmed = JSONArray()
        for (i in max(0, arr.length() - MAX_HISTORY) until arr.length()) trimmed.put(arr.get(i))
        sp.edit().putString(K_HISTORY, trimmed.toString()).apply()
    }

    /** Newest first. */
    fun history(): List<HistoryEntry> {
        val arr = readHistoryArray()
        val out = ArrayList<HistoryEntry>(arr.length())
        for (i in arr.length() - 1 downTo 0) {
            try {
                val o = arr.getJSONObject(i)
                val weapon = Weapon.fromName(o.getString("w")) ?: continue
                val summary = SessionSummary
