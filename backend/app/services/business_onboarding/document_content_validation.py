"""Server-side onboarding document format detection (magic bytes only)."""

from __future__ import annotations

from enum import StrEnum


class DetectedOnboardingDocumentFormat(StrEnum):
    PDF = "application/pdf"
    JPEG = "image/jpeg"
    PNG = "image/png"


def detect_onboarding_document_format(data: bytes) -> DetectedOnboardingDocumentFormat | None:
    """Return a MIME type from file content or ``None`` when unsupported."""

    if len(data) >= 4 and data[:4] == b"%PDF":
        return DetectedOnboardingDocumentFormat.PDF
    if len(data) >= 3 and data[:3] == b"\xff\xd8\xff":
        return DetectedOnboardingDocumentFormat.JPEG
    if len(data) >= 8 and data[:8] == b"\x89PNG\r\n\x1a\n":
        return DetectedOnboardingDocumentFormat.PNG
    return None
