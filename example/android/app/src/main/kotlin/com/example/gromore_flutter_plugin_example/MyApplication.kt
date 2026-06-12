package com.example.gromore_flutter_plugin_example

import android.app.Application
import android.content.Context
import android.util.Log

/**
 * 自定义 Application 类，确保广告 SDK 初始化时有正确的 Context。
 * 
 * 这个类的主要目的是：
 * 1. 提供全局可访问的 Application Context
 * 2. 确保广告 SDK 在 Application 完全初始化后才开始工作
 * 3. 防止第三方广告 SDK 在后台服务中访问空 Context
 */
class MyApplication : Application() {

    companion object {
        private const val TAG = "MyApplication"
        
        /**
         * 全局 Application 实例，供广告 SDK 使用
         */
        @Volatile
        private var instance: MyApplication? = null
        
        /**
         * 获取 Application 实例
         */
        @JvmStatic
        fun getInstance(): MyApplication? = instance
        
        /**
         * 安全获取 Application Context
         */
        @JvmStatic
        fun getAppContext(): Context? = instance?.applicationContext
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
        
        Log.i(TAG, "MyApplication onCreate - Context initialized successfully")
        
        // 确保在主线程中初始化
        if (android.os.Looper.myLooper() != android.os.Looper.getMainLooper()) {
            Log.w(TAG, "⚠️ Application.onCreate not on main thread!")
        }
    }

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        Log.d(TAG, "MyApplication attachBaseContext called")
    }
}
