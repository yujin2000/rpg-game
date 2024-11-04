class Character {
  String name;
  int stamina;
  int attack;
  int defense;

  Character(this.name, this.stamina, this.attack, this.defense);

  void showStatus() {
    print('$name - 체력: $stamina, 공격력: $attack, 방어력: $defense');
  }
}
