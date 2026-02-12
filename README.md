# MACS R15

A modern, extensible Roblox R15 combat framework built on top of ACS 2.0.0, featuring advanced weapon mechanics, modular architecture, and enhanced gameplay systems.

This project extends the original ACS framework with custom combat features, while maintaining compatibility with Roblox best practices and professional development workflows.

## Table of Contents

- [MACS R15](#macs-r15)
  - [Table of Contents](#table-of-contents)
  - [Baseline](#baseline)
  - [Setup](#setup)
    - [Requirements](#requirements)
    - [Installation](#installation)
  - [Documentation](#documentation)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Contributing](#contributing)
  - [Tools Used](#tools-used)
  - [License](#license)
  - [Credits](#credits)

## Baseline

This framework is built using **ACS 2.0.0 (R15)** as its baseline

## Setup

### Requirements
- [Rojo](https://rojo.space/) 7.6.1+ Project management & file syncing
- [Wally](https://wally.run/) Dependency management
- [Selene](https://kampfkarren.github.io/selene/) Lua linting

### Installation

1. Clone or download the project

2. Install dependencies:
```bash
wally install
```

3. Build the place file:
```bash
rojo build -o "MACS R15.rbxlx"
```

4. Open `MACS R15.rbxlx` in Roblox Studio

5. Start the Rojo development server:
```bash
rojo serve
```

6. In Roblox Studio, enable Rojo sync to connect with the dev server

## Documentation

Project documentation and patch notes are organized under the `Docs/` directory:

- **Framework Patch Notes**
    See [Patch Notes](Docs/Patch%20Notes.md)

- **Configurable Features**
    See [Configurable](Docs/Configurable.md)

- ACS Patch Notes
  - [ACS Patch Notes](Docs/ACS%20Patch%20Notes/ACS%20Patch%20Note.md)
  - [Official ACS 2.0.0 Patch Notes](Docs/ACS%20Patch%20Notes/Official%20ACS%202.0.0%20Patch%20Note.md)

## Dependencies

- [Cmdr](https://github.com/evaera/cmdr) 1.12.0 - Command framework for Roblox

## Configuration

Game settings can be configured in:
- `ACS_Engine/GameRules/Config.lua` - Global game configuration

## Contributing

When contributing to this project:
1. Follow the existing code structure and naming conventions
2. Ensure scripts are properly localized (use ReplicatedStorage for shared code)
3. Keep server logic authoritative
4. Avoid client-trusting mechanics
5. Validate all remote calls
6. Test animations, recoil, and replication
7. Document any gameplay modifications

## Tools Used

- **Rojo** - File synchronization and project management
- **Wally** - Package management
- **Selene** - Lua linting

## License

This project is licensed under the [Apache License 2.0](LICENSE).

## Credits

**ACS Framework** - 00Scorpion00

**(RCM) Ro-Combat Mod** - Inabuko

---

**Note**: This project uses Rojo for development. See [Rojo documentation](https://rojo.space/docs) for more information on syncing and building.