package com.ecommerce.gateway.filter;

import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.function.Predicate;

@Component
public class RouteValidator {

        public static final List<String> openApiEndpoints = List.of(
                        "/api/auth/register",
                        "/api/auth/token",
                        "/api/auth/validate",
                        "/api/auth/verify",
                        "/eureka",
                        "/api-docs",
                        "/v3/api-docs",
                        "/webjars",
                        "/swagger-ui.html",
                        "/swagger-ui",
                        "/swagger-resources");

        public Predicate<ServerHttpRequest> isSecured = request -> openApiEndpoints
                        .stream()
                        .noneMatch(uri -> request.getURI().getPath().contains(uri));
}
