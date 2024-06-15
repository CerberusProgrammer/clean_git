class Branch {
  final String name;
  final String lastCommit;
  final int totalCommits;

  Branch({
    required this.name,
    required this.lastCommit,
    required this.totalCommits,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      name: json['name'],
      lastCommit: json['lastCommit'],
      totalCommits: json['totalCommits'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lastCommit': lastCommit,
      'totalCommits': totalCommits,
    };
  }

  @override
  String toString() {
    return 'Branch: $name, $lastCommit, $totalCommits';
  }
}
