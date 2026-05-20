package com.platepilote.platepilote.common.security;

import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
@RequiredArgsConstructor
public class SecurityUtils {

    private final UserRepository userRepository;

    public UUID getCurrentUserId(UserDetails userDetails) {
        String email = userDetails.getUsername();
        OurUser user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found: " + email));
        return user.getId();
    }

    public void verifyOwnership(UUID resourceOwnerId, UUID requestingUserId, String resourceType, String resourceId) {
        if (!resourceOwnerId.equals(requestingUserId)) {
            throw new ResourceNotFoundException(resourceType, "id", resourceId);
        }
    }
}
