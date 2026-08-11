import 'package:feyam/core/locale/locale_cubit.dart';
import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Opens a two-option (English/Español) language picker, adapted to the
/// current platform, and applies the choice via [LocaleCubit].
Future<void> showLanguagePicker(BuildContext context) {
  final localeCubit = context.read<LocaleCubit>();
  return AdaptivePlatform.isCupertino(context)
      ? _showCupertinoLanguagePicker(context, localeCubit)
      : _showMaterialLanguagePicker(context, localeCubit);
}

Future<void> _showMaterialLanguagePicker(
  BuildContext context,
  LocaleCubit localeCubit,
) {
  final l10n = AppLocalizations.of(context)!;
  final currentCode = localeCubit.state.languageCode;

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                l10n.languagePickerTitle,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            RadioListTile<String>(
              title: Text(l10n.languageEnglish),
              value: 'en',
              groupValue: currentCode,
              onChanged: (code) {
                Navigator.of(sheetContext).pop();
                if (code != null) localeCubit.changeLanguage(code);
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.languageSpanish),
              value: 'es',
              groupValue: currentCode,
              onChanged: (code) {
                Navigator.of(sheetContext).pop();
                if (code != null) localeCubit.changeLanguage(code);
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _showCupertinoLanguagePicker(
  BuildContext context,
  LocaleCubit localeCubit,
) {
  final l10n = AppLocalizations.of(context)!;

  return showCupertinoModalPopup<void>(
    context: context,
    builder: (sheetContext) => CupertinoActionSheet(
      title: Text(l10n.languagePickerTitle),
      actions: <CupertinoActionSheetAction>[
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(sheetContext).pop();
            localeCubit.changeLanguage('en');
          },
          child: Text(l10n.languageEnglish),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(sheetContext).pop();
            localeCubit.changeLanguage('es');
          },
          child: Text(l10n.languageSpanish),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(sheetContext).pop(),
        child: Text(l10n.dialogCancel),
      ),
    ),
  );
}
