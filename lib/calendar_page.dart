import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'database.dart';
import 'entry.dart';

/// This file holds the Calendar page, where the user can see their past entries,
/// along with its helper methods.

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final DateTime _now = DateTime.now();
  final int _firstDayOfWeek = 0;
  late DateTime _firstDayOfMonth;
  late int _daysInMonth;
  DateTime? _selectedDate;

  List<Entry> _allEntries = [];
  Map<String, String> _emojiByDate = {};
  List<Entry> _selectedDateEntries = [];

  @override
  void initState() {
    super.initState();
    _firstDayOfMonth = DateTime(_now.year, _now.month, 1);
    _daysInMonth = DateTime(_now.year, _now.month + 1, 0).day;
    _selectedDate = _now;
    _fetchEntries();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _allEntries = context.watch<Data>().getEntries().toList();
    _fetchEntries();
  }

  Future<void> _fetchEntries() async {
    final Map<String, Entry> lastByDate = {};
    for (var entry in _allEntries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.id);
      if (!lastByDate.containsKey(dateKey) || entry.id.isAfter(lastByDate[dateKey]!.id)) {
        lastByDate[dateKey] = entry;
      }
    }
    _emojiByDate = {for (var entry in lastByDate.entries) entry.key: entry.value.emoji};
    _updateSelectedDateEntries();
  }

  void _updateSelectedDateEntries() {
    if (_selectedDate == null) return;

    final selectedKey = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    setState(() {
      _selectedDateEntries = _allEntries.where((entry) {
        return DateFormat('yyyy-MM-dd').format(entry.id) == selectedKey;
      }).toList();
    });
  }

  Future<void> _selectMonthYear() async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _firstDayOfMonth,
      firstDate: DateTime(_now.year - 5, 1),
      lastDate: DateTime(_now.year + 5, 12),
      builder: (context, child) => Theme(
        data: _datePickerTheme(context),
        child: child!,
      ),
    );

    if (selected != null) {
      setState(() {
        _firstDayOfMonth = DateTime(selected.year, selected.month, 1);
        _daysInMonth = DateTime(selected.year, selected.month + 1, 0).day;
        _selectedDate = selected;
      });
      _fetchEntries();
    }
  }

  ThemeData _datePickerTheme(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: colorScheme.primary,
        onPrimary: Colors.white,
        surface: colorScheme.surface,
        onSurface: colorScheme.onSurface,
        secondary: colorScheme.secondary,
        onSecondary: Colors.white,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
      ), 
      dialogTheme: DialogThemeData(backgroundColor: Theme.of(context).scaffoldBackgroundColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    int startWeekday = (_firstDayOfMonth.weekday - _firstDayOfWeek + 7) % 7;
    List<String> weekdayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    List<String> adjustedWeekdayNames = [
      ...weekdayNames.sublist(_firstDayOfWeek),
      ...weekdayNames.sublist(0, _firstDayOfWeek),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _selectMonthYear,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.yMMMM().format(_firstDayOfMonth),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),

            Row(
              children: adjustedWeekdayNames.map((day) => Expanded(
                child: Center(
                  child: Text(day, style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              )).toList(),
            ),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
                itemCount: _daysInMonth + startWeekday,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  if (index < startWeekday) return const SizedBox();
            
                  int day = index - startWeekday + 1;
                  DateTime date = DateTime(_firstDayOfMonth.year, _firstDayOfMonth.month, day);
                  bool isSelected = _selectedDate?.year == date.year &&
                                    _selectedDate?.month == date.month &&
                                    _selectedDate?.day == date.day;
            
                  String dateKey = DateFormat('yyyy-MM-dd').format(date);
                  String emoji = _emojiByDate[dateKey] ?? '🫥';
            
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                      _updateSelectedDateEntries();
                    },
                    child: Center(
                      child: Column(
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 24)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                            decoration: isSelected
                                ? BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  )
                                : null,
                            child: Text(
                              day.toString(),
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            Expanded(
              child: _selectedDateEntries.isNotEmpty
                ? ListView.builder(
                  itemCount: _selectedDateEntries.length,
                  itemBuilder: (context, index) {
                    final entry = _selectedDateEntries[index];
                    return ListTile(
                      leading: Text(entry.emoji, style: const TextStyle(fontSize: 24)),
                      title: Text(entry.sentence, style: GoogleFonts.lato()),
                      subtitle: Text(
                        DateFormat.jm().format(entry.id),
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 12),
                      ),
                    );
                  },
                )
                : _selectedDate != null
                  ? Center(
                    child: Text(
                      "No entries for this day.",
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.grey[600]),
                    ),
                  )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}