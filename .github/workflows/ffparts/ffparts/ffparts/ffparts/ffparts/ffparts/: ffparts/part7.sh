# FF DRAG PRO source, part 7 of 7
mkdir -p 'app/src/main/res/values-v35'
cat > 'app/src/main/res/values-v35/themes.xml' <<'FFDRAG_EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Android 15: keep the classic (non edge-to-edge) layout so content never sits under the system bars. -->
    <style name="Theme.FFDragPro" parent="Base.Theme.FFDragPro">
        <item name="android:windowOptOutEdgeToEdgeEnforcement">true</item>
    </style>
</resources>
FFDRAG_EOF
mkdir -p 'app/src/main/res/values'
cat > 'app/src/main/res/values/colors.xml' <<'FFDRAG_EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="bg">#FF0E1116</color>
    <color name="card">#FF1A1F27</color>
    <color name="btn">#FF262D38</color>
    <color name="btn_disabled">#FF2A2F36</color>
    <color name="brand">#FFFF6A00</color>
    <color name="text">#FFFFFFFF</color>
    <color name="text_dim">#FFA9B1BC</color>
    <color name="stroke">#33FFFFFF</color>
    <color name="ic_launcher_background">#FFFF6A00</color>
</resources>
FFDRAG_EOF
mkdir -p 'app/src/main/res/values'
cat > 'app/src/main/res/values/strings.xml' <<'FFDRAG_EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">FF DRAG PRO</string>
    <string name="tagline">Drag-headshot trainer and Free Fire India companion</string>
    <string name="on">on</string>
    <string name="off">off</string>

    <!-- Game card -->
    <string name="card_game">Game</string>
    <string name="game_detected">Found: %1$s</string>
    <string name="game_not_found">Free Fire India is not installed (or was not found). Install it from the Play Store, or choose the game manually.</string>
    <string name="launch_game">Launch Free Fire India</string>
    <string name="launch_game_named">Launch %1$s</string>
    <string name="choose_game">Choose game</string>
    <string name="get_game">Get from Play Store</string>
    <string name="choose_game_title">Which app is your game?</string>
    <string name="auto_detect">Auto-detect</string>
    <string name="launch_failed">Could not open the game.</string>
    <string name="no_apps_found">No launchable apps found.</string>

    <!-- Floating panel card -->
    <string name="card_overlay">Floating gaming panel</string>
    <string name="overlay_need_permission">Needs the \"Display over other apps\" permission. Turn the switch on to open that setting.</string>
    <string name="overlay_off_hint">Off. When on, a small FF bubble stays on screen over the game. Tap it for shortcuts; drag it to any edge so it does not cover your controls.</string>
    <string name="overlay_on_hint">On. Drag the bubble to a free edge of the screen. Tap it for Free Fire, Trainer and Guide. Close it from the bubble or the notification.</string>
    <string name="overlay_grant_toast">Allow \"Display over other apps\" for FF DRAG PRO, then come back.</string>
    <string name="app_permissions">App permissions (Redmi / HyperOS)</string>
    <string name="settings_unavailable">Settings screen not available.</string>

    <!-- Train card -->
    <string name="card_train">Drag-headshot trainer</string>
    <string name="train_config">Speed %1$d · %2$d targets · sensitivity %3$d%% · guide %4$s</string>
    <string name="train_weapon">%1$s  ·  %2$s</string>

    <!-- More -->
    <string name="card_more">More</string>
    <string name="guide_title">Drag-headshot guide</string>
    <string name="stats_title">Training stats</string>
    <string name="settings_title">Settings</string>
    <string name="fair_play">FF DRAG PRO is an independent practice tool. It does not read, inject into or modify Free Fire, does not automate input or aiming, and does not interact with anti-cheat. Not affiliated with Garena.</string>

    <!-- Trainer -->
    <string name="hud_idle">Choose weapon and speed, then press START.</string>
    <string name="hud_start">%1$s · 0/%2$d · thumb down when the target appears</string>
    <string name="hud_progress">%1$s · Shot %2$d/%3$d · Headshots %4$d%% · Last: %5$s %6$s</string>
    <string name="hud_ms">(%1$d ms)</string>
    <string name="hud_done">Session complete.</string>
    <string name="trainer_paused">Session paused. Press START to begin again.</string>
    <string name="trainer_stopped">Session stopped.</string>
    <string name="btn_weapon">Weapon: %1$s</string>
    <string name="btn_speed">Speed: %1$d</string>
    <string name="btn_guide_on">Guide: on</string>
    <string name="btn_guide_off">Guide: off</string>
    <string name="start">START</string>
    <string name="stop">Stop</string>
    <string name="exit">Exit</string>
    <string name="retry">Train again</string>
    <string name="close">Close</string>
    <string name="result_title">%1$d%% headshots · %2$s</string>

    <!-- Guide -->
    <string name="guide_fundamentals_title">Fundamentals</string>
    <string name="guide_fundamentals">1. Keep the crosshair at chest height while you move. The drag then only has to cover the gap from chest to head.\n\n2. Press fire and swipe up in one motion. A pause between press and swipe costs time.\n\n3. Swipe straight up. Sideways drift is the most common reason a drag misses.\n\n4. Distance changes the swipe: close enemies need a longer swipe, far enemies a shorter one.\n\n5. Stop at the head. Over-dragging sends shots over the target.\n\n6. Sensitivity: in Free Fire open Settings, then Sensitivity. Higher values mean a shorter swipe covers the same distance. Change one value at a time, set a similar feel here under Settings, Drag sensitivity, and re-test.\n\n7. HUD: put the fire button where your thumb already rests, so the swipe starts without moving your hand.</string>
    <string name="guide_weapon_title">%1$s  (%2$s)</string>
    <string name="guide_personal">%1$s: your average headshot swipe is %2$.1f mm (from %3$d headshots).</string>
    <string name="guide_personal_none">No headshots recorded with this weapon yet. Train to measure your personal swipe length.</string>
    <string name="guide_practice">Practise this weapon</string>
    <string name="guide_how_trainer_title">How the trainer scores you</string>
    <string name="guide_how_trainer">Each target appears with the crosshair at chest height. Put your thumb down anywhere (like pressing fire), swipe up and lift. The shot lands where the crosshair is when you lift.\n\nHeadshot: on the head. Body: stopped short. Over-drag: went above the head. Miss: off to the side. Too slow: no swipe before the timer bar ran out.\n\nThe orange guide shows the direction and the remaining finger distance in millimetres. Recoil classes (SMG, AR, Pistol) make the aim climb while your thumb is down, as in a real spray.\n\nThe trainer is a motion drill for swipe length and direction. It does not copy Free Fire aim assist or exact weapon behaviour.</string>

    <!-- Stats -->
    <string name="stats_overview">Per weapon</string>
    <string name="stats_recent">Recent sessions</string>
    <string name="stats_no_data">No sessions yet. Finish a training session to see your progress here.</string>
    <string name="stats_empty_list">Nothing here yet.</string>
    <string name="stats_clear">Clear history</string>
    <string name="stats_clear_title">Clear training history?</string>
    <string name="stats_clear_message">This deletes all sessions and personal swipe averages on this phone.</string>
    <string name="stats_clear_confirm">Clear</string>

    <!-- Settings -->
    <string name="set_training">Training</string>
    <string name="set_sensitivity">Drag sensitivity: %1$d%%</string>
    <string name="set_sensitivity_hint">How far the crosshair moves per millimetre of swipe. Higher = shorter swipe needed.</string>
    <string name="set_speed">Training speed: %1$d</string>
    <string name="set_speed_hint">1 = still targets, generous timer. 5 = fast strafing targets, about 1 second to react.</string>
    <string name="set_rounds">Targets per session: %1$d</string>
    <string name="set_guide">Show drag guide (arrow, distance, head zone)</string>
    <string name="set_haptics">Vibrate on headshot</string>
    <string name="set_overlay">Floating panel</string>
    <string name="set_overlay_alpha">Panel opacity: %1$d%%</string>
    <string name="set_lock_overlay">Lock panel position</string>
    <string name="set_overlay_reset">Reset panel position</string>
    <string name="set_overlay_reset_done">Panel moved back to the left edge.</string>

    <!-- Overlay service -->
    <string name="overlay_channel_name">Floating panel</string>
    <string name="overlay_channel_desc">Shown while the FF DRAG PRO floating panel is switched on.</string>
    <string name="overlay_notif_title">Floating panel is on</string>
    <string name="overlay_notif_text">Tap to open FF DRAG PRO. Use Close to remove the panel.</string>
    <string name="overlay_bubble_text">FF</string>
    <string name="overlay_bubble_desc">FF DRAG PRO panel. Tap to open, drag to move.</string>
    <string name="overlay_open_game">Open Free Fire</string>
    <string name="overlay_trainer">Drag trainer</string>
    <string name="overlay_guide">Drag guide</string>
    <string name="overlay_collapse">Hide menu</string>
    <string name="overlay_close">Close panel</string>
    <string name="overlay_guide_next">Tap this card for the next weapon.</string>
    <string name="overlay_no_game">Free Fire India not found. Choose the game in FF DRAG PRO.</string>
