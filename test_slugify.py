from slugify import slugify


def test_slugify_hello_world():
    assert slugify("Hello, World!") == "hello-world"


def test_slugify_alphanumeric():
    assert slugify("ABC123") == "abc123"


def test_slugify_non_alphanumeric_run():
    assert slugify("a ,__ b") == "a-b"


def test_slugify_strips_edge_hyphens():
    assert slugify("--Hello--") == "hello"


def test_slugify_empty():
    assert slugify("") == ""


def test_slugify_only_separators():
    assert slugify(" !_- ") == ""


def test_slugify_unicode():
    assert slugify("ŻÓŁĆ 東京 １２３") == "żółć-東京-１２３"
