---
name: etymology-research
description: Research the etymology (origin and historical development) of words, phrases, and concepts with structured analysis and sources
license: MIT
compatibility: pi
metadata:
  audience: general
  workflow: research
---

## Success Criteria

Before presenting output, verify:

- ✅ Word/concept clearly identified
- ✅ Original language and root identified
- ✅ Historical evolution traced chronologically
- ✅ Meaning shifts documented with examples
- ✅ Related/cognate words mentioned
- ✅ Sources cited or methodology explained

Iterate up to 3 times if criteria not met.

---

## What This Skill Does

When invoked, this skill conducts thorough etymological research following linguistic methodology to trace a word's or concept's origin, evolution, and semantic changes over time.

### Research Approach

**1. Identify the Target**

Clarify what needs research:

- Single word (e.g., "algorithm", "democracy")
- Compound term (e.g., "software", "breakfast")
- Phrase or idiom (e.g., "break a leg", "the whole nine yards")
- Concept (e.g., "zero", "democracy", "robot")

**2. Trace Etymological Lineage**

Investigate chronologically backward:

- Current usage and meaning
- First recorded appearance (date, text, author)
- Intermediate language forms
- Ultimate etymon (original source)

**3. Map Semantic Evolution**

Document meaning changes:

- Original meaning vs. current meaning
- Key semantic shifts with approximate dates
- Examples showing usage in different periods
- False friends or misunderstood origins

**4. Identify Cognates and Relationships**

Note linguistic connections:

- Related words in same language family
- Borrowings into other languages
- Words derived from same root

---

## Output Format

### Structure

Present findings in this order:

```
## Etymology: [word/concept]

### Overview
Brief summary of origin and key meaning changes

### Original Source
- Language: [e.g., Greek, Latin, Arabic, Old English]
- Word/Root: [original form]
- Literal meaning: [if applicable]
- Context: [how it was originally used]

### Historical Timeline

**[Date/Period 1]**
- Language/Form: [e.g., Medieval Latin]
- Meaning: [how used at this time]
- Example: [quotation or usage example]

**[Date/Period 2]**
- Language/Form: [e.g., Middle English]
- Meaning: [evolved meaning]
- Shift: [what changed and why]

**[Date/Period 3 - Present]**
- Current form: [modern spelling/pronunciation]
- Current meaning: [primary definitions]
- Extended meanings: [metaphorical/technical uses]

### Semantic Shifts
Key changes in meaning:
1. [Original] → [Intermediate] (circa [date])
2. [Intermediate] → [Current] (circa [date])

### Cognates and Related Terms
- [Language]: [word] - [meaning]
- [Language]: [word] - [meaning]
- Derived terms: [list words derived from this root]

### Interesting Facts
- False etymologies to avoid
- Surprising connections
- Cultural significance

### Sources
Primary references consulted (if specific sources available)
```

---

## When to Use This Skill

**Trigger when user:**

- Types `etymology` or `/etymology` followed by a word
- Asks "where does [word] come from"
- Asks "what is the origin of [word/concept]"
- Requests "tell me about the history of [word]"
- Asks about word meaning evolution

**Input formats:**

- Single word: `etymology algorithm`
- With context: `etymology of the word "robot"`
- Concept: `origin of zero as a number`
- Phrase: `etymology "the whole nine yards"`

---

## Examples

**Example 1: Technical term**

**User:** etymology algorithm

**Response:**

