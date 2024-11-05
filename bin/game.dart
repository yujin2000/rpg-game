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

  void startGame() async {
    late String? name;
    do {
      stdout.write('캐릭터의 이름을 입력하세요(한글, 영문 대소문자만 가능합니다): ');
      name = stdin.readLineSync();
    } while (!RegExp(r'^[a-zA-Z가-힣]+$').hasMatch(name!));
    int stamina = 0;
    int attack = 0;
    int defense = 0;

    try {
      var characterFile = File('C:/Workspace/dart_rpg_game/lib/characters.txt');
      var lines = characterFile
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

      var monsterFile = File('C:/Workspace/dart_rpg_game/lib/monsters.txt');
      lines = monsterFile
          .openRead()
          .transform(utf8.decoder)
          .transform(CsvToListConverter());
      // line[0] = name, line[1] = stamina, line[2] = maxAttack, line[3] = defense
      await for (var line in lines) {
        // 몬스터 생성
        monsters.add(Monster(line[0], line[1], line[2], defense: line[3]));
      }
    } catch (e) {
      print('error ${e.toString()}');
    }

    print('게임을 시작합니다!');
    character.showStatus();

    bool finishBattle = false;
    bool aliveCharacter = true;

    // 캐릭터의 체력이 0 이하, finishBattle=true, monsters 의 값이 비어있으면 battle 종료
    while (aliveCharacter && !finishBattle && monsters.isNotEmpty) {
      Monster fightMonster = getRandomMonster();
      print('\n새로운 몬스터가 나타났습니다!');
      fightMonster.showStatus();
      aliveCharacter = battle(character, fightMonster);

      bool exit = false;
      while (!exit && aliveCharacter) {
        // 처치한 몬스터 삭제 및 리스트에 추가
        monsters.remove(fightMonster);
        deathMonsters.add(fightMonster);

        stdout.write('\n다음 몬스터와 싸우시겠습니까? (y/N) ');
        var isFight = stdin.readLineSync();
        if (isFight! == 'y' || isFight == 'Y') {
          exit = true;
          print('배틀을 진행합니다.');
        } else if (isFight == 'n' || isFight == 'N') {
          finishBattle = true;
          exit = true;
          print('배틀을 종료합니다.');
        } else {
          print('잘못된 입력 값입니다. 다시 입력해주세요.');
        }
      }
    }

    print('\n게임을 종료합니다.');
    bool exit = false;
    while (!exit) {
      stdout.write('결과를 저장하시겠습니까? (y/N) ');
      var isSave = stdin.readLineSync();
      if (isSave! == 'y' || isSave == 'Y') {
        // 결과 저장
        String winLossResult = deathMonsters.isEmpty ? '패배' : '승리';
        String gameResult =
            '이름: ${character.name} 남은 체력: ${character.stamina} 게임 결과: $winLossResult';
        print(gameResult);
        File file = File('C:/Workspace/dart_rpg_game/lib/result.txt');
        file.writeAsStringSync(gameResult);
        print('파일에 저장되었습니다.');
        exit = true;
      } else if (isSave == 'n' || isSave == 'N') {
        print('결과를 저장하지 않습니다.');
        exit = true;
      } else {
        print('잘못된 입력 값입니다.');
      }
    }
    print('게임이 종료되었습니다.');
  }

  // 승리: true 패배: false
  bool battle(Character character, Monster monster) {
    // 캐릭터 공격/방어
    print('\n${character.name}의 턴');
    stdout.write('행동을 선택하세요. [1] 공격하기 / [2] 방어하기 => ');
    try {
      var action = stdin.readLineSync();
      switch (int.parse(action!)) {
        case 1: // 공격
          character.attackMonster(monster);
        case 2: // 방어
          character.defend(monster);
        default:
          print('올바르지 않은 숫자입니다.');
      }
    } catch (e) {
      //
    }

    if (character.stamina > 0 && monster.stamina <= 0) {
      // 몬스터 체력이 0 이하면 승리
      print('<승리> ${character.name}은(는) ${monster.name}을(를) 물리쳤습니다!');
      return true;
    } else if (character.stamina <= 0) {
      // 캐릭터 체력이 0 이하면 패배
      print('<패배> ${character.name}은(는) ${monster.name}에게 당했습니다!');
      return false;
    }

    // 몬스터 공격
    print('\n${monster.name}의 턴');
    monster.attackCharacter(character);

    // 캐릭터, 몬스터의 체력이 0 초과면 battle 진행
    if (character.stamina > 0 && monster.stamina > 0) {
      return battle(character, monster);
    } else if (character.stamina > 0 && monster.stamina <= 0) {
      // 몬스터 체력이 0 이하면 승리
      print('<승리> ${character.name}은(는) ${monster.name}을(를) 물리쳤습니다!');
      return true;
    } else {
      // 캐릭터 체력이 0 이하면 패배
      print('<패배> ${character.name}은(는) ${monster.name}에게 당했습니다!');
      return false;
    }
  }

  // 몬스터 랜덤으로 불러오기
  Monster getRandomMonster() {
    var index = Random().nextInt(monsters.length);
    return monsters[index];
  }
}
