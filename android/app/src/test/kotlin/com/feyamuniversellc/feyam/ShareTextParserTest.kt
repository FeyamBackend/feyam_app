package com.feyamuniversellc.feyam

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class ShareTextParserTest {

    @Test
    fun `splits a title glued to a short URL like Amazon's share sheet`() {
        val result = ShareTextParser.parse(
            "Amazon Essentials - Pantalón chino casual elástico de corte recto " +
                "para hombre https://a.co/d/0cHTXkqu",
        )

        assertEquals("https://a.co/d/0cHTXkqu", result?.get("url"))
        assertEquals(
            "Amazon Essentials - Pantalón chino casual elástico de corte recto para hombre",
            result?.get("title"),
        )
    }

    @Test
    fun `a bare URL with no title yields an empty title`() {
        val result = ShareTextParser.parse("https://a.co/d/0cHTXkqu")

        assertEquals("https://a.co/d/0cHTXkqu", result?.get("url"))
        assertEquals("", result?.get("title"))
    }

    @Test
    fun `URL appearing before the title is still extracted correctly`() {
        val result = ShareTextParser.parse("https://a.co/d/0cHTXkqu - great pants")

        assertEquals("https://a.co/d/0cHTXkqu", result?.get("url"))
        assertEquals("great pants", result?.get("title"))
    }

    @Test
    fun `http (non-https) links are also matched`() {
        val result = ShareTextParser.parse("Cool gadget http://example.com/p/1")

        assertEquals("http://example.com/p/1", result?.get("url"))
        assertEquals("Cool gadget", result?.get("title"))
    }

    @Test
    fun `text with no URL at all falls back to the whole text as the url`() {
        val result = ShareTextParser.parse("Just some text, no link here")

        assertEquals("Just some text, no link here", result?.get("url"))
        assertEquals("", result?.get("title"))
    }

    @Test
    fun `blank text returns null`() {
        assertNull(ShareTextParser.parse("   "))
    }

    @Test
    fun `null text returns null`() {
        assertNull(ShareTextParser.parse(null))
    }

    @Test
    fun `surrounding whitespace and dashes are trimmed from the title`() {
        val result = ShareTextParser.parse("  My Product -- https://a.co/d/xyz  ")

        assertEquals("https://a.co/d/xyz", result?.get("url"))
        assertEquals("My Product", result?.get("title"))
    }
}
