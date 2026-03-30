# Implementation notes

## Scope implemented
- add
- list
- done
- remove
- clear
- help

## Design choices
- local JSON file persistence
- atomic write via temp-file rename
- explicit storage validation on read
- default `list` view shows open items
- `list --all`, `list --done`, `list --open` supported

## Quality choices
- avoid hidden destructive behavior
- return understandable error messages
- keep command handlers small and explicit
