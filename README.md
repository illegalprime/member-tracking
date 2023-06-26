# ~ Member Tracking ~

## Local Development

### 1. Install Nix

The nix package manager works on linux & mac, and ensures our app and its
dependencies are exactly the same across machines (at the byte-level) by using
a system of determinstic builds and input hashing. Using it is the fastest way
to get all the needed packages on your machine. Install it with:

https://nixos.org/download.html

You might need to restart your shell or edit your PATH after the install
(just follow the prompts).

### 2. Enter the Shell

Running `nix-shell` in this directory will fetch all the project's dependencies
and (while you're in the shell) add them to your PATH. This is _not_ a
container, it's just a fancy shell environment. On first run it will take a
minute to download everything, so I find it eaiser to make it verbose:

```
nix-shell --verbose
```

If you have direnv, you can activate this shell every time you enter it in
the terminal. To enable this, install [direnv](https://direnv.net/)
and run `direnv allow` in this directory.

### 3. Launch PostgreSQL

In the nix-shell, the `scripts/database` script is already in your `PATH`, so run:

```bash
database start
```

### 4. Setup Phoenix

This will install Elixir's dependencies and run migrations:
packages using:

```
mix setup
```

### 5. Serve

Elixir will launch your app and put you in a REPL inside the app's context:

```
iex -S mix phx.server
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
