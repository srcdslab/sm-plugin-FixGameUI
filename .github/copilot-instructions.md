# Copilot Instructions for sm-plugin-FixGameUI

## Repository Overview
This repository contains a SourcePawn plugin for SourceMod that fixes a critical game_ui entity bug in Source engine games. The plugin prevents crashes and unexpected behavior when players disconnect while attached to game_ui entities.

### Key Information
- **Plugin Name**: FixGameUI
- **Language**: SourcePawn
- **Platform**: SourceMod 1.11.0+ (Source engine games)
- **Purpose**: Fixes game_ui entity bugs that cause crashes and player state issues
- **Authors**: hlstriker + GoD-Tony
- **Current Version**: 2.2.0

## Technical Environment & Dependencies

### Build System
- **Build Tool**: SourceKnight (modern SourcePawn build system)
- **Configuration**: `sourceknight.yaml`
- **Compiler**: SourcePawn compiler (spcomp) via SourceKnight
- **Target Output**: `/addons/sourcemod/plugins/FixGameUI.smx`

### Dependencies
- SourceMod 1.11.0-git6917 (minimum)
- DHooks extension (for function hooking)
- SDKTools (for entity manipulation)
- SDKHooks (for entity hooks)

### Build Commands
```bash
# Build using SourceKnight (via CI)
sourceknight build

# Manual compilation (if spcomp available)
spcomp addons/sourcemod/scripting/FixGameUI.sp
```

## Code Style & Standards

### SourcePawn Conventions
- Use `#pragma semicolon 1` and `#pragma newdecls required`
- Indentation: 4 spaces (tabs)
- Global variables: prefix with `g_` (e.g., `g_hAcceptInput`, `g_iAttachedGameUI`)
- Function names: PascalCase (e.g., `GameUI_PlayerOn`, `RemoveFromGameUI`)
- Local variables: camelCase
- Constants: UPPERCASE with underscores

### Handle Management
- Use `INVALID_HANDLE` for initialization
- Always use `CloseHandle()` for cleanup
- Use `delete` for StringMap/ArrayList cleanup (never `.Clear()`)
- Check for `INVALID_ENT_REFERENCE` when dealing with entity references

### Memory Management
- Properly manage DHooks handles
- Use `EntIndexToEntRef()` and `EntRefToEntIndex()` for entity references
- Clean up on client disconnect and plugin end

## Project Structure

```
addons/sourcemod/
├── scripting/
│   └── FixGameUI.sp          # Main plugin source
├── plugins/                  # Compiled output (generated)
│   └── FixGameUI.smx
├── gamedata/                 # Game signatures (if needed)
└── translations/             # Language files (if needed)
```

### Key Files
- `FixGameUI.sp`: Main plugin implementation
- `sourceknight.yaml`: Build configuration
- `.github/workflows/ci.yml`: CI/CD pipeline
- `.gitignore`: Excludes compiled plugins and build artifacts

## Plugin Architecture

### Core Functionality
The plugin addresses a critical bug where game_ui entities don't properly clean up when players disconnect, causing:
- Server crashes
- Player state corruption
- Entity reference issues

### Technical Approach
1. **DHooks Integration**: Hooks `AcceptInput` function to intercept game_ui deactivation
2. **Event Handling**: Monitors player death and disconnect events
3. **Entity Management**: Tracks game_ui attachments per player
4. **State Cleanup**: Forces proper cleanup on player state changes

### Key Components
- `g_hAcceptInput`: DHook handle for AcceptInput function
- `g_iAttachedGameUI[]`: Array tracking player-gameui associations
- `Hook_AcceptInput()`: Main hook function preventing crashes
- `RemoveFromGameUI()`: Cleanup function for player detachment

## Development Guidelines

### When Modifying Code
1. **Preserve Core Logic**: The DHooks implementation is critical - avoid changes unless necessary
2. **Entity Safety**: Always validate entity references and indices
3. **Client Validation**: Check client index bounds (1 <= client <= MaxClients)
4. **Handle Cleanup**: Ensure proper resource management
5. **Testing**: Test with player disconnections during game_ui usage

### Common Tasks
- **Adding Features**: Consider impact on existing hook logic
- **Performance**: Plugin runs on entity hooks - optimize carefully
- **Debugging**: Use `LogMessage()` for debugging, remove before commit
- **Version Updates**: Update version in plugin info block

### Code Patterns to Follow
```sourcepawn
// Client validation
if (!(1 <= client <= MaxClients))
    return;

// Entity validation  
if (entity >= GetMaxEntities() || entity < 0)
    return;

// Handle validation
if (handle == INVALID_HANDLE)
    return;

// Entity reference usage
int entRef = EntIndexToEntRef(entity);
int entity = EntRefToEntIndex(entRef);
if (entity == INVALID_ENT_REFERENCE)
    return;
```

## CI/CD Process

### Automated Workflow
1. **Build**: Compiles plugin using SourceKnight action
2. **Package**: Creates release-ready package
3. **Release**: Automatic releases on tags and main branch
4. **Artifacts**: Uploads compiled plugins for testing

### Release Management
- Uses semantic versioning (MAJOR.MINOR.PATCH)
- Tags create official releases
- `latest` tag for development builds
- Packages include full addon structure

## Testing & Validation

### Manual Testing Scenarios
1. **Basic Functionality**: Verify plugin loads without errors
2. **Game UI Interaction**: Test with maps using game_ui entities
3. **Player Disconnect**: Disconnect players while attached to game_ui
4. **Server Stability**: Monitor for crashes during game_ui operations
5. **Multiple Players**: Test concurrent game_ui usage

### Error Checking
- Monitor server logs for DHooks errors
- Check for entity leaks
- Validate proper cleanup on map changes
- Test plugin reload functionality

## Common Issues & Solutions

### Build Issues
- **Missing Dependencies**: Ensure SourceMod version compatibility
- **DHooks Missing**: Verify DHooks extension is loaded
- **Gamedata Errors**: Check sdktools.games gamedata file

### Runtime Issues
- **Hook Failures**: Verify game signatures are current
- **Entity Errors**: Check entity validation in all functions
- **Memory Leaks**: Ensure proper handle and reference cleanup

## Performance Considerations
- Plugin hooks frequently called functions - optimize carefully
- Minimize operations in `Hook_AcceptInput`
- Cache expensive lookups where possible
- Use entity references instead of indices for long-term storage

## Contributing Guidelines
- Follow existing code style exactly
- Test thoroughly with multiple players
- Update version number for releases
- Document any behavioral changes
- Preserve backward compatibility when possible

## Specialized Knowledge Required
- Understanding of Source engine entity system
- SourceMod API familiarity
- DHooks extension usage
- Game UI entity behavior
- Source engine event system
- Entity reference management in SourcePawn