"""Unit tests for onboarding document magic-byte validation."""

from app.services.business_onboarding.document_content_validation import (
    DetectedOnboardingDocumentFormat,
    detect_onboarding_document_format,
)

_MINIMAL_PDF = b"%PDF-1.4"
_MINIMAL_JPEG = b"\xff\xd8\xff"
_MINIMAL_PNG = b"\x89PNG\r\n\x1a\n"


def test_detects_allowed_formats() -> None:
    assert detect_onboarding_document_format(_MINIMAL_PDF) == DetectedOnboardingDocumentFormat.PDF
    assert detect_onboarding_document_format(_MINIMAL_JPEG) == DetectedOnboardingDocumentFormat.JPEG
    assert detect_onboarding_document_format(_MINIMAL_PNG) == DetectedOnboardingDocumentFormat.PNG


def test_rejects_unknown_bytes() -> None:
    assert detect_onboarding_document_format(b"plain-text") is None