</resources>
FFDRAG_EOF
mkdir -p 'app/src/main/res/values'
cat > 'app/src/main/res/values/styles.xml' <<'FFDRAG_EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Card">
        <item name="android:layout_width">match_parent</item>
        <item name="android:layout_height">wrap_content</item>
        <item name="android:layout_marginTop">14dp</item>
        <item name="android:orientation">vertical</item>
        <item name="android:padding">16dp</item>
        <item name="android:background">@drawable/bg_card</item>
    </style>

    <style name="CardTitle">
        <item name="android:layout_width">wrap_content</item>
        <item name="android:layout_height">wrap_content</item>
        <item name="android:textSize">17sp</item>
        <item name="android:textStyle">bold</item>
        <item name="android:textColor">@color/text</item>
    </style>

    <style name="ScreenTitle">
        <item name="android:layout_width">match_parent</item>
        <item name="android:layout_height">wrap_content</item>
        <item name="android:textSize">22sp</item>
        <item name="android:textStyle">bold</item>
        <item name="android:textColor">@color/text</item>
    </style>

    <style name="Body">
        <item name="android:layout_width">match_parent</item>
        <item name="android:layout_height">wrap_content</item>
        <item name="android:layout_marginTop">6dp</item>
        <item name="android:textSize">14sp</item>
        <item name="android:textColor">@color/text_dim</item>
        <item name="android:lineSpacingExtra">2dp</item>
    </style>

    <style name="Small">
        <item name="android:layout_width">match_parent</item>
        <item name="android:layout_height">wrap_content</item>
        <item name="android:textSize">12sp</item>
        <item name="android:textColor">@color/text_dim</item>
        <item name="android:lineSpacingExtra">2dp</item>
    </style>

    <style name="Btn" parent="android:Widget.Material.Button">
        <item name="android:layout_width">match_parent</item>
        <item name="android:layout_height">wrap_content</item>
        <item name="android:layout_marginTop">8dp</item>
        <item name="android:minHeight">48dp</item>
        <item name="android:paddingStart">16dp</item>
        <item name="android:paddingEnd">16dp</item>
        <item name="android:textAllCaps">false</item>
        <item name="android:textSize">15sp</item>
        <item name="android:textColor">@color/text</item>
        <item name="android:background">@drawable/bg_button</item>
        <item name="android:stateListAnimator">@null</item>
    </style>

    <style name="BtnPrimary" parent="Btn">
        <item name="android:background">@drawable/bg_button_primary</item>
        <item name="android:textStyle">bold</item>
    </style>

    <style name="BtnCompact" parent="Btn">
        <item name="android:layout_width">wrap_content</item>
        <item name="android:layout_marginTop">0dp</item>
        <item name="android:layout_marginStart">8dp</item>
        <item name="android:textSize">14sp</item>
    </style>

    <style name="BtnCompactPrimary" parent="BtnCompact">
        <item name="android:background">@drawable/bg_button_primary</item>
        <item name="android:textStyle">bold</item>
    </style>
