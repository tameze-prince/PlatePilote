package com.platepilote.platepilote.common.dto;

/**
 * PAGED RESPONSE - WRAPPER FOR PAGINATED LIST RESPONSES
 * ======================================================
 * 
 * WHAT IT IS:
 * A wrapper for API responses that return lists of items (e.g., list of recipes).
 * 
 * WHY IT EXISTS:
 * When returning lists, we don't want to send ALL items at once (could be thousands).
 * Instead, we send pages of items (e.g., 20 per page) with pagination metadata.
 * 
 * EXAMPLE RESPONSE:
 * {
 *   "content": [recipe1, recipe2, recipe3],
 *   "page": 0,
 *   "size": 20,
 *   "totalElements": 150,
 *   "totalPages": 8,
 *   "last": false
 * }
 * 
 * HOW FLUTTER APP USES THIS:
 * - Shows items from "content" array
 * - Shows "Page 1 of 8" using page and totalPages
 * - Loads next page when user scrolls down
 */

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.List;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PagedResponse<T> implements Serializable {

    private static final long serialVersionUID = 1L;

    private List<T> content;     // The actual items on this page
    private int page;            // Current page number (0-indexed)
    private int size;            // Number of items per page
    private long totalElements;  // Total number of items across all pages
    private int totalPages;      // Total number of pages
    private boolean last;        // True if this is the last page

    public static <T> PagedResponse<T> of(List<T> content, int page, int size, long totalElements) {
        int totalPages = (int) Math.ceil((double) totalElements / size);
        return PagedResponse.<T>builder()
                .content(content)
                .page(page)
                .size(size)
                .totalElements(totalElements)
                .totalPages(totalPages)
                .last(page >= totalPages - 1)
                .build();
    }
}
