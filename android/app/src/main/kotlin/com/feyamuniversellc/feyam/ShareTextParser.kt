package com.feyamuniversellc.feyam

/**
 * Splits the raw text delivered by an OS share intent (e.g. Amazon's
 * "Product title https://a.co/d/xxx") into a bare URL and a candidate
 * product title, so downstream consumers never receive a blob with the
 * title still glued to the link.
 */
object ShareTextParser {
    private val urlRegex = Regex("https?://\\S+")

    fun parse(sharedText: String?): Map<String, String>? {
        val text = sharedText?.trim() ?: return null
        if (text.isEmpty()) return null

        val match = urlRegex.find(text)
        val url = match?.value ?: text
        val title = if (match != null) {
            (text.substring(0, match.range.first) + text.substring(match.range.last + 1))
                .trim()
                .trim('-', '–', '—', ' ')
        } else {
            ""
        }

        return mapOf("url" to url, "title" to title)
    }
}
