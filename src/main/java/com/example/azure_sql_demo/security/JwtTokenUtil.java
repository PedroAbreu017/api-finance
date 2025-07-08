package com.example.azure_sql_demo.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Component
@Slf4j
public class JwtTokenUtil {

    @Value("${app.jwt.secret}")
    private String jwtSecret;

    @Value("${app.jwt.expiration}")
    private Long jwtExpiration;

    @Value("${app.jwt.refresh-expiration:604800000}")
    private Long jwtRefreshExpiration;

    @Value("${app.jwt.issuer:financeiro-api}")
    private String jwtIssuer;

    // ========== TOKEN GENERATION ==========

    /**
     * Generate JWT token from username
     */
    public String generateToken(String username) {
        log.debug("Generating JWT token for username: {}", username);
        Map<String, Object> claims = new HashMap<>();
        return createToken(claims, username, jwtExpiration);
    }

    /**
     * Generate JWT token from UserDetails
     */
    public String generateToken(UserDetails userDetails) {
        log.debug("Generating JWT token for user: {}", userDetails.getUsername());

        // Garante que todas as authorities estejam com prefixo ROLE_
        String authorities = userDetails.getAuthorities().stream()
            .map(authority -> {
                String role = authority.getAuthority();
                return role.startsWith("ROLE_") ? role : "ROLE_" + role;
            })
            .collect(java.util.stream.Collectors.joining(","));

        log.info("Authorities in token: {}", authorities);

        Map<String, Object> claims = new HashMap<>();
        claims.put("authorities", authorities);
        claims.put("type", "access_token");
        
        return createToken(claims, userDetails.getUsername(), jwtExpiration);
    }

    /**
     * Generate refresh token
     */
    public String generateRefreshToken(String username) {
        log.debug("Generating refresh token for username: {}", username);
        Map<String, Object> claims = new HashMap<>();
        claims.put("type", "refresh_token");
        return createToken(claims, username, jwtRefreshExpiration);
    }

    /**
     * Generate refresh token from UserDetails
     */
    public String generateRefreshToken(UserDetails userDetails) {
        log.debug("Generating refresh token for user: {}", userDetails.getUsername());
        return generateRefreshToken(userDetails.getUsername());
    }

    // ========== TOKEN EXTRACTION ==========

    /**
     * Extract username from token
     */
    public String getUsernameFromToken(String token) {
        return getClaimFromToken(token, Claims::getSubject);
    }

    /**
     * Extract expiration date from token
     */
    public Date getExpirationDateFromToken(String token) {
        return getClaimFromToken(token, Claims::getExpiration);
    }

    /**
     * Extract authorities from token
     */
    public String getAuthoritiesFromToken(String token) {
        try {
            Claims claims = getAllClaimsFromToken(token);
            return claims.get("authorities", String.class);
        } catch (Exception e) {
            log.error("Error parsing authorities from token", e);
            return null;
        }
    }

    /**
     * Extract issuer from token
     */
    public String getIssuerFromToken(String token) {
        return getClaimFromToken(token, Claims::getIssuer);
    }

    /**
     * Extract issued at date from token
     */
    public Date getIssuedAtDateFromToken(String token) {
        return getClaimFromToken(token, Claims::getIssuedAt);
    }

    // ========== TOKEN VALIDATION ==========

    /**
     * Validate token with username
     */
    public boolean validateToken(String token, String username) {
        try {
            final String tokenUsername = getUsernameFromToken(token);
            return (tokenUsername.equals(username) && !isTokenExpired(token));
        } catch (Exception e) {
            log.debug("Token validation failed: {}", e.getMessage());
            return false;
        }
    }

    /**
     * Validate token with UserDetails
     */
    public boolean validateToken(String token, UserDetails userDetails) {
        return validateToken(token, userDetails.getUsername());
    }

    /**
     * Check if token is expired
     */
    public boolean isTokenExpired(String token) {
        final Date expiration = getExpirationDateFromToken(token);
        return expiration.before(new Date());
    }

