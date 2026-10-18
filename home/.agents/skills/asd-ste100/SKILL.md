---
name: asd-ste100
description: "Teaches the ASD-STE100 Simplified Technical English format. Load and apply it only when the user directly asks for it. Never use it on your own initiative."
---

# Simplified Technical English (ASD-STE100)

ASD-STE100 is the controlled-language standard of the aerospace industry. Issue 9 (Jan 2025) has 53 writing rules in 9 sections and a dictionary of about 900 approved words, each with one meaning and one part of speech. It removes the two main causes of misreading: words with more than one meaning, and sentences with more than one possible structure. The target reader cannot ask the author a question: a non-native reader, a translation pipeline, or a model that parses a tool description or an instruction.

ASD does not allow redistribution of the dictionary, so this skill does not include it. The structural rules below are complete and you can apply them as written. The lexical rules depend on the dictionary, so treat them as a preference for plain, common words and never claim dictionary compliance. For certified STE (real maintenance documentation), check against the official standard: https://www.asd-ste100.org/STE_downloads.html

## Modes

Pick a mode from the text type. Do not announce it unless the user asks for the rule table.

- **Strict**: procedures, error messages, tool descriptions, inter-agent instructions, safety text. Apply every rule.
- **Flavored**: READMEs, PR descriptions, changelogs, explanatory prose. Apply the structural rules and verb forms in full. Treat the lexical rules as advisory, because prose needs some word range and a strict rewrite of prose reads as a personality transplant.

## Structural rules

| Rule | Do | Don't |
|---|---|---|
| Active voice | "The agent deletes the file." | "The file is deleted." Passive is allowed only in descriptive text when the actor is unknown or irrelevant, never in instructions. |
| No phrasal verbs (Rule 9.3) | "Remove the panel." / "Start the job." | "Take off the panel." / "Spin up the job." The parts do not predict the meaning. |
| One instruction per sentence | "Open the file. Read line 3." | "Open the file and read line 3, then check if it matches." |
| Sentence length | ≤20 words for instructions, ≤25 words for descriptions | Long compound or stacked subordinate clauses |
| No semicolons (Rule 8.1) | Split into separate sentences | Any semicolon. All other standard punctuation is allowed, but an em dash often marks a sentence to split. |
| Noun clusters | ≤3 nouns stacked ("fuel pump valve") | "high pressure fuel pump inlet valve assembly" |
| No omitted words | Keep subject, verb, and article explicit | "Files not backed up will be lost" (which files?) |
| Safety instructions | Start with the command or condition: "Warning: a timeout can produce a partial artifact." | A warning buried mid-sentence |
| Paragraphs | One topic, ≤6 sentences | Multi-topic paragraphs |
| Lists | Numbered or bulleted list for 3+ steps or conditions | A sequence buried in one sentence |

## Lexical rules (advisory without the dictionary)

| Rule | Do | Don't |
|---|---|---|
| One word, one meaning | Use one term for one action or thing everywhere ("check", never mixed with "verify"/"confirm") | Rotate synonyms. The reader cannot tell if they are one thing or three. |
| One part of speech per word | "Apply oil to the valve." | "Oil the valve." |
| Verb, not noun (Rule 3.7) | "Analyze the log." | "Perform an analysis of the log." |
| Plain words | "Obey the instructions." "Use." | "Follow" (also means "come after"), "utilize" |
| Domain terms | Keep necessary technical terms and define each once (STE allows a project glossary) | Undefined jargon |

Consistency inside one document is checkable. Which word is the approved one is not.

## Verb forms

Allowed: infinitive, imperative, simple present, simple past, simple future, and past participle as an adjective. Use "-ing" forms only as part of a technical noun. Do not use present perfect, past perfect, or other compound forms: "we received the report", not "we have received the report".

Exception: keep a compound form when it carries information the simple form cannot, and flag it. Two cases occur often:
- Current relevance: "the job has completed" means the output is available now. "The job completed" does not.
- A hedge: "may have failed". Modality wins over tense, because dropping the auxiliary also deletes the uncertainty.

## Process

1. Read the text once for meaning before you change anything.
2. Optionally run the linter for a mechanical first pass: `uv run python3 scripts/ste-lint.py FILE` (or pipe text on stdin, `--json` for structured output, `--help` for all flags). It uses regex heuristics. Passive voice and compound tense findings are advisory, and it never flags hedges.
3. Rewrite sentence by sentence and keep the meaning exact:
   - Keep every fact, condition, number, and scope qualifier. If a rule would remove precision, keep the longer phrasing and flag it.
   - Keep the strength of every hedge. "May have failed" is not "failed". "Could be caused by X" is not "X is the cause". Confidence is content, and length caps tempt you to cut it.
   - Add no cause, frequency, or mechanism that the source does not state.
   - Stop when the sentence is unambiguous, not when it is shortest.
4. If the text already complies, say so. STE fixes form, not substance. If the text has nothing to say, say that instead of polishing it.

## Output

Default: the rewritten text only. No preamble, mode announcement, change summary, or closing offer. If you kept a longer phrasing on purpose, add one line after the text: `Kept as-is: <phrase> (<precision it protects>)`.

When the user asks for the reasoning ("show the diff", "which rules", "before/after"), output a table instead:

```markdown
| Rule violated | Original | Simplified |
|---|---|---|
| Present perfect | "We have received your request." | "We received your request." |
| Noun cluster (4+ words) | "the agent task queue priority handler" | "the handler that sets task-queue priority" |

Mode: Strict. 2 violations found.
```

After the table, add one line about anything you deliberately did not simplify, and why.
