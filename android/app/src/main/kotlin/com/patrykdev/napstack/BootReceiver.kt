package com.patrykdev.napstack

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

/**
 * Odbiera ACTION_BOOT_COMPLETED i przywraca alarmy Nap Stack.
 *
 * Flow:
 * 1. Android wysyła BOOT_COMPLETED po uruchomieniu systemu.
 * 2. BootReceiver startuje headless FlutterEngine (bootRecoveryMain — kanał od razu).
 * 3. MethodChannel wywołuje recoverAlarms; Result na Kotlinie dopiero po Future z Dart.
 * 4. Dart: BootRecoveryService — Appwrite + planowanie alarmów; potem silnik jest zamykany.
 *
 * Wymagane w AndroidManifest.xml:
 * <receiver android:name=".BootReceiver" android:exported="true">
 *   <intent-filter>
 *     <action android:name="android.intent.action.BOOT_COMPLETED"/>
 *   </intent-filter>
 * </receiver>
 * Uprawnienie: <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
 */
class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return

        val appContext = context.applicationContext
        val loader = FlutterInjector.instance().flutterLoader()
        if (!loader.initialized()) {
            loader.startInitialization(appContext)
        }
        loader.ensureInitializationComplete(appContext, null)

        val engine = FlutterEngine(appContext)
        GeneratedPluginRegistrant.registerWith(engine)

        val bundlePath = loader.findAppBundlePath()
        val entrypoint = DartExecutor.DartEntrypoint(
            bundlePath,
            "package:napstack/boot_recovery_entry.dart",
            "bootRecoveryMain",
        )
        engine.dartExecutor.executeDartEntrypoint(entrypoint)
        FlutterEngineCache.getInstance().put(BOOT_ENGINE_ID, engine)

        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
            .invokeMethod("recoverAlarms", null, object : MethodChannel.Result {
                override fun success(result: Any?) {
                    tearDown(engine)
                }

                override fun error(code: String, msg: String?, details: Any?) {
                    tearDown(engine)
                }

                override fun notImplemented() {
                    tearDown(engine)
                }
            })
    }

    private fun tearDown(engine: FlutterEngine) {
        FlutterEngineCache.getInstance().remove(BOOT_ENGINE_ID)
        engine.destroy()
    }

    companion object {
        const val BOOT_ENGINE_ID = "boot_recovery_engine"
        const val CHANNEL = "com.patrykdev.napstack/boot_recovery"
    }
}
