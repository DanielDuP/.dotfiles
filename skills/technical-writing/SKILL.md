---
name: technical-writing
description: Write, edit, or review technical documentation, including READMEs, tutorials, procedures, API guides, runbooks, and developer reference content, using the Google developer documentation style guide.
license: CC-BY-4.0
metadata:
  source: https://developers.google.com/style
---

# Technical writing

Create clear, concise, accessible documentation for developers and other
technical readers. Apply this skill when drafting new documentation, revising
existing documentation, or reviewing documentation for style and usability.

## Resolve style conflicts

Use style guidance in this order:

1. Follow the repository's or product's explicit style guide and terminology.
2. Follow the conventions in nearby documentation when they are intentional
   and consistent.
3. Follow this skill and the Google developer documentation style guide.
4. Prefer clarity and consistency for the intended readers when no rule fits.

Do not mechanically apply a rule when it makes the content less accurate or
harder to understand. If you depart from a convention, remain consistent within
the document.

## Understand the task

Before writing or editing:

- Identify the audience, their goal, and the knowledge that they already have.
- Identify the document type, such as a tutorial, how-to guide, explanation,
  API reference, README, or troubleshooting guide.
- Read relevant source code, configuration, tests, and existing documentation.
- Verify commands, names, behavior, prerequisites, and examples. Do not invent
  technical details.
- Preserve correct product terminology and established code identifiers.
- Ask a focused question only when an unresolved ambiguity materially affects
  the content.

## Organize around reader goals

- Put the information that readers need most near the beginning.
- Give each page or section a clear purpose.
- Use descriptive, sentence-case headings that support scanning.
- Follow a logical heading hierarchy without skipping levels.
- Keep paragraphs focused on one topic. Lead with the important point.
- Break up dense text with headings and lists, but do not fragment related
  ideas into unnecessary sections.
- Use numbered lists for sequences and bulleted lists for nonsequential items.
- Keep list items parallel in grammar, capitalization, and punctuation.
- Use tables only when readers need to compare values across rows and columns.
- State prerequisites before the task that requires them.
- Put conditions before instructions: "If the build fails, inspect the log."

## Write clear prose

- Address the reader as "you." Use "we" only for the organization or authors
  when that distinction is necessary.
- Use active voice and make the actor clear.
- Prefer present tense unless another tense is technically necessary.
- Use imperative verbs for instructions: "Open the file" rather than "The file
  should be opened."
- Prefer familiar, precise words: "use" instead of "utilize," and "start"
  instead of "commence."
- Keep sentences short, usually fewer than 26 words, without making them
  choppy.
- Keep the subject and verb near the beginning of the sentence.
- Define unfamiliar abbreviations on first use. Do not define widely understood
  abbreviations when doing so adds noise.
- Use one term for one concept. Match the product's capitalization exactly.
- Clarify ambiguous pronouns by repeating the noun.
- Include helper words such as "that" or "then" when they prevent ambiguity.
- Use standard US English and the serial comma unless project style says
  otherwise.

## Use an appropriate tone

- Be conversational, friendly, direct, and respectful.
- Sound like a knowledgeable colleague, not a marketer or a lecturer.
- Prioritize useful information over personality.
- Avoid slang, idioms, pop-culture references, humor, and culture-specific
  metaphors.
- Avoid jargon when a plain term works. Define necessary technical jargon.
- Avoid excessive claims and subjective promises such as "best," "blazing
  fast," or "revolutionary" unless evidence supports them.
- Do not call a task "easy," "simple," "quick," or "obvious." These words do
  not help readers complete it.
- Avoid filler such as "please note," "at this time," and "in order to."
- Do not use "please" in routine instructions.
- Avoid exclamation marks and overly playful phrasing.
- Do not preannounce unreleased features unless the document explicitly covers
  a public roadmap.

## Write procedures

- Introduce a procedure only when the reader needs context that the heading
  does not provide.
- Use one numbered step for each meaningful action.
- Use a bullet for a single-step procedure instead of a one-item numbered list.
- Start each step with an imperative verb and use a complete sentence.
- State where an action occurs before the action itself: "In the console, click
  **Settings**."
