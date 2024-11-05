import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:csv/csv.dart';

import 'character.dart';
import 'monster.dart';

class Game {
  late Character character;
  List<Monster> monsters = [];
  int defeatedMonsterCount = 0;

  void startGame() async {
    print('캐릭터의 이름을 입력하세요: ');
    // TODO: 한글, 영문 대소문자만 허용하게 regex 사용
    String? name = stdin.readLineSync();
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
      character = Character(name!, stamina, attack, defense);

      var monsterFile = File('C:/Workspace/dart_rpg_game/lib/monsters.txt');
      lines = monsterFile
          .openRead()
          .transform(utf8.decoder)
          .transform(CsvToListConverter());
      // line[0] = name, line[1] = stamina, line[2] = attack, line[3] = defense
      await for (var line in lines) {
        // TODO: 몬스터 리스트 생성(설정된 최대값에서 Random()을 사용하기?)
        monsters.add(Monster(line[0], line[1], line[2], defense: line[3]));
      }
    } catch (e) {
      print('error ${e.toString()}');
    }

    print('게임을 시작합니다!');
    character.showStatus();

    bool finishBattle = false;
    // 캐릭터의 체력이 0 이하, finishBattle=true, monsters 의 값이 비어있으면 battle 종료
    while (character.stamina > 0 && !finishBattle && monsters.isNotEmpty) {
      Monster fightMonster = getRandomMonster();
      print('새로운 몬스터가 나타났습니다!');
      fightMonster.showStatus();
      battle(fightMonster);

      bool exit = false;
      while (!exit) {
        print('다음 몬스터와 싸우시겠습니까? (y/N)');
        var isFight = stdin.readLineSync();
        if (isFight! == 'y' || isFight == 'Y') {
          exit = true;
          print('배틀 진행');
        } else if (isFight == 'n' || isFight == 'N') {
          finishBattle = true;
          exit = true;
          print('배틀을 종료합니다.');
        } else {
          print('잘못된 입력 값입니다. 다시 입력해주세요.');
        }
      }
    }

    print('게임을 종료합니다.');
    bool exit = false;
    while (!exit) {
      print('결과를 저장하시겠습니까? (y/N)');
      var isSave = stdin.readLineSync();
      if (isSave! == 'y' || isSave == 'Y') {
        // 결과 저장
        String winLossResult = defeatedMonsterCount == 0 ? '패배' : '승리';
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

  void battle(Monster monster) {
    // 캐릭터 공격/방어
    print('${character.name}의 턴');
    print('행동을 선택하세요 => [1] 공격하기 / [2] 방어하기');
    try {
      var action = stdin.readLineSync();
      switch (int.parse(action!)) {
        case 1: // 공격
        // attackMonster
        case 2: // 방어
        // defend
        default:
          print('올바르지 않은 숫자입니다.');
      }
    } catch (e) {
      //
    }
    // 몬스터 공격
    print('${monster.name}의 턴');
    // monster.attackCharacter

    // battle(monster);
  }

  // 몬스터 랜덤으로 불러오기
  Monster getRandomMonster() {
    var index = Random().nextInt(monsters.length);
    return monsters[index];
  }
}
