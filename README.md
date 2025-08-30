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