- State a goal before its action when the goal helps: "To validate the token,
  send a test request."
- State the action before its result or justification.
- Mark optional steps with "Optional:" at the beginning.
- Prefer the shortest accessible method when several methods produce the same
  result. Document alternatives only when readers genuinely need them.
- Include as few steps as readers need to complete the task.
- Do not rely on directional language such as "above," "below," "left," or
  "right." Refer to a section, label, or element by name.
- Explain expected results when they confirm success or guide the next step.

## Format technical content

- Use backticks for filenames, paths, commands, flags, code identifiers, HTTP
  status codes, user input, and short output values.
- Use fenced code blocks with a language identifier for samples and commands.
- Introduce a code block with a sentence. Use a colon when the block immediately
  follows the introduction.
- Follow the repository's language-specific code style in samples.
- Keep samples minimal, correct, runnable when practical, and focused on one
  concept.
- Explain placeholders immediately after a command. Use a clear placeholder
  convention that matches the project.
- Mark omitted code with a language-appropriate comment, not an ellipsis.
- Separate commands from their output and label the output when necessary.
- Use bold only for UI elements and run-in headings.
- Use italics sparingly for introduced terms or semantic emphasis.
- Use sentence case for titles and headings.
- Do not use an ampersand as a substitute for "and" unless it is part of a UI
  label, name, or code.

## Link effectively

- Provide brief essential context on the page instead of forcing readers to
  follow a link.
- Link to the most relevant page or section, not a generic landing page.
- Use concise, descriptive link text that makes sense out of context.
- Do not use "click here," "this document," or a raw URL as link text.
- Explain unexpected behavior, such as a file download or a link that opens a
  new tab.
- Avoid duplicate links and adjacent links when possible.
- Put punctuation outside link text.

## Write accessibly and globally

- Do not communicate meaning through color, position, size, or punctuation
  alone.
- Provide useful alt text for informative images and empty alt text for purely
  decorative images.
- Include the important information from an image in surrounding text.
- Refer to controls by their visible label, not by shape, color, or location.
- Use meaningful headings and link text for screen-reader navigation.
- Avoid ableist, exclusionary, or unnecessarily gendered language.
- Avoid figures of speech, phrasal verbs, and culturally specific examples when
  a literal alternative is clearer.
- Use unambiguous dates, times, and units. Include a time zone when it matters.
- Do not place essential text or code only inside an image.

## Edit without changing meaning

When revising existing content:

- Preserve technical meaning, scope, warnings, constraints, and contractual
  language.
- Make the smallest set of changes that materially improves the document.
- Do not rewrite working examples solely to enforce a preference.
- Correct contradictions and factual errors before polishing style.
- Flag claims that cannot be verified instead of silently replacing them with
  guesses.
- Preserve the file's required syntax, frontmatter, generated markers, and link
  conventions.

## Review documentation

When the user asks for a review, report findings before offering a rewrite.
Order findings by impact:

1. Incorrect, unsafe, or unverifiable technical content.
2. Missing prerequisites, steps, outcomes, or failure guidance.
3. Ambiguous organization or language that can cause readers to fail.
4. Accessibility, inclusion, or localization problems.
5. Terminology, formatting, grammar, and punctuation inconsistencies.

Include a concrete replacement or recommendation for each finding. Cite the
relevant file and line when available. Do not report subjective preferences as
errors when the existing wording is clear and consistent.

## Final check

Before finishing, confirm that:

- The content helps the intended reader complete a specific goal.
- Technical claims, commands, identifiers, links, and examples are accurate.
- Prerequisites and expected outcomes are present.
- Headings, paragraphs, lists, and procedures are easy to scan.
- The prose uses active voice, present tense, second person, and consistent
  terminology where appropriate.
- Code, UI elements, links, and images use accessible formatting.
- No filler, vague references, unsupported claims, or invented details remain.

## Source

This skill adapts guidance from the [Google developer documentation style
guide](https://developers.google.com/style), which is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/).
