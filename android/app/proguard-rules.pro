# NapStack — release R8 / ProGuard keeps (Appwrite, RevenueCat, secure storage, kotlinx.serialization)

# Appwrite Kotlin SDK
-keep class io.appwrite.** { *; }
-keep interface io.appwrite.** { *; }

# RevenueCat / Purchases
-keep class com.revenuecat.purchases.** { *; }
-keep interface com.revenuecat.purchases.** { *; }

# flutter_secure_storage (Android embedding)
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep interface com.it_nomads.fluttersecurestorage.** { *; }

# Kotlin Serialization (runtime / serializers)
-keep class kotlinx.serialization.** { *; }
-keep interface kotlinx.serialization.** { *; }
