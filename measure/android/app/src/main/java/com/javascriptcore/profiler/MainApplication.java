package com.javascriptcore.profiler;

import android.app.Application;

import com.facebook.react.*;
import com.facebook.react.shell.MainReactPackage;
import com.facebook.soloader.SoLoader;

import java.util.Arrays;
import java.util.List;

public class MainApplication extends Application implements ReactApplication {

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
