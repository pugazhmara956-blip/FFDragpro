# FF DRAG PRO source, part 6 of 7
mkdir -p 'app/src/main/res/drawable'
cat > 'app/src/main/res/drawable/bg_button_primary.xml' <<'FFDRAG_EOF'
<?xml version="1.0" encoding="utf-8"?>
<ripple xmlns:android="http://schemas.android.com/apk/res/android" android:color="#33FFFFFF">
    <item>
        <selector>
            <item android:state_enabled="false">
                <shape android:shape="rectangle">
                    <solid android:color="@color/btn_disabled" />
                    <corners android:radius="12dp" />
                </shape>
            </item>
            <item>
                <shape android:shape="rectangle">
                    <solid android:color="@color/brand" />
                    <corners android:radius="12dp" />
                </shape>
            </item>
        </selector>
    </item>
</ripple>
FFDRAG_EOF
mkdir -p 'app/src/main/res/drawable'
cat > 'app/src/main/res/drawable/bg_card.xml' <<'FFDRAG_EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="@color/card" />
    <corners android:radius="16dp" />
    <stroke android:width="1dp" android:color="@color/stroke" />
</shape>
FFDRAG_EOF
mkdir -p 'app/src/main/res/drawable'
cat > 'app/src/main/res/drawable/ic_launcher_foreground.xml' <<'FFDRAG_EOF'
<?xml version="1.0" encoding="utf-8"?>
<!-- 108dp adaptive-icon foreground: crosshair with an upward drag arrow, inside the 66dp safe zone. -->
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <path
        android:fillColor="#00000000"
        android:strokeColor="#FFFFFFFF"
        android:strokeWidth="4.5"
        android:pathData="M40,64 a14,14 0 1,0 28,0 a14,14 0 1,0 -28,0" />
    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M50.5,64 a3.5,3.5 0 1,0 7,0 a3.5,3.5 0 1,0 -7,0" />
    <path
        android:fillColor="#00000000"
        android:strokeColor="#FFFFFFFF"
        android:strokeWidth="4.5"
        android:strokeLineCap="round"
        android:pathData="M29,64 L35,64 M73,64 L79,64 M54,82 L54,86" />
    <path
        android:fillColor="#00000000"
        android:strokeColor="#FFFFFFFF"
        android:strokeWidth="4.5"
        android:strokeLineCap="round"
        android:strokeLineJoin="round"
        android:pathData="M54,46 L54,26 M45.5,34 L54,25 L62.5,34" />
</vector>
FFDRAG_EOF
mkdir -p 'app/src/main/res/drawable'
cat > 'app/src/main/res/drawable/ic_stat_ffdrag.xml' <<'FFDRAG_EOF'
<?xml version="1.0" encoding="utf-8"?>
<!-- Notification icon (white on transparent). -->
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#00000000"
        android:strokeColor="#FFFFFFFF"
        android:strokeWidth="2"
        android:pathData="M7,15 a5,5 0 1,0 10,0 a5,5 0 1,0 -10,0" />
    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M11,15 a1,1 0 1,0 2,0 a1,1 0 1,0 -2,0" />
    <path
        android:fillColor="#00000000"
        android:strokeColor="#FFFFFFFF"
        android:strokeWidth="2"
        android:strokeLineCap="round"
        android:strokeLineJoin="round"
        android:pathData="M12,8 L12,2.5 M9,5.5 L12,2.5 L15,5.5" />
</vector>
FFDRAG_EOF
mkdir -p 'app/src/main/res/layout'
cat > 'app/src/main/res/layout/activity_guide.xml' <<'FFDRAG_EOF'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/bg"
    android:fitsSystemWindows="true">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:padding="16dp">

        <TextView
            style="@style/ScreenTitle"
            android:text="@string/guide_title" />

        <LinearLayout style="@style/Card">

            <TextView
                style="@style/CardTitle"
                android:text="@string/guide_fundamentals_title" />

            <TextView
                style="@style/Body"
                android:text="@string/guide_fundamentals" />
        </LinearLayout>

        <HorizontalScrollView
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="14dp"
            android:scrollbars="none">

            <LinearLayout
                android:id="@+id/weaponTabs"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:orientation="horizontal" />
        </HorizontalScrollView>

        <LinearLayout style="@style/Card">

            <TextView
                android:id="@+id/tvWeaponTitle"
                style="@style/CardTitle" />

            <TextView
                android:id="@+id/tvWeaponTips"
                style="@style/Body" />

            <TextView
                android:id="@+id/tvPersonal"
                style="@style/Body"
                android:layout_marginTop="12dp"
                android:textColor="@color/brand" />

            <Button
                android:id="@+id/btnPractice"
                style="@style/BtnPrimary"
                android:layout_marginTop="12dp"
                android:text="@string/guide_practice" />
        </LinearLayout>

        <LinearLayout style="@style/Card">

            <TextView
                style="@style/CardTitle"
                android:text="@string/guide_how_trainer_title" />

            <TextView
                style="@style/Body"
                android:text="@string/guide_how_trainer" />
        </LinearLayout>

        <TextView
            style="@style/Small"
            android:layout_marginTop="16dp"
            android:text="@string/fair_play" />
    </LinearLayout>
