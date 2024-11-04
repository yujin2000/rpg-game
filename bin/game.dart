import 'dart:convert';
import 'dart:io';

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

    bool terminate = false;
    while (character.stamina <= 0 || !terminate) {
      battle();
      print('다음 몬스터와 싸우시겠습니까? (y/N)');
      var isFight = stdin.readLineSync();
      if (isFight! == 'N') {
        terminate = true;
        print('게임을 종료합니다.');
      }
    }
  }

  void battle() {
    print('${character.name}의 턴');
    print('행동을 선택하세요 => [1] 공격하기 / [2] 방어하기');
    try {
      var a = stdin.readLineSync();
      switch (int.parse(a!)) {
        case 1: // 공격
        case 2: // 방어
        default:
          print('올바르지 않은 숫자입니다.');
      }
    } catch (e) {
      //
    }
  }
}
