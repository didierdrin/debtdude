package com.example.debtdude

import android.content.ContentResolver
import android.database.Cursor
import android.net.Uri
import android.provider.Telephony
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

class SmsReaderPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var contentResolver: ContentResolver? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "sms_reader")
        channel.setMethodCallHandler(this)
        contentResolver = flutterPluginBinding.applicationContext.contentResolver
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getInboxSms" -> {
                try {
                    val smsList = getInboxSms()
                    result.success(smsList)
                } catch (e: Exception) {
                    result.error("SMS_ERROR", "Failed to read SMS", e.toString())
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun getInboxSms(): List<Map<String, Any?>> {
        val smsList = mutableListOf<Map<String, Any?>>()
        val uri: Uri = Telephony.Sms.Inbox.CONTENT_URI
        val cursor: Cursor? = contentResolver?.query(
            uri,
            arrayOf(
                Telephony.Sms.ADDRESS,
                Telephony.Sms.BODY,
                Telephony.Sms.DATE
            ),
            null,
            null,
            "${Telephony.Sms.DATE} DESC"
        )

        cursor?.use { c ->
            val addressIndex = c.getColumnIndex(Telephony.Sms.ADDRESS)
            val bodyIndex = c.getColumnIndex(Telephony.Sms.BODY)
            val dateIndex = c.getColumnIndex(Telephony.Sms.DATE)

            while (c.moveToNext()) {
                val address = if (addressIndex >= 0) c.getString(addressIndex) else null
                val body = if (bodyIndex >= 0) c.getString(bodyIndex) else null
                val date = if (dateIndex >= 0) c.getLong(dateIndex) else null

                if (body != null && body.isNotEmpty()) {
                    smsList.add(
                        mapOf(
                            "address" to address,
                            "body" to body,
                            "date" to date
                        )
                    )
                }
            }
        }

        return smsList
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        contentResolver = null
    }
}