</ScrollView>
FFDRAG_EOF
mkdir -p 'app/src/main/res/layout'
cat > 'app/src/main/res/layout/activity_main.xml' <<'FFDRAG_EOF'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/bg"
    android:fillViewport="true"
    android:fitsSystemWindows="true">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:padding="16dp">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:gravity="center_vertical"
            android:orientation="horizontal">

            <ImageView
                android:layout_width="52dp"
                android:layout_height="52dp"
                android:contentDescription="@string/app_name"
                android:src="@mipmap/ic_launcher" />

            <LinearLayout
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_marginStart="12dp"
                android:layout_weight="1"
                android:orientation="vertical">

                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="@string/app_name"
                    android:textColor="@color/text"
                    android:textSize="24sp"
                    android:textStyle="bold" />

                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="@string/tagline"
                    android:textColor="@color/text_dim"
                    android:textSize="13sp" />
            </LinearLayout>
        </LinearLayout>

        <!-- Game -->
        <LinearLayout style="@style/Card">

            <TextView
                style="@style/CardTitle"
                android:text="@string/card_game" />

            <TextView
                android:id="@+id/tvGameStatus"
                style="@style/Body" />

            <Button
                android:id="@+id/btnLaunchGame"
                style="@style/BtnPrimary"
                android:layout_marginTop="12dp"
                android:text="@string/launch_game" />

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="horizontal">

                <Button
                    android:id="@+id/btnChooseGame"
                    style="@style/Btn"
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:text="@string/choose_game" />

                <Button
                    android:id="@+id/btnGetGame"
                    style="@style/Btn"
                    android:layout_width="0dp"
                    android:layout_marginStart="8dp"
                    android:layout_weight="1"
                    android:text="@string/get_game" />
            </LinearLayout>
        </LinearLayout>

        <!-- Floating panel -->
        <LinearLayout style="@style/Card">

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:gravity="center_vertical"
                android:orientation="horizontal">

                <TextView
                    style="@style/CardTitle"
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:text="@string/card_overlay" />

                <Switch
                    android:id="@+id/swOverlay"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:minHeight="48dp" />
            </LinearLayout>

            <TextView
                android:id="@+id/tvOverlayHint"
                style="@style/Body" />

            <Button
                android:id="@+id/btnAppPermissions"
                style="@style/Btn"
                android:text="@string/app_permissions" />
        </LinearLayout>

        <!-- Trainer -->
        <LinearLayout style="@style/Card">

            <TextView
                style="@style/CardTitle"
                android:text="@string/card_train" />

            <TextView
                android:id="@+id/tvTrainConfig"
                style="@style/Body" />

            <LinearLayout
                android:id="@+id/weaponButtons"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="vertical" />
        </LinearLayout>

        <!-- More -->
        <LinearLayout style="@style/Card">

            <TextView
                style="@style/CardTitle"
                android:text="@string/card_more" />

            <Button
                android:id="@+id/btnGuide"
                style="@style/Btn"
                android:text="@string/guide_title" />

            <Button
                android:id="@+id/btnStats"
                style="@style/Btn"
                android:text="@string/stats_title" />

            <Button
                android:id="@+id/btnSettings"
                style="@style/Btn"
                android:text="@string/settings_title" />
        </LinearLayout>

        <TextView
            style="@style/Small"
            android:layout_marginTop="16dp"
            android:layout_marginBottom="8dp"
            android:text="@string/fair_play" />
    </LinearLayout>
