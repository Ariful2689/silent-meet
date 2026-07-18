/// Short weekday labels for the day-picker chips, in English and Bengali.
/// Index 0 = Monday ... 6 = Sunday, matching MeetingSchedule's 1-7 convention
/// (index + 1 = weekday number).
const List<String> weekdayLabelsEn = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun'
];

const List<String> weekdayLabelsBn = [
  'সোম',
  'মঙ্গল',
  'বুধ',
  'বৃহ',
  'শুক্র',
  'শনি',
  'রবি'
];

List<String> weekdayLabels(String languageCode) =>
    languageCode == 'bn' ? weekdayLabelsBn : weekdayLabelsEn;
