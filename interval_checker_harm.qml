import MuseScore 3.0

MuseScore {
  menuPath: "Plugins.Proof Reading.Interval Checker Harmonic"
  version: "0.1"
  description: "This plugin checks intervals between adjacent notes within the voices in a score"

  function checkInterval(n1, n2) {
 var note1 = n1;
    var note2 = n2;
    if (note2.pitch < note1.pitch) {
      note1 = n2;
      note2 = n1;
    }
    var size = 0;
    var quality = "";
    var diff = note2.tpc - note1.tpc;
    if (diff >= -1 && diff <= 1) {
      quality = "P";
    } else if (diff >= 2 && diff <= 5) {
      quality = "M";
    } else if (diff >= 6 && diff <= 12) {
      quality = "+";
    } else if (diff >= 13 && diff <= 19) {
      quality = "++";
    } else if (diff <= -2 && diff >= -5) {
      quality = "m";
    } else if (diff <= -6 && diff >= -12) {
      quality = "d";
    } else if (diff <= -13 && diff >= -19) {
      quality = "dd";
    } else quality = "?";

    var circlediff = (28 + note2.tpc - note1.tpc) % 7;
    if (circlediff == 1) {
      size = 5;
    } else if (circlediff == 2) {
      size = 2;
    } else if (circlediff == 3) {
      size = 6;
    } else if (circlediff == 4) {
      size = 3;
    } else if (circlediff == 5) {
      size = 7;
    } else if (circlediff == 6) {
      size = 4;
    } else {
      if ((note2.pitch - note1.pitch) > 2)
        size = 8;
      else size = 1;
    }
    return quality + size;
  }

  onRun: {
    if (typeof curScore === 'undefined' || curScore === null) {
      console.log("No score found");
      Qt.quit();
    }

    for (var staffIdx = 0; staffIdx < curScore.nstaves; ++staffIdx) {
      var cursor = curScore.newCursor();
      cursor.staffIdx = staffIdx;
      cursor.voice = 0; // Change this if you want to target a different voice within the staff
      cursor.rewind(); // Перемещаем курсор в начало дорожки

      var prevNote = null; // Переменная для хранения предыдущей ноты

      // Цикл по всем сегментам дорожки
      while (cursor.segment) {
        var element = cursor.segment.elementAt(cursor.staffIdx);
        if (element && element.type === Element.NOTE) {
          var note = element;
          if (prevNote) {
            // Проверка и отображение интервала между предыдущей и текущей нотой
            var interval = checkInterval(prevNote, note);
            var text = newElement(Element.STAFF_TEXT);
            text.text = interval;
            text.color = "#0000FF";
            text.yOffset = -5; // Сдвигаем текст вверх для лучшей видимости
            curScore.startCmd();
            note.add(text);
            curScore.endCmd();
          }
          prevNote = note; // Сохраняем текущую ноту как предыдущую
        }
        cursor.next(); // Переходим к следующему сегменту
      }
    }

    console.log("Intervals check complete");
    Qt.quit();
  }
}
