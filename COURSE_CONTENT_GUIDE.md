# Course Content Guide (Noorine)

This guide is the single source of truth for adding new course levels.

**Where to edit**
`Noorine/Noorine/Core/course_content.json`

**How to add a new level**

1. Add or reuse content items in `letters`, `vowels`, `words`, `phrases`.
2. Add a new level entry in `levels.en` and `levels.fr` with the same `id` and `type`.
3. Build and run the app. Check Xcode console for `CourseContent validation` messages.

**Level types and required `contentIds`**
`alphabet` -> ids from `letters`
`vowels` -> ids from `vowels`
`wordBuild` -> ids from `words`
`phrases` -> ids from `phrases`
`speaking` -> ids from `letters` (used for pronunciation goals)
`solarLunar` -> `contentIds` must be an empty array

**Phrase rules**

1. `wordIds` is optional. If empty, the app splits the Arabic text by spaces to build the word tiles.
2. `audioName` is optional. If missing or no audio file exists, the app uses TTS on the Arabic text.
3. Use harakât (diacritics) for better TTS quality.

**Word rules**

1. `componentLetterIds` must match the letters used in the word, in correct order.

**Minimal level example**

```json
{
  "id": 25,
  "type": "phrases",
  "titleKey": "Au café",
  "subtitle": "مِنْ فَضْلِكَ",
  "contentIds": [11, 12, 13]
}
```
