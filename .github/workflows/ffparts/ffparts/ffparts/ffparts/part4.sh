# FF DRAG PRO source, part 4 of 7
mkdir -p 'app/src/main/java/com/ffdragpro/app'
cat > 'app/src/main/java/com/ffdragpro/app/SettingsActivity.kt' <<'FFDRAG_EOF'
package com.ffdragpro.app

import android.app.Activity
import android.os.Bundle
import android.widget.Button
import android.widget.SeekBar
import android.widget.Switch
import android.widget.TextView
import android.widget.Toast

class SettingsActivity : Activity() {

    private lateinit var prefs: Prefs

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_settings)
        prefs = Prefs(this)

        bindSeek(R.id.seekSensitivity, R.id.tvSensitivity, 50, 200, 5, prefs.sensitivityPct,
            { prefs.sensitivityPct = it }) { getString(R.string.set_sensitivity, it) }
        bindSeek(R.id.seekSpeed, R.id.tvSpeed, 1, 5, 1, prefs.speedLevel,
            { prefs.speedLevel = it }) { getString(R.string.set_speed, it) }
        bindSeek(R.id.seekRounds, R.id.tvRounds, 10, 50, 5, prefs.rounds,
            { prefs.rounds = it }) { getString(R.string.set_rounds, it) }
        bindSeek(R.id.seekOverlayAlpha, R.id.tvOverlayAlpha, 30, 100, 5, prefs.overlayAlpha,
            {
                prefs.overlayAlpha = it
                OverlayService.refresh(this)
            }) { getString(R.string.set_overlay_alpha, it) }

        bindSwitch(R.id.swGuide, prefs.showGuide) { prefs.showGuide = it }
        bindSwitch(R.id.swHaptics, prefs.haptics) { prefs.haptics = it }
        bindSwitch(R.id.swLockOverlay, prefs.overlayLocked) { prefs.overlayLocked = it }

        findViewById<Button>(R.id.btnResetOverlay).setOnClickListener {
            prefs.overlaySideRight = false
            prefs.overlayY = -1
            OverlayService.refresh(this)
            Toast.makeText(this, R.string.set_overlay_reset_done, Toast.LENGTH_SHORT).show()
        }
    }

    private fun bindSeek(
        seekId: Int,
        labelId: Int,
        min: Int,
        max: Int,
        step: Int,
        current: Int,
        onChange: (Int) -> Unit,
        label: (Int) -> String,
    ) {
        val seek = findViewById<SeekBar>(seekId)
        val tv = findViewById<TextView>(labelId)
        seek.max = (max - min) / step
        seek.progress = ((current - min) / step).coerceIn(0, seek.max)
        tv.text = label(current)
        seek.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar, progress: Int, fromUser: Boolean) {
                val value = min + progress * step
                tv.text = label(value)
                if (fromUser) onChange(value)
            }

            override fun onStartTrackingTouch(seekBar: SeekBar) = Unit
            override fun onStopTrackingTouch(seekBar: SeekBar) = Unit
        })
    }

    private fun bindSwitch(id: Int, current: Boolean, onChange: (Boolean) -> Unit) {
        val sw = findViewById<Switch>(id)
        sw.isChecked = current
        sw.setOnCheckedChangeListener { _, checked -> onChange(checked) }
    }
}
FFDRAG_EOF
mkdir -p 'app/src/main/java/com/ffdragpro/app'
cat > 'app/src/main/java/com/ffdragpro/app/StatsActivity.kt' <<'FFDRAG_EOF'
package com.ffdragpro.app

import android.app.Activity
import android.app.AlertDialog
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import java.text.DateFormat
import java.util.Date
import java.util.Locale

class StatsActivity : Activity() {

