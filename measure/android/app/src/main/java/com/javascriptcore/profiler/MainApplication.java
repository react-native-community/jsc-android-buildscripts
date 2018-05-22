package com.javascriptcore.profiler;

import android.app.Application;

import com.facebook.react.ReactApplication;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.shell.MainReactPackage;
import com.facebook.soloader.SoLoader;

import java.util.Arrays;
import java.util.List;

public class MainApplication extends Application implements ReactApplication {
	public static final String TAG = "JavaScriptCoreProfiler";
	public static final long appStartTime = System.currentTimeMillis();

	@Override
	public void onCreate() {
		super.onCreate();
		SoLoader.init(this, false);
	}

	private ReactNativeHost host = new ReactNativeHost(this) {
		@Override
		public boolean getUseDeveloperSupport() {
			return false;
		}

		@Override
		protected List<ReactPackage> getPackages() {
			return Arrays.<ReactPackage>asList(new MainReactPackage());
		}
	};

	@Override
	public ReactNativeHost getReactNativeHost() {
		return host;
	}
}
