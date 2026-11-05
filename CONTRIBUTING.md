# Contributing to Molt

Thanks for helping. Molt is small, so the process is light.

## Report a bug or ask for something

Open an [issue](https://github.com/ShiJianXi/molt/issues). Say what you asked Claude to do, what
happened, and what you expected. Mention whether you were in a claude.ai/code cloud session, the
Claude desktop app or the terminal.

## Change a skill

1. Fork the repo and make a branch.
2. Edit the skill under `skills/`. Keep `SKILL.md` frontmatter free of `<` and `>`, because
   claude.ai strips them from descriptions.
3. Run the checks in [Development](README.md#development). CI runs the same ones on your pull
   request, except the evals, which call the model.
4. If you fix a bug, add a check that fails before the fix and passes after it.
5. Update the README to match, and bump `version` in `.claude-plugin/plugin.json` for anything users
   will notice.
6. Open a pull request against `main` and describe what changed and why.

The website lives on the `gh-pages` branch. If your change shows up on the site, a second pull
request against `gh-pages` is welcome, or say so and the maintainer will update it.

## License

By contributing you agree that your work is released under the [MIT license](LICENSE).