    private lateinit var prefs: Prefs
    private lateinit var tvOverview: TextView
    private lateinit var historyList: LinearLayout
    private lateinit var tvEmpty: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_stats)
        prefs = Prefs(this)
        tvOverview = findViewById(R.id.tvOverview)
        historyList = findViewById(R.id.historyList)
        tvEmpty = findViewById(R.id.tvEmpty)
        findViewById<Button>(R.id.btnClearHistory).setOnClickListener {
            AlertDialog.Builder(this)
                .setTitle(R.string.stats_clear_title)
                .setMessage(R.string.stats_clear_message)
                .setPositiveButton(R.string.stats_clear_confirm) { _, _ ->
                    prefs.clearHistory()
                    render()
                }
                .setNegativeButton(android.R.string.cancel, null)
                .show()
        }
    }

    override fun onResume() {
        super.onResume()
        render()
    }

    private fun render() {
        val history = prefs.history()
        tvEmpty.visibility = if (history.isEmpty()) View.VISIBLE else View.GONE

        tvOverview.text = if (history.isEmpty()) {
            getString(R.string.stats_no_data)
        } else {
            buildString {
                for (w in Weapon.entries) {
                    val sessions = history.filter { it.weapon == w }
                    if (sessions.isEmpty()) continue
                    val best = sessions.maxOf { it.summary.headshotPct }
                    val last = sessions.first().summary.headshotPct
                    val avgReaction = sessions.map { it.summary.avgReactionMs }.average().toInt()
                    val swipe = prefs.headshotSwipe(w)
                    append(String.format(Locale.US, "%s: %d sessions · last %d%% · best %d%% · reaction %d ms",
                        w.label, sessions.size, last, best, avgReaction))
                    if (swipe != null) append(String.format(Locale.US, " · headshot swipe %.1f mm", swipe.first))
                    append('\n')
                }
            }.trimEnd()
        }

        historyList.removeAllViews()
        val dateFormat = DateFormat.getDateTimeInstance(DateFormat.SHORT, DateFormat.SHORT)
        for (entry in history.take(30)) {
            val s = entry.summary
            val item = layoutInflater.inflate(R.layout.item_history, historyList, false) as TextView
            item.text = String.format(
                Locale.US,
                "%s  ·  %s  ·  speed %d\nHeadshots %d%% (%d/%d) · over-drag %d · short %d · wide %d · slow %d\nReaction %d ms · swipe %d ms · error %.1f mm",
                dateFormat.format(Date(entry.timeMs)), entry.weapon.label, entry.speed,
                s.headshotPct, s.headshots, s.shots, s.overdrag, s.body, s.miss, s.timeout,
                s.avgReactionMs, s.avgSwipeMs, s.meanAbsErrorMm
            )
            historyList.addView(item)
        }
    }
}
FFDRAG_EOF
mkdir -p 'app/src/main/java/com/ffdragpro/app'
cat > 'app/src/main/java/com/ffdragpro/app/TrainerActivity.kt' <<'FFDRAG_EOF'
package com.ffdragpro.app

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.WindowInsets
import android.view.WindowInsetsController
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import java.util.Locale

class TrainerActivity : Activity(), TrainerView.Listener {

    companion object {
        private const val EXTRA_WEAPON = "com.ffdragpro.app.extra.WEAPON"

        fun intent(context: Context, weapon: Weapon): Intent =
            Intent(context, TrainerActivity::class.java).putExtra(EXTRA_WEAPON, weapon.name)
    }

