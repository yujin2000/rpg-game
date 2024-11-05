import 'monster.dart';

class Character {
  String name;
  int stamina;
  int attack;
  int defense;

  Character(this.name, this.stamina, this.attack, this.defense);

  void attackMonster(Monster monster) {
    monster.stamina -= attack;
  }

  // 방어하기
  // 몬스터가 입히는 데미지 만큼 캐릭터의 체력 상성
  void defend(Monster monster) {
    monster.setAttack(defense);
    int realAttackValue = defense - attack;
    monster.stamina += realAttackValue;
    print('$name이(가) 방어 태세를 취하여 $realAttackValue 만큼 체력을 얻었습니다.');
    showStatus();
  }

  void showStatus() {
    print('$name - 체력: $stamina, 공격력: $attack, 방어력: $defense');
  }
}