</ScrollView>
FFDRAG_EOF
mkdir -p 'app/src/main/res/layout'
cat > 'app/src/main/res/layout/activity_settings.xml' <<'FFDRAG_EOF'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/bg"
    android:fitsSystemWindows="true">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:padding="16dp">

        <TextView
            style="@style/ScreenTitle"
            android:text="@string/settings_title" />

        <LinearLayout style="@style/Card">

            <TextView
                style="@style/CardTitle"
                android:text="@string/set_training" />

            <TextView
                android:id="@+id/tvSensitivity"
                style="@style/Body"
                android:layout_marginTop="12dp"
                android:textColor="@color/text" />

            <SeekBar
                android:id="@+id/seekSensitivity"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:minHeight="40dp" />

            <TextView
                style="@style/Small"
                android:text="@string/set_sensitivity_hint" />

            <TextView
                android:id="@+id/tvSpeed"
                style="@style/Body"
                android:layout_marginTop="14dp"
                android:textColor="@color/text" />

            <SeekBar
                android:id="@+id/seekSpeed"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:minHeight="40dp" />

            <TextView
                style="@style/Small"
                android:text="@string/set_speed_hint" />

            <TextView
                android:id="@+id/tvRounds"
                style="@style/Body"
                android:layout_marginTop="14dp"
                android:textColor="@color/text" />

            <SeekBar
                android:id="@+id/seekRounds"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:minHeight="40dp" />

            <Switch
                android:id="@+id/swGuide"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="10dp"
                android:minHeight="48dp"
                android:text="@string/set_guide"
                android:textColor="@color/text" />

            <Switch
                android:id="@+id/swHaptics"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:minHeight="48dp"
                android:text="@string/set_haptics"
                android:textColor="@color/text" />
        </LinearLayout>

        <LinearLayout style="@style/Card">

            <TextView
                style="@style/CardTitle"
                android:text="@string/set_overlay" />

            <TextView
                android:id="@+id/tvOverlayAlpha"
                style="@style/Body"
                android:layout_marginTop="12dp"
                android:textColor="@color/text" />

            <SeekBar
                android:id="@+id/seekOverlayAlpha"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:minHeight="40dp" />

            <Switch
                android:id="@+id/swLockOverlay"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="6dp"
                android:minHeight="48dp"
                android:text="@string/set_lock_overlay"
                android:textColor="@color/text" />

            <Button
                android:id="@+id/btnResetOverlay"
                style="@style/Btn"
                android:text="@string/set_overlay_reset" />
        </LinearLayout>
    </LinearLayout>
</ScrollView>
FFDRAG_EOF
mkdir -p 'app/src/main/res/layout'
cat > 'app/src/main/res/layout/activity_stats.xml' <<'FFDRAG_EOF'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/bg"
    android:fitsSystemWindows="true">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:padding="16dp">

        <TextView
            style="@style/ScreenTitle"
            android:text="@string/stats_title" />

        <LinearLayout style="@style/Card">

            <TextView
                style="@style/CardTitle"
                android:text="@string/stats_overview" />

            <TextView
                android:id="@+id/tvOverview"
                style="@style/Body" />
        </LinearLayout>

        <TextView
            style="@style/CardTitle"
            android:layout_marginTop="18dp"
            android:text="@string/stats_recent" />

        <TextView
            android:id="@+id/tvEmpty"
            style="@style/Body"
            android:text="@string/stats_empty_list" />

        <LinearLayout
            android:id="@+id/historyList"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical" />

        <Button
            android:id="@+id/btnClearHistory"
            style="@style/Btn"
            android:layout_marginTop="16dp"
            android:text="@string/stats_clear" />
    </LinearLayout>
</ScrollView>
FFDRAG_EOF
mkdir -p 'app/src/main/res/layout'
cat > 'app/src/main/res/layout/activity_trainer.xml' <<'FFDRAG_EOF'
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/bg"
    android:keepScreenOn="true">

    <com.ffdragpro.app.TrainerView
        android:id="@+id/trainerView"
        android:layout_width="match_parent"
        android:layout_height="match_parent" />

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_gravity="top"
        android:gravity="center_vertical"
        android:orientation="horizontal"
        android:paddingStart="40dp"
        android:paddingTop="10dp"
        android:paddingEnd="40dp">

        <TextView
            android:id="@+id/tvHud"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:textColor="@color/text"
            android:textSize="14sp" />

        <Button
            android:id="@+id/btnStop"
            style="@style/BtnCompact"
            android:text="@string/stop"
            android:visibility="gone" />
    </LinearLayout>

    <LinearLayout
        android:id="@+id/idleControls"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="bottom|center_horizontal"
        android:layout_marginBottom="16dp"
        android:orientation="horizontal">

        <Button
            android:id="@+id/btnWeapon"
            style="@style/BtnCompact" />

        <Button
            android:id="@+id/btnSpeed"
            style="@style/BtnCompact" />

        <Button
            android:id="@+id/btnGuideToggle"
            style="@style/BtnCompact" />

        <Button
            android:id="@+id/btnStart"
            style="@style/BtnCompactPrimary"
            android:text="@string/start" />

        <Button
            android:id="@+id/btnExit"
            st
