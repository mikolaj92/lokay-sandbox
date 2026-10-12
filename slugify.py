import re


def slugify(text: str) -> str:
    """Lowercase text and separate runs of Unicode alphanumeric characters."""
    return re.sub(r"[\W_]+", "-", text.lower()).strip("-")
