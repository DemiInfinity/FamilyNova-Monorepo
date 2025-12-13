package com.example.familynovaparent.api;

import android.content.Context;
import android.content.SharedPreferences;
import okhttp3.OkHttpClient;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;
import java.util.concurrent.TimeUnit;

public class ApiClient {
    private static Retrofit retrofit = null;
    private static final String BASE_URL = "https://family-nova-monorepo.vercel.app/api/";
    
    public static Retrofit getClient(Context context) {
        if (retrofit == null) {
            // Get base URL from SharedPreferences or use default
            SharedPreferences prefs = context.getSharedPreferences("FamilyNovaParent", Context.MODE_PRIVATE);
            String baseUrl = prefs.getString("api_base_url", BASE_URL);
            
            // Add trailing slash if not present
            if (!baseUrl.endsWith("/")) {
                baseUrl += "/";
            }
            
            // Create logging interceptor
            HttpLoggingInterceptor logging = new HttpLoggingInterceptor();
            logging.setLevel(HttpLoggingInterceptor.Level.BODY);
            
            // Create OkHttp client
            OkHttpClient client = new OkHttpClient.Builder()
                    .addInterceptor(logging)
                    .addInterceptor(chain -> {
                        // Add auth token to requests
                        SharedPreferences sharedPrefs = context.getSharedPreferences("FamilyNovaParent", Context.MODE_PRIVATE);
                        String token = sharedPrefs.getString("token", null);
                        
                        if (token != null) {
                            return chain.proceed(chain.request().newBuilder()
                                    .addHeader("Authorization", "Bearer " + token)
                                    .build());
                        }
                        return chain.proceed(chain.request());
                    })
                    .connectTimeout(30, TimeUnit.SECONDS)
                    .readTimeout(30, TimeUnit.SECONDS)
                    .writeTimeout(30, TimeUnit.SECONDS)
                    .build();
            
            retrofit = new Retrofit.Builder()
                    .baseUrl(baseUrl)
                    .client(client)
                    .addConverterFactory(GsonConverterFactory.create())
                    .build();
        }
        return retrofit;
    }
    
    public static void resetClient() {
        retrofit = null;
    }
}

