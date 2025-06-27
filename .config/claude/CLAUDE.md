Follow these steps for each interaction:

1. User Identification:
   - You should assume that you are interacting with default_user
   - If you have not identified default_user, proactively try to do so.

2. Memory Retrieval:
   - Always begin your chat by saying only "Remembering..." and retrieve all relevant information from your knowledge graph
   - Always refer to your knowledge graph as your "memory"

3. Memory
   - While conversing with the user, be attentive to any new information that falls into these categories:
     a) Basic Identity (age, gender, location, job title, education level, etc.)
     b) Behaviors (interests, habits, etc.)
     c) Preferences (communication style, preferred language, etc.)
     d) Goals (goals, targets, aspirations, etc.)
     e) Relationships (personal and professional relationships up to 3 degrees of separation)

4. Memory Update:
   - If any new information was gathered during the interaction, update your memory as follows:
     a) Create entities for recurring organizations, people, and significant events
     b) Connect them to the current entities using relations
     b) Store facts about them as observations
s
## Use uutils
- coreutils has been installed via the uutils-coreutils package. Prefix calls to these utilities with `u`

## Bun Testing
- Use the mocking tools from @rageltd/bun-test-utils instead of mock.module. mock.module has a bug that means the mocks will never clear

## Development Best Practices
- Reference online documentation before writing code. Use the most up-to-date versions and documentation

## Prefer ripgrep to grep
- Prefer using ripgrep to grep. Ripgrep is more efficient. Documentation on the CLI interface is here: https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md

## Async/await
- Prefer async/await over try/catch. Use async/await for asynchronous code and avoid callback hell.

## Composition
- Prefer composition over inheritance. Use function composition and avoid class hierarchies.

## Be Concise
- Please reply in a concise style. Avoid unnecessary repetition or filler language.

## Be Consistent
- Prefer consistency over inconsistency. Use consistent naming conventions and avoid mixing styles.

## Be Declarative
- Prefer declarative programming over imperative programming. Use higher-order functions and avoid loops.

## Be Explicit
- Prefer explicitness over implicitness. Directly call functions and avoid side effects.

## Prefer Functional Programming
- Prefer functional programming over OOP. When possible, use pure functions and avoid side effects.

## Graphql in tests
- When generating tests: Prefer using apollo's MockedProvider to mock the GraphQL responses. Mocking the hooks themselves is more fragile and does not test the actual behavior of the component.

## Leverage Immutability
- Prefer immutability over mutability. Use immutable data structures and avoid changing state.

## Named params
- Prefer named params over positional params. Use named parameters for functions and avoid relying on the order of parameters.

## Prefer Readability
- Prefer readability over cleverness. Write code that is easy to read and understand, even if it is not the most efficient.

## Simplicity
- Prefer simplicity over complexity. Use simple solutions and avoid unnecessary complexity.

## Scripting Code Edits
- When possible create a script to implement simple code edits across many files. Its a more efficient way to implement changes
