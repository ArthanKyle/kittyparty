# Keep Stripe SDK classes
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**

# Keep Kotlin metadata (used by Stripe and other libs)
-keepclassmembers class kotlin.Metadata { *; }
