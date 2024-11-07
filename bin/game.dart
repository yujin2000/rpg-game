import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:csv/csv.dart';

import 'character.dart';
import 'monster.dart';

class Game {
  late Character character;
  List<Monster> monsters = [];
  List<Monster> deathMonsters = [];
  var regexp = RegExp(r'^[a-zA-Z가-힣]+$');

  String characterFilePath = 'C:/Workspace/dart_rpg_game/lib/characters.txt';
  String monsterFilePath = 'C:/Workspace/dart_rpg_game/lib/monsters.txt';
  String resultFilePath = 'C:/Workspace/dart_rpg_game/lib/result.txt';

  void startGame() async {
    await setBeforeBattle();

    print('게임을 시작합니다!');
    bonusStamina();
    character.showStatus();

    bool finishBattle = false;

    // 캐릭터의 체력이 0 이하, finishBattle=true, monsters 의 값이 비어있으면 battle 종료
    while (isAliveCharacter() && !finishBattle && monsters.isNotEmpty) {
      battle();

      // monsters 가 없으면 추가 배틀 종료
      if (monsters.isEmpty) {
        print('몬스터를 모두 처치했습니다!');
        break;
      }

      bool exit = false;
      while (!exit && isAliveCharacter()) {
        stdout.write('\n다음 몬스터와 싸우시겠습니까? (y/N) ');
        var isFight = stdin.readLineSync();
        if (yes(isFight!)) {
          exit = true;
          print('배틀을 진행합니다.');
        } else if (no(isFight)) {
          finishBattle = true;
          exit = true;
          print('배틀을 종료합니다.');
        } else {
          print('잘못된 입력 값입니다. 다시 입력해주세요.');
        }
      }
    }

    print('\n게임을 종료합니다.');
    saveResult();
    print('게임이 종료되었습니다.');
  }

  void battle() {
    Monster monster = getRandomMonster();
    print('\n새로운 몬스터가 나타났습니다!');
    monster.showStatus();

    int turnCount = 0;

    while (isAliveCharacter()) {
      print('\n${character.name}의 턴');
      bool exit = false;

      do {
        // 캐릭터 공격/방어
        stdout.write('행동을 선택하세요. [1] 공격하기 / [2] 방어하기 / [3] 아이템 사용 => ');
        try {
          var action = stdin.readLineSync();
          switch (int.parse(action!)) {
            case 1: // 공격
              character.attackMonster(monster);
              exit = true;
            case 2: // 방어
              character.defend(monster);
              exit = true;
            case 3: // 특수 아이템 사용 기능
              character.useItemAttackMonster(monster);
              exit = true;
            default:
              print('올바르지 않은 숫자입니다.');
          }
        } on FormatException catch (e) {
          print('유효하지 않은 입력 값입니다. ${e.toString()}');
        } catch (e) {
          print(e.toString());
        }
      } while (!exit);

      if (!checkPossibleBattle(monster)) {
        break;
      }

      // 몬스터 공격
      print('\n${monster.name}의 턴');
      monster.attackCharacter(character);

      if (!checkPossibleBattle(monster)) {
        break;
      }

      turnCount++;
      // 3번의 턴을 지나면 몬스터의 방어력을 올림
      if (turnCount == 3) {
        monster.increasedDefense();
        print('\n${monster.name}의 방어력이 증가헀습니다! 현재 방어력: ${monster.defense}');
        turnCount = 0;
      }
    }
  }

  // 몬스터 랜덤으로 불러오기
  Monster getRandomMonster() {
    var index = Random().nextInt(monsters.length);
    return monsters[index];
  }

  // battle 시작 전 캐릭터, 몬스터 객체 생성
  Future<void> setBeforeBattle() async {
    late String? name;
    do {
      stdout.write('캐릭터의 이름을 입력하세요(한글, 영문 대소문자만 가능합니다): ');
      name = stdin.readLineSync();
    } while (!regexp.hasMatch(name!));
    int stamina = 0;
    int attack = 0;
    int defense = 0;

    try {
      var lines = File(characterFilePath)
          .openRead()
          .transform(utf8.decoder)
          .transform(CsvToListConverter());
      // line[0] = stamina, line[1] = attack, line[2] = defense
      await for (var line in lines) {
        stamina = line[0];
        attack = line[1];
        defense = line[2];
      }
      // 캐릭터 생성
      character = Character(name, stamina, attack, defense);
    } catch (e) {
      print('캐릭터 데이터를 불러오는 데 실패했습니다. $e');
      exit(1);
    }

    try {
      var lines = File(monsterFilePath)
          .openRead()
          .transform(utf8.decoder)
          .transform(CsvToListConverter());
      // line[0] = name, line[1] = stamina, line[2] = maxAttack, line[3] = defense
      await for (var line in lines) {
        // 몬스터 생성
        monsters.add(Monster(line[0], line[1], line[2], defense: line[3]));
      }
    } catch (e) {
      print('몬스터 데이터를 불러오는 데 실패했습니다. $e');
      exit(1);
    }
  }

  // 배틀 종료 후 파일 저장
  void saveResult() {
    bool exit = false;
    while (!exit) {
      try {
        stdout.write('결과를 저장하시겠습니까? (y/N) ');
        var isSave = stdin.readLineSync();

        if (yes(isSave!)) {
          // 결과 저장
          String winLossResult = deathMonsters.isEmpty ? '패배' : '승리';
          String gameResult =
              '이름: ${character.name} | 남은 체력: ${character.stamina} | 게임 결과: $winLossResult\n';
          print(gameResult);

          File(resultFilePath)
              .writeAsStringSync(gameResult, mode: FileMode.append);
          print('파일에 저장되었습니다.');
          exit = true;
        } else if (no(isSave)) {
          print('결과를 저장하지 않습니다.');
          exit = true;
        } else {
          print('잘못된 입력 값입니다.');
        }
      } catch (e) {
        print('유효하지 않은 입력 값입니다. ${e.toString()}');
      }
    }
  }

  bool isAliveCharacter() {
    return character.stamina > 0;
  }

  // true: 진행 가능 / false: 진행 불가능(캐릭터 승리 or 패배)
  bool checkPossibleBattle(Monster monster) {
    // 캐릭터 몬스터 체력이 남아있으면 그대로 진행
    if (isAliveCharacter() && monster.stamina > 0) {
      return true;
    }

    if (isAliveCharacter() && monster.stamina <= 0) {
      // 몬스터 체력이 0 이하면 승리
      print('\n<승리> ${character.name}은(는) ${monster.name}을(를) 물리쳤습니다!');
      // 처치한 몬스터 삭제 및 리스트에 추가
      monsters.remove(monster);
      deathMonsters.add(monster);
      return false;
    } else if (character.stamina <= 0) {
      // 캐릭터 체력이 0 이하면 패배
      print('\n<패배> ${character.name}은(는) ${monster.name}에게 당했습니다!');
      return false;
    }
    return false;
  }

  bool yes(String str) {
    return str == 'y' || str == 'Y';
  }

  bool no(String str) {
    return str == 'n' || str == 'N';
  }

  // 30% 의 확률로 보너스 체력을 얻는 메서드
  void bonusStamina() {
    var value = Random().nextInt(10);
    if (value < 3) {
      character.stamina += 10;
      print('보너스 체력을 얻었습니다! 현재 체력: ${character.stamina}');
    }
  }
}
