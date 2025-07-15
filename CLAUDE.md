# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Emoji Tapper is a new Apple Watch game. It has a very simple user interface, that shows a timer, with time remaining (this will be on the order of seconds... never more than a minute), and shows a score, which will be a count of how many emojis they've tapped (probably on the order of <100, but maybe gets bigger).

The game play will be to show an emoji somewhere random on the screen (lets randomly pick one for now) and the user has to tap on it. They have some amount of starting time... lets say 10s for the first version. When you tap the emoji, it disappears, and we add 10% of the current time, to your timer. It then shows a new randomly positioned timer. It should add one to your score.

That's the basic game play.

We'll plan ahead for more complicated levels... maybe where we show a bunch of different emojis, where you only get points for tapping the correct one... but we can add that later, with more level modes - but lets structure our code expecting to have different types of levels.

## Development Commands

### Building and Running
- Open `EmojiTapper/EmojiTapper.xcodeproj` in Xcode
- Build: `⌘+B` in Xcode or `xcodebuild` from command line
- Run on simulator: `⌘+R` in Xcode
- Run tests: `⌘+U` in Xcode or `xcodebuild test` from command line

### Testing
The project uses Swift Testing framework (not XCTest). Test files are located in:
- `EmojiTapper Watch AppTests/` - Unit tests
- `EmojiTapper Watch AppUITests/` - UI tests

## Architecture

### App Structure
- **EmojiTapperApp.swift**: Main app entry point using `@main` App protocol
- **ContentView.swift**: Root SwiftUI view (currently template with "Hello, world!")
- **Assets.xcassets/**: App icons, accent colors, and other visual assets

### Target Configuration
- Main target: "EmojiTapper Watch App" 
- Test targets: Unit tests and UI tests for watch app
- Deployment target: Apple Watch (watchOS)

## Key Files
- `EmojiTapper Watch App/EmojiTapperApp.swift:11` - App entry point
- `EmojiTapper Watch App/ContentView.swift:10` - Main view struct