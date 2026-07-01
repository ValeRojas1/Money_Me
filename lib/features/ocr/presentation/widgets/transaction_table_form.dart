import 'package:flutter/material.dart';
import 'package:money_me/app/theme.dart';

class TransactionTableForm extends StatelessWidget {
  final List<TextEditingController> amountCtrls;
  final List<TextEditingController> entityCtrls;
  final List<TextEditingController> subjectCtrls;
  final List<TextEditingController> dateCtrls;
  final List<TextEditingController> timeCtrls;
  final List<String> types;
  final void Function(int index, String? type) onTypeChanged;

  const TransactionTableForm({
    super.key,
    required this.amountCtrls,
    required this.entityCtrls,
    required this.subjectCtrls,
    required this.dateCtrls,
    required this.timeCtrls,
    required this.types,
    required this.onTypeChanged,
  });

  Future<void> _selectDate(BuildContext context, int index) async {
    final initialDate = DateTime.tryParse(dateCtrls[index].text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      dateCtrls[index].text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _selectTime(BuildContext context, int index) async {
    TimeOfDay initialTime = TimeOfDay.now();
    final parts = timeCtrls[index].text.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1].split(' ')[0]);
      if (hour != null && minute != null) {
        initialTime = TimeOfDay(hour: hour, minute: minute);
      }
    }
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      timeCtrls[index].text =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Main data table ───────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: IntrinsicWidth(
                child: Table(
                  border: TableBorder.symmetric(
                    inside: BorderSide(
                        color: AppColors.border.withAlpha(150), width: 0.5),
                  ),
                  columnWidths: const {
                    0: FixedColumnWidth(110), // Tipo
                    1: FixedColumnWidth(160), // Monto
                    2: FixedColumnWidth(180), // Entidad
                    3: FixedColumnWidth(190), // Asunto
                    4: FixedColumnWidth(155), // Fecha
                    5: FixedColumnWidth(130), // Hora
                  },
                  children: [
                    // ── Header row ─────────────────────────────────────────
                    TableRow(
                      decoration:
                          const BoxDecoration(color: AppColors.surfaceVariant),
                      children: const [
                        _HeaderCell('Tipo'),
                        _HeaderCell('Monto'),
                        _HeaderCell('Entidad / Persona'),
                        _HeaderCell('Asunto (Detalle)'),
                        _HeaderCell('Fecha'),
                        _HeaderCell('Hora'),
                      ],
                    ),

                    // ── Data rows ───────────────────────────────────────────
                    ...List.generate(amountCtrls.length, (index) {
                      final isIncome = types[index] == 'income';
                      final amountColor = isIncome ? AppColors.income : AppColors.expense;
                      final amountPrefix = isIncome ? '+' : '-';

                      return TableRow(
                        children: [
                          // Tipo
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: types[index],
                                  isDense: true,
                                  isExpanded: true,
                                  icon: const Icon(Icons.swap_vert, size: 16),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'expense',
                                      child: Text('Salida (-)',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.expense,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    DropdownMenuItem(
                                      value: 'income',
                                      child: Text('Entrada (+)',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.income,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ],
                                  onChanged: (val) => onTypeChanged(index, val),
                                ),
                              ),
                            ),
                          ),

                          // Monto
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              child: Row(
                                children: [
                                  Text(
                                    amountPrefix,
                                    style: TextStyle(
                                      color: amountColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: TextFormField(
                                      controller: amountCtrls[index],
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: amountColor,
                                      ),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        filled: false,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        hintText: '0.00',
                                        hintStyle: TextStyle(
                                            color: AppColors.textSecondary
                                                .withAlpha(100)),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Entidad / Persona
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              child: TextFormField(
                                controller: entityCtrls[index],
                                style: const TextStyle(fontSize: 13),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintText: 'Nombre...',
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                          ),

                          // Asunto
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              child: TextFormField(
                                controller: subjectCtrls[index],
                                style: const TextStyle(fontSize: 13),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintText: 'Escribe aquí...',
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                          ),

                          // Fecha
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              child: InkWell(
                                onTap: () => _selectDate(context, index),
                                child: IgnorePointer(
                                  child: TextFormField(
                                    controller: dateCtrls[index],
                                    style: const TextStyle(fontSize: 13),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      filled: false,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      suffixIcon: Icon(Icons.calendar_today,
                                          size: 14,
                                          color: AppColors.textSecondary),
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 10),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Hora
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              child: InkWell(
                                onTap: () => _selectTime(context, index),
                                child: IgnorePointer(
                                  child: TextFormField(
                                    controller: timeCtrls[index],
                                    style: const TextStyle(fontSize: 13),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      filled: false,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      suffixIcon: Icon(Icons.access_time,
                                          size: 14,
                                          color: AppColors.textSecondary),
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 10),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Currency hint ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 6, left: 4),
          child: Text(
            'Toca cualquier campo para editarlo. La moneda es PEN (S/) por defecto.',
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: AppColors.textPrimary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