```
## Etymology: Algorithm

### Overview
From the name of a 9th-century Persian mathematician, through a
Latinized corruption, to the modern technical procedure.

### Original Source
- Language: Arabic
- Name: الخوارزمي (al-Khwārizmī)
- Literal meaning: "the native of Khwarazm" (region in Central Asia)
- Person: Muhammad ibn Musa al-Khwarizmi (c. 780-850 CE),
  Persian mathematician

### Historical Timeline

**820 CE**
- Original: al-Khwarizmi's work on Indian numerals and algebra
- Context: Introduced decimal positional notation to the Islamic world

**12th Century**
- Latin form: "algorismus"
- Meaning: The Arabic numeral system and calculation methods
- Usage: "Dixit Algorismus" (12th c. Latin text)

**13th-17th Century**
- Corruption: "algorithm" (confused with Greek "arithmos" meaning number)
- Meaning gradually shifted from person/system to procedure

**19th Century**
- Modern usage emerges in mathematics
- Meaning: Any systematic procedure for calculation

**20th Century - Present**
- Computer science adoption (1930s-1950s)
- Meaning: Precise, finite sequence of operations
  - Turing machines (1936)
  - Early computing applications

### Semantic Shifts
1. Person's name → Numeral system (12th c.)
2. Numeral system → Calculation method (13th-17th c.)
3. Calculation method → General procedure (19th c.)
4. General procedure → Computer procedure (20th c.)

### Cognates and Related Terms
- **Algebra**: From al-Khwarizmi's book "al-Jabr"
- **Cipher/Cypher**: From Arabic "ṣifr" (zero), via Medieval Latin
- **Zero**: Same Arabic root "ṣifr" (empty)

### Interesting Facts
- The "al-" prefix is the Arabic definite article ("the")
- Originally had nothing to do with computers
- Medieval Europeans had difficulty with the foreign name,
  leading to various corruptions
```

**Example 2: Everyday concept**

**User:** origin of the word salary

**Response:**

```
## Etymology: Salary

### Overview
From the allowance given to Roman soldiers to buy salt—one of
the most valuable commodities in the ancient world.

### Original Source
- Language: Latin
- Word: "salarium"
- Literal meaning: "salt money" or "salt allowance"
- Context: Roman military compensation

### Historical Timeline

**Ancient Rome (1st Century BCE - 5th Century CE)**
- Form: "salarium"
- Meaning: Money given to soldiers specifically for purchasing salt
- Significance: Salt was essential for food preservation and
  therefore extremely valuable

**Late Latin / Medieval Period**
- Extended meaning: Any regular payment for services
- Shift: From specific salt allowance to general wages

**14th Century (English)**
- Form: "salari" (via Anglo-French)
- First English usage: Regular payment (not specifically for salt)

**Modern Usage**
- Form: "salary"
- Meaning: Fixed regular payment, typically monthly/annual
- Distinction: Usually for professional/white-collar work vs.
  "wage" for hourly/manual work

### Semantic Shifts
1. Salt allowance → Regular payment (Medieval Latin)
2. Military → Civilian usage (Medieval period)
3. General wages → Professional fixed payment (Modern English)

### Cognates and Related Terms
- **Salt**: From same root (Proto-Germanic "saltom")
- **Salad**: Originally vegetables with salt/salted dressing
  (Latin "sal" = salt)
- **Sausage**: From Latin "salsus" (salted)
- **Salacious**: Originally "salty" (Latin "salax"), later
  "lustful" metaphor
- **Soldier**: Possibly from Latin "solidus" (gold coin),
  though connection debated

### Interesting Facts
- The phrase "worth one's salt" comes from this etymology
- Roman soldiers who weren't "worth their salt" weren't worth
  their pay
- Salt was so valuable that Roman roads ("via Salaria") were
  built specifically for salt transport
- The word "salary" preserves the historical value of salt
  even though the literal connection is lost in modern usage
```

**Example 3: Modern technical term**

**User:** etymology of the word robot

**Response:**

