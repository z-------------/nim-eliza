import std/strutils
import std/tables
import std/sugar
import std/options
import std/sequtils

type
  Eliza* = object
    whichReply: Table[string, int]
    lastInput: Option[string]
  Response = tuple[text: string, asterisk: bool]

const
  Swaps = {
    "ARE": "AM",
    "WERE": "WAS",
    "YOU": "I",
    "YOUR": "MY",
    "IVE": "YOU'VE",
    "IM": "YOU'RE",
    "YOU": "ME",
    "ME": "YOU",
    "AM": "ARE",
    "WAS": "WERE",
    "I": "YOU",
    "MY": "YOUR",
    "YOUVE": "I'VE",
    "YOURE": "I'M",
  }.toTable
  NotFoundKey = "NOKEYFOUND"
  Responses: OrderedTable[string, seq[Response]] = {
    "CAN YOU": @[
      "DON'T YOU BELIEVE THAT I CAN {}?",
      "PERHAPS YOU WOULD LIKE TO BE ABLE TO {}?",
      "YOU WANT ME TO BE ABLE TO {}?",
    ],
    "CAN I": @[
      "PERHAPS YOU DON'T WANT TO {}?",
      "DO YOU WANT TO BE ABLE TO {}?",
    ],
    "YOU ARE": @[
      "WHAT MAKES YOU THINK I AM {}?",
      "DOES IT PLEASE YOU TO BELIEVE I AM {}?",
      "PERHAPS YOU WOULD LIKE TO BE {}?",
      "DO YOU SOMETIMES WISH YOU WERE {}?",
    ],
    "YOURE": @[
      "WHAT MAKES YOU THINK I AM {}?",
      "DOES IT PLEASE YOU TO BELIEVE I AM {}?",
      "PERHAPS YOU WOULD LIKE TO BE {}?",
      "DO YOU SOMETIMES WISH YOU WERE {}?",
    ],
    "I DONT": @[
      "DON'T YOU REALLY {}?",
      "WHY DON'T YOU {}?",
      "DO YOU WISH TO BE ABLE TO {}?",
      "DOES THAT TROUBLE YOU?",
    ],
    "I FEEL": @[
      "TELL ME MORE ABOUT SUCH FEELINGS.",
      "DO YOU OFTEN FEEL {}?",
      "DO YOU ENJOY FEELING {}?",
    ],
    "WHY DONT YOU": @[
      "DO YOU REALLY BELIEVE I DON'T {}?",
      "PERHAPS IN GOOD TIME I WILL {}?",
      "DO YOU WANT ME TO {}?",
    ],
    "WHY CANT I": @[
      "DO YOU THINK YOU SHOULD BE ABLE TO {}?",
      "WHY CAN'T YOU {}?",
    ],
    "ARE YOU": @[
      "WHY ARE YOU INTERESTED IN WHETHER OR NOT I AM {}?",
      "WOULD YOU PREFER IF I WERE NOT {}?",
      "PERHAPS IN YOUR FANTASIES I AM {}?",
    ],
    "I CANT": @[
      "HOW DO YOU KNOW YOU CAN'T {}?",
      "HAVE YOU TRIED?",
      "PERHAPS YOU CAN NOW {}?",
    ],
    "I AM": @[
      "DID YOU COME TO ME BECAUSE YOU ARE {}?",
      "HOW LONG HAVE YOU BEEN {}?",
      "DO YOU BELIEVE IT IS NORMAL TO BE {}?",
      "DO YOU ENJOY BEING {}?",
    ],
    "IM ": @[
      "DID YOU COME TO ME BECAUSE YOU ARE {}?",
      "HOW LONG HAVE YOU BEEN {}?",
      "DO YOU BELIEVE IT IS NORMAL TO BE {}?",
      "DO YOU ENJOY BEING {}?",
    ],
    "YOU ": @[
      "WE WERE DISCUSSING YOU-- NOT ME.",
      "OH, I {}?",
      "YOU'RE NOT REALLY TALKING ABOUT ME, ARE YOU?",
    ],
    "I WANT": @[
      "WHAT WOULD IT MEAN TO YOU IF YOU GOT {}?",
      "WHY DO YOU WANT {}?",
      "SUPPOSE YOU SOON GOT {}?",
      "WHAT IF YOU NEVER GOT {}?",
      "I SOMETIMES ALSO WANT {}?",
    ],
    "WHAT": @[
      "WHY DO YOU ASK?",
      "DOES THAT QUESTION INTEREST YOU?",
      "WHAT ANSWER WOULD PLEASE YOU THE MOST?",
      "WHAT DO YOU THINK?",
      "ARE SUCH QUESTIONS ON YOUR MIND OFTEN?",
      "WHAT IS IT THAT YOU REALLY WANT TO KNOW?",
      "HAVE YOU ASKED ANYONE ELSE?",
      "HAVE YOU ASKED SUCH QUESTIONS BEFORE?",
      "WHAT ELSE COMES TO MIND WHEN YOU ASK THAT?",
    ],
    "HOW": @[
      "WHY DO YOU ASK?",
      "DOES THAT QUESTION INTEREST YOU?",
      "WHAT ANSWER WOULD PLEASE YOU THE MOST?",
      "WHAT DO YOU THINK?",
      "ARE SUCH QUESTIONS ON YOUR MIND OFTEN?",
      "WHAT IS IT THAT YOU REALLY WANT TO KNOW?",
      "HAVE YOU ASKED ANYONE ELSE?",
      "HAVE YOU ASKED SUCH QUESTIONS BEFORE?",
      "WHAT ELSE COMES TO MIND WHEN YOU ASK THAT?",
    ],
    "WHO": @[
      "WHY DO YOU ASK?",
      "DOES THAT QUESTION INTEREST YOU?",
      "WHAT ANSWER WOULD PLEASE YOU THE MOST?",
      "WHAT DO YOU THINK?",
      "ARE SUCH QUESTIONS ON YOUR MIND OFTEN?",
      "WHAT IS IT THAT YOU REALLY WANT TO KNOW?",
      "HAVE YOU ASKED ANYONE ELSE?",
      "HAVE YOU ASKED SUCH QUESTIONS BEFORE?",
      "WHAT ELSE COMES TO MIND WHEN YOU ASK THAT?",
    ],
    "WHERE": @[
      "WHY DO YOU ASK?",
      "DOES THAT QUESTION INTEREST YOU?",
      "WHAT ANSWER WOULD PLEASE YOU THE MOST?",
      "WHAT DO YOU THINK?",
      "ARE SUCH QUESTIONS ON YOUR MIND OFTEN?",
      "WHAT IS IT THAT YOU REALLY WANT TO KNOW?",
      "HAVE YOU ASKED ANYONE ELSE?",
      "HAVE YOU ASKED SUCH QUESTIONS BEFORE?",
      "WHAT ELSE COMES TO MIND WHEN YOU ASK THAT?",
    ],
    "WHEN": @[
      "WHY DO YOU ASK?",
      "DOES THAT QUESTION INTEREST YOU?",
      "WHAT ANSWER WOULD PLEASE YOU THE MOST?",
      "WHAT DO YOU THINK?",
      "ARE SUCH QUESTIONS ON YOUR MIND OFTEN?",
      "WHAT IS IT THAT YOU REALLY WANT TO KNOW?",
      "HAVE YOU ASKED ANYONE ELSE?",
      "HAVE YOU ASKED SUCH QUESTIONS BEFORE?",
      "WHAT ELSE COMES TO MIND WHEN YOU ASK THAT?",
    ],
    "WHY": @[
      "WHY DO YOU ASK?",
      "DOES THAT QUESTION INTEREST YOU?",
      "WHAT ANSWER WOULD PLEASE YOU THE MOST?",
      "WHAT DO YOU THINK?",
      "ARE SUCH QUESTIONS ON YOUR MIND OFTEN?",
      "WHAT IS IT THAT YOU REALLY WANT TO KNOW?",
      "HAVE YOU ASKED ANYONE ELSE?",
      "HAVE YOU ASKED SUCH QUESTIONS BEFORE?",
      "WHAT ELSE COMES TO MIND WHEN YOU ASK THAT?",
    ],
    "NAME": @[
      "NAMES DON'T INTEREST ME.",
      "I DON'T CARE ABOUT NAMES-- PLEASE GO ON.",
    ],
    "CAUSE": @[
      "IS THAT THE REAL REASON?",
      "DON'T ANY OTHER REASONS COME TO MIND?",
      "DOES THAT REASON EXPLAIN ANY THING ELSE?",
      "WHAT OTHER REASONS MIGHT THERE BE?",
    ],
    "SORRY": @[
      "PLEASE DON'T APOLOGIZE.",
      "APOLOGIES ARE NOT NECESSARY.",
      "WHAT FEELINGS DO YOU HAVE WHEN YOU APOLOGIZE?",
      "DON'T BE SO DEFENSIVE!",
    ],
    "DREAM": @[
      "WHAT DOES THAT DREAM SUGGEST TO YOU?",
      "DO YOU DREAM OFTEN?",
      "WHAT PERSONS APPEAR IN YOUR DREAMS?",
      "ARE YOU DISTURBED BY YOUR DREAMS?",
    ],
    "HELLO": @[
      "HOW DO YOU DO--PLEASE STATE YOUR PROBLEM.",
    ],
    "HI ": @[
      "HOW DO YOU DO--PLEASE STATE YOUR PROBLEM.",
    ],
    "MAYBE": @[
      "YOU DON'T SEEM QUITE CERTAIN.",
      "WHY THE UNCERTAIN TONE?",
      "CAN'T YOU BE MORE POSITIVE?",
      "YOU AREN'T SURE?",
      "DON'T YOU KNOW?",
    ],
    " NO": @[
      "ARE YOU SAYING NO JUST TO BE NEGATIVE?",
      "YOU ARE BEING A BIT NEGATIVE.",
      "WHY NOT?",
      "ARE YOU SURE?",
      "WHY NO?",
    ],
    "YOUR": @[
      "WHY ARE YOU CONCERNED ABOUT MY {}?",
      "WHAT ABOUT YOUR OWN {}?",
    ],
    "ALWAYS": @[
      "CAN YOU THINK OF A SPECIFIC EXAMPLE?",
      "WHEN?",
      "WHAT ARE YOU THINKING OF?",
      "REALLY, ALWAYS?",
    ],
    "THINK": @[
      "DO YOU REALLY THINK SO?",
      "BUT YOU ARE NOT SURE YOU {}?",
      "DO YOU DOUBT YOU {}?",
    ],
    "ALIKE": @[
      "IN WHAT WAY?",
      "WHAT RESEMBLANCE DO YOU SEE?",
      "WHAT DOES THE SIMILARITY SUGGEST TO YOU?",
      "WHAT OTHER CONNECTIONS DO YOU SEE?",
      "COULD THERE REALLY BE SOME CONNECTION?",
      "HOW?",
    ],
    "YES": @[
      "YOU SEEM QUITE POSITIVE.",
      "ARE YOU SURE?",
      "I SEE.",
      "I UNDERSTAND.",
    ],
    "FRIEND": @[
      "WHY DO YOU BRING UP THE TOPIC OF FRIENDS?",
      "DO YOUR FRIENDS WORRY YOU?",
      "DO YOUR FRIENDS PICK ON YOU?",
      "ARE YOU SURE YOU HAVE ANY FRIENDS?",
      "DO YOU IMPOSE ON YOUR FRIENDS?",
      "PERHAPS YOUR LOVE FOR FRIENDS WORRIES YOU?",
    ],
    "COMPUTER": @[
      "DO COMPUTERS WORRY YOU?",
      "ARE YOU TALKING ABOUT ME IN PARTICULAR?",
      "ARE YOU FRIGHTENED BY MACHINES?",
      "WHY DO YOU MENTION COMPUTERS?",
      "WHAT DO YOU THINK MACHINES HAVE TO DO WITH YOUR PROBLEM?",
      "DON'T YOU THINK COMPUTERS CAN HELP PEOPLE?",
      "WHAT IS IT ABOUT MACHINES THAT WORRIES YOU?",
    ],
    "CAR": @[
      "OH, DO YOU LIKE CARS?",
      "MY FAVORITE CAR IS A LAMBORGINI COUNTACH. WHAT IS YOUR FAVORITE CAR?",
      "MY FAVORITE CAR COMPANY IS FERRARI.  WHAT IS YOURS?",
      "DO YOU LIKE PORSCHES?",
      "DO YOU LIKE PORSCHE TURBO CARRERAS?",
    ],
    NotFoundKey: @[
      "SAY, DO YOU HAVE ANY PSYCHOLOGICAL PROBLEMS?",
      "WHAT DOES THAT SUGGEST TO YOU?",
      "I SEE.",
      "I'M NOT SURE I UNDERSTAND YOU FULLY.",
      "COME, COME ELUCIDATE YOUR THOUGHTS.",
      "CAN YOU ELABORATE ON THAT?",
      "THAT IS QUITE INTERESTING.",
    ],
  }.map(pair =>
    (let (key, responses) = pair; (key, responses.map(
      response => (response, response.contains("{}"))
    )))
  ).toOrderedTable
  Separator = " "

