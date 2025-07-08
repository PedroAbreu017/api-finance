package com.example.azure_sql_demo.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Arrays;
import java.util.Collection;
import java.util.stream.Collectors;

@Component
@Slf4j
public class JwtRequestFilter extends OncePerRequestFilter {

    @Autowired
    private UserDetailsService userDetailsService;

    @Autowired
    private JwtTokenUtil jwtTokenUtil;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {

        final String requestTokenHeader = request.getHeader("Authorization");

        String username = null;
        String jwtToken = null;

        // JWT Token is in the form "Bearer token". Remove Bearer word and get only the Token
        if (requestTokenHeader != null && requestTokenHeader.startsWith("Bearer ")) {
            jwtToken = requestTokenHeader.substring(7);
            try {
                username = jwtTokenUtil.getUsernameFromToken(jwtToken);
            } catch (IllegalArgumentException e) {
                log.error("Unable to get JWT Token", e);
            } catch (Exception e) {
                log.error("JWT Token has expired or is invalid", e);
            }
        } else {
            log.debug("JWT Token does not begin with Bearer String");
        }

        // Once we get the token validate it.
        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {

            UserDetails userDetails = this.userDetailsService.loadUserByUsername(username);

            // if token is valid configure Spring Security to manually set authentication
            if (jwtTokenUtil.validateToken(jwtToken, userDetails)) {
                
                // CORREÇÃO CRÍTICA: Extrair authorities DO TOKEN, não do UserDetails
                String authoritiesFromToken = jwtTokenUtil.getAuthoritiesFromToken(jwtToken);
                
                Collection<SimpleGrantedAuthority> authorities;
                
                if (StringUtils.hasText(authoritiesFromToken)) {
                    // Converter string de authorities do token em Collection<GrantedAuthority>
                    authorities = Arrays.stream(authoritiesFromToken.split(","))
                            .map(String::trim)
                            .map(SimpleGrantedAuthority::new)
                            .collect(Collectors.toList());
                    
                    log.debug("Authorities from token: {}", authorities.stream()
                            .map(SimpleGrantedAuthority::getAuthority)
                            .collect(Collectors.toList()));
                } else {
                    // Fallback: usar authorities do UserDetails se não houver no token
                    authorities = userDetails.getAuthorities().stream()
                            .map(auth -> new SimpleGrantedAuthority(auth.getAuthority()))
                            .collect(Collectors.toList());
                    
                    log.debug("Using authorities from UserDetails: {}", authorities.stream()
                            .map(SimpleGrantedAuthority::getAuthority)
                            .collect(Collectors.toList()));
                }

                UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                        userDetails, null, authorities); // ← USAR AUTHORITIES DO TOKEN!
                        
                authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authToken);
                
                log.debug("Successfully set authentication for user: {} with authorities: {}", 
                        username, authorities.stream()
                                .map(SimpleGrantedAuthority::getAuthority)
                                .collect(Collectors.toList()));
            }
        }
        chain.doFilter(request, response);
    }
}