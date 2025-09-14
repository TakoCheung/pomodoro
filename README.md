Users should be able to:
Set a pomodoro timer and short and long break timers
- [ ] Customize the duration of each timer
- [ ] See a circular progress indicator for each timer, updated once per minute
- [ ] Customize the appearance of the app with the ability to set preferences for colors and fonts

Technical Requirements:
- [ ] Riverpod for state management
- [ ] Unit and golden tests

Follow the Figma design file (pomodora-app.fig) included in this project for mobile and tablet only. Download Figma and import the file to inspect the designs.

## Git hooks

This repo includes a pre-commit hook to format staged files with Prettier.

Setup once:

- Configure Git to use this repo's hooks directory: `git config core.hooksPath .githooks`
- Ensure Prettier is installed locally: `npm i -D prettier`

On commit, staged JS/TS/JSON/Markdown/YAML/CSS/HTML files will be formatted and re-added.

## Background notifications: sound & vibration

- Android: Background/killed completions post a high-importance notification with sound and vibration. The app enables vibration on the notification channel and per-notification with a short pattern. Sound selection honors your chosen sound in Settings.
- iOS: The system controls vibration for notifications. The app requests alert and sound permissions and plays the default notification sound. Background notification haptics cannot be explicitly enabled by the app.