</resources>
FFDRAG_EOF
mkdir -p 'app/src/main/res/values'
cat > 'app/src/main/res/values/themes.xml' <<'FFDRAG_EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Base.Theme.FFDragPro" parent="android:Theme.Material.NoActionBar">
        <item name="android:colorPrimary">@color/brand</item>
        <item name="android:colorPrimaryDark">@color/bg</item>
        <item name="android:colorAccent">@color/brand</item>
        <item name="android:windowBackground">@color/bg</item>
        <item name="android:statusBarColor">@color/bg</item>
        <item name="android:navigationBarColor">@color/bg</item>
        <item name="android:textColorPrimary">@color/text</item>
        <item name="android:textColorSecondary">@color/text_dim</item>
    </style>

    <style name="Theme.FFDragPro" parent="Base.Theme.FFDragPro" />

    <style name="Theme.FFDragPro.Fullscreen">
        <item name="android:windowFullscreen">true</item>
    </style>
</resources>
FFDRAG_EOF
mkdir -p 'app/src/test/java/com/ffdragpro/app'
cat > 'app/src/test/java/com/ffdragpro/app/DragEvaluatorTest.kt' <<'FFDRAG_EOF'
package com.ffdragpro.app

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class DragEvaluatorTest {

    // Head centred at (500, 200), radius 20. Body from y=225 to y=500, half width 30.
    private val target = TargetGeometry(
        centerX = 500f, headCenterY = 200f, headRadius = 20f,
        bodyTop = 225f, bodyBottom = 500f, bodyHalfWidth = 30f,
    )

    @Test fun centreOfHeadIsHeadshot() =
        assertEquals(ShotOutcome.HEADSHOT, DragEvaluator.classify(500f, 200f, target, 1f))

    @Test fun toleranceWidensHeadZone() {
        // 24 px from the centre: outside radius 20, inside 20 * 1.3 = 26.
        assertEquals(ShotOutcome.OVERDRAG, DragEvaluator.classify(500f, 176f, target, 1f))
        assertEquals(ShotOutcome.HEADSHOT, DragEvaluator.classify(500f, 176f, target, 1.3f))
    }

    @Test fun stoppingAtChestIsBody() =
        assertEquals(ShotOutcome.BODY, DragEvaluator.classify(505f, 300f, target, 1f))

    @Test fun neckGapCountsAsBody() =
        assertEquals(ShotOutcome.BODY, DragEvaluator.classify(500f, 222f, target, 1f))

    @Test fun goingAboveHeadIsOverdrag() =
        assertEquals(ShotOutcome.OVERDRAG, DragEvaluator.classify(510f, 120f, target, 1f))

    @Test fun farToTheSideIsMiss() =
        assertEquals(ShotOutcome.MISS, DragEvaluator.classify(600f, 200f, target, 1f))

    @Test fun belowTheFeetIsMiss() =
        assertEquals(ShotOutcome.MISS, DragEvaluator.classify(500f, 560f, target, 1f))

    @Test fun pxToMmUsesDpi() =
        assertEquals(25.4f, DragEvaluator.pxToMm(300f, 300f), 0.001f)

    private fun rec(o: ShotOutcome, reaction: Long = 300, swipe: Long = 200, err: Float = 0f, finger: Float = 10f) =
        ShotRecord(o, reaction, swipe, err, finger, 10f)

    @Test fun summaryCountsAndAverages() {
        val records = listOf(
            rec(ShotOutcome.HEADSHOT, reaction = 200, swipe = 100, err = 0.5f, finger = 9f),
            rec(ShotOutcome.HEADSHOT, reaction = 400, swipe = 300, err = -0.5f, finger = 11f),
            rec(ShotOutcome.OVERDRAG, reaction = 300, swipe = 200, err = 3f),
            rec(ShotOutcome.BODY, reaction = 300, swipe = 200, err = -2f),
            ShotRecord(ShotOutcome.TIMEOUT, -1, 0, 0f, 0f, 10f),
        )
        val s = SessionSummary.from(records)
        assertEquals(5, s.shots)
        assertEquals(2, s.headshots)
        assertEquals(1, s.overdrag)
        assertEquals(1, s.body)
        assertEquals(1, s.timeout)
        assertEquals(40, s.headshotPct)
        // Timeouts are excluded from reaction and swipe averages.
        assertEquals(300, s.avgReactionMs)
        assertEquals(200, s.avgSwipeMs)
        // Mean signed error of the two non-headshot attempts: (3 + -2) / 2.
        assertEquals(0.5f, s.meanSignedErrorMm, 0.001f)
        assertEquals(10f, s.avgHeadshotSwipeMm!!, 0.001f)
    }

    @Test fun noHeadshotsGivesNullSwipe() {
        val s = SessionSummary.from(listOf(rec(ShotOutcome.MISS)))
        assertNull(s.avgHeadshotSwipeMm)
        assertEquals(0, s.headshotPct)
    }

    @Test fun emptySessionIsSafe() {
        val s = SessionSummary.from(emptyList())
        assertEquals(0, s.shots)
        assertEquals(0, s.headshotPct)
        assertEquals("No shots recorded.", s.coachingTip(Weapon.SMG))
    }

    @Test fun tipPointsAtOverdrag() {
        val records = List(6) { rec(ShotOutcome.OVERDRAG, err = 2.5f) } + List(4) { rec(ShotOutcome.HEADSHOT) }
        val tip = SessionSummary.from(records).coachingTip(Weapon.SMG)
        assertTrue(tip, tip.contains("over the head"))
        assertTrue(tip, tip.contains("2.5 mm"))
    }

    @Test fun tipPointsAtStoppingShort() {
        val records = List(6) { rec(ShotOutcome.BODY, err = -1.5f) } + List(4) { rec(ShotOutcome.HEADSHOT) }
        val tip = SessionSummary.from(records).coachingTip(Weapon.AR)
        assertTrue(tip, tip.contains("below the head"))
        assertTrue(tip, tip.contains("1.5 mm"))
    }

    @Test fun tipFlagsSlowSwipes() {
        val records = List(10) { rec(ShotOutcome.HEADSHOT, swipe = 900) }
        val tip = SessionSummary.from(records).coachingTip(Weapon.SHOTGUN)
        assertTrue(tip, tip.contains("900 ms"))
    }

    @Test fun weaponCycleWrapsAround() {
        assertEquals(Weapon.SMG, Weapon.SHOTGUN.next())
        assertEquals(Weapon.SHOTGUN, Weapon.SNIPER.next())
        assertEquals(Weapon.AR, Weapon.fromName("AR"))
        assertNull(Weapon.fromName("ROCKET"))
    }
}
FFDRAG_EOF
cat > 'build.gradle.kts' <<'FFDRAG_EOF'
// Top-level build file.
plugins {
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
}
FFDRAG_EOF
cat > 'gradle.properties' <<'FFDRAG_EOF'
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
org.gradle.caching=true
android.nonTransitiveRClass=true
kotlin.code.style=official
FFDRAG_EOF
cat > 'settings.gradle.kts' <<'FFDRAG_EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "FFDragPro"
include(":app")
FFDRAG_EOF
