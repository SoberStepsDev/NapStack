package com.patrykdev.napstack

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/**
 * Odbiera ACTION_BOOT_COMPLETED i przywraca alarmy Nap Stack.
 *
 * Flow:
 * 1. Android wysyła BOOT_COMPLETED po uruchomieniu systemu.
 * 2. BootReceiver startuje headless FlutterEngine.
 * 3. Przez MethodChannel wywołuje Dart BootRecoveryService.recoverAlarms().
 * 4. Dart pobiera Nap Stack z Appwrite i planuje alarmy FLN.
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

        val engine = FlutterEngine(context)
        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        FlutterEngineCache.getInstance().put(BOOT_ENGINE_ID, engine)

        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
            .invokeMethod("recoverAlarms", null, object : MethodChannel.Result {
                override fun success(result: Any?) {
                    FlutterEngineCache.getInstance().remove(BOOT_ENGINE_ID)
                    engine.destroy()
                }
                override fun error(code: String, msg: String?, details: Any?) {
                    FlutterEngineCache.getInstance().remove(BOOT_ENGINE_ID)
                    engine.destroy()
                }
                override fun notImplemented() {
                    FlutterEngineCache.getInstance().remove(BOOT_ENGINE_ID)
                    engine.destroy()
                }
            })
    }

    companion object {
        const val BOOT_ENGINE_ID = "boot_recovery_engine"
        const val CHANNEL = "com.patrykdev.napstack/boot_recovery"
    }
}
