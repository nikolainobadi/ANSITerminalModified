public private(set) var isReplacingMode = false
public private(set) var isCursorVisible = true

// Reference: https://invisible-island.net/xterm/ctlseqs/ctlseqs.html

public enum CursorStyle: UInt8 {
  case block = 1
  case line  = 3
  case bar   = 5
}

public func setCursorStyle(_ style: CursorStyle, blinking: Bool = true) {
  if blinking { write(CSI+"\(style.rawValue) q") }
    else { write(CSI+"\(style.rawValue + 1) q") }
}

#if os(macOS)
public func storeCursorPosition(isANSI: Bool = false) {
  if isANSI { write(CSI,"s") } else { write(ESC,"7") }
}
#else
public func storeCursorPosition(isANSI: Bool = true) {
  if isANSI { write(CSI,"s") } else { write(ESC,"7") }
}
#endif

#if os(macOS)
public func restoreCursorPosition(isANSI: Bool = false) {
  if isANSI { write(CSI,"u") } else { write(ESC,"8") }
}
#else
public func restoreCursorPosition(isANSI: Bool = true) {
  if isANSI { write(CSI,"u") } else { write(ESC,"8") }
}
#endif

public func clearBelow() {
  write(CSI,"0J")
}

public func clearAbove() {
  write(CSI,"1J")
}

public func clearScreen() {
  write(CSI,"2J",CSI,"H")
}

public func clearToEndOfLine() {
  write(CSI,"0K")
}

public func clearToStartOfLine() {
  write(CSI,"1K")
}

public func clearLine() {
  write(CSI,"2K")
}

public func moveUp(_ row: Int = 1) {
  write(CSI,"\(row)A")
}

public func moveDown(_ row: Int = 1) {
  write(CSI,"\(row)B")
}

public func moveRight(_ col: Int = 1) {
  write(CSI,"\(col)C")
}

public func moveLeft(_ col: Int = 1) {
  write(CSI,"\(col)D")
}

public func moveLineDown(_ row: Int = 1) {
  write(CSI,"\(row)E")
}

public func moveLineUp(_ row: Int = 1) {
  write(CSI,"\(row)F")
}

public func moveToColumn(_ col: Int) {
  write(CSI,"\(col)G")
}

public func moveTo(_ row: Int, _ col: Int) {
  write(CSI,"\(row);\(col)H")
}

public func insertLine(_ row: Int = 1) {
  write(CSI,"\(row)L")
}

public func deleteLine(_ row: Int = 1) {
  write(CSI,"\(row)M")
}

public func deleteChar(_ char: Int = 1) {
  write(CSI,"\(char)P")
}

public func enableReplaceMode() {
  write(CSI,"4l")
  isReplacingMode = true
}

public func disableReplaceMode() {
  write(CSI,"4h")
  isReplacingMode = false
}

public func cursorOff() {
  write(CSI,"?25l")
  isCursorVisible = false
}

public func cursorOn() {
  write(CSI,"?25h")
  isCursorVisible = true
}

public func setScrollRegion(top: Int, bottom: Int) {
    write(CSI+"\(top);\(bottom)r")
}

public func scrollRegion(top: Int, bottom: Int) {
  write(CSI,"\(top);\(bottom)r")
}

public func scrollUp(lines: Int = 1) {
    write(CSI+"\(lines)S")
}

public func scrollDown(lines: Int = 1) {
    write(CSI+"\(lines)T")
}

public func readCursorPos() -> (row: Int, col: Int) {
  let str = ansiRequest(CSI+"6n", endChar: "R")  // returns ^[row;colR
  if str.isEmpty { return (-1, -1) }

  let esc = str.firstIndex(of: "[")!
  let del = str.firstIndex(of: ";")!
  let end = str.firstIndex(of: "R")!
  let row = String(str[str.index(after: esc)...str.index(before: del)])
  let col = String(str[str.index(after: del)...str.index(before: end)])

  return (Int(row)!, Int(col)!)
}

//! WARNING: 18t only works on a real terminal console, *not* on emulation.
//public func readScreenSize() -> (row: Int, col: Int) {
//  var str = ansiRequest(CSI+"18t", endChar: "t")  // returns ^[8;row;colt
//  if str.isEmpty { return (-1, -1) }
//
//  str = String(str.dropFirst(4))  // remove ^[8;
//  let del = str.firstIndex(of: ";")!
//  let end = str.firstIndex(of: "t")!
//  let row = String(str[...str.index(before: del)])
//  let col = String(str[str.index(after: del)...str.index(before: end)])
//
//  return (Int(row)!, Int(col)!)
//}

public func getTerminalSize() -> (rows: Int, cols: Int) {
    let (rows, cols) = readScreenSize()
    return (rows > 0 ? rows : 24, cols > 0 ? cols : 80) // Default to 24x80 if size can't be read
}

public func readScreenSize() -> (rows: Int, cols: Int) {
    let str = ansiRequest(CSI+"18t", endChar: "t")
    guard !str.isEmpty else { return (-1, -1) }
    let parts = str.split(separator: ";")
    if parts.count >= 3,
       let rows = Int(parts[1]),
       let cols = Int(parts[2].dropLast()) {
        return (rows, cols)
    }
    return (-1, -1)
}

// Save the current screen content and cursor position
public func saveScreen() {
    write(ESC + "7")
}

// Restore the saved screen content and cursor position
public func restoreScreen() {
    write(ESC + "8")
}

// Move the cursor to home position
public func moveToHome() {
    write(CSI + "H")
}

// Example usage:
public func switchToNewScreen() {
    saveScreen() // Save the current screen
    clearScreen() // Clear the screen
    moveToHome() // Move the cursor to home position
    // Perform operations on the new screen
}

public func returnToOriginalScreen() {
    restoreScreen() // Restore the saved screen
}

public func enterAlternativeScreen() {
    write(CSI + "?1049h" + CSI + "H")
}

// Exit the alternative screen buffer
public func exitAlternativeScreen() {
    write(CSI + "?1049l")
}
