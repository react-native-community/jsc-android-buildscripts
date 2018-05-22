package com.javascriptcore.profiler;

import android.app.Application;
import android.util.Log;

import com.facebook.react.ReactApplication;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.shell.MainReactPackage;
import com.facebook.soloader.SoLoader;

import java.util.Arrays;
import java.util.List;

public class MainApplication extends Application implements ReactApplication {
	public static final String TAG = "JavaScriptCoreProfiler";

	@Override
	public void onCreate() {
		super.onCreate();
		Log.d(TAG, TAG + ":ApplicationOnCreate:" + System.currentTimeMillis());
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
