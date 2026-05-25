package com.plateplate.common.util;

import java.text.Normalizer;
import java.util.Locale;

public final class StringNormalizer {

    private StringNormalizer() {}

    public static String normalize(String input) {
        if (input == null || input.isEmpty()) return "";
        String lower = input.toLowerCase(Locale.ROOT).trim();
        return Normalizer.normalize(lower, Normalizer.Form.NFD)
                .replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
    }

    public static String toSlug(String input) {
        return normalize(input)
                .replaceAll("[^a-z0-9\\s-]", "")
                .replaceAll("\\s+", "-")
                .replaceAll("-+", "-")
                .replaceAll("^-|-$", "");
    }

    public static boolean isSimilar(String a, String b, double threshold) {
        if (a == null || b == null) return false;
        String na = normalize(a);
        String nb = normalize(b);
        if (na.equals(nb)) return true;
        int dist = levenshtein(na, nb);
        int maxLen = Math.max(na.length(), nb.length());
        if (maxLen == 0) return true;
        double score = 1.0 - (double) dist / maxLen;
        return score >= threshold;
    }

    public static int levenshtein(String a, String b) {
        int[][] dp = new int[a.length() + 1][b.length() + 1];
        for (int i = 0; i <= a.length(); i++) dp[i][0] = i;
        for (int j = 0; j <= b.length(); j++) dp[0][j] = j;
        for (int i = 1; i <= a.length(); i++) {
            for (int j = 1; j <= b.length(); j++) {
                int cost = a.charAt(i - 1) == b.charAt(j - 1) ? 0 : 1;
                dp[i][j] = Math.min(Math.min(dp[i - 1][j] + 1, dp[i][j - 1] + 1), dp[i - 1][j - 1] + cost);
            }
        }
        return dp[a.length()][b.length()];
    }
}
