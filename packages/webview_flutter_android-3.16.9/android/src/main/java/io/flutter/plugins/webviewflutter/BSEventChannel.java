package io.flutter.plugins.webviewflutter;
import android.util.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry;
public class BSEventChannel implements EventChannel.StreamHandler {
    public static final String CHANNEL = "kitty";
    public static EventChannel.EventSink bsSink;
    // private Activity activity;
    public static EventChannel channel;
    public static BSEventChannel registerWith(FlutterPlugin.FlutterPluginBinding binding) {
        channel = new EventChannel(binding.getBinaryMessenger(), CHANNEL);
    // channel = new EventChannel(registrar.messenger(), CHANNEL);
        BSEventChannel instance = new BSEventChannel();
        channel.setStreamHandler(instance);
        return instance;
    }
    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {

        bsSink = events;
    }
    @Override
    public void onCancel(Object arguments) {
        bsSink = null;
    }
    public void sendEvent(Object o) {
        if (bsSink != null) {
            bsSink.success(o);
        }
    }
}