class Report {
  final String? publisherType;
  final int? hours;
  final int? bibleStudies;
  final bool participated;

  Report({
    this.publisherType,
    this.hours,
    this.bibleStudies,
    required this.participated,
  });

  
}
void main(){
  final report = Report(
    publisherType: 'Publisher',
    participated: true,
    bibleStudies: 2,
  );

  final report2 = Report(publisherType: 'Publisher', participated: false);
}