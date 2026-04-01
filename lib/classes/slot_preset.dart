class SlotPreset {
  final String presetId;
  final String presetName;

  const SlotPreset({required this.presetId, required this.presetName});

  factory SlotPreset.fromJson(Map<String, dynamic> json) {
    try {
      return SlotPreset(
        presetId: json["preset_id"],
        presetName: json["preset_name"],
      );
    } catch (e) {
      rethrow;
    }
  }
}
