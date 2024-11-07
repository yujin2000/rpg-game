import 'monster.dart';

class Character {
  String name;
  int stamina;
  int attack;
  int defense;
  bool useItem;

  Character(this.name, this.stamina, this.attack, this.defense,
      {this.useItem = false});

  // 몬스터 공격
  void attackMonster(Monster monster, {int muliple = 1}) {
    int realAttack = attack * muliple;
    monster.stamina -= monster.defense + realAttack;
    print('$name이(가) ${monster.name}에게 $realAttack의 데미지를 입혔습니다.');
  }

  // 아이템 사용하여 몬스터 공격하면 공격력 두 배
  void useItemAttackMonster(Monster monster) {
    if (!useItem) {
      useItem = true;
      attackMonster(monster, muliple: 2);
    } else {
      throw Exception('아이템을 이미 사용했습니다.');
    }
  }

  // 방어하기
  // 몬스터가 입히는 데미지 만큼 캐릭터의 체력 상성
  void defend(Monster monster) {
    monster.setAttack(defense);
    int realAttackValue = monster.attack - defense;
    stamina += realAttackValue;
    print('$name이(가) 방어 태세를 취하여 $realAttackValue 만큼 체력을 얻었습니다.');
    showStatus();
  }

  void showStatus() {
    print('[캐릭터] $name - 체력: $stamina, 공격력: $attack, 방어력: $defense');
  }
}
