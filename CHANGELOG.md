# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Changed

- An end tag that doesn't name its block, like `<{ :if }>`, has the name `:nameless` in the lexer's segments, as `Lexeme::NAMELESS_END`, where it had `'level_1'`

### Fixed

- A component with a `<{ :slot }>` can be used without one, like `<{ Card }>`, and its slot renders nothing, where it raised `undefined method 'children' for nil`

## 1.5.4

### Fixed

- An `if` inside an `if`, or a `for` inside a `for`, closes with its own end tag, where it closed the outer one and the template didn't parse

## 1.5.3

### Added

- A form's HTML attributes, like `<{ form: '/cart' class='add-to-cart' }>`

### Fixed

- Components get the render context of the template they're in
- `method: 'GET'` and anything else after a form's action went into its action, so `<{ form: '/search' method: 'GET' }>` posted to `/search' method: 'GET`

## 1.5.2

### Added

- A child node's `RenderEvent` has its parent's `request`, when the installed lowevent's `RenderEvent` takes one

## 1.5.1

### Changed

- Rendering a template takes about a third less time, as the lexer compiles its patterns once, rather than for each part of a template

## 1.5.0

### Changed

- **Breaking:** `PropNode` is `SoloNode`, and its element and lexeme are `:solo`, as every node can have props, while a solo node is one without a slot, like `<{ Card title='Hi' }>`
- A lexeme's `match?` and `lexeme` get the directive as it's written, as `segment:`, so an app can read its own syntax
- **Breaking:** `metadata:` is `context:` in `Antlers.render` and every node's `render`, as it's whatever the app passes down to its nodes

## 1.4.0

### Changed

- Escape variables with `CGI.escapeHTML` and drop the erb dependency, which took about 0.3s to load
- **Breaking:** Limit allowed methods on basic types

## 1.3.1

### Added

- Pass params when their parent event has them

## 1.3.0

### Added

- Support translations (`{"Hello"}` and `{:app_name}`)

## 1.2.2

### Changed

- Identify values like `true`, `false`, `nil`, `:draft` with `Lowkey::ValueParser`

## 1.2.0

## Added

- Support keywords without a value
- Raise error for missing closing tag

### Changed

- Preserve whitespace

## 1.1.0

### Added

- Support metadata

### Changed

- Remove hard dependency on lowevent

## 1.0.0

### Added

- Release V1 API

## 0.9.0

### Added

- Support props on slots

## 0.8.2

### Changed

- Use plugs gem to manage supported elements

## 0.8.0

### Added

- Support if condition
- Support variables in deerheads syntax

## 0.7.0

### Added

- Make arguments omittable
- Namespace support

## 0.6.0

### Added

- Basic form support

## 0.5.0

### Added

- Pass props to initialize when method is present

### Changed

- Standardise falling back to a user defined string

## 0.4.0

### Added

- Support key/value iteration of hashes in for loop (`<{ for: key, value in: @items }>`)
- Support method chain syntax `{ variable.method }`

## 0.3.0

### Added

- Introduce for loop (`<{ for: user in: @users }>`)

### Changed

- Rename `Antlers.parse` to `Antlers.ast`

## 0.2.0

### Added

- Support props
- Support slots
- Support variables

## 0.1.0

### Added

- Add lexer
- Add parser

## 0.0.0

### Added

- Basic template
