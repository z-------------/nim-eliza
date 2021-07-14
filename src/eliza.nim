import std/strutils
when defined(js):
  import std/dom

import elizapkg/eliza

export eliza

when defined(js):
  var lastPrint: string

template print(msg: string) =
  when defined(js):
    var el = document.createElement("pre")
    el.textContent = msg
    document.body.appendChild(el)

    lastPrint = msg
  else:
    echo(msg)

proc printCenter(msg: string) =
  let numSpaces = (80 - msg.len) div 2
  var padding: string
  for i in 0..<numSpaces:
    padding.add(' ')
  print(padding & msg)

proc printTitle() =
  print("")
  print("")
  printCenter("*** ELIZA ***")
  printCenter("Original code by Weizenbaum, 1966")
  printCenter("To stop Eliza, type 'bye'")
  print("")
  print("")
  print("HI!  I'M ELIZA.  WHAT'S YOUR PROBLEM?")

proc getInput(): string =
  result =
    when defined(js):
      window.prompt(lastPrint, "")
    else:
      stdin.readLine()
  when defined(js):
    print("> " & result)

proc main() =
  var eliza = initEliza()

  # print a nice centered title screen
  printTitle()

  while true:
    let
      rawInput = getInput()
      (response, isContinue) = eliza.tell(rawInput)
    print(response)
    if not isContinue:
      break


when isMainModule:
  main()
