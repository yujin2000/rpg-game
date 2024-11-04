class Monster {
  String name;
  int stamina;
  int attack;
  int defense;

  Monster(this.name, this.stamina, this.attack, {this.defense = 0});

  void showStatus() {
    print('$name - 체력: $stamina, 공격력: $attack, 방어력: $defense');
  }
}
