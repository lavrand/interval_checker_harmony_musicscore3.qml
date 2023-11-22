import MuseScore 3.0

MuseScore {
  menuPath: "Plugins.Proof Reading.Interval Checker Harmonic"
  version: "0.1"
  description: "This plugin checks intervals between adjacent notes within the voices in a score."

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

    // Iterate through all staves in the score.
    for (var staffIdx = 0; staffIdx < curScore.nstaves; ++staffIdx) {
      // Iterate through all voices in the staff.
      for (var voiceIdx = 0; voiceIdx < 4; ++voiceIdx) {
        var cursor = curScore.newCursor();
        cursor.staffIdx = staffIdx;
        cursor.voice = voiceIdx;
        cursor.rewind(); // Move cursor to the beginning of the score.

        var prevNote = null; // Variable to hold the previous note.

        // Loop through all segments in the staff.
        while (cursor.segment) {
          // Ensure we are looking at a note.
          if (cursor.element && cursor.element.type === Element.NOTE) {
            var note = cursor.element;
            if (prevNote) {
              // Check and display the interval between the previous and current note.
              var interval = checkInterval(prevNote, note);
              curScore.startCmd();
              var text = newElement(Element.STAFF_TEXT);
              text.text = interval;
              text.color = "#0000FF";
              // The yOffset property might not be supported, instead try using the placement property
              // text.yOffset = -5;
              text.placement = Placement.ABOVE;
              // Add the text element to the score at the current cursor position
              curScore.addElement(text, cursor.segment, cursor.staffIdx, cursor.voice);
              curScore.endCmd();
            }
            prevNote = note; // Save the current note as previous.
          }
          cursor.next(); // Move to the next segment.
        }
      }
    }

    console.log("Intervals check complete");
    Qt.quit();
  }
}
