# FF DRAG PRO source, part 2 of 7
mkdir -p 'app/src/main/java/com/ffdragpro/app'
cat > 'app/src/main/java/com/ffdragpro/app/MainActivity.kt' <<'FFDRAG_EOF'
package com.ffdragpro.app

import android.Manifest
import android.app.Activity
import android.app.AlertDialog
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.View
import android.widget.Button
import android.widget.LinearLayout
import android.widget.Switch
import android.widget.TextView
import android.widget.Toast

class MainActivity : Activity() {

    private lateinit var prefs: Prefs
    private lateinit var tvGameStatus: TextView
    private lateinit var btnLaunchGame: Button
    private lateinit var btnGetGame: Button
    private lateinit var swOverlay: Switch
    private lateinit var tvOverlayHint: TextView
    private lateinit var tvTrainConfig: TextView

    private var currentGame: GameLauncher.GameApp? = null
    private var updatingUi = false
    private var pendingOverlayEnable = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        prefs = Prefs(this)

        tvGameStatus = findViewById(R.id.tvGameStatus)
        btnLaunchGame = findViewById(R.id.btnLaunchGame)
        btnGetGame = findViewById(R.id.btnGetGame)
        swOverlay = findViewById(R.id.swOverlay)
        tvOverlayHint = findViewById(R.id.tvOverlayHint)
        tvTrainConfig = findViewById(R.id.tvTrainConfig)

        btnLaunchGame.setOnClickListener { launchGame() }
        findViewById<Button>(R.id.btnChooseGame).setOnClickListener { chooseGame() }
        btnGetGame.setOnClickListener { GameLauncher.openStore(this) }

        swOverlay.setOnCheckedChangeListener { _, isChecked ->
            if (!updatingUi) onOverlayToggled(isChecked)
        }
        findViewById<Button>(R.id.btnAppPermissions).setOnClickListener { openAppPermissions() }

        findViewById<Button>(R.id.btnGuide).setOnClickListener {
            startActivity(Intent(this, GuideActivity::class.java))
        }
        findViewById<Button>(R.id.btnStats).setOnClickListener {
            startActivity(Intent(this, StatsActivity::class.java))
        }
        findViewById<Button>(R.id.btnSettings).setOnClickListener {
            startActivity(Intent(this, SettingsActivity::class.java))
        }

        buildWeaponButtons()
    }

    override fun onResume() {
        super.onResume()
        if (pendingOverlayEnable) {
            pendingOverlayEnable = false
            if (Settings.canDrawOverlays(this)) startOverlay()
        }
        refreshGame()
        refreshOverlayUi()
        refreshTrainConfig()
    }

    // ---- Game ----------------------------------------------------------------------------

    private fun refreshGame() {
        val game = GameLauncher.resolveGame(this, prefs)
        currentGame = game
        if (game != null) {
            tvGameStatus.text = getString(R.string.game_detected, game.label)
            btnLaunchGame.isEnabled = true
            btnLaunchGame.text = getString(R.string.launch_game_named, game.label)
            btnGetGame.visibility = View.GONE
        } else {
            tvGameStatus.text = getString(R.string.game_not_found)
            btnLaunchGame.isEnabled = false
            btnLaunchGame.text = getString(R.string.launch_game)
            btnGetGame.visibility = View.VISIBLE
        }
    }

    private fun launchGame() {
        val game = currentGame ?: return
        if (!GameLauncher.launch(this, game.packageName)) {
            Toast.makeText(this, R.string.launch_failed, Toast.LENGTH_SHORT).show()
            refreshGame()
        }
    }

    private fun chooseGame() {
        val apps = GameLauncher.sortForPicker(GameLauncher.launchableApps(this))
        if (apps.isEmpty()) {
            Toast.makeText(this, R.string.no_apps_found, Toast.LENGTH_SHORT).show()
            return
        }
        val labels = apps.map { it.label }.toTypedArray()
        AlertDialog.Builder(this)
            .setTitle(R.string.choose_game_title)
            .setItems(labels) { _, which ->
                prefs.gamePackage = apps[which].packageName
                refreshGame()
            }
            .setNeutralButton(R.string.auto_detect) { _, _ ->
                prefs.gamePackage = null
                refreshGame()
            }
            .setNegativeButton(android.R.string.cancel, null)
            .show()
    }

    // ---- Floating panel ------------------------------------------------------------------

    private fun onOverlayToggled(enable: Boolean) {
        if (enable) {
            if (Settings.canDrawOverlays(this)) {
                startOverlay()
            } else {
                pendingOverlayEnable = true
                Toast.makeText(this, R.string.overlay_grant_toast, Toast.LENGTH_LONG).show()
                try {
                    startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName")))
                } catch (e: ActivityNotFoundException) {
                    openAppPermissions()
                }
            }
        } else {
            OverlayService.stop(this)
        }
        // The service reports its state asynchronously; re-read it shortly.
        swOverlay.postDelayed({ refreshOverlayUi() }, 500L)
    }

    private fun startOverlay() {
        if (Build.VERSION.SDK_INT >= 33 &&
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        ) {
            // Optional: lets the "panel active" notification (with its Close button) appear.
            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), REQ_NOTIFICATIONS)
        }
        OverlayService.start(this)
    }

    private fun refreshOverlayUi() {
        if (isFinishing || isDestroyed) return
        updatingUi = true
        swOverlay.isChecked = OverlayService.isRunning
        updatingUi = false
        tvOverlayHint.setText(
            when {
                !Settings.canDrawOverlays(this) -> R.string.overlay_need_permission
                OverlayService.isRunning -> R.string.overlay_on_hint
                else -> R.string.overlay_off_hint
            }
        )
    }

    /** Xiaomi/Redmi (HyperOS) keeps extra pop-up permissions on its own screen; fall back to app info. */
    private fun openAppPermissions() {
        val isXiaomi = Build.MANUFACTURER.equals("Xiaomi", ignoreCase = true) ||
            Build.BRAND.equals("Redmi", ignoreCase = true) || Build.BRAND.equals("POCO", ignoreCase = true)
        if (isXiaomi) {
            val miui = Intent("miui.intent.action.APP_PERM_EDITOR")
                .setClassName("com.miui.securitycenter", "com.miui.permcenter.permissions.PermissionsEditorActivity")
                .putExtra("extra_pkgname", packageName)
            try {
                startActivity(miui)
                return
            } catch (e: Exception) {
                // Not available on this build: use the standard screen below.
            }
        }
        try {
            startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.fromParts("package", packageName, null)))
        } catch (e: ActivityNotFoundException) {
            Toast.makeText(this, R.string.settings_unavailable, Toast.LENGTH_SHORT).show()
        }
    }

    // ---- Training ------------------------------------------------------------------------

    private fun buildWeaponButtons() {
        val container = findViewById<LinearLayout>(R.id.weaponButtons)
        for (w in Weapon.entries) {
            val b = layoutInflater.inflate(R.layout.item_weapon_button, container, false) as Button
            b.text = getString(R.string.train_weapon, w.label, w.examples)
            b.setOnClickListener {
                prefs.weapon = w
                startActivity(TrainerActivity.intent(this, w))
            }
            container.addView(b)
        }
    }

    private fun refreshTrainConfig() {
        tvTrainConfig.text = getString(
            R.string.train_config,
            prefs.speedLevel,
            prefs.rounds,
            prefs.sensitivityPct,
            getString(if (prefs.showGuide) R.string.on else R.string.off)
        )
    }

    private companion object {
        const val REQ_NOTIFICATIONS = 10
    }
}
FFDRAG_EOF
