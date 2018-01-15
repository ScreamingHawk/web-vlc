# web-vlc
A website for selecting shows to watch on VLC locally

# Usage

Install dependencies.

```
npm i
```

Edit `server/config.coffee` with your defaults.

Build everything and run in a single command, because you are lazy.

```
npm run complete
```

Navigate to the application at `http://localhost:3000`.
Note your path may be different if you changed the config.

# Development

Watch for CoffeeScript changes.

```
npm run coffee-watch
```

Watch for Webpack changes.

```
npm run webpack-watch
```

Run server watching for changes.

```
npm run start-watch
```

# Configuration

Files must be organised like so:

```
Show Name
	> Season x
		> video with episode x.ext
```

Season folder may be omitted.