```
## Etymology: Robot

### Overview
From a Czech word for forced labor/serfdom, popularized through
a 1920 play, then adopted into English as a mechanical automaton.

### Original Source
- Language: Czech (Slavic)
- Word: "robota"
- Literal meaning: "forced labor, corvée, serf labor"
- Context: Feudal obligations in Central Europe

### Historical Timeline

**Pre-1920 (Czech Usage)**
- Form: "robota"
- Meaning: Compulsory unpaid work, typically agricultural labor
  that serfs owed to their lord
- Legal context: Part of feudal obligations in Austro-Hungarian Empire

**1920**
- Play: "R.U.R." (Rossumovi Univerzální Roboti / Rossum's
  Universal Robots) by Karel Čapek
- Introduced: "robot" as artificial workers made of organic
  material (not mechanical)
- Plot: Robots revolt and destroy humanity
- Čapek credited his brother Josef with coining the term for the play

**1923**
- English translation of R.U.R. premieres in London
- Word enters English vocabulary
- Initial meaning: Artificial/automated worker (originally biological)

**Mid-20th Century**
- Shift to mechanical/electronic robots in science fiction
- Industrial robots developed (1960s)
- Meaning solidifies as "programmable mechanical device"

**Present**
- Broad meaning: Any automated machine, especially with AI
- Distinctions: Industrial robots, humanoid robots, software bots

### Semantic Shifts
1. Feudal forced labor → Artificial workers (1920, Čapek's play)
2. Biological androids → Mechanical machines (1930s-1960s)
3. Physical machines → Including software (1990s-present)

### Cognates and Related Terms
- **Russian**: "работа" (rabota) - work, labor
- **German**: "Arbeit" - work (cognate through Proto-Slavic/Germanic)
- **English**: "orb" (possibly related to "orbit," circle of labor)
- **Czech**: "robotník" - worker, laborer (older usage)

### Interesting Facts
- Čapek originally wanted to call them "labori" (from Latin "labor")
- His brother Josef suggested "roboti" from "robota"
- In the original play, robots were biological (artificial humans),
  not mechanical
- The word existed for centuries before becoming famous through
  the play
- "Robota" is still used in Czech/Slovak for "work"
- The robot uprising theme was present from the very first
  usage of the word
```

---

## Research Guidelines

### For Single Words

Investigate:

1. Dictionary definitions (current and historical)
2. First recorded usage (OED, Merriam-Webster dates)
3. Language family and cognates
4. Borrowing path between languages
5. Semantic changes with approximate dates

### For Phrases and Idioms

Investigate:

1. Literal vs. figurative meaning
2. Earliest recorded usage
3. Proposed origins (documented theories)
4. Folk etymologies to debunk
5. Cultural context of origin

### For Concepts

Investigate:

1. Term used to describe it across languages
2. Historical development of the concept itself
3. How naming evolved (multiple terms?)
4. Cross-cultural variations
5. Technical vs. common usage

---

## Quality Standards

### DO:

- Provide specific dates when available
- Include original language forms with proper scripts
- Note uncertainty when etymology is disputed
- Distinguish folk etymology from scholarly consensus
- Show meaning with example sentences
- Mention cognates in related languages

### DON'T:

- Present folk etymologies as fact (e.g., "posh" from "port
  out, starboard home")
- Guess at connections without evidence
- Confuse similar-sounding words from different roots
- Omit uncertainty when etymology is speculative
- Ignore semantic shifts (words often change meaning dramatically)

---

## Verification

Before presenting output:

1. Is the word/concept clearly stated?
2. Have I traced back to the ultimate etymon?
3. Did I document major semantic shifts?
4. Are there cognates or related words to mention?
5. Have I noted any disputed or uncertain aspects?
6. Are there false etymologies I should warn about?

If any answer indicates missing information, research further
or note the limitation explicitly.

---

## Critical Constraints

**NEVER:**

- Invent etymologies or connections without evidence
- Present folk etymology as scholarly consensus
- Ignore semantic shifts (original meaning often differs
  dramatically from current)
- Skip noting when etymology is disputed or uncertain

**ALWAYS:**

- Distinguish between certain and speculative etymologies
- Show the chronological development
- Include original language forms
- Note cognates and derived words when relevant
- Warn about common misconceptions