    /**
     * Check if token is valid (not expired and properly signed)
     */
    public boolean isTokenValid(String token) {
        try {
            getAllClaimsFromToken(token); // This will throw exception if invalid
            return !isTokenExpired(token);
        } catch (Exception e) {
            log.debug("Token validation failed: {}", e.getMessage());
            return false;
        }
    }

    // ========== GETTERS ==========

    /**
     * Get JWT expiration time in milliseconds
     */
    public Long getJwtExpiration() {
        return jwtExpiration;
    }

    /**
     * Get JWT refresh expiration time in milliseconds
     */
    public Long getJwtRefreshExpiration() {
        return jwtRefreshExpiration;
    }

    /**
     * Get JWT expiration time in seconds
     */
    public Long getJwtExpirationInSeconds() {
        return jwtExpiration / 1000;
    }

    // ========== PRIVATE HELPER METHODS ==========

    /**
     * Create JWT token with claims
     */
    private String createToken(Map<String, Object> claims, String subject, Long expiration) {
        try {
            Date now = new Date();
            Date expiryDate = new Date(now.getTime() + expiration);

            SecretKey key = getSigningKey();

            return Jwts.builder()
                    .setClaims(claims)
                    .setSubject(subject)
                    .setIssuer(jwtIssuer)
                    .setIssuedAt(now)
                    .setExpiration(expiryDate)
                    .signWith(key, SignatureAlgorithm.HS256)
                    .compact();

        } catch (Exception e) {
            log.error("Error creating JWT token: {}", e.getMessage());
            throw new RuntimeException("Error creating JWT token", e);
        }
    }

    /**
     * Extract claim from token
     */
    private <T> T getClaimFromToken(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = getAllClaimsFromToken(token);
        return claimsResolver.apply(claims);
    }

    /**
     * Get all claims from token
     */
    private Claims getAllClaimsFromToken(String token) {
        try {
            SecretKey key = getSigningKey();
            return Jwts.parserBuilder()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
        } catch (ExpiredJwtException e) {
            log.debug("JWT token is expired: {}", e.getMessage());
            throw e;
        } catch (UnsupportedJwtException e) {
            log.debug("JWT token is unsupported: {}", e.getMessage());
            throw e;
        } catch (MalformedJwtException e) {
            log.debug("JWT token is malformed: {}", e.getMessage());
            throw e;
        } catch (SecurityException e) {
            log.debug("JWT signature does not match: {}", e.getMessage());
            throw e;
        } catch (IllegalArgumentException e) {
            log.debug("JWT token compact of handler are invalid: {}", e.getMessage());
            throw e;
        }
    }

    /**
     * Get signing key from secret
     */
    private SecretKey getSigningKey() {
        byte[] keyBytes = jwtSecret.getBytes();
        return Keys.hmacShaKeyFor(keyBytes);
    }

    // ========== TOKEN UTILITIES ==========

    /**
     * Get token type from claims
     */
    public String getTokenType(String token) {
        try {
            Claims claims = getAllClaimsFromToken(token);
            return claims.get("type", String.class);
        } catch (Exception e) {
            log.debug("Error getting token type: {}", e.getMessage());
            return null;
        }
    }

    /**
     * Check if token is refresh token
     */
    public boolean isRefreshToken(String token) {
        return "refresh_token".equals(getTokenType(token));
    }

    /**
     * Check if token is access token
     */
    public boolean isAccessToken(String token) {
        return "access_token".equals(getTokenType(token));
    }

    /**
     * Get remaining time until token expires (in milliseconds)
     */
    public long getRemainingTimeUntilExpiration(String token) {
        Date expiration = getExpirationDateFromToken(token);
        return expiration.getTime() - System.currentTimeMillis();
    }

    /**
     * Check if token will expire soon (within 5 minutes)
     */
    public boolean willExpireSoon(String token) {
        long remainingTime = getRemainingTimeUntilExpiration(token);
        return remainingTime < 300000; // 5 minutes in milliseconds
    }
}