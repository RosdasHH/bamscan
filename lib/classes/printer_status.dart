class PrinterStatus {
  final int id;
  final String name;
  final bool connected;
  final String state;
  final String currentPrint;
  final String subtaskName;
  final String gcodeFile;
  final int progress;
  final int remainingTime;
  final int layerNum;
  final int totalLayers;
  final String? coverUrl;
  const PrinterStatus({
    required this.id,
    required this.name,
    required this.connected,
    required this.state,
    required this.currentPrint,
    required this.subtaskName,
    required this.gcodeFile,
    required this.progress,
    required this.remainingTime,
    required this.layerNum,
    required this.totalLayers,
    this.coverUrl,
  });

  factory PrinterStatus.fromJson(Map<String, dynamic> json) {
    return PrinterStatus(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] ?? '',
      connected: json['connected'] ?? false,
      state: json['state'] ?? '',
      currentPrint: json['current_print'] ?? '',
      subtaskName: json['subtask_name'] ?? '',
      gcodeFile: json['gcode_file'] ?? '',
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      remainingTime: (json['remaining_time'] as num?)?.toInt() ?? 0,
      layerNum: (json['layer_num'] as num?)?.toInt() ?? 0,
      totalLayers: (json['total_layers'] as num?)?.toInt() ?? 0,

      coverUrl: json['cover_url'],
    );
  }
}
