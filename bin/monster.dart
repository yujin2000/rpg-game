import 'dart:math';

import 'character.dart';

class Monster {
  String name;
  int stamina;
  int maxAttack;
  int attack;
  int defense;

  Monster(this.name, this.stamina, this.maxAttack,
      {this.attack = 0, this.defense = 0});

  // 캐릭터 공격
  void attackCharacter(Character character) {
    int charDefense = character.defense;
    setAttack(charDefense);
    int realAttackValue = charDefense - attack;
    character.stamina -= realAttackValue;

    print('$name이(가) ${character.name}에게 $realAttackValue 만큼 데미지를 입혔습니다.');
    character.showStatus();
    showStatus();
  }

  // 캐릭터 최대 공격력 범위 내에서 랜덤으로 공격력을 추출하여 캐릭터 방어력과 max 비교하여 공격력 지정
  void setAttack(int charDefense) {
    attack = max(charDefense, Random().nextInt(maxAttack));
  }

  void showStatus() {
    print('$name - 체력: $stamina, 최대공격력: $maxAttack, 방어력: $defense');
  }
}
