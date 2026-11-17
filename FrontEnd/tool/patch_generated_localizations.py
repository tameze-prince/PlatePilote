from pathlib import Path
import re

LOCALIZATIONS = Path("lib/l10n/app_localizations.dart")


def main() -> None:
    if not LOCALIZATIONS.is_file():
        raise SystemExit(f"Generated localization file not found: {LOCALIZATIONS}")

    source = LOCALIZATIONS.read_text(encoding="utf-8")
    source = source.replace(
        "import 'package:flutter/widgets.dart';\n",
        "",
    )
    source = source.replace(
        "import 'package:flutter_localizations/flutter_localizations.dart';",
        "import 'package:material_ui/material_ui.dart';",
    )

    pattern = re.compile(
        r"  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates"
        r"\s*=\s*<LocalizationsDelegate<dynamic>>\["
        r"\s*delegate,"
        r"\s*GlobalMaterialLocalizations\.delegate,"
        r"\s*GlobalCupertinoLocalizations\.delegate,"
        r"\s*GlobalWidgetsLocalizations\.delegate,"
        r"\s*\];"
    )
    replacement = (
        "  static final List<LocalizationsDelegate<dynamic>> localizationsDelegates =\n"
        "      <LocalizationsDelegate<dynamic>>[\n"
        "        delegate,\n"
        "        ...GlobalMaterialLocalizations.delegates,\n"
        "      ];"
    )

    if pattern.search(source):
        source = pattern.sub(replacement, source, count=1)
    elif "...GlobalMaterialLocalizations.delegates" not in source:
        raise SystemExit("Unrecognized generated localization delegate block; refusing an unsafe rewrite.")

    if "flutter_localizations/flutter_localizations.dart" in source:
        raise SystemExit("Legacy localization import remains after patching.")
    LOCALIZATIONS.write_text(source, encoding="utf-8")


if __name__ == "__main__":
    main()
