// AuthResponse.java
package com.example.azure_sql_demo.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Set;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    
    private String token;
    
    @Builder.Default
    private String type = "Bearer";
    
    private Long id;
    
    private String username;
    
    private String email;
    
    private Set<String> roles;
    
    private Long expiresIn;
}

