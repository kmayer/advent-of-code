# Advent of Code 2021

https://adventofcode.com/2021/

I'm experimenting with creating a working, helpful, low ceremony development environment. I've chosen to standardize on Docker and `docker-compose`

To get started ...

- Check out this repository and `cd` into 2021
- You'll need Docker running
- `cp dot.env .env`
- run `script/devcontainer-shell` to launch the container from any number of terminal windows.
- run `script/setup` to install gems etc., just once (or when you change `Gemfile`)
- If you want to make changes:
  - Runtime changes go in `.devcontainer/docker-compose.yml`
  - Image changes go in `.devcontainer/Dockerfile`
  - Other developer customizations go in `.devcontainer`

You will be able to run tests by invoking the Ruby files. The container mounts your work in `/workspace`.
