package com.platepilote.platepilote.common.security;

import jakarta.servlet.http.HttpServletRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.test.util.ReflectionTestUtils;

import static org.assertj.core.api.Assertions.assertThat;

class RateLimitingFilterTest {

    private RateLimitingFilter filter;

    @BeforeEach
    void setUp() {
        filter = new RateLimitingFilter();
        ReflectionTestUtils.setField(filter, "trustedProxies", "");
        ReflectionTestUtils.setField(filter, "maxTrackedClients", 10);
        ReflectionTestUtils.setField(filter, "maxRequests", 100);
        ReflectionTestUtils.setField(filter, "windowSeconds", 60);
    }

    @Test
    void ignoresForwardedHeadersFromUntrustedRemoteAddresses() {
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.setRemoteAddr("198.51.100.10");
        request.addHeader("X-Forwarded-For", "203.0.113.99");

        assertThat(resolveClientIp(request)).isEqualTo("198.51.100.10");
    }

    @Test
    void usesRightMostForwardedAddressOnlyFromConfiguredProxy() {
        ReflectionTestUtils.setField(filter, "trustedProxies", "10.0.0.8, 10.0.0.9");
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.setRemoteAddr("10.0.0.8");
        request.addHeader("X-Forwarded-For", "192.0.2.55, 203.0.113.25");

        assertThat(resolveClientIp(request)).isEqualTo("203.0.113.25");
    }

    @Test
    void evictsOldestTrackedClientWhenConfiguredCapacityIsReached() {
        ReflectionTestUtils.setField(filter, "maxTrackedClients", 1);

        assertThat(allowRequest("198.51.100.1")).isTrue();
        assertThat(allowRequest("198.51.100.2")).isTrue();
        assertThat(allowRequest("198.51.100.1")).isTrue();
    }

    private String resolveClientIp(HttpServletRequest request) {
        return ReflectionTestUtils.invokeMethod(filter, "resolveClientIp", request);
    }

    private boolean allowRequest(String clientIp) {
        return ReflectionTestUtils.invokeMethod(filter, "allowRequest", clientIp);
    }
}