    private lateinit var prefs: Prefs
    private lateinit var trainer: TrainerView
    private lateinit var tvHud: TextView
    private lateinit var btnStop: Button
    private lateinit var idleControls: View
    private lateinit var btnWeapon: Button
    private lateinit var btnSpeed: Button
    private lateinit var btnGuide: Button
    private lateinit var resultsPanel: View
    private lateinit var tvResultTitle: TextView
    private lateinit var tvResultStats: TextView
    private lateinit var tvResultTip: TextView
    private var weapon = Weapon.SMG

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= 28) {
            val attrs = window.attributes
            attrs.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
            window.attributes = attrs
        }
        setContentView(R.layout.activity_trainer)
        prefs = Prefs(this)
        weapon = Weapon.fromName(intent.getStringExtra(EXTRA_WEAPON)) ?: prefs.weapon

        trainer = findViewById(R.id.trainerView)
        tvHud = findViewById(R.id.tvHud)
        btnStop = findViewById(R.id.btnStop)
        idleControls = findViewById(R.id.idleControls)
        btnWeapon = findViewById(R.id.btnWeapon)
        btnSpeed = findViewById(R.id.btnSpeed)
        btnGuide = findViewById(R.id.btnGuideToggle)
        resultsPanel = findViewById(R.id.resultsPanel)
        tvResultTitle = findViewById(R.id.tvResultTitle)
        tvResultStats = findViewById(R.id.tvResultStats)
        tvResultTip = findViewById(R.id.tvResultTip)

        trainer.listener = this
        applyPrefsToTrainer()

        btnWeapon.setOnClickListener {
            weapon = weapon.next()
            prefs.weapon = weapon
            trainer.weapon = weapon
            refreshIdleUi()
        }
        btnSpeed.setOnClickListener {
            prefs.speedLevel = prefs.speedLevel % 5 + 1
            trainer.speedLevel = prefs.speedLevel
            refreshIdleUi()
        }
        btnGuide.setOnClickListener {
            prefs.showGuide = !prefs.showGuide
            trainer.showGuide = prefs.showGuide
            refreshIdleUi()
        }
        findViewById<Button>(R.id.btnStart).setOnClickListener { startSession() }
        findViewById<Button>(R.id.btnExit).setOnClickListener { finish() }
        btnStop.setOnClickListener {
            trainer.stopSession()
            showIdle(getString(R.string.trainer_stopped))
        }
        findViewById<Button>(R.id.btnRetry).setOnClickListener { startSession() }
        findViewById<Button>(R.id.btnResultsClose).setOnClickListener {
            resultsPanel.visibility = View.GONE
            showIdle(null)
        }
        showIdle(null)
    }

    override fun onResume() {
        super.onResume()
        enterImmersive()
    }

    override fun onPause() {
        super.onPause()
        if (trainer.isSessionRunning) {
            trainer.stopSession()
            showIdle(getString(R.string.trainer_paused))
        }
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) enterImmersive()
    }

    private fun applyPrefsToTrainer() {
        trainer.weapon = weapon
        trainer.speedLevel = prefs.speedLevel
        trainer.rounds = prefs.rounds
        trainer.sensitivity = prefs.sensitivityPct / 100f
        trainer.showGuide = prefs.showGuide
        trainer.hapticsEnabled = prefs.haptics
    }

    private fun startSession() {
        applyPrefsToTrainer()
        resultsPanel.visibility = View.GONE
        idleControls.visibility = View.GONE
        btnStop.visibility = View.VISIBLE
        tvHud.text = getString(R.string.hud_start, weapon.label, prefs.rounds)
        trainer.startSession()
    }

    private fun showIdle(message: String?) {
        idleControls.visibility = View.VISIBLE
        btnStop.visibility = View.GONE
        refreshIdleUi()
        tvHud.text = message ?: getString(R.string.hud_idle)
    }

    private fun refreshIdleUi() {
        btnWeapon.text = getString(R.string.btn_weapon, weapon.label)
        btnSpeed.text = getString(R.string.btn_speed, prefs.speedLevel)
        btnGuide.text = getString(if (prefs.showGuide) R.string.btn_guide_on else R.string.btn_guide_off)
        trainer.invalidate()
    }

    override fun onShot(record: ShotRecord, shotNumber: Int, totalShots: Int, headshots: Int) {
        val pct = headshots * 100 / shotNumber
        val reaction = if (record.reactionMs >= 0) getString(R.string.hud_ms, record.reactionMs) else ""
        tvHud.text = getString(R.string.hud_progress, weapon.label, shotNumber, totalShots, pct, record.outcome.label, reaction)
    }

    override fun onSessionFinished(records: List<ShotRecord>) {
        val s = SessionSummary.from(records)
        prefs.addSession(weapon, prefs.speedLevel, s)
        prefs.addHeadshotSwipes(weapon, records)

        tvResultTitle.text = getString(R.string.result_title, s.headshotPct, weapon.label)
        val bias = when {
            s.meanSignedErrorMm > 0.05f -> "over"
            s.meanSignedErrorMm < -0.05f -> "short"
            else -> "centred"
        }
        tvResultStats.text = buildString {
            appendLine(String.format(Locale.US, "Headshots: %d / %d", s.headshots, s.shots))
            appendLine(String.format(Locale.US, "Body (stopped short): %d   Over-drag: %d", s.body, s.overdrag))
            appendLine(String.format(Locale.US, "Wide misses: %d   Too slow: %d", s.miss, s.timeout))
            appendLine(String.format(Locale.US, "Avg reaction: %d ms   Avg swipe time: %d ms", s.avgReactionMs, s.avgSwipeMs))
            appendLine(String.format(Locale.US, "Avg vertical error: %.1f mm (misses lean %s)", s.meanAbsErrorMm, bias))
            appendLine(String.format(Locale.US, "Consistency (error spread): %.1f mm", s.errorSpreadMm))
            append(
                s.avgHeadshotSwipeMm?.let { String.format(Locale.US, "Avg headshot swipe: %.1f mm", it) }
                    ?: "Avg headshot swipe: no headshots yet"
            )
        }
        tvResultTip.text = s.coachingTip(weapon)
        btnStop.visibility = View.GONE
        idleControls.visibility = View.GONE
        resultsPanel.visibility = View.VISIBLE
        tvHud.text = getString(R.string.hud_done)
    }

    private fun enterImmersive() {
        if (Build.VERSION.SDK_INT >= 30) {
            window.setDecorFitsSystemWindows(false)
            window.insetsController?.let {
                it.hide(WindowInsets.Type.systemBars())
                it.systemBarsBehavior = WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        } else {
            enterImmersiveLegacy()
        }
    }

    @Suppress("DEPRECATION")
    private fun enterImmersiveLegacy() {
        window.decorView.systemUiVisibility = (
            View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or
                View.SYSTEM_UI_FLAG_FULLSCREEN or
                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
                View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
            )
    }
}
FFDRAG_EOF
