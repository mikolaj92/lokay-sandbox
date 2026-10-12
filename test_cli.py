from cli import main


def test_version(capsys):
    result = main(["--version"])

    assert capsys.readouterr().out == "lokay-sandbox 0.1.0\n"
    assert result == 0


def test_no_arguments(capsys):
    result = main([])

    assert capsys.readouterr().out == "usage: lokay-sandbox --version\n"
    assert result == 2


def test_unknown_flag(capsys):
    result = main(["--unknown"])

    assert capsys.readouterr().out == "usage: lokay-sandbox --version\n"
    assert result == 2


def test_version_with_extra_argument(capsys):
    result = main(["--version", "extra"])

    assert capsys.readouterr().out == "usage: lokay-sandbox --version\n"
    assert result == 2
