package com.example.familynova.api;

import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.POST;
import java.util.Map;

public interface AuthApi {
    @POST("auth/login")
    Call<Map<String, Object>> login(@Body Map<String, Object> body);
    
    @POST("auth/register")
    Call<Map<String, Object>> register(@Body Map<String, Object> body);
}

