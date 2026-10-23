import 'package:flutter/material.dart';

import '../../common.dart';

/// A compact QWERTY panel aimed at car head units. It talks straight to
/// [InputModel] so it needs no soft keyboard and no text field focus.
class CarKeyboard extends StatefulWidget {
  const CarKeyboard(
      {Key? key, required this.onHide, this.onSystemKeyboard})
      : super(key: key);

  final VoidCallback onHide;
  final VoidCallback? onSystemKeyboard;

  @override
  State<CarKeyboard> createState() => _CarKeyboardState();
}

class _CarKeyboardState extends State<CarKeyboard> {
  static const _digits = '1234567890';
  static const _row1 = 'qwertyuiop';
  static const _row2 = 'asdfghjkl';
  static const _row3 = 'zxcvbnm';

  bool get _shift => gFFI.inputModel.shift;

  void _send(String key, {bool consumeShift = false}) {
    final input = gFFI.inputModel;
    input.inputKey(key);
    if (consumeShift && input.shift) {
      setState(() => input.shift = false);
    }
  }

  void _char(String char) => _send(char, consumeShift: true);

  void _toggleCtrl() =>
      setState(() => gFFI.inputModel.ctrl = !gFFI.inputModel.ctrl);

  void _toggleAlt() =>
      setState(() => gFFI.inputModel.alt = !gFFI.inputModel.alt);

  void _toggleShift() =>
      setState(() => gFFI.inputModel.shift = !gFFI.inputModel.shift);

  void _toggleMeta() =>
      setState(() => gFFI.inputModel.command = !gFFI.inputModel.command);

  Widget _key(String label,
      {VoidCallback? onTap,
      IconData? icon,
      int flex = 10,
      bool active = false}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Material(
          color: active ? MyTheme.accent : const Color(0xFF262626),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: SizedBox(
              height: 46,
              child: Center(
                child: icon != null
                    ? Icon(icon, color: Colors.white, size: 22)
                    : Text(
                        label,
                        maxLines: 1,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          const SizedBox(width: 4),
          Text(
            translate('Car keyboard'),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          if (_shift) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: MyTheme.accent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('SHIFT',
                  style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ],
          const Spacer(),
          IconButton(
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.keyboard, color: Colors.white70, size: 20),
            tooltip: translate('Keyboard'),
            onPressed: widget.onSystemKeyboard,
          ),
          IconButton(
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.close, color: Colors.white70, size: 20),
            tooltip: translate('Close'),
            onPressed: widget.onHide,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final input = gFFI.inputModel;
    return ExcludeFocus(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xF5101010),
          border: Border(top: BorderSide(color: Colors.white24)),
        ),
        padding: const EdgeInsets.fromLTRB(6, 2, 6, 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(),
            Row(
              children: [
                _key('Esc',
                    flex: 4, onTap: () => _send('VK_ESCAPE')),
                _key('Tab', flex: 4, onTap: () => _send('VK_TAB')),
                _key('Ctrl',
                    flex: 4, active: input.ctrl, onTap: _toggleCtrl),
                _key('Alt', flex: 4, active: input.alt, onTap: _toggleAlt),
                _key('Shift',
                    flex: 5, active: input.shift, onTap: _toggleShift),
                for (final char in _digits)
                  _key(char, flex: 10, onTap: () => _char(char)),
                _key('', flex: 5, icon: Icons.backspace_outlined, onTap: () {
                  _send('VK_BACK');
                }),
              ],
            ),
            Row(
              children: [
                for (final char in _row1)
                  _key(_shift ? char.toUpperCase() : char,
                      flex: 10, onTap: () => _char(char)),
                _key('[', flex: 6, onTap: () => _char('[')),
                _key(']', flex: 6, onTap: () => _char(']')),
                _key('\\', flex: 6, onTap: () => _char('\\')),
                _key('Enter', flex: 10, onTap: () => _send('VK_RETURN')),
              ],
            ),
            Row(
              children: [
                for (final char in _row2)
                  _key(_shift ? char.toUpperCase() : char,
                      flex: 10, onTap: () => _char(char)),
                _key(';', flex: 6, onTap: () => _char(';')),
                _key("'", flex: 6, onTap: () => _char("'")),
                _key('', flex: 8, icon: Icons.arrow_back,
                    onTap: () => _send('VK_LEFT')),
                _key('', flex: 8, icon: Icons.arrow_upward,
                    onTap: () => _send('VK_UP')),
                _key('', flex: 8, icon: Icons.arrow_downward,
                    onTap: () => _send('VK_DOWN')),
                _key('', flex: 8, icon: Icons.arrow_forward,
                    onTap: () => _send('VK_RIGHT')),
              ],
            ),
            Row(
              children: [
                for (final char in _row3)
                  _key(_shift ? char.toUpperCase() : char,
                      flex: 10, onTap: () => _char(char)),
                _key(',', flex: 6, onTap: () => _char(',')),
                _key('.', flex: 6, onTap: () => _char('.')),
                _key('/', flex: 6, onTap: () => _char('/')),
                _key('Win',
                    flex: 6, active: input.command, onTap: _toggleMeta),
                _key('', flex: 24, icon: Icons.space_bar,
                    onTap: () => _send('VK_SPACE')),
                _key('', flex: 8, icon: Icons.keyboard_hide, onTap: widget.onHide),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