proc initEliza*(): Eliza =
  result.whichReply = collect(initTable):
    for key in Responses.keys:
      {key: 0}

proc tell*(e: var Eliza; inputStr: string): tuple[response: string, isContinue: bool] =
  # check for termination
  if inputStr == "BYE":
    return ("GOODBYE!  THANKS FOR VISITING WITH ME...", false)

  # check for repeated entries
  if e.lastInput.isSome and inputStr == e.lastInput.get:
    return ("PLEASE DON'T REPEAT YOURSELF!", true)
  e.lastInput = inputStr.some

  # see if any of the keywords is contained in the input
  # if not, we use the last element of keywords as our default responses
  var
    keyword = NotFoundKey
    locationIdx = -1
  for key in Responses.keys:
    locationIdx = inputStr.find(key)
    if locationIdx != -1:
      keyword = key
      break

  # Build Eliza's response
  # start with Eliza's canned response, based on the keyword match
  let (baseResponse, asterisk) = Responses[keyword][e.whichReply[keyword]]

  # if we have a baseResponse without a {}, just use it as-is
  let reply =
    if not asterisk:
      baseResponse
    else:
      # if we do have a {}, fill it with the user input
      var swappedInput: seq[string]
      # add in the rest of the user's input, starting at <location>
      # but skip over the keyword itself
      locationIdx += keyword.len
      # take them one word at a time, so that we can substitute pronouns
      for token in inputStr[locationIdx..inputStr.high].split(Separator):
        if token.len == 0:
          continue
        swappedInput.add(
          if Swaps.contains(token):
            Swaps[token]
          else:
            token
        )
      baseResponse.replace("{}", swappedInput.join(" "))

  # next time, use the next appropriate reply for that keyword
  e.whichReply[keyword] = (e.whichReply[keyword] + 1) mod Responses[keyword].len

  (reply, true)
